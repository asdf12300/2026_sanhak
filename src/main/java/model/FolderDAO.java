package model;

import java.sql.*;
import java.util.*;

public class FolderDAO {

    // 폴더 목록 가져오기
    public List<FolderDTO> getFoldersByUser(String userId) {
        List<FolderDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM folder WHERE owner_id = ? ORDER BY created_at ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                FolderDTO dto = new FolderDTO();
                dto.setId(rs.getInt("id"));
                dto.setName(rs.getString("name"));
                dto.setOwnerId(rs.getString("owner_id"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 폴더 생성
    public void createFolder(String name, String userId) {
        String sql = "INSERT INTO folder (name, owner_id) VALUES (?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, userId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 폴더 삭제
    public void deleteFolder(int folderId) {
        String sql = "DELETE FROM folder WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, folderId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 프로젝트를 폴더에 넣기
    public void assignProjectToFolder(int projectId, int folderId) {
        String sql = "UPDATE board SET folder_id = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, folderId);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 프로젝트를 폴더에서 꺼내기
    public void removeProjectFromFolder(int projectId) {
        String sql = "UPDATE board SET folder_id = NULL WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}