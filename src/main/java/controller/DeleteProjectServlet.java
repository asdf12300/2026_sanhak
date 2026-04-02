package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.ProjectDAO;

@WebServlet("/deleteProject")
public class DeleteProjectServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            new ProjectDAO().delete(Integer.parseInt(idStr));
        }
        response.sendRedirect("list");
    }
}
