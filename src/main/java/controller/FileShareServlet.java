package controller;

import java.io.*;
import java.net.URLEncoder;
import java.nio.file.*;
import java.sql.Connection;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.DBConnection;
import model.FileShareDAO;
import model.FileShareDTO;
import model.LoginDTO;

@WebServlet("/fileShare")
@MultipartConfig(
    maxFileSize    = 20 * 1024 * 1024,   // 파일 1개 최대 20MB
    maxRequestSize = 25 * 1024 * 1024    // 요청 전체 최대 25MB
)
public class FileShareServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/fileshare";
    private FileShareDAO dao = new FileShareDAO();

    /** 실제 저장 경로 반환 */
    // 현재 (로컬 테스트용)
    private String getUploadPath() {
        return getServletContext().getRealPath("/") + UPLOAD_DIR;
    }
    
    /*
    // 배포용
    private String getUploadPath() {
        return "/home/ec2-user/uploads/fileshare"; // 서버 절대경로
    }
    */

    // ── 목록 조회 ──
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action  = req.getParameter("action");
        String pidStr  = req.getParameter("projectId");
        if (pidStr == null || pidStr.isEmpty()) {
            resp.sendRedirect("projects.jsp");
            return;
        }
        int projectId = Integer.parseInt(pidStr);

        // 다운로드
        if ("download".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr == null) { resp.sendRedirect("fileShare?projectId=" + projectId); return; }
            try (Connection conn = DBConnection.getConnection()) {
                FileShareDTO file = dao.getById(conn, Integer.parseInt(idStr));
                if (file == null || file.getProjectId() != projectId) {
                    resp.sendRedirect("fileShare?projectId=" + projectId);
                    return;
                }
                File f = new File(getUploadPath(), file.getSavedName());
                if (!f.exists()) {
                    resp.sendRedirect("fileShare?projectId=" + projectId);
                    return;
                }
                String encoded = URLEncoder.encode(file.getOriginalName(), "UTF-8").replace("+", "%20");
                resp.setContentType("application/octet-stream");
                resp.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encoded);
                resp.setContentLengthLong(f.length());
                Files.copy(f.toPath(), resp.getOutputStream());
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("fileShare?projectId=" + projectId);
            }
            return;
        }

        // 목록
        try (Connection conn = DBConnection.getConnection()) {
            boolean isMember = dao.isProjectMember(conn, projectId, loginUser.getId());
            if (!isMember) { resp.sendRedirect("projects.jsp"); return; }

            req.setAttribute("fileList", dao.getList(conn, projectId));
            req.setAttribute("projectId", projectId);
            req.setAttribute("loginUser", loginUser);
            req.setAttribute("isProfessor", "professor".equals(loginUser.getRole()));
            req.getRequestDispatcher("fileShare.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("projects.jsp");
        }
    }

    // ── 업로드 / 삭제 ──
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        if (loginUser == null) { resp.sendRedirect("login.jsp"); return; }

        // 교수는 업로드/삭제 불가
        if ("professor".equals(loginUser.getRole())) {
            resp.sendRedirect("fileShare?projectId=" + req.getParameter("projectId"));
            return;
        }

        String action = req.getParameter("action");
        String pidStr = req.getParameter("projectId");
        int projectId = (pidStr != null && !pidStr.isEmpty()) ? Integer.parseInt(pidStr) : 0;

        try (Connection conn = DBConnection.getConnection()) {
            boolean isMember = dao.isProjectMember(conn, projectId, loginUser.getId());
            if (!isMember) { resp.sendRedirect("projects.jsp"); return; }

            if ("upload".equals(action)) {
                Part filePart = req.getPart("file");
                if (filePart == null || filePart.getSize() == 0) {
                    resp.sendRedirect("fileShare?projectId=" + projectId);
                    return;
                }

                String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String ext = originalName.contains(".")
                    ? originalName.substring(originalName.lastIndexOf('.'))
                    : "";
                String savedName = UUID.randomUUID().toString() + ext;

                // 저장 디렉토리 생성
                File uploadDir = new File(getUploadPath());
                if (!uploadDir.exists()) uploadDir.mkdirs();

                File dest = new File(uploadDir, savedName);
                filePart.write(dest.getAbsolutePath());

                FileShareDTO dto = new FileShareDTO();
                dto.setProjectId(projectId);
                dto.setUploaderId(loginUser.getId());
                dto.setOriginalName(originalName);
                dto.setSavedName(savedName);
                dto.setFileSize(filePart.getSize());

                conn.setAutoCommit(false);
                dao.insert(conn, dto);
                conn.commit();

            } else if ("delete".equals(action)) {
                int fileId = Integer.parseInt(req.getParameter("id"));
                conn.setAutoCommit(false);
                FileShareDTO file = dao.getById(conn, fileId);
                if (file != null && file.getUploaderId().equals(loginUser.getId())) {
                    // 실제 파일 삭제
                    File f = new File(getUploadPath(), file.getSavedName());
                    if (f.exists()) f.delete();
                    dao.delete(conn, fileId, loginUser.getId());
                }
                conn.commit();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect("fileShare?projectId=" + projectId);
    }
}
