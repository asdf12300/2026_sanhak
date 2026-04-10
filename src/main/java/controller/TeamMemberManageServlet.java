package controller;

import model.LoginDTO;
import model.ProjectMemberDAO;
import model.ProjectMemberDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/teamMemberManage")
public class TeamMemberManageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ProjectMemberDAO dao = new ProjectMemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String projectIdStr = request.getParameter("projectId");

        if (projectIdStr == null || projectIdStr.trim().isEmpty()) {
            response.sendRedirect("list");
            return;
        }

        int projectId;
        try {
            projectId = Integer.parseInt(projectIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("list");
            return;
        }

        String loginId = null;

        if (request.getSession().getAttribute("id") != null) {
            loginId = (String) request.getSession().getAttribute("id");
        } else if (request.getSession().getAttribute("loginUser") != null) {
            LoginDTO loginUser = (LoginDTO) request.getSession().getAttribute("loginUser");
            if (loginUser != null) {
                loginId = loginUser.getId();
            }
        }

        List<ProjectMemberDTO> projectMemberList = dao.getMembersByProject(projectId);
        List<ProjectMemberDTO> receivedInviteList = null;

        if (loginId != null) {
            receivedInviteList = dao.getReceivedInvitations(loginId);
        }

        request.setAttribute("projectId", projectId);
        request.setAttribute("projectMemberList", projectMemberList);
        request.setAttribute("receivedInviteList", receivedInviteList);

        request.getRequestDispatcher("/teamMemberManage.jsp").forward(request, response);
    }
}