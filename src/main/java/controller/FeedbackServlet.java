package controller;

import java.io.IOException;
import java.sql.Connection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.DBConnection;
import model.FeedbackDAO;
import model.FeedbackDTO;
import model.FeedbackCommentDTO;
import model.LoginDTO;

@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private FeedbackDAO dao = new FeedbackDAO();

    // ── 피드백 목록 / 상세 페이지 이동 ──
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String pidStr  = req.getParameter("projectId");

        if (pidStr == null || pidStr.isEmpty()) {
            resp.sendRedirect("projects.jsp");
            return;
        }

        int projectId = Integer.parseInt(pidStr);

        try (Connection conn = DBConnection.getConnection()) {
            String myRole = dao.getMemberRole(conn, loginUser.getId());
            boolean isMember = dao.isProjectMember(conn, projectId, loginUser.getId());

            // 프로젝트 멤버가 아니면 차단
            if (!isMember) {
                resp.sendRedirect("projects.jsp");
                return;
            }

            req.setAttribute("projectId", projectId);
            req.setAttribute("myRole", myRole);
            req.setAttribute("loginUser", loginUser);

            if ("view".equals(action)) {
                // 피드백 상세
                int feedbackId = Integer.parseInt(req.getParameter("id"));
                FeedbackDTO feedback = dao.getById(conn, feedbackId);
                if (feedback == null || feedback.getProjectId() != projectId) {
                    resp.sendRedirect("feedback?projectId=" + projectId);
                    return;
                }
                req.setAttribute("feedback", feedback);
                req.setAttribute("comments", dao.getComments(conn, feedbackId));
                req.getRequestDispatcher("feedbackView.jsp").forward(req, resp);

            } else {
                // 피드백 목록
                req.setAttribute("feedbackList", dao.getList(conn, projectId));
                req.getRequestDispatcher("feedback.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("projects.jsp");
        }
    }

    // ── 피드백 등록/수정/삭제, 댓글 등록/삭제 ──
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action    = req.getParameter("action");
        String pidStr    = req.getParameter("projectId");
        int projectId    = (pidStr != null && !pidStr.isEmpty()) ? Integer.parseInt(pidStr) : 0;
        String loginId   = loginUser.getId();

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            String myRole  = dao.getMemberRole(conn, loginId);
            boolean isMember = dao.isProjectMember(conn, projectId, loginId);

            if (!isMember) {
                resp.sendRedirect("projects.jsp");
                return;
            }

            // ── 피드백 등록 (교수만) ──
            if ("write".equals(action)) {
                if (!"professor".equals(myRole)) {
                    resp.sendRedirect("feedback?projectId=" + projectId);
                    return;
                }
                FeedbackDTO dto = new FeedbackDTO();
                dto.setProjectId(projectId);
                dto.setAuthorId(loginId);
                dto.setTitle(req.getParameter("title"));
                dto.setContent(req.getParameter("content"));
                dao.insert(conn, dto);
                conn.commit();
                resp.sendRedirect("feedback?projectId=" + projectId);

            // ── 피드백 수정 (교수 본인만) ──
            } else if ("update".equals(action)) {
                if (!"professor".equals(myRole)) {
                    resp.sendRedirect("feedback?projectId=" + projectId);
                    return;
                }
                FeedbackDTO dto = new FeedbackDTO();
                dto.setId(Integer.parseInt(req.getParameter("id")));
                dto.setAuthorId(loginId);
                dto.setTitle(req.getParameter("title"));
                dto.setContent(req.getParameter("content"));
                dao.update(conn, dto);
                conn.commit();
                resp.sendRedirect("feedback?action=view&projectId=" + projectId + "&id=" + dto.getId());

            // ── 피드백 삭제 (교수 본인만) ──
            } else if ("delete".equals(action)) {
                if (!"professor".equals(myRole)) {
                    resp.sendRedirect("feedback?projectId=" + projectId);
                    return;
                }
                int id = Integer.parseInt(req.getParameter("id"));
                dao.delete(conn, id, loginId);
                conn.commit();
                resp.sendRedirect("feedback?projectId=" + projectId);

            // ── 댓글 등록 (팀원/팀장) ──
            } else if ("comment".equals(action)) {
                int feedbackId = Integer.parseInt(req.getParameter("feedbackId"));
                FeedbackCommentDTO dto = new FeedbackCommentDTO();
                dto.setFeedbackId(feedbackId);
                dto.setAuthorId(loginId);
                dto.setContent(req.getParameter("content"));
                dao.insertComment(conn, dto);
                conn.commit();
                resp.sendRedirect("feedback?action=view&projectId=" + projectId + "&id=" + feedbackId);

            // ── 댓글 삭제 (작성자 본인만) ──
            } else if ("deleteComment".equals(action)) {
                int commentId  = Integer.parseInt(req.getParameter("commentId"));
                int feedbackId = Integer.parseInt(req.getParameter("feedbackId"));
                dao.deleteComment(conn, commentId, loginId);
                conn.commit();
                resp.sendRedirect("feedback?action=view&projectId=" + projectId + "&id=" + feedbackId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("feedback?projectId=" + projectId);
        }
    }
}
