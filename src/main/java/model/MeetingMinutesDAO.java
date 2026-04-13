package model;

import java.sql.*;
import java.util.*;

public class MeetingMinutesDAO {

    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    // 프로젝트별 회의록 목록 조회
    public List<MeetingMinutesDTO> getByProjectId(int projectId) {
        return getListByProject(projectId);
    }

    // 프로젝트별 회의록 목록 조회
    public List<MeetingMinutesDTO> getListByProject(int projectId) {
        List<MeetingMinutesDTO> list = new ArrayList<>();
        
        String sql = 
            "SELECT mm.*, " +
            "m1.name as created_by_name, " +
            "m2.name as last_modified_by_name " +
            "FROM meeting_minutes mm " +
            "LEFT JOIN member m1 ON mm.created_by = m1.id " +
            "LEFT JOIN member m2 ON mm.last_modified_by = m2.id " +
            "WHERE mm.project_id = ? " +
            "ORDER BY mm.meeting_date DESC, mm.created_at DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, projectId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MeetingMinutesDTO dto = new MeetingMinutesDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setTitle(rs.getString("title"));
                    dto.setMeetingDate(rs.getString("meeting_date"));
                    dto.setContent(rs.getString("content"));
                    dto.setCreatedBy(rs.getString("created_by"));
                    dto.setCreatedAt(rs.getTimestamp("created_at"));
                    dto.setLastModifiedBy(rs.getString("last_modified_by"));
                    dto.setLastModifiedAt(rs.getTimestamp("last_modified_at"));
                    dto.setCreatedByName(rs.getString("created_by_name"));
                    dto.setLastModifiedByName(rs.getString("last_modified_by_name"));
                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            System.err.println("회의록 목록 조회 중 DB 오류 발생: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("회의록 목록 조회 중 예상치 못한 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
        
        return list;
    }

    // 회의록 상세 조회
    public MeetingMinutesDTO getById(int id) {
        String sql = 
            "SELECT mm.*, " +
            "m1.name as created_by_name, " +
            "m2.name as last_modified_by_name " +
            "FROM meeting_minutes mm " +
            "LEFT JOIN member m1 ON mm.created_by = m1.id " +
            "LEFT JOIN member m2 ON mm.last_modified_by = m2.id " +
            "WHERE mm.id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MeetingMinutesDTO dto = new MeetingMinutesDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setProjectId(rs.getInt("project_id"));
                    dto.setTitle(rs.getString("title"));
                    dto.setMeetingDate(rs.getString("meeting_date"));
                    dto.setContent(rs.getString("content"));
                    dto.setCreatedBy(rs.getString("created_by"));
                    dto.setCreatedAt(rs.getTimestamp("created_at"));
                    dto.setLastModifiedBy(rs.getString("last_modified_by"));
                    dto.setLastModifiedAt(rs.getTimestamp("last_modified_at"));
                    dto.setCreatedByName(rs.getString("created_by_name"));
                    dto.setLastModifiedByName(rs.getString("last_modified_by_name"));
                    return dto;
                }
            }
        } catch (SQLException e) {
            System.err.println("회의록 상세 조회 중 DB 오류 발생 (ID: " + id + "): " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("회의록 상세 조회 중 예상치 못한 오류 발생 (ID: " + id + "): " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    // 회의록 작성
    public boolean insert(MeetingMinutesDTO dto) {
        String sql = 
            "INSERT INTO meeting_minutes " +
            "(project_id, title, meeting_date, content, created_by) " +
            "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, dto.getProjectId());
            ps.setString(2, dto.getTitle());
            ps.setString(3, dto.getMeetingDate());
            ps.setString(4, dto.getContent());
            ps.setString(5, dto.getCreatedBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("회의록 작성 중 DB 오류 발생: " + e.getMessage());
            System.err.println("프로젝트 ID: " + dto.getProjectId() + ", 제목: " + dto.getTitle());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("회의록 작성 중 예상치 못한 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 회의록 수정 (이력 저장 포함)
    public boolean update(MeetingMinutesDTO dto) {
        Connection conn = null;
        PreparedStatement psSelect = null;
        PreparedStatement psHistory = null;
        PreparedStatement psUpdate = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            // 트랜잭션 시작
            conn.setAutoCommit(false);
            
            // 1. 기존 내용 조회
            String selectSql = "SELECT content FROM meeting_minutes WHERE id = ?";
            psSelect = conn.prepareStatement(selectSql);
            psSelect.setInt(1, dto.getId());
            rs = psSelect.executeQuery();
            
            String oldContent = null;
            if (rs.next()) {
                oldContent = rs.getString("content");
            }
            
            // 2. 이력 저장
            if (oldContent != null && dto.getLastModifiedBy() != null) {
                String historySql = 
                    "INSERT INTO meeting_minutes_history " +
                    "(minutes_id, modified_by, content_before) " +
                    "VALUES (?, ?, ?)";
                
                psHistory = conn.prepareStatement(historySql);
                psHistory.setInt(1, dto.getId());
                psHistory.setString(2, dto.getLastModifiedBy());
                psHistory.setString(3, oldContent);
                psHistory.executeUpdate();
            }
            
            // 3. 회의록 업데이트
            String updateSql = 
                "UPDATE meeting_minutes SET " +
                "title = ?, meeting_date = ?, content = ?, " +
                "last_modified_by = ?, last_modified_at = NOW() " +
                "WHERE id = ?";
            
            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setString(1, dto.getTitle());
            psUpdate.setString(2, dto.getMeetingDate());
            psUpdate.setString(3, dto.getContent());
            psUpdate.setString(4, dto.getLastModifiedBy());
            psUpdate.setInt(5, dto.getId());
            
            int rowsAffected = psUpdate.executeUpdate();
            
            // 트랜잭션 커밋
            conn.commit();
            return rowsAffected > 0;
            
        } catch (Exception e) {
            // 트랜잭션 롤백
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("Transaction rolled back due to error: " + e.getMessage());
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            // 리소스 정리
            try {
                if (rs != null) rs.close();
                if (psSelect != null) psSelect.close();
                if (psHistory != null) psHistory.close();
                if (psUpdate != null) psUpdate.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // 원래 상태로 복구
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // 회의록 삭제
    public boolean delete(int id) {
        String sql = "DELETE FROM meeting_minutes WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("회의록 삭제 중 DB 오류 발생 (ID: " + id + "): " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("회의록 삭제 중 예상치 못한 오류 발생 (ID: " + id + "): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 수정 이력 조회
    public List<MeetingMinutesDTO> getHistory(int minutesId) {
        List<MeetingMinutesDTO> history = new ArrayList<>();
        
        String sql = 
            "SELECT h.*, m.name as modifier_name " +
            "FROM meeting_minutes_history h " +
            "LEFT JOIN member m ON h.modified_by = m.id " +
            "WHERE h.minutes_id = ? " +
            "ORDER BY h.modified_at DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, minutesId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MeetingMinutesDTO dto = new MeetingMinutesDTO();
                    dto.setModifiedBy(rs.getString("modified_by"));
                    dto.setModifiedByName(rs.getString("modifier_name"));
                    dto.setModifiedAt(rs.getTimestamp("modified_at"));
                    history.add(dto);
                }
            }
        } catch (SQLException e) {
            System.err.println("수정 이력 조회 중 DB 오류 발생 (회의록 ID: " + minutesId + "): " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("수정 이력 조회 중 예상치 못한 오류 발생 (회의록 ID: " + minutesId + "): " + e.getMessage());
            e.printStackTrace();
        }
        
        return history;
    }
}
