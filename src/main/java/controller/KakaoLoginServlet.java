package controller;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/kakao/login")  // ← fetch('/kakao/login') 과 일치
public class KakaoLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // 프론트에서 보낸 사용자 정보 받기
        BufferedReader reader = request.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        String body = sb.toString();

        // 세션 생성
        HttpSession session = request.getSession();
        session.setAttribute("kakaoUser", body);

        // 응답
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"ok\"}");
    }
}