package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginDAO {

    // DBConnection 재사용 (설정 통합)
    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    // 로그인 인증 메서드 (role 검증 포함)
    public LoginDTO authenticate(String userid, String password, String role) {

        String sql = "SELECT id, name, role FROM member WHERE id = ? AND pw = ? AND role = ?";

        try (
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            ps.setString(1, userid);
            ps.setString(2, password);
            ps.setString(3, role);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LoginDTO member = new LoginDTO();
                    member.setId(rs.getString("id"));
                    member.setName(rs.getString("name"));
                    member.setRole(rs.getString("role"));
                    return member;
                }
            }

        } catch (Exception e) {
            e.printStackTrace(); // 콘솔에서 원인 확인 가능
        }

        return null; // 로그인 실패
    }

    // DB 연결 상태 확인용 메서드(LoginServlet에서 함수 호출해서 웹페이지에서 오류창 팝업)
    public boolean testConnection() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("LoginDAO: DB 연결 성공");
                return true;
            } else {
                System.out.println("LoginDAO: DB 연결 실패 (conn is null or closed)");
                return false;
            }
        } catch (Exception e) {
            System.out.println("LoginDAO: DB 연결 실패 (예외 발생)");
            e.printStackTrace();
            return false;
        }
    }
}
