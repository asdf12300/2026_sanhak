package controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

import model.LoginDTO;
import model.ProjectMemberDAO;
import model.ProjectMemberDTO;

@WebServlet("/inviteMembers")
public class InviteMemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ProjectMemberDAO dao = new ProjectMemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type");

        // 받은 초대 목록
        if ("received".equals(type)) {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("loginUser") == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
            String loginId = loginUser.getId();

            List<ProjectMemberDTO> invitationList = dao.getInvitationList(loginId);
            request.setAttribute("invitationList", invitationList);

            request.getRequestDispatcher("/projectMember.jsp").forward(request, response);
            return;
        }

        // 팀원 초대 화면
        int projectId = 1;
        String projectIdParam = request.getParameter("projectId");

        if (projectIdParam != null && !projectIdParam.trim().isEmpty()) {
            projectId = Integer.parseInt(projectIdParam);
        }

        List<ProjectMemberDTO> memberList = dao.getMembersByProject(projectId);

        request.setAttribute("projectId", projectId);
        request.setAttribute("memberList", memberList);

        request.getRequestDispatcher("/teamInvite.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // 수락 / 거절 / 삭제
        if ("accept".equals(action) || "reject".equals(action) || "delete".equals(action)) {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("loginUser") == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
            String loginId = loginUser.getId();

            int pmNo = Integer.parseInt(request.getParameter("pmNo"));

            if ("accept".equals(action)) {
                dao.acceptInvitation(pmNo, loginId);
            } else if ("reject".equals(action)) {
                dao.rejectInvitation(pmNo, loginId);
            } else if ("delete".equals(action)) {
                dao.deleteInvitation(pmNo, loginId);
            }

            response.sendRedirect(request.getContextPath() + "/inviteMembers?type=received");
            return;
        }

        // 팀원 초대 처리
        int projectId = 1;
        String projectIdStr = request.getParameter("projectId");
        if (projectIdStr != null && !projectIdStr.trim().isEmpty()) {
            projectId = Integer.parseInt(projectIdStr);
        }

        try {
            String memberId = request.getParameter("memberId");

            if (memberId == null || memberId.trim().isEmpty()) {
                request.setAttribute("errorMsg", "초대할 회원 ID를 입력하세요.");
            } else if (!dao.memberExists(memberId.trim())) {
                request.setAttribute("errorMsg", "존재하지 않는 회원 ID입니다.");
            } else if (dao.isMember(projectId, memberId.trim())) {
                request.setAttribute("errorMsg", "이미 초대되었거나 팀원으로 등록된 회원입니다.");
            } else {
                boolean result = dao.addMember(projectId, memberId.trim());

                if (result) {
                    request.setAttribute("successMsg", "팀원 초대가 완료되었습니다.");
                } else {
                    request.setAttribute("errorMsg", "팀원 초대에 실패했습니다.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "오류 발생: " + e.getMessage());
        }

        List<ProjectMemberDTO> memberList = dao.getMembersByProject(projectId);
        request.setAttribute("projectId", projectId);
        request.setAttribute("memberList", memberList);

        request.getRequestDispatcher("/teamInvite.jsp").forward(request, response);
    }
}