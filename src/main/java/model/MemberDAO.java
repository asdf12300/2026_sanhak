package model;

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
}