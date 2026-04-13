package controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.LoginDTO;
import model.MeetingMinutesDAO;
import model.MeetingMinutesDTO;
import model.ProjectDAO;
import model.ProjectDTO;
import model.ProjectMemberDAO;

@WebServlet("/meetingMinutes")
public class MeetingMinutesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String projectIdStr = request.getParameter("projectId");
        if (projectIdStr == null || projectIdStr.trim().isEmpty()) {
            response.sendRedirect("projects.jsp");
            return;
        }
        
        try {
            int projectId = Integer.parseInt(projectIdStr);
            
            // 권한 체크: 프로젝트 멤버인지 확인
            ProjectMemberDAO memberDAO = new ProjectMemberDAO();
            if (!memberDAO.isActiveMember(projectId, loginUser.getId())) {
                response.sendRedirect("projects.jsp?error=access_denied");
                return;
            }
            
            // 프로젝트 정보 조회
            ProjectDAO projectDAO = new ProjectDAO();
            ProjectDTO project = projectDAO.getById(projectId);
            
            if (project == null) {
                response.sendRedirect("projects.jsp");
                return;
            }
            
            // 회의록 목록 조회
            MeetingMinutesDAO minutesDAO = new MeetingMinutesDAO();
            List<MeetingMinutesDTO> minutesList = minutesDAO.getByProjectId(projectId);
            
            request.setAttribute("project", project);
            request.setAttribute("minutesList", minutesList);
            request.getRequestDispatcher("meetingMinutes.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("잘못된 프로젝트 ID 형식: " + projectIdStr);
            response.sendRedirect("projects.jsp?error=invalid_project");
        } catch (Exception e) {
            System.err.println("회의록 목록 조회 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
