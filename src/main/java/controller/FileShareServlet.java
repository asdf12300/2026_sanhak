package controller;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.sql.Connection;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import model.DBConnection;
import model.FileShareDAO;
import model.FileShareDTO;
import model.LoginDTO;
import util.S3FileStorage;

@WebServlet("/fileShare")
@MultipartConfig(
    maxFileSize = 20 * 1024 * 1024,
    maxRequestSize = 25 * 1024 * 1024
)
public class FileShareServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final FileShareDAO dao = new FileShareDAO();
    private final S3FileStorage storage = new S3FileStorage();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        LoginDTO loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        int projectId = parseProjectId(req);
        if (projectId <= 0) {
            resp.sendRedirect("projects.jsp");
            return;
        }

        String action = req.getParameter("action");
        if ("download".equals(action)) {
            download(req, resp, loginUser, projectId);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (!dao.isProjectMember(conn, projectId, loginUser.getId())) {
                resp.sendRedirect("projects.jsp");
                return;
            }

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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        LoginDTO loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        int projectId = parseProjectId(req);
        if (projectId <= 0) {
            resp.sendRedirect("projects.jsp");
            return;
        }

        if ("professor".equals(loginUser.getRole())) {
            resp.sendRedirect("fileShare?projectID=" + projectId);
            return;
        }

        String action = req.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            if (!dao.isProjectMember(conn, projectId, loginUser.getId())) {
                resp.sendRedirect("projects.jsp");
                return;
            }

            if ("upload".equals(action)) {
                upload(req, projectId, loginUser, conn);
            } else if ("delete".equals(action)) {
                delete(req, loginUser, conn);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect("fileShare?projectID=" + projectId);
    }

    private void upload(HttpServletRequest req, int projectId, LoginDTO loginUser, Connection conn)
            throws Exception {
        Part filePart = req.getPart("file");
        if (filePart == null || filePart.getSize() == 0) return;

        String originalName = extractFileName(filePart);
        if (originalName.isEmpty()) return;

        String savedName = UUID.randomUUID().toString() + extensionOf(originalName);
        String s3Key = "projects/" + projectId + "/files/" + savedName;
        String contentType = filePart.getContentType();

        try (InputStream input = filePart.getInputStream()) {
            storage.upload(input, s3Key, contentType);
        }

        FileShareDTO dto = new FileShareDTO();
        dto.setProjectId(projectId);
        dto.setUploaderId(loginUser.getId());
        dto.setOriginalName(originalName);
        dto.setSavedName(savedName);
        dto.setFileSize(filePart.getSize());
        dto.setStorageType("s3");
        dto.setS3Bucket(storage.getBucket());
        dto.setS3Key(s3Key);
        dto.setContentType(contentType);

        conn.setAutoCommit(false);
        try {
            dao.insert(conn, dto);
            conn.commit();
        } catch (Exception e) {
            conn.rollback();
            try {
                storage.delete(s3Key);
            } catch (Exception cleanupError) {
                cleanupError.printStackTrace();
            }
            throw e;
        }
    }

    private void download(HttpServletRequest req, HttpServletResponse resp, LoginDTO loginUser, int projectId)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect("fileShare?projectID=" + projectId);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (!dao.isProjectMember(conn, projectId, loginUser.getId())) {
                resp.sendRedirect("projects.jsp");
                return;
            }

            FileShareDTO file = dao.getById(conn, Integer.parseInt(idStr));
            if (file == null || file.getProjectId() != projectId || file.getS3Key() == null) {
                resp.sendRedirect("fileShare?projectID=" + projectId);
                return;
            }

            String encoded = URLEncoder.encode(file.getOriginalName(), "UTF-8").replace("+", "%20");
            resp.setContentType(file.getContentType() != null ? file.getContentType() : "application/octet-stream");
            resp.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encoded);
            resp.setContentLengthLong(file.getFileSize());
            storage.download(file.getS3Key(), resp.getOutputStream());
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("fileShare?projectID=" + projectId);
        }
    }

    private void delete(HttpServletRequest req, LoginDTO loginUser, Connection conn) throws Exception {
        String id = req.getParameter("id");
        if (id == null || id.trim().isEmpty()) return;

        FileShareDTO file = dao.getById(conn, Integer.parseInt(id));
        if (file == null || !loginUser.getId().equals(file.getUploaderId())) return;

        conn.setAutoCommit(false);
        try {
            dao.delete(conn, file.getId(), loginUser.getId());
            conn.commit();
            if (file.getS3Key() != null && !file.getS3Key().trim().isEmpty()) {
                storage.delete(file.getS3Key());
            }
        } catch (Exception e) {
            conn.rollback();
            throw e;
        }
    }

    private LoginDTO getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return null;
        }
        return loginUser;
    }

    private int parseProjectId(HttpServletRequest req) {
        try {
            return Integer.parseInt(req.getParameter("projectID"));
        } catch (Exception e) {
            return 0;
        }
    }

    private String extractFileName(Part filePart) {
        String submitted = filePart.getSubmittedFileName();
        if (submitted == null) return "";
        return submitted.replace("\\", "/").substring(submitted.replace("\\", "/").lastIndexOf('/') + 1);
    }

    private String extensionOf(String fileName) {
        int dot = fileName.lastIndexOf('.');
        if (dot < 0 || dot == fileName.length() - 1) return "";
        return fileName.substring(dot);
    }
}
