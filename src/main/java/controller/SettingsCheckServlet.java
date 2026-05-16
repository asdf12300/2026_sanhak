package controller;

import model.LoginDTO;
import model.UserSettingDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/settings/check")
public class SettingsCheckServlet extends HttpServlet {

    private LoginDTO getLoginUser(HttpSession session) {
        if (session == null) return null;

        Object obj = session.getAttribute("loginUser");
        if (obj instanceof LoginDTO) {
            return (LoginDTO) obj;
        }

        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        LoginDTO loginUser = getLoginUser(session);

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String loginType = loginUser.getLoginType();

        if ("naver".equals(loginType)) {
            request.setAttribute("naverUser", true);
            request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
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
        String loginType = loginUser.getLoginType();

        if ("naver".equals(loginType)) {
            String inputCode = request.getParameter("settingsCode");

            String sessionCode = (String) session.getAttribute("deleteEmailCode");
            Long codeTime = (Long) session.getAttribute("deleteEmailCodeTime");

            if (sessionCode == null || inputCode == null || !sessionCode.equals(inputCode)) {
                request.setAttribute("error", "이메일 인증번호가 일치하지 않습니다.");
                request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
                return;
            }

            if (codeTime == null || System.currentTimeMillis() - codeTime > 3 * 60 * 1000) {
                request.setAttribute("error", "이메일 인증번호가 만료되었습니다. 다시 발송해주세요.");
                request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
                return;
            }

            session.setAttribute("settingsAuthUserId", userId);
            response.sendRedirect(request.getContextPath() + "/settings.jsp");
            return;
        }
        
        String currentPw = request.getParameter("currentPw");
        
        UserSettingDAO dao = new UserSettingDAO();
        boolean valid = dao.checkPassword(userId, currentPw);

        if (valid) {
            session.setAttribute("settingsAuthUserId", userId);
            response.sendRedirect(request.getContextPath() + "/settings.jsp");
        } else {
            request.setAttribute("error", "비밀번호가 일치하지 않습니다.");
            request.getRequestDispatcher("/settingsCheck.jsp").forward(request, response);
        }
    }
}