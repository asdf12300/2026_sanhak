package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.LoginDTO;
import model.LoginDAO;
import model.ProjectMemberDAO;

@WebServlet("/deleteAccount")
public class DeleteAccountServlet extends HttpServlet {

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

        String confirmText = request.getParameter("confirmText");
        String password = request.getParameter("password");
        String inputCode = request.getParameter("deleteCode");

        String sessionCode = (String) session.getAttribute("deleteEmailCode");
        Long codeTime = (Long) session.getAttribute("deleteEmailCodeTime");

        if (sessionCode == null || inputCode == null || !sessionCode.equals(inputCode)) {
            request.setAttribute("deleteError", "이메일 인증번호가 일치하지 않습니다.");
            request.getRequestDispatcher("/settings.jsp").forward(request, response);
            return;
        }

        if (codeTime == null || System.currentTimeMillis() - codeTime > 3 * 60 * 1000) {
            request.setAttribute("deleteError", "이메일 인증번호가 만료되었습니다. 다시 발송해주세요.");
            request.getRequestDispatcher("/settings.jsp").forward(request, response);
            return;
        }
        try {
            if (!"탈퇴합니다".equals(confirmText)) {
                request.setAttribute("deleteError", "탈퇴 확인 문구를 정확히 입력해주세요.");
                request.getRequestDispatcher("settings.jsp").forward(request, response);
                return;
            }

            LoginDAO loginDAO = new LoginDAO();

            boolean passwordOk = loginDAO.checkPassword(userId, password);

            if (!passwordOk) {
                request.setAttribute("deleteError", "비밀번호가 일치하지 않습니다.");
                request.getRequestDispatcher("settings.jsp").forward(request, response);
                return;
            }

            ProjectMemberDAO projectMemberDAO = new ProjectMemberDAO();

            boolean isLeader = projectMemberDAO.isUserLeader(userId);

            if (isLeader) {
                request.setAttribute("deleteError", "팀장은 탈퇴할 수 없습니다. 팀장을 다른 팀원에게 넘긴 후 탈퇴해주세요.");
                request.getRequestDispatcher("settings.jsp").forward(request, response);
                return;
            }

            boolean result = loginDAO.deleteMember(userId);

            if (result) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login.jsp?deleted=1");
            } else {
                request.setAttribute("deleteError", "계정 탈퇴에 실패했습니다.");
                request.getRequestDispatcher("settings.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("deleteError", "오류 발생: " + e.getMessage());
            request.getRequestDispatcher("settings.jsp").forward(request, response);
        }
    }
}