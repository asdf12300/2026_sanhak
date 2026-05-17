package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginDAO {

    private Connection getConnection() {
        return DBConnection.getConnection();
    }

    public LoginDTO authenticate(String userid, String password, String role) {
        String sql = "SELECT id, name, role FROM member WHERE id = ? AND pw = ? AND role = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userid);
            ps.setString(2, password);
            ps.setString(3, role);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LoginDTO member = new LoginDTO();
                    member.setId(rs.getString("id"));
                    member.setName(rs.getString("name"));
                    member.setRole(rs.getString("role"));
                    return member;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean testConnection() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("LoginDAO: DB connection success");
                return true;
            }
            System.out.println("LoginDAO: DB connection failed (conn is null or closed)");
            return false;
        } catch (Exception e) {
            System.out.println("LoginDAO: DB connection failed (exception)");
            e.printStackTrace();
            return false;
        }
    }

    public boolean checkPassword(String userId, String password) {
        String sql = "SELECT id FROM member WHERE id = ? AND pw = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, password);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteMember(String userId) {
        String deleteOwnMinutesHistory =
            "DELETE FROM meeting_minutes_history " +
            "WHERE minutes_id IN (SELECT id FROM meeting_minutes WHERE created_by = ?)";
        String deleteModifiedMinutesHistory =
            "DELETE FROM meeting_minutes_history WHERE modified_by = ?";
        String deleteMeetingMinutes =
            "DELETE FROM meeting_minutes WHERE created_by = ?";
        String deleteProjectMember =
            "DELETE FROM project_member WHERE member_id = ?";
        String deleteMember =
            "DELETE FROM member WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement psOwnHistory = conn.prepareStatement(deleteOwnMinutesHistory);
                 PreparedStatement psModifiedHistory = conn.prepareStatement(deleteModifiedMinutesHistory);
                 PreparedStatement psMinutes = conn.prepareStatement(deleteMeetingMinutes);
                 PreparedStatement psProjectMember = conn.prepareStatement(deleteProjectMember);
                 PreparedStatement psMember = conn.prepareStatement(deleteMember)) {

                new ProjectMemberDAO().cleanupMemberAllProjectData(conn, userId);

                psOwnHistory.setString(1, userId);
                psOwnHistory.executeUpdate();

                psModifiedHistory.setString(1, userId);
                psModifiedHistory.executeUpdate();

                psMinutes.setString(1, userId);
                psMinutes.executeUpdate();

                psProjectMember.setString(1, userId);
                psProjectMember.executeUpdate();

                psMember.setString(1, userId);
                int result = psMember.executeUpdate();

                conn.commit();
                return result > 0;

            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
