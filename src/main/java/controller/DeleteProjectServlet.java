package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.LoginDTO;
import model.ProjectDAO;
import model.ProjectDTO;

@WebServlet("/deleteProject")
public class DeleteProjectServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("projectID");
        if (idStr != null) {
            ProjectDAO dao = new ProjectDAO();
            int projectID = Integer.parseInt(idStr);
            ProjectDTO project = dao.getById(projectID);
            LoginDTO loginUser = (LoginDTO) request.getSession().getAttribute("loginUser");

            if (project != null
                    && loginUser != null
                    && loginUser.getId().equals(project.getTeam_leader())) {
                dao.delete(projectID);
            } else {
                request.getSession().setAttribute("accessError", "\uC798\uBABB\uB41C \uC811\uADFC \uC785\uB2C8\uB2E4.");
            }
        }
        response.sendRedirect("projects.jsp");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
