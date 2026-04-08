package model;

import java.sql.*;
import java.util.*;

public class ListDAO {

    // 특정 사용자가 속한 프로젝트 목록 (팀장 + 팀원)
    public List<ProjectDTO> getMyProjects(String userId) {
        List<ProjectDTO> list = new ArrayList<>();

        String sql = "SELECT DISTINCT b.id, b.title, b.content, b.deadline, b.team_leader, b.created_at " +
                     "FROM board b " +
                     "LEFT JOIN project_member pm ON b.id = pm.project_id " +
                     "WHERE b.team_leader = ? OR (pm.member_id = ? AND pm.status = 'accepted') " +
                     "ORDER BY b.id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, userId);

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                ProjectDTO dto = new ProjectDTO();
                dto.setId(rs.getInt("id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setDeadline(rs.getString("deadline"));
                dto.setTeam_leader(rs.getString("team_leader"));
                dto.setCreated_at(rs.getTimestamp("created_at"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 게시글 목록 출력 (LIMIT) - 기존 메서드 유지
    public List<ProjectDTO> getList(int page, int pageSize) {
        List<ProjectDTO> list = new ArrayList<>();

        int start = (page - 1) * pageSize; // offset 계산

        String sql = "SELECT id, title, deadline FROM board ORDER BY id DESC LIMIT ?, ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, start);
            pstmt.setInt(2, pageSize);

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
            	ProjectDTO dto = new ProjectDTO();
                dto.setId(rs.getInt("id"));
                dto.setTitle(rs.getString("title"));
                dto.setDeadline(rs.getString("deadline"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 전체 게시글 수
    public int getTotalCount() {
        int count = 0;

        String sql = "SELECT COUNT(*) FROM board";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }
}
