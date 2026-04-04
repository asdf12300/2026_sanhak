package controller;

import javax.servlet.*;
import javax.servlet.http.*;

import model.ProjectMemberDAO;
import model.ProjectMemberDTO;

import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet("/inviteMembers")
public class InviteMemberServlet extends HttpServlet {

    // POST: 팀원 초대 처리
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = model.DBConnection.getConnection();

            String memberId = request.getParameter("memberId");
            String projectId = request.getParameter("projectId");
            if (projectId == null) projectId = "1";

            if (memberId == null || memberId.trim().isEmpty()) {
                out.print("{\"success\":false,\"message\":\"memberId 없음\"}");
                return;
            }

            String[] memberIds = {memberId.trim()};

            String sql = "INSERT INTO project_member(project_id, member_id) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (String id : memberIds) {
                    ps.setInt(1, Integer.parseInt(projectId));
                    ps.setString(2, id.trim());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            response.sendRedirect(request.getContextPath() + "/teamInvite.jsp?projectId=" + projectId + "&successMsg=" + URLEncoder.encode("초대가 완료되었습니다.", "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        } finally {
            out.flush();
        }
    }

    // GET: 팀원 초대 페이지 표시
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String projectId = request.getParameter("projectId");
        if (projectId == null) projectId = "1";
        
        // invitationList 세팅
        ProjectMemberDAO dao = new ProjectMemberDAO();
        model.LoginDTO loginUser = (model.LoginDTO) request.getSession().getAttribute("loginUser");
        String loginId = (loginUser != null) ? loginUser.getId() : null;
        List<ProjectMemberDTO> invitationList = dao.getInvitationList(loginId);
        
        request.setAttribute("projectId", projectId);
        request.setAttribute("invitationList", invitationList);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/teamInvite.jsp");
        dispatcher.forward(request, response);
    }
}