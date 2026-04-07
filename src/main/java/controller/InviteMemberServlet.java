package controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet("/inviteMembers")
public class InviteMemberServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.setContentType("application/json;charset=UTF-8");
		PrintWriter out = response.getWriter();
		try {
			Connection conn = model.DBConnection.getConnection();

			BufferedReader reader = request.getReader();
			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
			String body = sb.toString(); // {"memberIds":["user1","user2"]}

			String memberIdsPart = body.replaceAll(".*\\[(.*)\\].*", "$1") // user1","user2 추출
					.replaceAll("\"", "").trim(); // 따옴표 제거

			if (memberIdsPart.isEmpty()) {
				out.print("{\"success\":false,\"message\":\"memberIds 없음\"}");
				return;
			}

			String[] memberIds = memberIdsPart.split(",");

			String projectId = request.getParameter("projectId");
			if (projectId == null)
				projectId = "1";

			String sql = "INSERT INTO project_member(project_id, member_id) VALUES (?, ?)";
			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				for (String memberId : memberIds) {
					ps.setInt(1, Integer.parseInt(projectId));
					ps.setString(2, memberId.trim());
					ps.addBatch();
				}
				ps.executeBatch();
			}
			out.print("{\"success\":true}");

		} catch (Exception e) {
			e.printStackTrace();
			out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
		} finally {
			out.flush();
		}
	}
}