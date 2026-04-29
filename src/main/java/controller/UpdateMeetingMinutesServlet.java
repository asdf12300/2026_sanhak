package controller;

import java.io.IOException;

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

@WebServlet("/updateMeetingMinutes")
public class UpdateMeetingMinutesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 교수는 회의록 수정 불가
        if ("professor".equals(loginUser.getRole())) {
            response.sendRedirect("projects.jsp?error=access_denied");
            return;
        }
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int projectId = Integer.parseInt(request.getParameter("projectId"));
            
            // 권한 체크: 프로젝트 멤버인지 확인
            ProjectMemberDAO memberDAO = new ProjectMemberDAO();
            if (!memberDAO.isActiveMember(projectId, loginUser.getId())) {
                response.sendRedirect("projects.jsp?error=access_denied");
                return;
            }
            
            String title = request.getParameter("title");
            String meetingDateStr = request.getParameter("meetingDate");
            String content = request.getParameter("content");
            
            // 입력값 검증
            if (title == null || title.trim().isEmpty()) {
                response.sendRedirect("meetingMinutesView?id=" + id + "&projectId=" + projectId + "&error=empty_title");
                return;
            }
            if (meetingDateStr == null || meetingDateStr.trim().isEmpty()) {
                response.sendRedirect("meetingMinutesView?id=" + id + "&projectId=" + projectId + "&error=empty_date");
                return;
            }
            if (content == null || content.trim().isEmpty()) {
                response.sendRedirect("meetingMinutesView?id=" + id + "&projectId=" + projectId + "&error=empty_content");
                return;
            }
            
            MeetingMinutesDTO minutes = new MeetingMinutesDTO();
            minutes.setId(id);
            minutes.setProjectId(projectId);
            minutes.setTitle(title.trim());
            minutes.setMeetingDate(meetingDateStr);
            minutes.setContent(content.trim());
            minutes.setLastModifiedBy(loginUser.getId());
            
            MeetingMinutesDAO dao = new MeetingMinutesDAO();
            boolean success = dao.update(minutes);
            
            if (success) {
                // iframe 안에서 실행되면 같은 페이지 새로고침
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().println("<script>");
                response.getWriter().println("location.href='meetingMinutesView?id=" + id + "&projectId=" + projectId + "';");
                response.getWriter().println("</script>");
            } else {
                response.sendRedirect("meetingMinutesView?id=" + id + "&projectId=" + projectId + "&error=update_failed");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("잘못된 파라미터 형식: " + e.getMessage());
            response.sendRedirect("projects.jsp?error=invalid_parameter");
        } catch (Exception e) {
            System.err.println("회의록 수정 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
