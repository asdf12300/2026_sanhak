package model;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.*;
import java.util.*;

public class MemberDAO {
    private Connection conn;

    public MemberDAO(Connection conn) {
        this.conn = conn;
    }

    // 이름으로 회원 검색
    public List<MemberDTO> searchMembers(String keyword) throws SQLException {
        List<MemberDTO> list = new ArrayList<>();
        String sql = "SELECT id, name FROM member WHERE name LIKE ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while(rs.next()) {
                    list.add(new MemberDTO(rs.getString("id"), rs.getString("name")));
                }
            }
        }
        return list;
    }
    public String getEmailById(String id) {
        String sql = "SELECT email FROM member WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("email");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}