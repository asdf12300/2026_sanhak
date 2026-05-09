package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FileShareDAO {

    /** 파일 목록 조회 (프로젝트별, 최신순) */
    public List<FileShareDTO> getList(Connection conn, int projectId) throws Exception {
        List<FileShareDTO> list = new ArrayList<>();
        String sql = "SELECT f.id, f.project_id, f.uploader_id, m.name AS uploader_name, " +
                     "f.original_name, f.saved_name, f.file_size, f.storage_type, " +
                     "f.s3_bucket, f.s3_key, f.content_type, " +
                     "DATE_FORMAT(f.created_at, '%Y-%m-%d %H:%i') AS created_at " +
                     "FROM file_share f " +
                     "LEFT JOIN member m ON f.uploader_id = m.id " +
                     "WHERE f.project_id = ? " +
                     "ORDER BY f.created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FileShareDTO dto = new FileShareDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setUploaderId(rs.getString("uploader_id"));
                    dto.setUploaderName(rs.getString("uploader_name"));
                    dto.setOriginalName(rs.getString("original_name"));
                    dto.setSavedName(rs.getString("saved_name"));
                    dto.setFileSize(rs.getLong("file_size"));
                    dto.setStorageType(rs.getString("storage_type"));
                    dto.setS3Bucket(rs.getString("s3_bucket"));
                    dto.setS3Key(rs.getString("s3_key"));
                    dto.setContentType(rs.getString("content_type"));
                    dto.setCreatedAt(rs.getString("created_at"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    /** 파일 단건 조회 (다운로드용) */
    public FileShareDTO getById(Connection conn, int id) throws Exception {
        String sql = "SELECT f.id, f.project_id, f.uploader_id, m.name AS uploader_name, " +
                     "f.original_name, f.saved_name, f.file_size, f.storage_type, " +
                     "f.s3_bucket, f.s3_key, f.content_type, " +
                     "DATE_FORMAT(f.created_at, '%Y-%m-%d %H:%i') AS created_at " +
                     "FROM file_share f " +
                     "LEFT JOIN member m ON f.uploader_id = m.id " +
                     "WHERE f.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FileShareDTO dto = new FileShareDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setUploaderId(rs.getString("uploader_id"));
                    dto.setUploaderName(rs.getString("uploader_name"));
                    dto.setOriginalName(rs.getString("original_name"));
                    dto.setSavedName(rs.getString("saved_name"));
                    dto.setFileSize(rs.getLong("file_size"));
                    dto.setStorageType(rs.getString("storage_type"));
                    dto.setS3Bucket(rs.getString("s3_bucket"));
                    dto.setS3Key(rs.getString("s3_key"));
                    dto.setContentType(rs.getString("content_type"));
                    dto.setCreatedAt(rs.getString("created_at"));
                    return dto;
                }
            }
        }
        return null;
    }

    /** 파일 등록 */
    public void insert(Connection conn, FileShareDTO dto) throws Exception {
        String sql = "INSERT INTO file_share " +
                     "(project_id, uploader_id, original_name, saved_name, file_size, storage_type, s3_bucket, s3_key, content_type) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dto.getProjectId());
            ps.setString(2, dto.getUploaderId());
            ps.setString(3, dto.getOriginalName());
            ps.setString(4, dto.getSavedName());
            ps.setLong(5, dto.getFileSize());
            ps.setString(6, dto.getStorageType());
            ps.setString(7, dto.getS3Bucket());
            ps.setString(8, dto.getS3Key());
            ps.setString(9, dto.getContentType());
            ps.executeUpdate();
        }
    }

    /** 파일 삭제 (업로더 본인만, 교수는 불가) */
    public boolean delete(Connection conn, int id, String uploaderId) throws Exception {
        String sql = "DELETE FROM file_share WHERE id = ? AND uploader_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, uploaderId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 프로젝트 멤버 여부 확인 */
    public boolean isProjectMember(Connection conn, int projectId, String memberId) throws Exception {
        String sql = "SELECT id FROM project_member WHERE project_id = ? AND member_id = ? AND status = 'accepted'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setString(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
