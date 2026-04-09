package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CalendarDAO {

    // 프로젝트별 조회 (task JOIN)
    public List<CalendarDTO> getEventsByProject(Connection conn, int projectId) throws Exception {
        List<CalendarDTO> list = new ArrayList<>();
        String sql = "SELECT c.*, t.status AS task_status, t.assignee AS task_assignee " +
                     "FROM calendar c " +
                     "LEFT JOIN task t ON c.task_id = t.id " +
                     "WHERE c.project_id = ? " +
                     "ORDER BY c.event_date, c.event_time";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CalendarDTO e = new CalendarDTO();
                    e.setId(rs.getInt("event_id"));
                    e.setProjectId(rs.getInt("project_id"));
                    e.setTaskId((Integer) rs.getObject("task_id"));
                    e.setDate(rs.getString("event_date"));
                    e.setTime(rs.getString("event_time"));
                    e.setTitle(rs.getString("title"));
                    e.setCategory(rs.getInt("category"));
                    e.setMemo(rs.getString("memo"));
                    e.setTaskStatus(rs.getString("task_status"));
                    e.setTaskAssignee(rs.getString("task_assignee"));
                    list.add(e);
                }
            }
        }
        return list;
    }

    // 등록 - category 3(업무)이면 task 자동 생성
    public void insertEvent(Connection conn, CalendarDTO e) throws Exception {
        Integer finalTaskId = null;

        if (e.getCategory() == 3) {
            String taskSql = "INSERT INTO task (project_id, title, status, deadline) " +
                             "VALUES (?, ?, 'To Do', ?)";
            try (PreparedStatement ps = conn.prepareStatement(taskSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, e.getProjectId());
                ps.setString(2, e.getTitle());
                ps.setString(3, e.getDate());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new SQLException("task 생성 실패");
                    finalTaskId = keys.getInt(1);
                }
            }
        }

        String calSql = "INSERT INTO calendar (project_id, task_id, event_date, event_time, title, category, memo) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(calSql)) {
            ps.setInt(1, e.getProjectId());
            if (finalTaskId == null) ps.setNull(2, Types.INTEGER);
            else ps.setInt(2, finalTaskId);
            ps.setString(3, e.getDate());
            ps.setString(4, e.getTime());
            ps.setString(5, e.getTitle());
            ps.setInt(6, e.getCategory());
            ps.setString(7, e.getMemo());
            ps.executeUpdate();
        }
    }

    // 수정 - calendar + 연결된 task 동기화
    public void updateEvent(Connection conn, CalendarDTO e) throws Exception {
        String calSql = "UPDATE calendar SET event_date=?, event_time=?, title=?, category=?, memo=? " +
                        "WHERE event_id=?";
        try (PreparedStatement ps = conn.prepareStatement(calSql)) {
            ps.setString(1, e.getDate());
            ps.setString(2, e.getTime());
            ps.setString(3, e.getTitle());
            ps.setInt(4, e.getCategory());
            ps.setString(5, e.getMemo());
            ps.setInt(6, e.getId());
            ps.executeUpdate();
        }

        if (e.getTaskId() != null) {
            String taskSql = "UPDATE task SET title=?, deadline=? WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(taskSql)) {
                ps.setString(1, e.getTitle());
                ps.setString(2, e.getDate());
                ps.setInt(3, e.getTaskId());
                ps.executeUpdate();
            }
        }
    }

    // 삭제 - 연결된 task도 함께 삭제
    public void deleteEvent(Connection conn, int eventId) throws Exception {
        Integer taskId = null;
        String selectSql = "SELECT task_id FROM calendar WHERE event_id=?";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) taskId = (Integer) rs.getObject("task_id");
            }
        }

        String calSql = "DELETE FROM calendar WHERE event_id=?";
        try (PreparedStatement ps = conn.prepareStatement(calSql)) {
            ps.setInt(1, eventId);
            ps.executeUpdate();
        }

        if (taskId != null) {
            String taskSql = "DELETE FROM task WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(taskSql)) {
                ps.setInt(1, taskId);
                ps.executeUpdate();
            }
        }
    }
}