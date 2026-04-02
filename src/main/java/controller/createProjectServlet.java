package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.ProjectDAO;
import model.ProjectDTO;

@WebServlet("/writeProcess")
public class createProjectServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String deadline = request.getParameter("deadline"); 

        ProjectDTO dto = new ProjectDTO();
        dto.setTitle(title);
        dto.setContent(content);
        dto.setDeadline(deadline); 

        ProjectDAO dao = new ProjectDAO();
        dao.insert(dto);

        response.sendRedirect("list");
    }
}