package model;

import java.sql.*;
import java.util.*;

public class ProjectMemberDAO {

    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    // 팀원 추가
    public boolean addMember(int projectId, String memberId) {
        String sql = "INSERT INTO project_member (project_id, member_id, status) VALUES (?, ?, 'accepted')";
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

    // 프로젝트 팀원 목록 조회
    public List<ProjectMemberDTO> getMembersByProject(int projectId) {
        List<ProjectMemberDTO> list = new ArrayList<ProjectMemberDTO>();
        String sql = "SELECT m.id, m.name FROM member m "
                   + "JOIN project_member pm ON m.id = pm.member_id "
                   + "WHERE pm.project_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                	ProjectMemberDTO dto = new ProjectMemberDTO();
                	dto.setMemberId(rs.getString("id"));
                	dto.setName(rs.getString("name"));  // ProjectMemberDTO의 실제 setter명 확인 필요
                	list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
 // 내가 받은 초대 목록 조회
    public List<ProjectMemberDTO> getInvitationList(String memberId) {
        List<ProjectMemberDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM project_member WHERE member_id = ? AND status = 'invited'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProjectMemberDTO dto = new ProjectMemberDTO();
                    dto.setPmNo(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setMemberId(rs.getString("member_id"));
                    dto.setStatus(rs.getString("status"));
                    dto.setInvitedAt(rs.getString("invited_at"));
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
        String sql = "SELECT id FROM project_member WHERE project_id = ? AND member_id = ?";
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
