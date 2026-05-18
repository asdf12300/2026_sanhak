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

        String action = request.getParameter("action");
        String userId = loginUser.getId();
        FolderDAO dao = new FolderDAO();

        if ("create".equals(action)) {
            String name = request.getParameter("folderName");
            if (name != null && !name.trim().isEmpty()) {
                dao.createFolder(name.trim(), userId);
            }

        } else if ("delete".equals(action)) {
            int folderId = parseInt(request.getParameter("folderId"));
            if (folderId <= 0 || !dao.deleteFolder(folderId, userId)) {
                reject(session);
            }

        } else if ("assign".equals(action)) {
            int projectId = parseInt(request.getParameter("projectID"));
            int folderId = parseInt(request.getParameter("folderId"));
            if (projectId <= 0 || folderId <= 0 || !dao.isFolderOwner(folderId, userId)) {
                reject(session);
            } else {
                dao.assignProjectToFolder(projectId, folderId);
            }

        } else if ("remove".equals(action)) {
            int projectId = parseInt(request.getParameter("projectID"));
            if (projectId <= 0) {
                reject(session);
            } else {
                dao.removeProjectFromFolder(projectId);
            }

        } else if ("rename".equals(action)) {
            int folderId = parseInt(request.getParameter("folderId"));
            String folderName = request.getParameter("folderName");
            if (folderName == null || folderName.trim().isEmpty()
                    || folderId <= 0
                    || !dao.renameFolder(folderId, folderName.trim(), userId)) {
                reject(session);
            }
        }

        response.sendRedirect(request.getContextPath() + "/" + getProjectListPage(loginUser));
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

    private void reject(HttpSession session) {
        session.setAttribute("accessError", INVALID_ACCESS_MESSAGE);
    }

    private String getProjectListPage(LoginDTO loginUser) {
        return "professor".equals(loginUser.getRole()) ? "professorProject.jsp" : "projects.jsp";
    }
}
