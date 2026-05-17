package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ProjectMemberDAO {

    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    public List<ProjectMemberDTO> getMembersByProject(int projectId) {
        List<ProjectMemberDTO> list = new ArrayList<>();
        String sql =
            "SELECT pm.id, pm.project_id, pm.member_id, pm.role, pm.status, pm.invited_at, " +
            "       m.name, m.role AS member_role " +
            "FROM project_member pm " +
            "LEFT JOIN member m ON pm.member_id = m.id " +
            "WHERE pm.project_id = ? " +
            "ORDER BY pm.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProjectMemberDTO dto = mapProjectMember(rs);
                    dto.setRole(rs.getString("member_role"));
                    list.add(dto);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<ProjectMemberDTO> getReceivedInvitations(String memberId) {
        List<ProjectMemberDTO> list = new ArrayList<>();
        String sql =
            "SELECT pm.id, pm.project_id, pm.member_id, pm.role, pm.status, pm.invited_at, m.name " +
            "FROM project_member pm " +
            "LEFT JOIN member m ON pm.member_id = m.id " +
            "WHERE pm.member_id = ? AND pm.status = 'invited' " +
            "ORDER BY pm.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProjectMember(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean inviteMember(int projectId, String memberId, String role) {
        String sql =
            "INSERT INTO project_member (project_id, member_id, role, status) " +
            "VALUES (?, ?, ?, 'invited')";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            ps.setString(3, role);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateInvitationStatus(int pmNo, String memberId, String status) {
        String sql =
            "UPDATE project_member SET status = ? " +
            "WHERE id = ? AND member_id = ? AND status = 'invited'";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, pmNo);
            ps.setString(3, memberId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addMember(int projectId, String memberId) {
        String sql =
            "INSERT INTO project_member (project_id, member_id, role, status) " +
            "VALUES (?, ?, '팀원', 'accepted')";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeMember(int projectId, String memberId) {
        String sql = "DELETE FROM project_member WHERE project_id = ? AND member_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean memberExists(String memberId) {
        String sql = "SELECT id FROM member WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getMemberRole(String memberId) {
        String sql = "SELECT role FROM member WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "student";
    }

    public List<ProjectMemberDTO> getProfessorsByProject(int projectId) {
        return getMembersByProjectAndRole(projectId, "professor");
    }

    public List<ProjectMemberDTO> getStudentsByProject(int projectId) {
        List<ProjectMemberDTO> list = new ArrayList<>();
        String sql =
            "SELECT pm.id, pm.project_id, pm.member_id, pm.role, pm.status, pm.invited_at, m.name " +
            "FROM project_member pm " +
            "LEFT JOIN member m ON pm.member_id = m.id " +
            "WHERE pm.project_id = ? AND (m.role = 'student' OR m.role IS NULL) " +
            "ORDER BY pm.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProjectMember(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private List<ProjectMemberDTO> getMembersByProjectAndRole(int projectId, String role) {
        List<ProjectMemberDTO> list = new ArrayList<>();
        String sql =
            "SELECT pm.id, pm.project_id, pm.member_id, pm.role, pm.status, pm.invited_at, m.name " +
            "FROM project_member pm " +
            "LEFT JOIN member m ON pm.member_id = m.id " +
            "WHERE pm.project_id = ? AND m.role = ? " +
            "ORDER BY pm.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProjectMember(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int getProjectIdByPmNo(int pmNo) {
        String sql = "SELECT project_id FROM project_member WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, pmNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("project_id");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getInvitedProjectId(int pmNo, String memberId) {
        String sql =
            "SELECT project_id FROM project_member " +
            "WHERE id = ? AND member_id = ? AND status = 'invited'";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, pmNo);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("project_id");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public boolean isMember(int projectId, String memberId) {
        String sql =
            "SELECT id FROM project_member " +
            "WHERE project_id = ? AND member_id = ? AND status IN ('invited','accepted')";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isActiveMember(int projectId, String memberId) {
        String sql =
            "SELECT id FROM project_member " +
            "WHERE project_id = ? AND member_id = ? AND status = 'accepted'";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean setLeader(int projectId, String memberId) {
        String sql = "UPDATE board SET team_leader = ? WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            ps.setInt(2, projectId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isUserLeader(String userId) {
        String sql = "SELECT 1 FROM board WHERE team_leader = ? LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean hasBlockingLeaderProject(String memberId) {
        String sql =
            "SELECT 1 " +
            "FROM board b " +
            "WHERE b.team_leader = ? " +
            "  AND EXISTS ( " +
            "      SELECT 1 FROM project_member pm " +
            "      WHERE pm.project_id = b.id " +
            "        AND pm.status = 'accepted' " +
            "        AND pm.member_id <> ? " +
            "  ) " +
            "LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    public boolean isProjectLeader(int projectId, String memberId) {
        String sql = "SELECT 1 FROM board WHERE id = ? AND team_leader = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isSoloProject(int projectId, String memberId) {
        String sql =
            "SELECT 1 " +
            "FROM board b " +
            "WHERE b.id = ? " +
            "  AND b.team_leader = ? " +
            "  AND NOT EXISTS ( " +
            "      SELECT 1 FROM project_member pm " +
            "      WHERE pm.project_id = b.id " +
            "        AND pm.status = 'accepted' " +
            "        AND pm.member_id <> ? " +
            "  )";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            ps.setString(3, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteProject(int projectId) {
        String sql = "DELETE FROM board WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean leaveProject(int projectId, String memberId) {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try {
                cleanupMemberProjectData(conn, memberId, projectId);
                executeUpdate(conn,
                    "DELETE FROM project_member WHERE project_id = ? AND member_id = ?",
                    projectId, memberId);

                conn.commit();
                return true;

            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteSoloLeaderProjects(String memberId) {
        String selectSql =
            "SELECT b.id " +
            "FROM board b " +
            "WHERE b.team_leader = ? " +
            "  AND NOT EXISTS ( " +
            "      SELECT 1 FROM project_member pm " +
            "      WHERE pm.project_id = b.id " +
            "        AND pm.status = 'accepted' " +
            "        AND pm.member_id <> ? " +
            "  )";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try {
                List<Integer> projectIds = new ArrayList<>();

                try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                    ps.setString(1, memberId);
                    ps.setString(2, memberId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            projectIds.add(rs.getInt("id"));
                        }
                    }
                }

                for (Integer projectId : projectIds) {
                    executeUpdate(conn, "DELETE FROM board WHERE id = ?", projectId);
                }

                conn.commit();
                return true;

            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public void cleanupMemberAllProjectData(Connection conn, String memberId) throws Exception {
        List<Integer> projectIds = new ArrayList<>();
        String sql = "SELECT project_id FROM project_member WHERE member_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    projectIds.add(rs.getInt("project_id"));
                }
            }
        }

        for (Integer projectId : projectIds) {
            cleanupMemberProjectData(conn, memberId, projectId);
        }
    }

    private void cleanupMemberProjectData(Connection conn, String memberId, int projectId) throws Exception {
        executeUpdate(conn,
            "DELETE FROM meeting_minutes_history " +
            "WHERE minutes_id IN (SELECT id FROM meeting_minutes WHERE project_id = ? AND created_by = ?)",
            projectId, memberId);

        executeUpdate(conn,
            "DELETE FROM meeting_minutes_history " +
            "WHERE modified_by = ? " +
            "  AND minutes_id IN (SELECT id FROM meeting_minutes WHERE project_id = ?)",
            memberId, projectId);

        executeUpdate(conn,
            "DELETE FROM meeting_minutes WHERE project_id = ? AND created_by = ?",
            projectId, memberId);

        executeUpdate(conn,
            "DELETE FROM calendar " +
            "WHERE project_id = ? " +
            "  AND (assignee = ? OR task_id IN (SELECT id FROM task WHERE project_id = ? AND assignee = ?))",
            projectId, memberId, projectId, memberId);

        executeUpdate(conn,
            "DELETE FROM task WHERE project_id = ? AND assignee = ?",
            projectId, memberId);

        executeUpdate(conn,
            "DELETE FROM chat_room_members " +
            "WHERE member_id = ? " +
            "  AND room_id IN (SELECT room_id FROM chat_rooms WHERE project_id = ?)",
            memberId, projectId);

        executeUpdate(conn,
            "DELETE FROM chat_messages " +
            "WHERE sender_id = ? " +
            "  AND room_id IN (SELECT room_id FROM chat_rooms WHERE project_id = ?)",
            memberId, projectId);

        executeUpdate(conn,
            "DELETE fc FROM feedback_comment fc " +
            "JOIN feedback f ON fc.feedback_id = f.id " +
            "WHERE f.project_id = ? AND fc.author_id = ?",
            projectId, memberId);

        executeUpdate(conn,
            "DELETE FROM feedback WHERE project_id = ? AND author_id = ?",
            projectId, memberId);

        executeUpdate(conn,
            "DELETE FROM file_share WHERE project_id = ? AND uploader_id = ?",
            projectId, memberId);
    }

    public boolean canAccessProject(int projectId, String memberId) {
        if (memberId == null || memberId.trim().isEmpty()) {
            return false;
        }

        String sql =
            "SELECT 1 " +
            "FROM board b " +
            "LEFT JOIN project_member pm " +
            "  ON b.id = pm.project_id " +
            " AND pm.member_id = ? " +
            " AND pm.status = 'accepted' " +
            "WHERE b.id = ? " +
            "  AND (b.team_leader = ? OR pm.id IS NOT NULL)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            ps.setInt(2, projectId);
            ps.setString(3, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private ProjectMemberDTO mapProjectMember(ResultSet rs) throws Exception {
        ProjectMemberDTO dto = new ProjectMemberDTO();
        dto.setPmNo(rs.getInt("id"));
        dto.setProjectId(rs.getInt("project_id"));
        dto.setMemberId(rs.getString("member_id"));
        dto.setName(rs.getString("name"));
        dto.setRole(rs.getString("role"));
        dto.setStatus(rs.getString("status"));
        Timestamp invitedAt = rs.getTimestamp("invited_at");
        dto.setInvitedAt(invitedAt != null ? invitedAt.toString() : "");
        return dto;
    }

    private void executeUpdate(Connection conn, String sql, Object... params) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                Object param = params[i];
                if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else {
                    ps.setString(i + 1, String.valueOf(param));
                }
            }
            ps.executeUpdate();
        }
    }
}
