package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.DBConnection;

@WebServlet("/JoinServlet")
public class JoinServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name     = request.getParameter("name");
        String id       = request.getParameter("id");
        String pw       = request.getParameter("pw");
        String pw_check = request.getParameter("pw_check");
        String email    = request.getParameter("email");
        String role     = request.getParameter("role");

        // 빈값 체크
        if (name == null || id == null || pw == null || pw_check == null || email == null || role == null ||
            name.isEmpty() || id.isEmpty() || pw.isEmpty() || pw_check.isEmpty() || email.isEmpty() || role.isEmpty()) {
            response.sendRedirect("join.jsp?error=empty");
            return;
        }

        // 비밀번호 확인
        if (!pw.equals(pw_check)) {
            response.sendRedirect("join.jsp?error=pw_mismatch");
            return;
        }

        // role 검증
        if (!role.equals("student") && !role.equals("professor")) {
            response.sendRedirect("join.jsp?error=invalid_role");
            return;
        }

        // 이메일 인증 확인
        HttpSession session = request.getSession();
        Boolean codeVerified = (Boolean) session.getAttribute("codeVerified");
        String verifyEmail   = (String) session.getAttribute("verifyEmail");

        if (codeVerified == null || !codeVerified || !email.equals(verifyEmail)) {
            response.sendRedirect("join.jsp?error=email_not_verified");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // 아이디 중복 체크
            String checkSql = "SELECT id FROM member WHERE id = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, id);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("join.jsp?error=id_exists");
                        return;
                    }
                }
            }

            // 이메일 중복 체크
            String checkEmailSql = "SELECT email FROM member WHERE email = ?";
            try (PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql)) {
                checkEmailStmt.setString(1, email);
                try (ResultSet rs = checkEmailStmt.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("join.jsp?error=email_exists");
                        return;
                    }
                }
            }

            // DB에 저장
            String sql = "INSERT INTO member (name, id, pw, email, role) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, name);
                pstmt.setString(2, id);
                pstmt.setString(3, pw);
                pstmt.setString(4, email);
                pstmt.setString(5, role);
                pstmt.executeUpdate();
            }

            // 세션 정리
            session.removeAttribute("codeVerified");
            session.removeAttribute("verifyEmail");
            session.removeAttribute("verifyCode");

            response.sendRedirect("login.jsp?joined=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("join.jsp?error=server_error");
        }
    }
}