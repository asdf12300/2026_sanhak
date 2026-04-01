package model;

import java.sql.*;
import java.util.*;

public class ListDAO {

    // 게시글 목록 출력 (LIMIT)
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
