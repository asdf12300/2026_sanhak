package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.ProjectMemberDAO;

@WebServlet("/leaveProject")
public class LeaveProjectServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String projectIdStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        String userId = null;
        if (session.getAttribute("id") != null) {
            userId = (String) session.getAttribute("id");
        } else if (session.getAttribute("loginUser") != null) {
            model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
            userId = loginUser.getId();
        }
        
        if (projectIdStr != null && userId != null) {
            int projectId = Integer.parseInt(projectIdStr);
            ProjectMemberDAO dao = new ProjectMemberDAO();
            dao.removeMember(projectId, userId);

            // role에 따라 리다이렉트 분기
            String myRole = dao.getMemberRole(userId);
            if ("professor".equals(myRole)) {
                response.sendRedirect("professorProject.jsp");
            } else {
                response.sendRedirect("projects.jsp");
            }
        } else {
            response.sendRedirect("projects.jsp");
        }
    }
}
