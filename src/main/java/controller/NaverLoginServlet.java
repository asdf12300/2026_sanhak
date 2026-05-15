package controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import model.DBConnection;
import model.LoginDTO;

@WebServlet("/naver/login")
public class NaverLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String clientId;
    private String clientSecret;

    @Override
    public void init() {
        try (InputStream is = getServletContext().getResourceAsStream("/WEB-INF/classes/secret.properties")) {
            if (is == null) {
                throw new IllegalStateException("secret.properties 파일을 찾을 수 없습니다.");
            }

            Properties prop = new Properties();
            prop.load(is);

            clientId = prop.getProperty("naver.client.id");
            clientSecret = prop.getProperty("naver.client.secret");
        } catch (Exception e) {
            throw new IllegalStateException("네이버 로그인 설정을 불러오지 못했습니다.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");

        String code = request.getParameter("code");
        String state = request.getParameter("state");
        String role = (state != null && state.startsWith("professor")) ? "professor" : "student";

        try {
            String accessToken = requestAccessToken(code, state);
            if (accessToken.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            JSONObject profile = requestNaverProfile(accessToken);
            if (!"00".equals(profile.optString("resultcode", ""))) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            JSONObject responseNode = profile.getJSONObject("response");
            String email = responseNode.optString("email", "");
            String name = responseNode.optString("name", "");

            if (email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/join.jsp?error=empty");
                return;
            }

            try (Connection dbConn = DBConnection.getConnection()) {
                LoginDTO loginUser = findOrCreateNaverMember(dbConn, email, name, role);
                HttpSession session = request.getSession();
                session.setAttribute("loginUser", loginUser);
                session.setAttribute("loginType", "naver");
            }

            response.sendRedirect(request.getContextPath() + "/projects.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    private String requestAccessToken(String code, String state) throws IOException {
        String tokenUrl = "https://nid.naver.com/oauth2.0/token"
                + "?grant_type=authorization_code"
                + "&client_id=" + encode(clientId)
                + "&client_secret=" + encode(clientSecret)
                + "&code=" + encode(code)
                + "&state=" + encode(state);

        JSONObject tokenJson = new JSONObject(readGet(tokenUrl));
        return tokenJson.optString("access_token", "");
    }

    private JSONObject requestNaverProfile(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL("https://openapi.naver.com/v1/nid/me").openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                result.append(line);
            }
            return new JSONObject(result.toString());
        }
    }

    private LoginDTO findOrCreateNaverMember(Connection dbConn, String email, String name, String role) throws Exception {
        String selectSql = "SELECT id, name, role FROM member WHERE email = ?";
        try (PreparedStatement pstmt = dbConn.prepareStatement(selectSql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return toLoginUser(rs.getString("id"), rs.getString("name"), rs.getString("role"));
                }
            }
        }

        String memberId = createNaverMemberId(email);
        String insertSql = "INSERT INTO member(id, pw, email, name, role) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = dbConn.prepareStatement(insertSql)) {
            pstmt.setString(1, memberId);
            pstmt.setString(2, "NaverLogin");
            pstmt.setString(3, email);
            pstmt.setString(4, name);
            pstmt.setString(5, role);
            pstmt.executeUpdate();
        }

        return toLoginUser(memberId, name, role);
    }

    private LoginDTO toLoginUser(String id, String name, String role) {
        LoginDTO loginUser = new LoginDTO();
        loginUser.setId(id);
        loginUser.setName(name);
        loginUser.setRole(role);
        return loginUser;
    }

    private String createNaverMemberId(String email) {
        return "NAVER_" + email;
    }
    
    private String readGet(String url) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        conn.setRequestMethod("GET");

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                result.append(line);
            }
            return result.toString();
        }
    }

    private String encode(String value) {
        if (value == null) {
            return "";
        }
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

}
