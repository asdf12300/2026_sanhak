package controller;

import model.UserSettingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/settings/update")
public class SettingsUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Boolean settingsAuth = (Boolean) session.getAttribute("settingsAuth");

        if (settingsAuth == null || !settingsAuth) {
            response.sendRedirect(request.getContextPath() + "/settings/check");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String email = request.getParameter("email");
        String newPw = request.getParameter("newPw");
        String newPwCheck = request.getParameter("newPwCheck");

        if ((email == null || email.trim().isEmpty()) &&
            (newPw == null || newPw.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/settings.jsp?error=empty");
            return;
        }

        if (newPw != null && !newPw.trim().isEmpty()) {
            if (newPwCheck == null || !newPw.equals(newPwCheck)) {
                response.sendRedirect(request.getContextPath() + "/settings.jsp?error=pw");
                return;
            }
        }

        UserSettingDAO dao = new UserSettingDAO();
        boolean result = dao.updateUserInfo(userId, email, newPw);

        if (result) {
            session.removeAttribute("settingsAuth");
            response.sendRedirect(request.getContextPath() + "/settings.jsp?success=1");
            return;
        } else {
            response.sendRedirect(request.getContextPath() + "/settings.jsp?error=fail");
            return;
        }
    }
}