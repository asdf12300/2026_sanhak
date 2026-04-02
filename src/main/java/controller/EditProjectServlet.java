package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.ProjectDAO;
import model.ProjectDTO;

@WebServlet("/editProject")
public class EditProjectServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) { response.sendRedirect("list"); return; }

        ProjectDAO dao = new ProjectDAO();
        ProjectDTO dto = dao.getById(Integer.parseInt(idStr));
        request.setAttribute("dto", dto);
        request.getRequestDispatcher("editProject.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        ProjectDTO dto = new ProjectDTO();
        dto.setId(Integer.parseInt(request.getParameter("id")));
        dto.setTitle(request.getParameter("title"));
        dto.setContent(request.getParameter("content"));
        dto.setDeadline(request.getParameter("deadline"));

        new ProjectDAO().update(dto);
        response.sendRedirect("view?id=" + dto.getId());
    }
}
