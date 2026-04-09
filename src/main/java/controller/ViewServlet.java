package controller;

import model.ProjectDAO;
import model.ProjectDTO;
import model.ProjectMemberDAO;
import model.LoginDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.ProjectMemberDTO;

@WebServlet("/view")
public class ViewServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.isEmpty()) {
            request.setAttribute("error", "잘못된 접근입니다.");
            request.getRequestDispatcher("view.jsp").forward(request, response);
            return;
        }

        int id;
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

            ProjectMemberDAO pmDao = new ProjectMemberDAO();
            List<ProjectMemberDTO> members = pmDao.getMembersByProject(id);
            request.setAttribute("members", members);
        }

        request.getRequestDispatcher("view.jsp").forward(request, response);
    }
}