package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {

    // ── 피드백 목록 조회 (프로젝트별) ──
    public List<FeedbackDTO> getList(Connection conn, int projectId) throws Exception {
        List<FeedbackDTO> list = new ArrayList<>();
        String sql = "SELECT f.id, f.project_id, f.author_id, m.name AS author_name, " +
                     "f.title, f.content, " +
                     "DATE_FORMAT(f.created_at, '%Y-%m-%d %H:%i') AS created_at, " +
                     "DATE_FORMAT(f.updated_at, '%Y-%m-%d %H:%i') AS updated_at " +
                     "FROM feedback f " +
                     "LEFT JOIN member m ON f.author_id = m.id " +
                     "WHERE f.project_id = ? " +
                     "ORDER BY f.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FeedbackDTO dto = new FeedbackDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setAuthorId(rs.getString("author_id"));
                    dto.setAuthorName(rs.getString("author_name"));
                    dto.setTitle(rs.getString("title"));
                    dto.setContent(rs.getString("content"));
                    dto.setCreatedAt(rs.getString("created_at"));
                    dto.setUpdatedAt(rs.getString("updated_at"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    // ── 피드백 단건 조회 ──
    public FeedbackDTO getById(Connection conn, int id) throws Exception {
        String sql = "SELECT f.id, f.project_id, f.author_id, m.name AS author_name, " +
                     "f.title, f.content, " +
                     "DATE_FORMAT(f.created_at, '%Y-%m-%d %H:%i') AS created_at, " +
                     "DATE_FORMAT(f.updated_at, '%Y-%m-%d %H:%i') AS updated_at " +
                     "FROM feedback f " +
                     "LEFT JOIN member m ON f.author_id = m.id " +
                     "WHERE f.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FeedbackDTO dto = new FeedbackDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setAuthorId(rs.getString("author_id"));
                    dto.setAuthorName(rs.getString("author_name"));
                    dto.setTitle(rs.getString("title"));
                    dto.setContent(rs.getString("content"));
                    dto.setCreatedAt(rs.getString("created_at"));
                    dto.setUpdatedAt(rs.getString("updated_at"));
                    return dto;
                }
            }
        }
        return null;
    }

    // ── 피드백 등록 (교수만) ──
    public int insert(Connection conn, FeedbackDTO dto) throws Exception {
        String sql = "INSERT INTO feedback (project_id, author_id, title, content) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, dto.getProjectId());
            ps.setString(2, dto.getAuthorId());
            ps.setString(3, dto.getTitle());
            ps.setString(4, dto.getContent());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    // ── 피드백 수정 (작성자 본인만) ──
    public boolean update(Connection conn, FeedbackDTO dto) throws Exception {
        String sql = "UPDATE feedback SET title=?, content=? WHERE id=? AND author_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dto.getTitle());
            ps.setString(2, dto.getContent());
            ps.setInt(3, dto.getId());
            ps.setString(4, dto.getAuthorId());
            return ps.executeUpdate() > 0;
        }
    }

    // ── 피드백 삭제 (작성자 본인만) ──
    public boolean delete(Connection conn, int id, String authorId) throws Exception {
        String sql = "DELETE FROM feedback WHERE id=? AND author_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, authorId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── 댓글 목록 조회 ──
    public List<FeedbackCommentDTO> getComments(Connection conn, int feedbackId) throws Exception {
        List<FeedbackCommentDTO> list = new ArrayList<>();
        String sql = "SELECT fc.id, fc.feedback_id, fc.author_id, m.name AS author_name, " +
                     "fc.content, DATE_FORMAT(fc.created_at, '%Y-%m-%d %H:%i') AS created_at " +
                     "FROM feedback_comment fc " +
                     "LEFT JOIN member m ON fc.author_id = m.id " +
                     "WHERE fc.feedback_id = ? " +
                     "ORDER BY fc.created_at ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FeedbackCommentDTO dto = new FeedbackCommentDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setFeedbackId(rs.getInt("feedback_id"));
                    dto.setAuthorId(rs.getString("author_id"));
                    dto.setAuthorName(rs.getString("author_name"));
                    dto.setContent(rs.getString("content"));
                    dto.setCreatedAt(rs.getString("created_at"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    // ── 댓글 등록 ──
    public void insertComment(Connection conn, FeedbackCommentDTO dto) throws Exception {
        String sql = "INSERT INTO feedback_comment (feedback_id, author_id, content) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dto.getFeedbackId());
            ps.setString(2, dto.getAuthorId());
            ps.setString(3, dto.getContent());
            ps.executeUpdate();
        }
    }

    // ── 댓글 삭제 (작성자 본인만) ──
    public boolean deleteComment(Connection conn, int commentId, String authorId) throws Exception {
        String sql = "DELETE FROM feedback_comment WHERE id=? AND author_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setString(2, authorId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── 멤버 role 조회 ──
    public String getMemberRole(Connection conn, String memberId) throws Exception {
        String sql = "SELECT role FROM member WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("role");
            }
        }
        return "student";
    }

    // ── 프로젝트 멤버 여부 확인 (accepted) ──
    public boolean isProjectMember(Connection conn, int projectId, String memberId) throws Exception {
        String sql = "SELECT id FROM project_member WHERE project_id=? AND member_id=? AND status='accepted'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
