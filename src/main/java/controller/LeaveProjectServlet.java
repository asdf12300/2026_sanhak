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

@WebServlet("/leaveProject")
public class LeaveProjectServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String projectIdStr = request.getParameter("projectID");
        HttpSession session = request.getSession(false);
        String userId = getLoginUserId(session);

        if (projectIdStr == null || userId == null) {
            response.sendRedirect("projects.jsp");
            return;
        }

        int projectId = Integer.parseInt(projectIdStr);
        ProjectMemberDAO dao = new ProjectMemberDAO();

        String msg;
        if (dao.isProjectLeader(projectId, userId)) {
            if (dao.isSoloProject(projectId, userId)) {
                boolean deleted = dao.deleteProject(projectId);
                msg = deleted
                    ? "혼자 있는 프로젝트를 삭제하고 나갔습니다."
                    : "프로젝트 나가기에 실패했습니다.";
            } else {
                msg = "팀장은 프로젝트에서 나갈 수 없습니다. 팀장을 다른 팀원에게 넘긴 후 나가주세요.";
            }
        } else {
            boolean left = dao.leaveProject(projectId, userId);
            msg = left ? "프로젝트에서 나갔습니다." : "프로젝트 나가기에 실패했습니다.";
        }

        redirectByRole(response, dao.getMemberRole(userId), msg);
    }

    private String getLoginUserId(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object legacyId = session.getAttribute("id");
        if (legacyId instanceof String) {
            return (String) legacyId;
        }

        Object loginUserAttr = session.getAttribute("loginUser");
        if (loginUserAttr instanceof LoginDTO) {
            return ((LoginDTO) loginUserAttr).getId();
        }

        return null;
    }

    private void redirectByRole(HttpServletResponse response, String role, String msg) throws IOException {
        String target = "professor".equals(role) ? "professorProject.jsp" : "projects.jsp";
        response.sendRedirect(target + "?msg=" + URLEncoder.encode(msg, "UTF-8"));
    }
}
