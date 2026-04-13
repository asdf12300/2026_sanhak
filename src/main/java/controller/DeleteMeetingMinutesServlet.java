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
import model.ProjectMemberDAO;

@WebServlet("/deleteMeetingMinutes")
public class DeleteMeetingMinutesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
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
            
            MeetingMinutesDAO dao = new MeetingMinutesDAO();
            boolean success = dao.delete(id);
            
            if (success) {
                // iframe 안에서 실행되면 부모 창에 메시지 전송
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().println("<script>");
                response.getWriter().println("if (window.parent !== window) {");
                response.getWriter().println("    window.parent.postMessage('closeModal', '*');");
                response.getWriter().println("} else {");
                response.getWriter().println("    location.href='meetingMinutes?projectId=" + projectId + "';");
                response.getWriter().println("}");
                response.getWriter().println("</script>");
            } else {
                response.sendRedirect("meetingMinutes?projectId=" + projectId + "&error=delete_failed");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("잘못된 파라미터 형식: " + e.getMessage());
            response.sendRedirect("projects.jsp?error=invalid_parameter");
        } catch (Exception e) {
            System.err.println("회의록 삭제 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
