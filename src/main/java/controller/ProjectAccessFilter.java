package controller;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.LoginDTO;
import model.ProjectMemberDAO;
import util.RequestParamNames;

@WebFilter(urlPatterns = {
    "/index.jsp",
    "/task.jsp",
    "/calendar.jsp",
    "/chat.jsp",
    "/teamMemberManage.jsp",
    "/teamMemberManage",
    "/projectMember",
    "/taskApi",
    "/event",
    "/ChatServlet",
    "/fileShare",
    "/feedback",
    "/meetingMinutes",
    "/createMeetingMinutes",
    "/deleteMeetingMinutes",
    "/meetingMinutesView",
    "/updateMeetingMinutes",
    "/folderAction",
    "/editProject",
    "/deleteProject",
    "/leaveProject",
    "/inviteMembers",
    "/teamMemberAction",
    "/view"
})
public class ProjectAccessFilter implements Filter {

    private static final String INVALID_ACCESS_MESSAGE = "\uC798\uBABB\uB41C \uC811\uADFC \uC785\uB2C8\uB2E4.";
    private final ProjectMemberDAO projectMemberDAO = new ProjectMemberDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        LoginDTO loginUser = session != null ? (LoginDTO) session.getAttribute("loginUser") : null;
        if (loginUser == null) {
            reject(req, resp, "login.jsp");
            return;
        }

        String projectListPage = getProjectListPage(loginUser);

        if (isInvitationResponse(req)) {
            chain.doFilter(request, response);
            return;
        }

        Integer projectID = parseProjectID(req);
        if (projectID == null || projectID <= 0) {
            reject(req, resp, projectListPage);
            return;
        }

        if (!projectMemberDAO.canAccessProject(projectID, loginUser.getId())) {
            reject(req, resp, projectListPage);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }

    private Integer parseProjectID(HttpServletRequest req) {
        String value = req.getParameter(RequestParamNames.PROJECT_ID);
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isInvitationResponse(HttpServletRequest req) {
        String servletPath = req.getServletPath();
        String action = req.getParameter("action");
        return "/teamMemberAction".equals(servletPath)
                && ("accept".equals(action) || "reject".equals(action));
    }

    private String getProjectListPage(LoginDTO loginUser) {
        return "professor".equals(loginUser.getRole()) ? "professorProject.jsp" : "projects.jsp";
    }

    private void reject(HttpServletRequest req, HttpServletResponse resp, String target)
            throws IOException {
        HttpSession session = req.getSession();
        session.setAttribute("accessError", INVALID_ACCESS_MESSAGE);
        resp.sendRedirect(req.getContextPath() + "/" + target);
    }
}
