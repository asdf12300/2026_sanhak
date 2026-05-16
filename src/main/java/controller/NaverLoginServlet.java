package controller;

import java.io.*;
import java.net.*;
import java.sql.*;
import java.util.Properties;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.json.JSONObject;

import model.LoginDTO;

@WebServlet("/naver/login")
public class NaverLoginServlet extends HttpServlet {

    private String CLIENT_ID;
    private String CLIENT_SECRET;

    @Override
    public void init() {
        try {
            Properties prop = new Properties();
            InputStream is = getServletContext()
                .getResourceAsStream("/WEB-INF/classes/secret.properties");
            prop.load(is);

            CLIENT_ID = prop.getProperty("naver.client.id");
            CLIENT_SECRET = prop.getProperty("naver.client.secret");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String code = request.getParameter("code");
        String state = request.getParameter("state");
        System.out.println("state 값: " + state);

        String role = "student";
        if (state != null && state.startsWith("professor")) {
            role = "professor";
        }
        System.out.println("role 값: " + role);
        Connection dbConn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            /* =========================
               1. 토큰 요청
            ========================= */
            String tokenUrl = "https://nid.naver.com/oauth2.0/token"
                    + "?grant_type=authorization_code"
                    + "&client_id=" + CLIENT_ID
                    + "&client_secret=" + CLIENT_SECRET
                    + "&code=" + code
                    + "&state=" + state;

            HttpURLConnection conn = (HttpURLConnection) new URL(tokenUrl).openConnection();
            conn.setRequestMethod("GET");

            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"));

            StringBuilder tokenResult = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                tokenResult.append(line);
            }
            br.close();

            System.out.println("토큰 응답: " + tokenResult.toString());

            /* =========================
               2. 토큰 파싱 + 검증
            ========================= */
            JSONObject tokenJson = new JSONObject(tokenResult.toString());
            String accessToken = tokenJson.optString("access_token", "");

            if (accessToken.equals("")) {
                System.out.println("토큰 발급 실패");
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            /* =========================
               3. 사용자 정보 요청
            ========================= */
            HttpURLConnection profileConn = (HttpURLConnection)
                    new URL("https://openapi.naver.com/v1/nid/me").openConnection();

            profileConn.setRequestMethod("GET");
            profileConn.setRequestProperty("Authorization", "Bearer " + accessToken);

            BufferedReader pbr = new BufferedReader(
                    new InputStreamReader(profileConn.getInputStream(), "UTF-8"));

            StringBuilder profileResult = new StringBuilder();
            while ((line = pbr.readLine()) != null) {
                profileResult.append(line);
            }
            pbr.close();

            System.out.println("프로필 응답: " + profileResult.toString());

            /* =========================
               4. 프로필 파싱 + 검증
            ========================= */
            JSONObject profileJson = new JSONObject(profileResult.toString());

            if (!profileJson.optString("resultcode").equals("00")) {
                System.out.println("프로필 조회 실패");
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            JSONObject responseNode = profileJson.getJSONObject("response");

            String email = responseNode.optString("email", "");
            if (email.endsWith("@jr.naver.com")) {
                email = email.replace("@jr.naver.com", "@naver.com");
            }
            String name = responseNode.optString("name", "");

            System.out.println("email: " + email);
            System.out.println("name: " + name);
            System.out.println("isEmpty: " + email.trim().isEmpty());
            
            /* =========================
               5. 이메일 없을 경우 처리
            ========================= */
            if (email == null || email.trim().isEmpty()) {
                System.out.println("이메일 없음 → 회원가입으로 이동");
                response.sendRedirect(request.getContextPath() + "/join.jsp?error=empty");
                return;
            }
            /* =========================
               6. DB 연결 및 로그인 처리
            ========================= */
            Class.forName("com.mysql.cj.jdbc.Driver");
            dbConn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/test2026?serverTimezone=Asia/Seoul&characterEncoding=UTF-8",
                    "root",
                    "lost5595@"
                    //"1234"
            );

            String extractedId = "naver_" + email.split("@")[0];

            String sql = "SELECT * FROM member WHERE login_type = 'naver' AND email = ?";
            pstmt = dbConn.prepareStatement(sql);
            pstmt.setString(1, email);

            HttpSession session = request.getSession();

         // 기존 회원 로그인
            if (rs.next()) {
                LoginDTO loginUser = new LoginDTO();
                loginUser.setId(rs.getString("id"));
                loginUser.setName(rs.getString("name"));
                loginUser.setRole(rs.getString("role"));
                loginUser.setLoginType("naver");
                
                session.setAttribute("loginUser", loginUser);
                session.setAttribute("loginType", "naver");
                
                response.sendRedirect(request.getContextPath() + "/projects.jsp");

            } else {
                // 신규 회원 INSERT
                // String extractedId = email.split("@")[0];
                
            	String insertSql = "INSERT INTO member(id, pw, email, name, role, login_type) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement insertStmt = dbConn.prepareStatement(insertSql);
                insertStmt.setString(1, extractedId);
                insertStmt.setString(2, "NaverLogin");
                insertStmt.setString(3, email);
                insertStmt.setString(4, name);
                insertStmt.setString(5, role);
                insertStmt.setString(6, "naver");
                insertStmt.executeUpdate();
                
                LoginDTO loginUser = new LoginDTO();
                loginUser.setId(extractedId);
                loginUser.setName(name);
                loginUser.setRole(role);
                loginUser.setLoginType("naver");
                
                session.setAttribute("loginUser", loginUser);
                session.setAttribute("loginType", "naver");
                
                response.sendRedirect(request.getContextPath() + "/projects.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp");

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (dbConn != null) dbConn.close(); } catch (Exception e) {}
        }
    }
}