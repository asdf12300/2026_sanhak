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
import model.ProjectMemberDAO;

@WebServlet("/meetingMinutesView")
public class MeetingMinutesViewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String projectId = request.getParameter("projectId");
            
            MeetingMinutesDAO dao = new MeetingMinutesDAO();
            MeetingMinutesDTO minutes = dao.getById(id);
            
            if (minutes == null) {
                response.sendRedirect("meetingMinutes?projectId=" + projectId + "&error=not_found");
                return;
            }
            
            // 권한 체크: 프로젝트 멤버인지 확인
            ProjectMemberDAO memberDAO = new ProjectMemberDAO();
            if (!memberDAO.isActiveMember(minutes.getProjectId(), loginUser.getId())) {
                response.sendRedirect("projects.jsp?error=access_denied");
                return;
            }
            
            // 수정 이력 조회
            List<MeetingMinutesDTO> history = dao.getHistory(id);
            
            request.setAttribute("minutes", minutes);
            request.setAttribute("history", history);
            request.setAttribute("projectId", projectId);
            request.getRequestDispatcher("meetingMinutesView.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("잘못된 파라미터 형식: " + e.getMessage());
            response.sendRedirect("projects.jsp?error=invalid_parameter");
        } catch (Exception e) {
            System.err.println("회의록 상세 조회 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
