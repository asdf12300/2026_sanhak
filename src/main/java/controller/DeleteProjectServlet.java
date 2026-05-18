package controller;

import java.io.IOException;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.LoginDTO;
import model.ProjectMemberDAO;

@WebServlet("/deleteProject")
public class DeleteProjectServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String INVALID_ACCESS_MESSAGE = "\uC798\uBABB\uB41C \uC811\uADFC \uC785\uB2C8\uB2E4.";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        LoginDTO loginUser = session != null ? (LoginDTO) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int projectID = parseInt(request.getParameter("projectID"));
        ProjectMemberDAO dao = new ProjectMemberDAO();
        String msg;

        if (projectID <= 0 || !dao.isProjectLeader(projectID, loginUser.getId())) {
            session.setAttribute("accessError", INVALID_ACCESS_MESSAGE);
            redirectByRole(response, loginUser, null);
            return;
        }

        if (!dao.isSoloProject(projectID, loginUser.getId())) {
            msg = "팀장은 프로젝트를 바로 삭제하거나 나갈 수 없습니다. 팀장을 다른 팀원에게 넘긴 후 진행해주세요.";
            redirectByRole(response, loginUser, msg);
            return;
        }

        boolean deleted = dao.deleteProject(projectID);
        msg = deleted ? "혼자 있는 프로젝트를 삭제했습니다." : "프로젝트 삭제에 실패했습니다.";
        redirectByRole(response, loginUser, msg);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    private int parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }

        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void redirectByRole(HttpServletResponse response, LoginDTO loginUser, String msg) throws IOException {
        String target = "professor".equals(loginUser.getRole()) ? "professorProject.jsp" : "projects.jsp";
        if (msg == null || msg.trim().isEmpty()) {
            response.sendRedirect(target);
        } else {
            response.sendRedirect(target + "?msg=" + URLEncoder.encode(msg, "UTF-8"));
        }
    }
}
