package controller;

import model.ProjectDAO;
import model.ProjectDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/view")
public class ViewServlet extends HttpServlet {
	
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.isEmpty()) {
            request.setAttribute("error", "잘못된 접근입니다.");
            request.getRequestDispatcher("view.jsp").forward(request, response);
            return;
        }

        int id = 0;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "올바른 글 번호가 아닙니다.");
            request.getRequestDispatcher("view.jsp").forward(request, response);
            return;
        }

        ProjectDAO dao = new ProjectDAO();
        ProjectDTO dto = dao.getById(id);

        if (dto == null) {
            request.setAttribute("error", "존재하지 않는 글입니다.");
        } else {
            request.setAttribute("dto", dto);
        }

        request.getRequestDispatcher("view.jsp").forward(request, response);
    }
}
