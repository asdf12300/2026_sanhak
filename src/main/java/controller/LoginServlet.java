package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.LoginDAO;
import model.LoginDTO;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userid = request.getParameter("userid");
        String password = request.getParameter("password");
        
        LoginDAO dao = new LoginDAO();
        
        try {
        //로그인 인증
        LoginDTO member = dao.authenticate(userid, password);

        if (member != null) {
            // 로그인 성공 → 세션에 사용자 정보 저장
            HttpSession session = request.getSession();
            session.setAttribute("loginUser", member);
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        } else {
            // 로그인 실패 → 다시 login.jsp
            request.setAttribute("error", "아이디 또는 비밀번호가 일치하지 않습니다.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
        }catch(Exception e) {
        	// 여기서 화면에 예외 메시지 전달
            request.setAttribute("error", "예외 발생: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp"); // GET 요청은 로그인 페이지로
    }
}
