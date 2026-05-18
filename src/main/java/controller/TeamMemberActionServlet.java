package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import model.ChatDAO;
import model.LoginDTO;
import model.ProjectDAO;
import model.ProjectDTO;
import model.ProjectMemberDAO;

@WebServlet("/teamMemberAction")
public class TeamMemberActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ProjectMemberDAO dao = new ProjectMemberDAO();
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String projectIdStr = request.getParameter("projectID");
        String memberId = request.getParameter("memberId");
        String pmNoStr = request.getParameter("pmNo");

        int projectId = parseInt(projectIdStr);
        String loginId = getLoginId(request);

        String msg = "";
        ProjectDTO project = new ProjectDAO().getById(projectId);
        String teamLeaderId = project != null ? project.getTeam_leader() : null;

        if (("remove".equals(action) || "setLeader".equals(action))
                && (teamLeaderId == null || !teamLeaderId.equals(loginId))) {
            msg = "팀장만 사용할 수 있는 기능입니다.";
            redirect(response, "teamMemberManage.jsp", projectId, "msg", msg);
            return;
        }

        if ("invite".equals(action)) {
            msg = inviteStudent(projectId, memberId);

        } else if ("inviteProfessor".equals(action)) {
            String profMsg = inviteProfessor(projectId, memberId, teamLeaderId, loginId);
            redirect(response, "teamMemberManage.jsp", projectId, "profMsg", profMsg);
            return;

        } else if ("accept".equals(action)) {
            handleAccept(response, pmNoStr, loginId);
            return;

        } else if ("reject".equals(action)) {
            handleReject(response, pmNoStr, loginId);
            return;

        } else if ("remove".equals(action)) {
            boolean result = dao.removeMember(projectId, memberId);
            msg = result ? "팀원을 제외했습니다." : "팀원 제외에 실패했습니다.";

        } else if ("removeProfessor".equals(action)) {
            boolean result = dao.removeMember(projectId, memberId);
            String profMsg = result ? "교수를 제외했습니다." : "교수 제외에 실패했습니다.";
            redirect(response, "teamMemberManage.jsp", projectId, "profMsg", profMsg);
            return;

        } else if ("setLeader".equals(action)) {
            boolean result = dao.setLeader(projectId, memberId);
            msg = result ? "팀장을 지정했습니다." : "팀장 지정에 실패했습니다.";

        } else {
            msg = "잘못된 요청입니다.";
        }

        redirect(response, "teamMemberManage.jsp", projectId, "msg", msg);
    }

    private String inviteStudent(int projectId, String memberId) {
        if (!dao.memberExists(memberId)) {
            return "존재하지 않는 아이디입니다.";
        }
        if (dao.isMember(projectId, memberId)) {
            return "이미 초대되었거나 팀원으로 등록된 사용자입니다.";
        }

        String targetRole = dao.getMemberRole(memberId);
        if (!"student".equals(targetRole)) {
            return "학생 계정만 팀원으로 초대할 수 있습니다. 교수 초대는 아래 교수 초대 항목을 이용하세요.";
        }

        boolean result = dao.inviteMember(projectId, memberId, "팀원");
        return result ? "팀원 초대가 완료되었습니다." : "팀원 초대에 실패했습니다.";
    }

    private String inviteProfessor(int projectId, String memberId, String teamLeaderId, String loginId) {
        if (teamLeaderId == null || !teamLeaderId.equals(loginId)) {
            return "팀장만 교수를 초대할 수 있습니다.";
        }
        if (!dao.memberExists(memberId)) {
            return "존재하지 않는 아이디입니다.";
        }
        if (dao.isMember(projectId, memberId)) {
            return "이미 초대되었거나 등록된 사용자입니다.";
        }

        String targetRole = dao.getMemberRole(memberId);
        if (!"professor".equals(targetRole)) {
            return "교수 계정만 초대할 수 있습니다.";
        }

        boolean result = dao.inviteMember(projectId, memberId, "교수");
        return result ? "교수 초대가 완료되었습니다." : "교수 초대에 실패했습니다.";
    }

    private void handleAccept(HttpServletResponse response, String pmNoStr, String loginId) throws IOException {
        int pmNo = parseInt(pmNoStr);
        int targetProjectId = dao.getInvitedProjectId(pmNo, loginId);

        System.out.println("[TeamMemberAction] accept: loginId=" + loginId
                + ", pmNo=" + pmNo + ", projectId=" + targetProjectId);

        boolean result = targetProjectId > 0 && dao.updateInvitationStatus(pmNo, loginId, "accepted");
        String myRole = dao.getMemberRole(loginId);

        if (result && !"professor".equals(myRole)) {
            List<Integer> teamRoomIds = chatDAO.getTeamChatRoomIds(targetProjectId);
            for (int roomId : teamRoomIds) {
                chatDAO.addRoomMember(roomId, loginId);
            }
            System.out.println("[TeamMemberAction] " + loginId + " -> "
                    + teamRoomIds.size() + " team chat rooms auto-added (projectId="
                    + targetProjectId + ")");
        }

        response.sendRedirect("professor".equals(myRole) ? "professorProject.jsp" : "projects.jsp");
    }

    private void handleReject(HttpServletResponse response, String pmNoStr, String loginId) throws IOException {
        int pmNo = parseInt(pmNoStr);
        int targetProjectId = dao.getInvitedProjectId(pmNo, loginId);
        boolean result = targetProjectId > 0 && dao.updateInvitationStatus(pmNo, loginId, "rejected");

        System.out.println("[TeamMemberAction] reject: loginId=" + loginId
                + ", pmNo=" + pmNo + ", projectId=" + targetProjectId
                + ", result=" + result);

        String myRole = dao.getMemberRole(loginId);
        response.sendRedirect("professor".equals(myRole) ? "professorProject.jsp" : "projects.jsp");
    }

    private String getLoginId(HttpServletRequest request) {
        Object legacyId = request.getSession().getAttribute("id");
        if (legacyId instanceof String) {
            return (String) legacyId;
        }

        Object loginUserAttr = request.getSession().getAttribute("loginUser");
        if (loginUserAttr instanceof LoginDTO) {
            return ((LoginDTO) loginUserAttr).getId();
        }

        return null;
    }

    private int parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void redirect(HttpServletResponse response, String target, int projectId, String key, String msg)
            throws IOException {
        response.sendRedirect(target + "?projectID=" + projectId
                + "&" + key + "=" + URLEncoder.encode(msg, "UTF-8"));
    }
}
