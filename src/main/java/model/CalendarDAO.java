package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CalendarDAO {

    // 프로젝트 팀원 목록 (accepted 상태, 학생만)
    public List<model.ProjectMemberDTO> getProjectMembers(Connection conn, int projectId) throws Exception {
        List<model.ProjectMemberDTO> list = new ArrayList<>();
        String sql = "SELECT pm.member_id, m.name " +
                     "FROM project_member pm " +
                     "LEFT JOIN member m ON pm.member_id = m.id " +
                     "WHERE pm.project_id = ? AND pm.status = 'accepted' " +
                     "AND (m.role = 'student' OR m.role IS NULL) " +
                     "ORDER BY m.name";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.ProjectMemberDTO dto = new model.ProjectMemberDTO();
                    dto.setMemberId(rs.getString("member_id"));
                    dto.setName(rs.getString("name"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    // 프로젝트별 조회 (task JOIN)
    public List<CalendarDTO> getEventsByProject(Connection conn, int projectId) throws Exception {
        List<CalendarDTO> list = new ArrayList<>();
        String sql = "SELECT c.event_id, c.project_id, c.task_id, " +
                     "DATE_FORMAT(c.event_date, '%Y-%m-%d') AS event_date, " +
                     "c.event_time, c.title, c.category, c.memo, c.assignee, " +
                     "t.status AS task_status, t.assignee AS task_assignee " +
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
                    e.setAssignee(rs.getString("assignee"));
                    list.add(e);
                }
            }
        }
        return list;
    }

    // 등록 - category 3(업무)이면 task 자동 생성
    public void insertEvent(Connection conn, CalendarDTO e) throws Exception {
        Integer finalTaskId = null;
        String assignee = (e.getAssignee() == null || e.getAssignee().trim().isEmpty()) ? null : e.getAssignee().trim();

        if (e.getCategory() == 3) {
            String taskSql = "INSERT INTO task (project_id, title, content, status, deadline, assignee) " +
                             "VALUES (?, ?, ?, 'To Do', ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(taskSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, e.getProjectId());
                ps.setString(2, e.getTitle());
                ps.setString(3, e.getMemo());
                ps.setString(4, e.getDate());
                if (assignee == null) ps.setNull(5, Types.VARCHAR);
                else ps.setString(5, assignee);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new SQLException("task 생성 실패");
                    finalTaskId = keys.getInt(1);
                }
            }
        }

        String calSql = "INSERT INTO calendar (project_id, task_id, event_date, event_time, title, category, memo, assignee) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(calSql)) {
            ps.setInt(1, e.getProjectId());
            if (finalTaskId == null) ps.setNull(2, Types.INTEGER);
            else ps.setInt(2, finalTaskId);
            ps.setString(3, e.getDate());
            ps.setString(4, e.getTime());
            ps.setString(5, e.getTitle());
            ps.setInt(6, e.getCategory());
            ps.setString(7, e.getMemo());
            if (assignee == null) ps.setNull(8, Types.VARCHAR);
            else ps.setString(8, assignee);
            ps.executeUpdate();
        }
    }

    // 수정 - calendar + 연결된 task 동기화
    public void updateEvent(Connection conn, CalendarDTO e) throws Exception {
        String assignee = (e.getAssignee() == null || e.getAssignee().trim().isEmpty()) ? null : e.getAssignee().trim();

        String calSql = "UPDATE calendar SET event_date=?, event_time=?, title=?, category=?, memo=?, assignee=? " +
                "WHERE event_id=?";
        try (PreparedStatement ps = conn.prepareStatement(calSql)) {
            ps.setString(1, e.getDate());
            ps.setString(2, e.getTime());
            ps.setString(3, e.getTitle());
            ps.setInt(4, e.getCategory());
            ps.setString(5, e.getMemo());
            if (assignee == null) ps.setNull(6, Types.VARCHAR);
            else ps.setString(6, assignee);
            ps.setInt(7, e.getId());
            ps.executeUpdate();
        }

        if (e.getTaskId() != null) {
            String taskSql = "UPDATE task SET title=?, deadline=?, assignee=?, content=? WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(taskSql)) {
                ps.setString(1, e.getTitle());
                ps.setString(2, e.getDate());
                if (assignee == null) ps.setNull(3, Types.VARCHAR);
                else ps.setString(3, assignee);
                ps.setString(4, e.getMemo());
                ps.setInt(5, e.getTaskId());
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

    // ↓ TaskServlet 연동용 추가 메서드 2개 ↓

    // 태스크 삭제 시 연동된 캘린더 이벤트 삭제
    public void deleteEventByTaskId(Connection conn, int taskId) throws Exception {
        String sql = "DELETE FROM calendar WHERE task_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.executeUpdate();
        }
    }

    // 태스크 수정 시 연동된 캘린더 이벤트 메모/담당자 동기화
    public void syncByTaskId(Connection conn, int taskId, String title, String memo, String assignee, String deadline) throws Exception {
        String sql = "UPDATE calendar SET title=?, memo=?, assignee=?, event_date=? WHERE task_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, memo);
            ps.setString(3, assignee);
            ps.setString(4, deadline);
            ps.setInt(5, taskId);
            ps.executeUpdate();
        }
    }
}