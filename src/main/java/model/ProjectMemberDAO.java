package model;

import java.sql.*;
import java.util.*;

public class ProjectMemberDAO {

    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    // 팀원 추가(초대)
    public boolean addMember(int projectId, String memberId) {
        String sql = "INSERT INTO project_member (project_id, member_id, status) VALUES (?, ?, 'invited')";
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

    // 프로젝트 기준 팀원/초대 목록 조회
    public List<ProjectMemberDTO> getMembersByProject(int projectId) {
        List<ProjectMemberDTO> list = new ArrayList<>();

        String sql = "SELECT pm_no, project_id, member_id, role, status, invited_at " +
                     "FROM project_member WHERE project_id = ? " +
                     "ORDER BY invited_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProjectMemberDTO dto = new ProjectMemberDTO();
                    dto.setPmNo(rs.getInt("pm_no"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setMemberId(rs.getString("member_id"));
                    dto.setRole(rs.getString("role"));
                    dto.setStatus(rs.getString("status"));
                    dto.setInvitedAt(rs.getTimestamp("invited_at"));
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
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

    // 이미 팀원인지 확인
    public boolean isMember(int projectId, String memberId) {
        String sql = "SELECT pm_no FROM project_member WHERE project_id = ? AND member_id = ?";
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

    // 내가 받은 초대 목록 조회
    public List<ProjectMemberDTO> getInvitationList(String memberId) {
        List<ProjectMemberDTO> list = new ArrayList<>();

        String sql = "SELECT pm_no, project_id, member_id, role, status, invited_at " +
                     "FROM project_member " +
                     "WHERE member_id = ? " +
                     "ORDER BY invited_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProjectMemberDTO dto = new ProjectMemberDTO();
                    dto.setPmNo(rs.getInt("pm_no"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setMemberId(rs.getString("member_id"));
                    dto.setRole(rs.getString("role"));
                    dto.setStatus(rs.getString("status"));
                    dto.setInvitedAt(rs.getTimestamp("invited_at"));
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 초대 수락
    public boolean acceptInvitation(int pmNo, String memberId) {
        String sql = "UPDATE project_member SET status = 'accepted' " +
                     "WHERE pm_no = ? AND member_id = ? AND status = 'invited'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pmNo);
            ps.setString(2, memberId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 초대 거절
    public boolean rejectInvitation(int pmNo, String memberId) {
        String sql = "UPDATE project_member SET status = 'rejected' " +
                     "WHERE pm_no = ? AND member_id = ? AND status = 'invited'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pmNo);
            ps.setString(2, memberId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 초대 기록 삭제
    public boolean deleteInvitation(int pmNo, String memberId) {
        String sql = "DELETE FROM project_member WHERE pm_no = ? AND member_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pmNo);
            ps.setString(2, memberId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}