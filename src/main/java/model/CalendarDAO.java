package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CalendarDAO {

    // =====================
    // 프로젝트별 조회
    // =====================
    public List<CalendarDTO> getEventsByProject(Connection conn, int projectId) throws Exception {

        List<CalendarDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM calendar WHERE project_id=? ORDER BY event_date, event_time";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CalendarDTO e = new CalendarDTO();
                    e.setId(rs.getInt("event_id"));
                    e.setProjectId(rs.getInt("project_id"));
                    e.setDate(rs.getString("event_date"));
                    e.setTime(rs.getString("event_time"));
                    e.setTitle(rs.getString("title"));
                    e.setCategory(rs.getInt("category"));
                    e.setMemo(rs.getString("memo"));
                    list.add(e);
                }
            }
        }
        return list;
    }

    // =====================
    // 등록
    // =====================
    public void insertEvent(Connection conn, CalendarDTO e) throws Exception {
        String sql = "INSERT INTO calendar (project_id, event_date, event_time, title, category, memo) VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, e.getProjectId());
            ps.setString(2, e.getDate());
            ps.setString(3, e.getTime());
            ps.setString(4, e.getTitle());
            ps.setInt(5, e.getCategory());
            ps.setString(6, e.getMemo());
            ps.executeUpdate();
        }
    }

    // =====================
    // 수정
    // =====================
    public void updateEvent(Connection conn, CalendarDTO e) throws Exception {
        String sql = "UPDATE calendar SET event_date=?, event_time=?, title=?, category=?, memo=? WHERE project_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, e.getDate());
            ps.setString(2, e.getTime());
            ps.setString(3, e.getTitle());
            ps.setInt(4, e.getCategory());
            ps.setString(5, e.getMemo());
            ps.setInt(6, e.getProjectId());
            ps.executeUpdate();
        }
    }

    // =====================
    // 삭제
    // =====================
    public void deleteEvent(Connection conn, int id) throws Exception {
        String sql = "DELETE FROM calendar WHERE event_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}