package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.CalendarDAO;
import model.CalendarDTO;
import model.DBConnection;

@WebServlet("/event")
public class CalendarServlet extends HttpServlet {

    private CalendarDAO dao = new CalendarDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("list".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();

            try (Connection conn = DBConnection.getConnection()) {
                int projectId = Integer.parseInt(req.getParameter("projectId"));
                List<CalendarDTO> list = dao.getEventsByProject(conn, projectId);

                StringBuilder json = new StringBuilder();
                json.append("[");
                boolean first = true;
                for (CalendarDTO e : list) {
                    if (!first) json.append(",");
                    first = false;

                    String title = esc(e.getTitle());
                    String memo = esc(e.getMemo());
                    String status = esc(e.getTaskStatus());
                    String assignee = esc(e.getTaskAssignee());

                    json.append("{");
                    json.append("\"id\":").append(e.getId()).append(",");
                    json.append("\"title\":\"").append(title).append("\",");
                    json.append("\"date\":\"").append(e.getDate()).append("\",");
                    json.append("\"time\":\"").append(e.getTime() == null ? "" : e.getTime()).append("\",");
                    json.append("\"cat\":").append(e.getCategory()).append(",");
                    json.append("\"memo\":\"").append(memo).append("\",");
                    json.append("\"taskId\":").append(e.getTaskId() == null ? "null" : e.getTaskId()).append(",");
                    json.append("\"taskStatus\":\"").append(status).append("\",");
                    json.append("\"taskAssignee\":\"").append(assignee).append("\"");
                    json.append("}");
                }
                json.append("]");
                out.print(json.toString());

            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {

            if ("save".equals(action)) {
                String projectIdStr = req.getParameter("project_id");
                if (projectIdStr == null || projectIdStr.isEmpty() || projectIdStr.equals("null")) {
                    resp.getWriter().print("error");
                    return;
                }

                CalendarDTO e = new CalendarDTO();
                e.setProjectId(Integer.parseInt(projectIdStr));
                e.setTitle(req.getParameter("title"));
                e.setDate(req.getParameter("date"));
                e.setTime(req.getParameter("time"));
                e.setCategory(Integer.parseInt(req.getParameter("cat")));
                e.setMemo(req.getParameter("memo"));
                dao.insertEvent(conn, e);
                conn.commit();

            } else if ("update".equals(action)) {
                CalendarDTO e = new CalendarDTO();
                e.setId(Integer.parseInt(req.getParameter("id")));
                e.setProjectId(Integer.parseInt(req.getParameter("project_id")));
                e.setTitle(req.getParameter("title"));
                e.setDate(req.getParameter("date"));
                e.setTime(req.getParameter("time"));
                e.setCategory(Integer.parseInt(req.getParameter("cat")));
                e.setMemo(req.getParameter("memo"));

                String taskIdStr = req.getParameter("taskId");
                if (taskIdStr != null && !taskIdStr.isEmpty() && !taskIdStr.equals("null")) {
                    e.setTaskId(Integer.parseInt(taskIdStr));
                }

                dao.updateEvent(conn, e);
                conn.commit();

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                dao.deleteEvent(conn, id);
                conn.commit();
            }

            resp.getWriter().print("ok");

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("error");
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}