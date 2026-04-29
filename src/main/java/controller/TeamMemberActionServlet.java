package controller;

import model.LoginDTO;
import model.ProjectMemberDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import model.ProjectDAO;
import model.ProjectDTO;

@WebServlet("/teamMemberAction")
public class TeamMemberActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ProjectMemberDAO dao = new ProjectMemberDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String projectIdStr = request.getParameter("projectId");
        String memberId = request.getParameter("memberId");
        String pmNoStr = request.getParameter("pmNo");

        int projectId = 0;
        if (projectIdStr != null && !projectIdStr.trim().isEmpty()) {
            projectId = Integer.parseInt(projectIdStr);
        }

        String loginId = null;
        if (request.getSession().getAttribute("id") != null) {
            loginId = (String) request.getSession().getAttribute("id");
        } else if (request.getSession().getAttribute("loginUser") != null) {
            LoginDTO loginUser = (LoginDTO) request.getSession().getAttribute("loginUser");
            if (loginUser != null) {
                loginId = loginUser.getId();
            }
        }

        String msg = "";
        ProjectDAO projectDao = new ProjectDAO();
        ProjectDTO project = projectDao.getById(projectId);

        String teamLeaderId = null;
        if (project != null) {
            teamLeaderId = project.getTeam_leader();
        }
        if (("remove".equals(action) || "setLeader".equals(action))
                && (teamLeaderId == null || !teamLeaderId.equals(loginId))) {
            msg = "팀장만 사용할 수 있는 기능입니다.";
            response.sendRedirect("teamMemberManage.jsp?projectId=" + projectId + "&msg=" + URLEncoder.encode(msg, "UTF-8"));
            return;
        }

        if ("invite".equals(action)) {
            if (!dao.memberExists(memberId)) {
                msg = "존재하지 않는 아이디입니다.";
            } else if (dao.isMember(projectId, memberId)) {
                msg = "이미 초대되었거나 팀원으로 등록된 사용자입니다.";
            } else {
                // 학생만 팀원 초대 가능
                String targetRole = dao.getMemberRole(memberId);
                if (!"student".equals(targetRole)) {
                    msg = "학생 계정만 팀원으로 초대할 수 있습니다. 교수 초대는 아래 교수 초대 항목을 이용하세요.";
                } else {
                    boolean result = dao.inviteMember(projectId, memberId, "팀원");
                    msg = result ? "팀원 초대가 완료되었습니다." : "팀원 초대에 실패했습니다.";
                }
            }

        } else if ("inviteProfessor".equals(action)) {
            // 팀장만 교수 초대 가능
            String profMsg = "";
            if (teamLeaderId == null || !teamLeaderId.equals(loginId)) {
                profMsg = "팀장만 교수를 초대할 수 있습니다.";
            } else if (!dao.memberExists(memberId)) {
                profMsg = "존재하지 않는 아이디입니다.";
            } else if (dao.isMember(projectId, memberId)) {
                profMsg = "이미 초대되었거나 등록된 사용자입니다.";
            } else {
                String targetRole = dao.getMemberRole(memberId);
                if (!"professor".equals(targetRole)) {
                    profMsg = "교수 계정만 초대할 수 있습니다.";
                } else {
                    boolean result = dao.inviteMember(projectId, memberId, "교수");
                    profMsg = result ? "교수 초대가 완료되었습니다." : "교수 초대에 실패했습니다.";
                }
            }
            response.sendRedirect("teamMemberManage.jsp?projectId=" + projectId + "&profMsg=" + URLEncoder.encode(profMsg, "UTF-8"));
            return;
        } else if ("accept".equals(action)) {
            int pmNo = Integer.parseInt(pmNoStr);
            boolean result = dao.updateInvitationStatus(pmNo, loginId, "accepted");
            msg = result ? "초대를 수락했습니다." : "초대 수락에 실패했습니다.";
            response.sendRedirect("projects.jsp");
            return;

        } else if ("reject".equals(action)) {
            int pmNo = Integer.parseInt(pmNoStr);
            boolean result = dao.updateInvitationStatus(pmNo, loginId, "rejected");
            msg = result ? "초대를 거절했습니다." : "초대 거절에 실패했습니다.";
            response.sendRedirect("projects.jsp");
            return;

        } else if ("remove".equals(action)) {
            boolean result = dao.removeMember(projectId, memberId);
            msg = result ? "팀원을 제외했습니다." : "팀원 제외에 실패했습니다.";

        } else if ("removeProfessor".equals(action)) {
            String profMsg = "";
            boolean result = dao.removeMember(projectId, memberId);
            profMsg = result ? "교수를 제외했습니다." : "교수 제외에 실패했습니다.";
            response.sendRedirect("teamMemberManage.jsp?projectId=" + projectId + "&profMsg=" + URLEncoder.encode(profMsg, "UTF-8"));
            return;

        } else if ("setLeader".equals(action)) {
            boolean result = dao.setLeader(projectId, memberId);
            msg = result ? "팀장을 지정했습니다." : "팀장 지정에 실패했습니다.";

        } else {
            msg = "잘못된 요청입니다.";
        }

        //response.sendRedirect("teamMemberManage?projectId=" + projectId + "&msg=" + URLEncoder.encode(msg, "UTF-8"));
        response.sendRedirect("teamMemberManage.jsp?projectId=" + projectId + "&msg=" + URLEncoder.encode(msg, "UTF-8"));
    }
}