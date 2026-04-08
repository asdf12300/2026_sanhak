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

    public void insertTask(Connection conn, TaskDTO t) throws Exception {
        String sql = "INSERT INTO task (project_id, title, content, assignee, status, deadline) VALUES (?, ?, ?, ?, ?, ?)";
        System.out.println("DAO.insertTask - projectId=" + t.getProjectId() + ", title=" + t.getTitle() + ", deadline=" + t.getDeadline());
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getProjectId());
            ps.setString(2, t.getTitle());
            ps.setString(3, t.getContent());
            String assignee = (t.getAssignee() == null || t.getAssignee().trim().isEmpty()) ? null : t.getAssignee().trim();
            if (assignee == null) ps.setNull(4, java.sql.Types.VARCHAR);
            else ps.setString(4, assignee);
            ps.setString(5, t.getStatus() != null ? t.getStatus() : "To Do");
            String deadline = (t.getDeadline() == null || t.getDeadline().trim().isEmpty()) ? null : t.getDeadline().trim();
            if (deadline == null) ps.setNull(6, java.sql.Types.DATE);
            else ps.setString(6, deadline);
            int rows = ps.executeUpdate();
            System.out.println("DAO.insertTask - 영향받은 행: " + rows);
        }
    }

    public void updateTask(Connection conn, TaskDTO t) throws Exception {
        String sql = "UPDATE task SET title=?, content=?, assignee=?, status=?, deadline=? WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getContent());
            String assignee = (t.getAssignee() == null || t.getAssignee().trim().isEmpty()) ? null : t.getAssignee().trim();
            if (assignee == null) ps.setNull(3, java.sql.Types.VARCHAR);
            else ps.setString(3, assignee);
            ps.setString(4, t.getStatus());
            String deadline = (t.getDeadline() == null || t.getDeadline().trim().isEmpty()) ? null : t.getDeadline().trim();
            if (deadline == null) ps.setNull(5, java.sql.Types.DATE);
            else ps.setString(5, deadline);
            ps.setInt(6, t.getId());
            ps.executeUpdate();
        }
    }

    public void deleteTask(Connection conn, int id) throws Exception {
        String sql = "DELETE FROM task WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
