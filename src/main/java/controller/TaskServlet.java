package controller;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.TaskDAO;
import model.TaskDTO;
import model.DBConnection;

@WebServlet("/taskApi")
public class TaskServlet extends HttpServlet {

    private TaskDAO dao = new TaskDAO();

    private Properties loadDB() throws Exception {
        Properties prop = new Properties();
        InputStream input = getServletContext().getResourceAsStream("/WEB-INF/classes/db.properties");
        if (input == null) throw new RuntimeException("db.properties를 찾을 수 없습니다.");
        prop.load(input);
        input.close();
        return prop;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        int projectId = 0;
        try { projectId = Integer.parseInt(req.getParameter("projectId")); } catch (Exception e) {}

        // 팀원 목록 요청
        if ("members".equals(req.getParameter("type"))) {
            try (Connection conn = DBConnection.getConnection()) {
                List<model.ProjectMemberDTO> members = dao.getProjectMembers(conn, projectId);
                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                for (model.ProjectMemberDTO m : members) {
                    if (!first) json.append(",");
                    first = false;
                    json.append("{")
                        .append("\"id\":\"").append(esc(m.getMemberId())).append("\",")
                        .append("\"name\":\"").append(esc(m.getName())).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            List<TaskDTO> list = dao.getAllTasks(conn, projectId);

            StringBuilder json = new StringBuilder();
            json.append("[");
            boolean first = true;
            for (TaskDTO t : list) {
                if (!first) json.append(",");
                first = false;
                json.append("{")
                    .append("\"id\":").append(t.getId()).append(",")
                    .append("\"projectId\":").append(t.getProjectId()).append(",")
                    .append("\"title\":\"").append(esc(t.getTitle())).append("\",")
                    .append("\"content\":\"").append(esc(t.getContent())).append("\",")
                    .append("\"assignee\":\"").append(esc(t.getAssignee())).append("\",")
                    .append("\"status\":\"").append(esc(t.getStatus())).append("\",")
                    .append("\"deadline\":\"").append(t.getDeadline() == null ? "" : t.getDeadline()).append("\"")
                    .append("}");
            }
            json.append("]");
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain;charset=UTF-8");
        String action = req.getParameter("action");
        System.out.println("1. 요청 도착 - Action: " + action);

        try {
            Properties prop = loadDB();
            System.out.println("2. 설정 로드 완료: " + prop.getProperty("url"));

            try (Connection conn = DBConnection.getConnection()) {
            	conn.setAutoCommit(false);
                System.out.println("3. DB 연결 성공 여부: " + (conn != null));

                if ("save".equals(action)) {
                    TaskDTO t = new TaskDTO();
                    String projectIdStr = req.getParameter("projectId");
                    String assignee = req.getParameter("assignee");
                    System.out.println("4. 업무 등록 - projectId: " + projectIdStr + ", title: " + req.getParameter("title"));

                    if (assignee != null && !assignee.trim().isEmpty()) {
                        if (!dao.memberExists(conn, assignee.trim())) {
                            resp.getWriter().print("error:존재하지 않는 담당자 아이디입니다.");
                            return;
                        }
                        t.setAssignee(assignee.trim());
                    } else {
                        t.setAssignee(null);
                    }

                    t.setProjectId(Integer.parseInt(projectIdStr));
                    t.setTitle(req.getParameter("title"));
                    t.setContent(req.getParameter("content"));
                    t.setStatus(req.getParameter("status") != null && !req.getParameter("status").isEmpty()
                            ? req.getParameter("status") : "To Do");
                    t.setDeadline(req.getParameter("deadline"));
                    dao.insertTask(conn, t);
                    conn.commit();
                    System.out.println("5. 저장 완료");

                } else if ("update".equals(action)) {
                    System.out.println("4. 업무 수정 - id: " + req.getParameter("id"));
                    TaskDTO t = new TaskDTO();
                    t.setId(Integer.parseInt(req.getParameter("id")));
                    t.setProjectId(Integer.parseInt(req.getParameter("projectId") != null
                                    ? req.getParameter("projectId") : "0"));
                    t.setTitle(req.getParameter("title"));
                    t.setContent(req.getParameter("content"));
                    t.setAssignee(req.getParameter("assignee"));
                    t.setStatus(req.getParameter("status"));
                    t.setDeadline(req.getParameter("deadline"));
                    dao.updateTask(conn, t);
                    conn.commit();
                    System.out.println("5. 수정 완료");

                } else if ("delete".equals(action)) {
                    System.out.println("4. 업무 삭제 - id: " + req.getParameter("id"));
                    dao.deleteTask(conn, Integer.parseInt(req.getParameter("id")));
                    conn.commit();
                    System.out.println("5. 삭제 완료");
                }

                resp.getWriter().print("ok");
            }
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