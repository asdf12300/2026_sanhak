package model;

import java.sql.*;
import java.util.*;

public class ProjectMemberDAO {

    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    // 프로젝트 팀원 목록 조회
    public List<ProjectMemberDTO> getMembersByProject(int projectId) {
        List<ProjectMemberDTO> list = new ArrayList<>();

        String sql =
            "SELECT pm.id, pm.project_id, pm.member_id, pm.role, pm.status, pm.invited_at, m.name " +
            "FROM project_member pm " +
            "LEFT JOIN member m ON pm.member_id = m.id " +
            "WHERE pm.project_id = ? " +
            "ORDER BY pm.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProjectMemberDTO dto = new ProjectMemberDTO();
                    dto.setPmNo(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setMemberId(rs.getString("member_id"));
                    dto.setName(rs.getString("name"));
                    dto.setRole(rs.getString("role"));
                    dto.setStatus(rs.getString("status"));
                    Timestamp ts = rs.getTimestamp("invited_at");
                    dto.setInvitedAt(ts != null ? ts.toString() : "");
                    list.add(dto);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 내가 받은 초대 목록
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
                    ProjectMemberDTO dto = new ProjectMemberDTO();
                    dto.setPmNo(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setMemberId(rs.getString("member_id"));
                    dto.setName(rs.getString("name"));
                    dto.setRole(rs.getString("role"));
                    dto.setStatus(rs.getString("status"));
                    Timestamp ts = rs.getTimestamp("invited_at");
                    dto.setInvitedAt(ts != null ? ts.toString() : "");
                    list.add(dto);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 팀원 초대
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

    // 초대 상태 변경
    public boolean updateInvitationStatus(int pmNo, String memberId, String status) {
        String sql = "UPDATE project_member SET status = ? WHERE id = ? AND member_id = ?";

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

    // 팀원 바로 추가
    public boolean addMember(int projectId, String memberId) {
        String sql = "INSERT INTO project_member (project_id, member_id, role, status) VALUES (?, ?, '팀원', 'accepted')";

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

    // 팀원 삭제
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

    // member 테이블에 존재하는 아이디인지 확인
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

    // 이미 초대/참여 상태인지 확인
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

    // 프로젝트에 실제 참여 중인 멤버인지 확인 (accepted 상태만)
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

    // 팀장 지정
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
}