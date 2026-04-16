package controller;

import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.CalendarDAO;
import model.CalendarDTO;
import model.DBConnection;
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

        int id          = Integer.parseInt(request.getParameter("id"));
        String title    = request.getParameter("title");
        String content  = request.getParameter("content");
        String deadline = request.getParameter("deadline");

        ProjectDTO dto = new ProjectDTO();
        dto.setId(id);
        dto.setTitle(title);
        dto.setContent(content);
        dto.setDeadline(deadline);
        new ProjectDAO().update(dto);

        // 캘린더 마감일 이벤트 동기화
        if (deadline != null && !deadline.trim().isEmpty()) {
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                String updateSql = "UPDATE calendar SET event_date=?, title=? " +
                                   "WHERE project_id=? AND title LIKE '[마감]%' AND task_id IS NULL";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, deadline.trim());
                    ps.setString(2, "[마감] " + title);
                    ps.setInt(3, id);
                    int updated = ps.executeUpdate();
                    if (updated == 0) {
                        CalendarDTO cal = new CalendarDTO();
                        cal.setProjectId(id);
                        cal.setTitle("[마감] " + title);
                        cal.setDate(deadline.trim());
                        cal.setCategory(1);
                        cal.setMemo("프로젝트 마감일");
                        new CalendarDAO().insertEvent(conn, cal);
                    }
                }
                conn.commit();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("projects.jsp");
    }
}
