package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.*;

@WebServlet("/list")
public class ListServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int page = 1;
        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        ListDAO dao = new ListDAO();
        int totalCount = dao.getTotalCount();

        PagingVO paging = new PagingVO(page, totalCount);

        // offset 계산 후 DAO 호출
        List<ProjectDTO> list = dao.getList(page, paging.getPageSize());

        request.setAttribute("list", list);
        request.setAttribute("paging", paging);

        RequestDispatcher rd = request.getRequestDispatcher("list.jsp");
        rd.forward(request, response);
    }
}
