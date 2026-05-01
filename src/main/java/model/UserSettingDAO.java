package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserSettingDAO {

	
	public boolean checkPassword(String userId, String currentPw) {
	    String sql = "SELECT * FROM member WHERE id = ? AND pw = ?";

	    try (
	        Connection conn = DBConnection.getConnection();
	        PreparedStatement pstmt = conn.prepareStatement(sql)
	    ) {
	        pstmt.setString(1, userId);
	        pstmt.setString(2, currentPw);

	        ResultSet rs = pstmt.executeQuery();
	        return rs.next();

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return false;
	}

    public boolean updateUserInfo(String userId, String email, String newPw) {
        boolean updateEmail = email != null && !email.trim().isEmpty();
        boolean updatePw = newPw != null && !newPw.trim().isEmpty();

        String sql;

        if (updateEmail && updatePw) {
            sql = "UPDATE member SET email = ?, pw = ? WHERE id = ?";
        } else if (updateEmail) {
            sql = "UPDATE member SET email = ? WHERE id = ?";
        } else {
            sql = "UPDATE member SET pw = ? WHERE id = ?";
        }

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            if (updateEmail && updatePw) {
                pstmt.setString(1, email);
                pstmt.setString(2, newPw);
                pstmt.setString(3, userId);
            } else if (updateEmail) {
                pstmt.setString(1, email);
                pstmt.setString(2, userId);
            } else {
                pstmt.setString(1, newPw);
                pstmt.setString(2, userId);
            }

            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}