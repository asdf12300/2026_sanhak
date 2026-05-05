package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/verifyCode")
public class VerifyCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String inputCode = request.getParameter("code");
        HttpSession session = request.getSession();

        String savedCode = (String) session.getAttribute("verifyCode");
        String savedEmail = (String) session.getAttribute("verifyEmail");

        if (savedCode == null || savedEmail == null) {
            response.getWriter().write("{\"result\":\"fail\",\"msg\":\"인증 코드를 먼저 요청해주세요.\"}");
            return;
        }

        if (savedCode.equals(inputCode)) {
            session.setAttribute("codeVerified", true);
            response.getWriter().write("{\"result\":\"ok\"}");
        } else {
            response.getWriter().write("{\"result\":\"fail\",\"msg\":\"인증 코드가 일치하지 않습니다.\"}");
        }
    }
}