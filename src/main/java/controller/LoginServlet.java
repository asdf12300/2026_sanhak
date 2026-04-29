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
            LoginDTO member = dao.authenticate(userid, password);

            if (member != null) {
                HttpSession session = request.getSession();
                session.setAttribute("loginUser", member);
                response.sendRedirect(request.getContextPath() + "/projects.jsp");
            } else {
                request.setAttribute("error", "아이디 또는 비밀번호가 일치하지 않습니다.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "예외 발생: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
        
    }
}
