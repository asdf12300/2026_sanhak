package controller;

import model.LoginDTO;
import model.UserSettingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/settings/update")
public class SettingsUpdateServlet extends HttpServlet {

    private LoginDTO getLoginUser(HttpSession session) {
        if (session == null) return null;

        Object obj = session.getAttribute("loginUser");
        if (obj instanceof LoginDTO) {
            return (LoginDTO) obj;
        }

        return null;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        LoginDTO loginUser = getLoginUser(session);

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userId = loginUser.getId();
        boolean isNaverUser = userId != null && userId.startsWith("naver_");

        String authUserId = (String) session.getAttribute("settingsAuthUserId");
        if (authUserId == null || !authUserId.equals(userId)) {
            response.sendRedirect(request.getContextPath() + "/settings/check");
            return;
        }

        String email = request.getParameter("email");
        String newPw = request.getParameter("newPw");
        String newPwCheck = request.getParameter("newPwCheck");
        
        if (isNaverUser && newPw != null && !newPw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/settings.jsp?error=naverPw");
            return;
        }

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
            session.removeAttribute("settingsAuthUserId");
            response.sendRedirect(request.getContextPath() + "/settings.jsp?success=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/settings.jsp?error=fail");
        }
    }
}