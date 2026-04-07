<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.ProjectMemberDTO" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>팀원 초대</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Malgun Gothic", Arial, sans-serif;
            background: #f3f6fb;
        }
        .wrap {
            width: 1000px;
            margin: 60px auto;
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.08);
            padding: 36px 40px;
        }
        .title {
            font-size: 34px;
            font-weight: 700;
            color: #2f6fed;
            margin-bottom: 28px;
        }
        .top-info {
            margin-bottom: 16px;
            color: #666;
            font-size: 14px;
        }
        .invite-form {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
        }
        .invite-form input[type="text"] {
            flex: 1;
            height: 48px;
            border: 1px solid #d8dfeb;
            border-radius: 10px;
            padding: 0 14px;
            font-size: 15px;
            outline: none;
        }
        .invite-form button {
            width: 120px;
            height: 48px;
            border: none;
            border-radius: 10px;
            background: #2f6fed;
            color: white;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
        }
        .invite-form button:hover {
            background: #2458c9;
        }
        .msg {
            margin-bottom: 20px;
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 14px;
        }
        .msg.success {
            background: #eaf7ee;
            color: #1f7a39;
            border: 1px solid #b9e2c4;
        }
        .msg.error {
            background: #fff1f1;
            color: #cc2f2f;
            border: 1px solid #f0c2c2;
        }
        .sub-title {
            font-size: 22px;
            font-weight: 700;
            color: #2f6fed;
            margin: 28px 0 16px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            overflow: hidden;
            border-radius: 12px;
        }
        thead th {
            background: #eef3ff;
            color: #2f6fed;
            padding: 14px 10px;
            font-size: 15px;
            text-align: center;
        }
        tbody td {
            padding: 14px 10px;
            border-bottom: 1px solid #eceff5;
            text-align: center;
            font-size: 14px;
            color: #333;
        }
        .empty {
            text-align: center;
            padding: 30px 0;
            color: #888;
        }
        .status-invited { color: #ff9800; font-weight: bold; }
        .status-accepted { color: #22a745; font-weight: bold; }
        .status-rejected { color: #e74c3c; font-weight: bold; }
    </style>
</head>
<body>

<%
    Object projectIdObj = request.getAttribute("projectId");
    int projectId = 1;
    if (projectIdObj != null) {
        projectId = (Integer) projectIdObj;
    }

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");

    List<ProjectMemberDTO> memberList = (List<ProjectMemberDTO>) request.getAttribute("memberList");
%>

<div class="wrap">
    <div class="title">팀원 초대</div>

    <div class="top-info">
        프로젝트 번호: <strong><%= projectId %></strong>
    </div>

    <% if (successMsg != null) { %>
        <div class="msg success"><%= successMsg %></div>
    <% } %>

    <% if (errorMsg != null) { %>
        <div class="msg error"><%= errorMsg %></div>
    <% } %>

    <form class="invite-form" action="<%= request.getContextPath() %>/inviteMembers" method="post">
        <input type="hidden" name="projectId" value="<%= projectId %>">
        <input type="text" name="memberId" placeholder="초대할 회원 ID를 입력하세요" required>
        <button type="submit">초대하기</button>
    </form>

    <div class="sub-title">현재 팀원 / 초대 목록</div>

    <table>
        <thead>
            <tr>
                <th>번호</th>
                <th>프로젝트 번호</th>
                <th>회원 ID</th>
                <th>역할</th>
                <th>상태</th>
                <th>초대일</th>
            </tr>
        </thead>
        <tbody>
        <%
            if (memberList == null || memberList.isEmpty()) {
        %>
            <tr>
                <td colspan="6" class="empty">현재 팀원이 없습니다.</td>
            </tr>
        <%
            } else {
                for (ProjectMemberDTO dto : memberList) {
                    String status = dto.getStatus() == null ? "" : dto.getStatus();
        %>
            <tr>
                <td><%= dto.getPmNo() %></td>
                <td><%= dto.getProjectId() %></td>
                <td><%= dto.getMemberId() %></td>
                <td><%= dto.getRole() == null ? "팀원" : dto.getRole() %></td>
                <td>
                    <% if ("invited".equalsIgnoreCase(status)) { %>
                        <span class="status-invited"><%= status %></span>
                    <% } else if ("accepted".equalsIgnoreCase(status)) { %>
                        <span class="status-accepted"><%= status %></span>
                    <% } else if ("rejected".equalsIgnoreCase(status)) { %>
                        <span class="status-rejected"><%= status %></span>
                    <% } else { %>
                        <%= status %>
                    <% } %>
                </td>
                <td><%= dto.getInvitedAt() == null ? "" : dto.getInvitedAt() %></td>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
</div>

</body>
</html>