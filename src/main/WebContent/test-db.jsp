<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DB 연결 테스트</title>
</head>
<body>
    <h1>MySQL 연결 테스트</h1>
    <%
        try {
            Connection conn = DBConnection.getConnection();
            if (conn != null && !conn.isClosed()) {
                out.println("<p style='color:green;'>✓ MySQL 연결 성공!</p>");
                conn.close();
            } else {
                out.println("<p style='color:red;'>✗ MySQL 연결 실패</p>");
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>✗ 오류 발생: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    %>
</body>
</html>
