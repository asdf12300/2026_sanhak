package controller;
import model.*;
import model.UserSettingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/settings/check")
public class SettingsCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loginUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loginUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        String userId = loginUser.getId();
        String currentPw = request.getParameter("currentPw");

        UserSettingDAO dao = new UserSettingDAO();

        boolean valid = dao.checkPassword(userId, currentPw);

        if (valid) {
            session.setAttribute("settingsAuth", true);
            response.sendRedirect(request.getContextPath() + "/settings.jsp");
        } else {
            request.setAttribute("error", "비밀번호가 일치하지 않습니다.");
            request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
        }
    }
}