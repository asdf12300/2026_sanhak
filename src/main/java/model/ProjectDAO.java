package model;

import java.sql.*;

public class ProjectDAO {

    // 글쓰기
	public boolean insert(ProjectDTO dto) {
		String sql = "INSERT INTO board (title, team_leader, content, deadline) "
 	           + "VALUES (?, ?, ?, ?)";

	    try (Connection conn = DBConnection.getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql)) {

	    	pstmt.setString(1, dto.getTitle());
	    	pstmt.setString(2, dto.getTeam_leader());
	    	pstmt.setString(3, dto.getContent());
	    	pstmt.setString(4, dto.getDeadline());

	        int count = pstmt.executeUpdate();
	        if (count == 0) {
	            throw new SQLException("DB insert failed, no rows affected.");
	        }

	        return true;

	    } catch (Exception e) {
	        e.printStackTrace();
	        throw new RuntimeException("글쓰기 실패: " + e.getMessage(), e);
	    }
	}

    // 단일 글 조회
    public ProjectDTO getById(int id) {
        String sql = "SELECT * FROM board WHERE id = ?";
        ProjectDTO dto = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                dto = new ProjectDTO();
                dto.setId(rs.getInt("id"));
                dto.setTitle(rs.getString("title"));
                dto.setTeam_leader(rs.getString("team_leader"));
                dto.setContent(rs.getString("content"));
                dto.setDeadline(rs.getString("deadline"));
                dto.setCreated_at(rs.getTimestamp("created_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("글 조회 실패: " + e.getMessage(), e);
        }

        return dto;
    }
}
