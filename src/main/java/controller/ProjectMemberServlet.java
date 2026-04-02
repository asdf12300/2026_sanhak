package controller;

import model.ProjectMemberDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/projectMember")
public class ProjectMemberServlet extends HttpServlet {

    private final ProjectMemberDAO dao = new ProjectMemberDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String action       = req.getParameter("action");
        String projectIdStr = req.getParameter("projectId");
        String memberId     = req.getParameter("memberId");

        if (projectIdStr == null || memberId == null || action == null) {
            resp.sendRedirect("list");
            return;
        }

        int projectId = Integer.parseInt(projectIdStr);
        String msg;

        if ("add".equals(action)) {
            if (!dao.memberExists(memberId)) {
                msg = "존재하지 않는 아이디입니다.";
            } else if (dao.isMember(projectId, memberId)) {
                msg = "이미 팀원으로 등록된 사용자입니다.";
            } else {
                dao.addMember(projectId, memberId);
                msg = memberId + " 님을 팀원으로 추가했습니다.";
            }
        } else if ("remove".equals(action)) {
            dao.removeMember(projectId, memberId);
            msg = memberId + " 님을 팀에서 제외했습니다.";
        } else {
            msg = "잘못된 요청입니다.";
        }

        resp.sendRedirect("view?id=" + projectId + "&msg=" + URLEncoder.encode(msg, "UTF-8"));
    }
}
