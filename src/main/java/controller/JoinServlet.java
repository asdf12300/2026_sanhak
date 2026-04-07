package controller;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import util.DBUtil; 

@WebServlet("/JoinServlet")
public class JoinServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8"); 
        
     

        // 1. db.properties 설정 파일 로드
        Properties prop = new Properties();
        try (InputStream is = getServletContext().getResourceAsStream("/WEB-INF/classes/db.properties")) {
            if (is != null) {
                prop.load(is);
                System.out.println("로드된 URL: " + prop.getProperty("url"));
            } else {
                System.out.println("설정 파일을 찾을 수 없습니다: /WEB-INF/classes/db.properties");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 2. 파라미터 수집
        String name = request.getParameter("name");
        String id = request.getParameter("id");
        String pw = request.getParameter("pw");
        String pw_check = request.getParameter("pw_check");
        String email = request.getParameter("email");
        

        // 3. 필수 입력값 체크
        if (name == null || id == null || pw == null || pw_check == null || email == null ||
            name.isEmpty() || id.isEmpty() || pw.isEmpty() || pw_check.isEmpty() || email.isEmpty() ) {
            response.sendRedirect("join.jsp?error=empty");
            return;
        }

        // 4. 비밀번호 확인
        if (!pw.equals(pw_check)) {
            response.sendRedirect("join.jsp?error=pw_mismatch");
            return;
        }

        // 5. DBUtil을 사용하여 연결 및 쿼리 실행
        try (Connection conn = DBUtil.getConnection(prop)) { // prop 객체를 전달!
            
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

            // 회원가입 처리 (INSERT)
            String sql = "INSERT INTO member (name, id, pw, email) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, name);
                pstmt.setString(2, id);
                pstmt.setString(3, pw);
                pstmt.setString(4, email);
                pstmt.executeUpdate();
            }

            // 성공 시 페이지 이동
            response.sendRedirect("join_success.jsp");

        } catch (Exception e) {
            e.printStackTrace(); // 콘솔에서 에러 확인용
            response.sendRedirect("join.jsp?error=server_error");
        }
    }
}