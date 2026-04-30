package controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Properties;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/naver/login")
public class NaverLoginServlet extends HttpServlet {

    private String CLIENT_ID;
    private String CLIENT_SECRET;

    @Override
    public void init() {
        try {
            Properties prop = new Properties();
            InputStream is = getClass().getClassLoader()
                .getResourceAsStream("secret.properties");
            prop.load(is);
            CLIENT_ID = prop.getProperty("naver.client.id");
            CLIENT_SECRET = prop.getProperty("naver.client.secret");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String code = request.getParameter("code");
        String state = request.getParameter("state");

        // 1. 액세스 토큰 요청
        String tokenUrl = "https://nid.naver.com/oauth2.0/token"
            + "?grant_type=authorization_code"
            + "&client_id=" + CLIENT_ID
            + "&client_secret=" + CLIENT_SECRET
            + "&code=" + code
            + "&state=" + state;

        URL url = new URL(tokenUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        BufferedReader br = new BufferedReader(
            new InputStreamReader(conn.getInputStream(), "UTF-8")
        );
        StringBuilder tokenResult = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) tokenResult.append(line);
        br.close();

        // 2. 토큰 파싱
        String accessToken = tokenResult.toString()
            .split("\"access_token\":\"")[1]
            .split("\"")[0];

        // 3. 사용자 정보 요청
        URL profileUrl = new URL("https://openapi.naver.com/v1/nid/me");
        HttpURLConnection profileConn = (HttpURLConnection) profileUrl.openConnection();
        profileConn.setRequestMethod("GET");
        profileConn.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader pbr = new BufferedReader(
            new InputStreamReader(profileConn.getInputStream(), "UTF-8")
        );
        StringBuilder profileResult = new StringBuilder();
        while ((line = pbr.readLine()) != null) profileResult.append(line);
        pbr.close();

        // 4. 사용자 정보 파싱
        String userId = profileResult.toString()
            .split("\"id\":\"")[1]
            .split("\"")[0];

        String nickname = profileResult.toString()
            .split("\"nickname\":\"")[1]
            .split("\"")[0];

        String email = "";
        if (profileResult.toString().contains("\"email\":\"")) {
            email = profileResult.toString()
                .split("\"email\":\"")[1]
                .split("\"")[0];
        }

        // 5. 세션 저장
        HttpSession session = request.getSession();
        session.setAttribute("userId", userId);
        session.setAttribute("nickname", nickname);
        session.setAttribute("email", email);
        session.setAttribute("loginType", "naver");

        // 6. 메인 페이지로 이동
        response.sendRedirect("/projects.jsp");
    }
}