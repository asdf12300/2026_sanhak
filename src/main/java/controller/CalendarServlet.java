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

import model.CalendarDAO;
import model.CalendarDTO;
import util.DBUtil;

@WebServlet("/event")
public class CalendarServlet extends HttpServlet {

    private CalendarDAO dao = new CalendarDAO();

    // WEB-INF에서 properties 읽기
    private Properties loadDB() throws Exception {
        Properties prop = new Properties();
        InputStream input = getServletContext().getResourceAsStream("/WEB-INF/classes/db.properties");

        if (input == null) {
            throw new RuntimeException("설정 파일을 찾을 수 없습니다: /WEB-INF/classes/db.properties 경로를 확인하세요.");
        }

        prop.load(input);
        input.close(); 
        return prop;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("list".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();

            try (Connection conn = DBUtil.getConnection(loadDB())) {
                List<CalendarDTO> list = dao.getAllEvents(conn);

                StringBuilder json = new StringBuilder();
                json.append("[");
                boolean first = true;
                for (CalendarDTO e : list) {
                    if (!first) json.append(",");
                    first = false;

                    String title = e.getTitle() == null ? "" :
                            e.getTitle().replace("\\", "\\\\").replace("\"", "\\\"");
                    String memo = e.getMemo() == null ? "" :
                            e.getMemo().replace("\\", "\\\\").replace("\"", "\\\"");

                    json.append("{");
                    json.append("\"id\":").append(e.getId()).append(",");
                    json.append("\"title\":\"").append(title).append("\",");
                    json.append("\"date\":\"").append(e.getDate()).append("\",");
                    json.append("\"time\":\"").append(e.getTime() == null ? "" : e.getTime()).append("\",");
                    json.append("\"cat\":").append(e.getCategory()).append(",");
                    json.append("\"memo\":\"").append(memo).append("\"");
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
        
        System.out.println("1. 요청 도착 - Action: " + action);
        
        try {
            // 1. DB 설정 로드
            Properties prop = loadDB();
            System.out.println("2. 설정 로드 완료: " + prop.getProperty("db.url"));
            
            // 2. DB 연결 (try-with-resources로 자동 close)
            try (Connection conn = DBUtil.getConnection(prop)) {
                System.out.println("3. DB 연결 성공 여부: " + (conn != null));
                
                // 등록
                if ("save".equals(action)) {
                    CalendarDTO e = new CalendarDTO();
                    e.setTitle(req.getParameter("title"));
                    e.setDate(req.getParameter("date"));
                    e.setTime(req.getParameter("time"));
                    e.setCategory(Integer.parseInt(req.getParameter("cat")));
                    e.setMemo(req.getParameter("memo"));
                    
                    System.out.println("4. 등록 DAO 호출 직전");
                    dao.insertEvent(conn, e);
                    conn.commit();
                    System.out.println("5. 저장 및 커밋 완료");
                } 
                // 수정
                else if ("update".equals(action)) {
                    CalendarDTO e = new CalendarDTO();
                    e.setId(Integer.parseInt(req.getParameter("id")));
                    e.setTitle(req.getParameter("title"));
                    e.setDate(req.getParameter("date"));
                    e.setTime(req.getParameter("time"));
                    e.setCategory(Integer.parseInt(req.getParameter("cat")));
                    e.setMemo(req.getParameter("memo"));

                    dao.updateEvent(conn, e);
                    conn.commit();
                    System.out.println("5. 수정 및 커밋 완료");
                } 
                // 삭제
                else if ("delete".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.deleteEvent(conn, id);
                    conn.commit();
                    System.out.println("5. 삭제 및 커밋 완료");
                }

                resp.getWriter().print("ok");
            } // Connection 종료
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("error");
        }
    }
}