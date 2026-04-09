package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

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
        dto.setTeam_leader(teamLeader); // 생성자를 팀장으로 설정

        ProjectDAO dao = new ProjectDAO();
        int projectId = dao.insert(dto);
        
        // 생성자를 자동으로 팀원에 추가
        if (projectId > 0 && teamLeader != null) {
            model.ProjectMemberDAO memberDAO = new model.ProjectMemberDAO();
            memberDAO.addMember(projectId, teamLeader);
        }

        response.sendRedirect("projects.jsp");
    }
}
