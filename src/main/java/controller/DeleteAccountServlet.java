package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.LoginDAO;
import model.LoginDTO;
import model.ProjectMemberDAO;

@WebServlet("/deleteAccount")
public class DeleteAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final long CODE_EXPIRE_MILLIS = 3 * 60 * 1000;

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
        boolean naverUser = isNaverUser(userId);

        String confirmText = request.getParameter("confirmText");
        String password = request.getParameter("password");
        String inputCode = request.getParameter("deleteCode");

        try {
            String sessionCode = (String) session.getAttribute("deleteEmailCode");
            Long codeTime = (Long) session.getAttribute("deleteEmailCodeTime");

            if (sessionCode == null || inputCode == null || !sessionCode.equals(inputCode)) {
                forwardError(request, response, "이메일 인증번호가 일치하지 않습니다.");
                return;
            }

            if (codeTime == null || System.currentTimeMillis() - codeTime > CODE_EXPIRE_MILLIS) {
                forwardError(request, response, "이메일 인증번호가 만료되었습니다. 다시 발송해주세요.");
                return;
            }

            if (!"탈퇴합니다".equals(confirmText)) {
                forwardError(request, response, "탈퇴 확인 문구를 정확히 입력해주세요.");
                return;
            }

            LoginDAO loginDAO = new LoginDAO();
            if (!naverUser && !loginDAO.checkPassword(userId, password)) {
                forwardError(request, response, "비밀번호가 일치하지 않습니다.");
                return;
            }

            ProjectMemberDAO projectMemberDAO = new ProjectMemberDAO();
            if (projectMemberDAO.hasBlockingLeaderProject(userId)) {
                forwardError(request, response, "팀장은 탈퇴할 수 없습니다. 팀장을 다른 팀원에게 넘긴 후 탈퇴해주세요.");
                return;
            }

            if (!projectMemberDAO.deleteSoloLeaderProjects(userId)) {
                forwardError(request, response, "개인 프로젝트 정리에 실패했습니다.");
                return;
            }

            boolean result = loginDAO.deleteMember(userId);
            if (result) {
                session.removeAttribute("deleteEmailCode");
                session.removeAttribute("deleteEmailCodeTime");
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login.jsp?deleted=1");
            } else {
                forwardError(request, response, "계정 탈퇴에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            forwardError(request, response, "오류 발생: " + e.getMessage());
        }
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("deleteError", message);
        request.getRequestDispatcher("settings.jsp").forward(request, response);
    }

    private boolean isNaverUser(String userId) {
        return userId != null && userId.startsWith("NAVER_");
    }
}
