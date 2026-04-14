package controller;

import java.io.*;
import java.sql.Connection;
import java.sql.Types;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.CalendarDAO;
import model.CalendarDTO;
import model.DBConnection;
import model.ProjectDAO;
import model.ProjectDTO;

@WebServlet("/writeProcess")
public class CreateProjectServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String deadline = request.getParameter("deadline");

        // 로그인한 사용자 정보 가져오기
        HttpSession session = request.getSession();
        model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
        String teamLeader = (loginUser != null) ? loginUser.getId() : null;

        ProjectDTO dto = new ProjectDTO();
        dto.setTitle(title);
        dto.setContent(content);
        dto.setDeadline(deadline);
        dto.setTeam_leader(teamLeader);

        ProjectDAO dao = new ProjectDAO();
        int projectId = dao.insert(dto);

        // 생성자를 자동으로 팀원에 추가
        if (projectId > 0 && teamLeader != null) {
            model.ProjectMemberDAO memberDAO = new model.ProjectMemberDAO();
            memberDAO.addMember(projectId, teamLeader);
        }

        // 마감일이 있으면 캘린더에 자동 등록
        if (projectId > 0 && deadline != null && !deadline.trim().isEmpty()) {
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                CalendarDTO cal = new CalendarDTO();
                cal.setProjectId(projectId);
                cal.setTitle("[마감] " + title);
                cal.setDate(deadline.trim());
                cal.setCategory(1); // 중요(빨간색)
                cal.setMemo("프로젝트 마감일");
                new CalendarDAO().insertEvent(conn, cal);
                conn.commit();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("projects.jsp");
    }
}
