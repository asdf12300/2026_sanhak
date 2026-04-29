package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.FolderDAO;
import model.LoginDTO;

@WebServlet("/folderAction")
public class FolderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        String userId = loginUser.getId();

        FolderDAO dao = new FolderDAO();

        if ("create".equals(action)) {
            String name = request.getParameter("folderName");
            dao.createFolder(name, userId);

        } else if ("delete".equals(action)) {
            int folderId = Integer.parseInt(request.getParameter("folderId"));
            dao.deleteFolder(folderId);

        } else if ("assign".equals(action)) {
            int projectId = Integer.parseInt(request.getParameter("projectId"));
            int folderId  = Integer.parseInt(request.getParameter("folderId"));
            dao.assignProjectToFolder(projectId, folderId);

        } else if ("remove".equals(action)) {
            int projectId = Integer.parseInt(request.getParameter("projectId"));
            dao.removeProjectFromFolder(projectId);
        }

        response.sendRedirect(request.getContextPath() + "/professorProject.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}