package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.DBConnection;


@WebServlet("/JoinServlet")
public class JoinServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8"); // 한글 처리

        String name = request.getParameter("name");
        String id = request.getParameter("id");
        String pw = request.getParameter("pw");
        String pw_check = request.getParameter("pw_check");
        String email = request.getParameter("email");
        String tel = request.getParameter("tel");

        // 1. 필수 입력값 체크
        if (name == null || id == null || pw == null || pw_check == null || email == null || tel == null ||
            name.isEmpty() || id.isEmpty() || pw.isEmpty() || pw_check.isEmpty() || email.isEmpty() || tel.isEmpty()) {
            response.sendRedirect("join.jsp?error=empty");
            return;
        }

        // 2. 서버에서 비밀번호 확인
        if (!pw.equals(pw_check)) {
            response.sendRedirect("join.jsp?error=pw_mismatch");
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement("SELECT id FROM member WHERE id = ?")) {

            // 3. 아이디 중복 체크
            checkStmt.setString(1, id);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    response.sendRedirect("join.jsp?error=id_exists");
                    return;
                }
            }

            // 4. 회원가입 처리 (INSERT)
            String sql = "INSERT INTO member (name, id, pw, email, tel) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, name);
                pstmt.setString(2, id);
                pstmt.setString(3, pw);
                pstmt.setString(4, email);
                pstmt.setString(5, tel);
                pstmt.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("join.jsp?error=server_error");
            return;
        }

        // 5. 성공 시 success.jsp로 이동
        response.sendRedirect("success.jsp");
    }
}
