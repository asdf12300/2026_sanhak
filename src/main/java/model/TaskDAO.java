package model;
import java.sql.*;
import java.util.*;

public class TaskDAO {

    public List<TaskDTO> getAllTasks(Connection conn, int projectId) throws Exception {
        List<TaskDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM task WHERE project_id = ? ORDER BY deadline, id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TaskDTO t = new TaskDTO();
                    t.setId(rs.getInt("id"));
                    t.setProjectId(rs.getInt("project_id"));
                    t.setTitle(rs.getString("title"));
                    t.setContent(rs.getString("content"));
                    t.setAssignee(rs.getString("assignee"));
                    t.setStatus(rs.getString("status"));
                    t.setDeadline(rs.getString("deadline"));
                    t.setCreatedAt(rs.getString("created_at"));
                    list.add(t);
                }
            }
        }
        return list;
    }

    public boolean memberExists(Connection conn, String memberId) throws Exception {
        String sql = "SELECT id FROM member WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // =====================
    // 등록 - deadline 있으면 calendar 자동 등록
    // =====================
    public void insertTask(Connection conn, TaskDTO t) throws Exception {
        String sql = "INSERT INTO task (project_id, title, content, assignee, status, deadline) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, t.getProjectId());
            ps.setString(2, t.getTitle());
            ps.setString(3, t.getContent());

            String assignee = (t.getAssignee() == null || t.getAssignee().trim().isEmpty())
                            ? null : t.getAssignee().trim();
            if (assignee == null) ps.setNull(4, Types.VARCHAR);
            else ps.setString(4, assignee);

            ps.setString(5, t.getStatus() != null ? t.getStatus() : "To Do");

            String deadline = (t.getDeadline() == null || t.getDeadline().trim().isEmpty())
                            ? null : t.getDeadline().trim();
            if (deadline == null) ps.setNull(6, Types.DATE);
            else ps.setString(6, deadline);

            ps.executeUpdate();

            // 생성된 task id 가져오기
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int generatedId = keys.getInt(1);
                    t.setId(generatedId);

                    // deadline 있으면 캘린더 자동 등록 (category=3 업무)
                    if (deadline != null) {
                        String calSql = "INSERT INTO calendar (project_id, task_id, event_date, title, category) " +
                                        "VALUES (?, ?, ?, ?, 3)";
                        try (PreparedStatement cps = conn.prepareStatement(calSql)) {
                            cps.setInt(1, t.getProjectId());
                            cps.setInt(2, generatedId);
                            cps.setString(3, deadline);
                            cps.setString(4, t.getTitle());
                            cps.executeUpdate();
                        }
                    }
                }
            }
        }
    }

    // =====================
    // 수정 - deadline 바뀌면 calendar도 업데이트
    // =====================
    public void updateTask(Connection conn, TaskDTO t) throws Exception {
        String sql = "UPDATE task SET title=?, content=?, assignee=?, status=?, deadline=? WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getContent());

            String assignee = (t.getAssignee() == null || t.getAssignee().trim().isEmpty())
                            ? null : t.getAssignee().trim();
            if (assignee == null) ps.setNull(3, Types.VARCHAR);
            else ps.setString(3, assignee);

            ps.setString(4, t.getStatus());

            String deadline = (t.getDeadline() == null || t.getDeadline().trim().isEmpty())
                            ? null : t.getDeadline().trim();
            if (deadline == null) ps.setNull(5, Types.DATE);
            else ps.setString(5, deadline);

            ps.setInt(6, t.getId());
            ps.executeUpdate();
        }

        // ← 연결된 캘린더 이벤트 날짜/제목 동기화
        syncCalendarFromTask(conn, t);
    }

    // =====================
    // 삭제 - calendar FK가 ON DELETE SET NULL이므로 그대로
    // =====================
    public void deleteTask(Connection conn, int id) throws Exception {
        String sql = "DELETE FROM task WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // =====================
    // 내부 헬퍼: task → calendar 신규 등록
    // =====================
    private void insertCalendarFromTask(Connection conn, TaskDTO t) throws Exception {
        String sql = "INSERT INTO calendar (project_id, task_id, event_date, title, category) "
                   + "VALUES (?, ?, ?, ?, 3)"; // category=3 (업무)
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getProjectId());
            ps.setInt(2, t.getId());
            ps.setString(3, t.getDeadline());
            ps.setString(4, t.getTitle());
            ps.executeUpdate();
        }
    }

    // =====================
    // 내부 헬퍼: task 수정 시 연결된 calendar 동기화
    // =====================
    private void syncCalendarFromTask(Connection conn, TaskDTO t) throws Exception {
        String deadline = (t.getDeadline() == null || t.getDeadline().trim().isEmpty())
                        ? null : t.getDeadline().trim();

        if (deadline != null) {
            // 연결된 캘린더 있으면 날짜+제목 업데이트, 없으면 새로 등록
            String checkSql = "SELECT event_id FROM calendar WHERE task_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, t.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        // 기존 캘린더 이벤트 업데이트
                        String updateSql = "UPDATE calendar SET event_date=?, title=? WHERE task_id=?";
                        try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                            ups.setString(1, deadline);
                            ups.setString(2, t.getTitle());
                            ups.setInt(3, t.getId());
                            ups.executeUpdate();
                        }
                    } else {
                        // 캘린더 이벤트 없으면 새로 등록
                        insertCalendarFromTask(conn, t);
                    }
                }
            }
        }
    }
}