<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.ProjectDTO" %>
<%@ page import="model.LoginDTO" %>
<%@ page import="model.ProjectMemberDTO" %>
<%
    request.setCharacterEncoding("UTF-8");

    ProjectDTO dto = (ProjectDTO) request.getAttribute("dto");
    List<ProjectMemberDTO> members = (List<ProjectMemberDTO>) request.getAttribute("members");
    String error = (String) request.getAttribute("error");
    String msg = request.getParameter("msg");

    String userId = null;
    if (session.getAttribute("id") != null) {
        userId = (String) session.getAttribute("id");
    } else if (session.getAttribute("loginUser") != null) {
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
        if (loginUser != null) {
            userId = loginUser.getId();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프로젝트 상세</title>
<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        padding: 0;
        background: #f5f7fb;
        font-family: Arial, sans-serif;
        color: #222;
    }

    .container {
        max-width: 1100px;
        margin: 40px auto;
        padding: 0 20px;
    }

    .card {
        background: #ffffff;
        border-radius: 18px;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.08);
        padding: 28px;
        margin-bottom: 24px;
    }

    .title {
        margin: 0 0 18px 0;
        font-size: 28px;
        font-weight: bold;
        color: #2F6FED;
    }

    .section-title {
        margin: 0 0 16px 0;
        font-size: 22px;
        font-weight: bold;
        color: #2F6FED;
    }

    .info-row {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 12px;
    }

    .info-box {
        flex: 1 1 220px;
        background: #f8fbff;
        border: 1px solid #e3ebff;
        border-radius: 12px;
        padding: 14px 16px;
    }

    .label {
        display: block;
        font-size: 13px;
        color: #6b7280;
        margin-bottom: 6px;
    }

    .value {
        font-size: 16px;
        font-weight: 600;
        color: #111827;
        word-break: break-word;
    }

    .content-box {
        margin-top: 18px;
        background: #fcfcfd;
        border: 1px solid #eceff5;
        border-radius: 12px;
        padding: 18px;
        min-height: 140px;
        line-height: 1.7;
        white-space: pre-wrap;
    }

    .message {
        margin-bottom: 16px;
        padding: 12px 14px;
        background: #eef4ff;
        color: #2F6FED;
        border-radius: 10px;
        font-weight: 600;
    }

    .error {
        margin-bottom: 16px;
        padding: 12px 14px;
        background: #fff1f2;
        color: #dc2626;
        border-radius: 10px;
        font-weight: 600;
    }

    .form-row {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        margin-bottom: 18px;
    }

    .form-row input[type="text"] {
        flex: 1 1 260px;
        padding: 11px 12px;
        border: 1px solid #cfd8e3;
        border-radius: 10px;
        font-size: 14px;
        outline: none;
    }

    .btn {
        border: none;
        border-radius: 10px;
        padding: 10px 14px;
        color: white;
        cursor: pointer;
        font-size: 14px;
        font-weight: 600;
    }

    .btn-blue {
        background: #2F6FED;
    }

    .btn-yellow {
        background: #f59e0b;
    }

    .btn-red {
        background: #ef4444;
    }

    .btn-gray {
        background: #6b7280;
    }

    .action-inline {
        display: inline-block;
        margin: 2px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        overflow: hidden;
        border-radius: 12px;
    }

    th {
        background: #f5f7fb;
        color: #374151;
        font-weight: 700;
        font-size: 14px;
        padding: 12px 10px;
        border-bottom: 1px solid #e5e7eb;
        text-align: center;
    }

    td {
        padding: 12px 10px;
        border-bottom: 1px solid #eef2f7;
        text-align: center;
        font-size: 14px;
    }

    .role-leader {
        color: #2F6FED;
        font-weight: bold;
    }

    .role-me {
        color: #16a34a;
        font-weight: bold;
    }

    .role-member {
        color: #4b5563;
    }

    .top-actions {
        margin-top: 20px;
    }

    .top-actions a {
        display: inline-block;
        text-decoration: none;
        background: #6b7280;
        color: white;
        padding: 10px 14px;
        border-radius: 10px;
        font-weight: 600;
    }

    @media (max-width: 768px) {
        .container {
            margin: 20px auto;
        }

        .card {
            padding: 18px;
        }

        .title {
            font-size: 24px;
        }

        .section-title {
            font-size: 20px;
        }
    }
</style>
</head>
<body>

<div class="container">

    <% if (error != null) { %>
        <div class="card">
            <div class="error"><%= error %></div>
            <div class="top-actions">
                <a href="<%=request.getContextPath()%>/list">목록으로 돌아가기</a>
            </div>
        </div>
    <% } else if (dto != null) { %>

        <!-- 프로젝트 상세 -->
        <div class="card">
            <h1 class="title">프로젝트 상세</h1>

            <div class="info-row">
                <div class="info-box">
                    <span class="label">프로젝트 번호</span>
                    <span class="value"><%= dto.getId() %></span>
                </div>

                <div class="info-box">
                    <span class="label">제목</span>
                    <span class="value"><%= dto.getTitle() %></span>
                </div>
            </div>

            <div class="info-row">
                <div class="info-box">
                    <span class="label">작성자</span>
                    <span class="value"><%= dto.getAuthor() %></span>
                </div>

                <div class="info-box">
                    <span class="label">작성일</span>
                    <span class="value"><%= dto.getFormattedCreatedAt() %></span>
                </div>

                <div class="info-box">
                    <span class="label">마감일</span>
                    <span class="value"><%= dto.getDeadline() != null ? dto.getDeadline() : "-" %></span>
                </div>

                <div class="info-box">
                    <span class="label">현재 팀장</span>
                    <span class="value"><%= dto.getTeam_leader() != null ? dto.getTeam_leader() : "-" %></span>
                </div>
            </div>

            <div class="content-box"><%= dto.getContent() %></div>

            <div class="top-actions">
                <a href="<%=request.getContextPath()%>/list">목록으로 돌아가기</a>
            </div>
        </div>

        <!-- 팀원 관리 -->
        <div class="card" id="team-member-section">
            <h2 class="section-title">팀원 관리</h2>

            <% if (msg != null && !msg.trim().isEmpty()) { %>
                <div class="message"><%= msg %></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/projectMember" method="post" class="form-row">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="projectId" value="<%= dto.getId() %>">
                <input type="text" name="memberId" placeholder="추가할 팀원 아이디를 입력하세요" required>
                <button type="submit" class="btn btn-blue">팀원 추가</button>
            </form>

            <table>
                <tr>
                    <th>아이디</th>
                    <th>이름</th>
                    <th>역할</th>
                    <th>관리</th>
                </tr>

                <%
        if (members != null && !members.isEmpty()) {
            boolean amILeader = userId != null
                    && dto.getTeam_leader() != null
                    && userId.equals(dto.getTeam_leader());

            for (ProjectMemberDTO m : members) {
                boolean isLeader = dto.getTeam_leader() != null
                        && dto.getTeam_leader().equals(m.getMemberId());

                boolean isMe = userId != null
                        && userId.equals(m.getMemberId());
    %>
                <tr>
        <td><%= m.getMemberId() %></td>
        <td><%= m.getName() %></td>
        <td>
            <% if (isLeader) { %>
                <span class="role-leader">팀장</span>
            <% } else if (isMe) { %>
                <span class="role-me">나</span>
            <% } else { %>
                <span class="role-member">팀원</span>
            <% } %>
        </td>
        <td>
            <% if (amILeader && !isLeader) { %>
                <form action="<%=request.getContextPath()%>/projectMember" method="post" class="action-inline">
                    <input type="hidden" name="action" value="setLeader">
                    <input type="hidden" name="projectId" value="<%= dto.getId() %>">
                    <input type="hidden" name="memberId" value="<%= m.getMemberId() %>">
                    <button type="submit" class="btn btn-yellow">팀장 지정</button>
                </form>
            <% } %>

            <% if (amILeader && !isLeader && !isMe) { %>
                <form action="<%=request.getContextPath()%>/projectMember" method="post" class="action-inline">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="projectId" value="<%= dto.getId() %>">
                    <input type="hidden" name="memberId" value="<%= m.getMemberId() %>">
                    <button type="submit" class="btn btn-red">팀원 제외</button>
                </form>
            <% } %>

            <% if (!amILeader) { %>
                -
            <% } %>
        </td>
    </tr>
    <%
            }
        } else {
    %>
    <tr>
        <td colspan="4">등록된 팀원이 없습니다.</td>
    </tr>
    <%
        }
    %>
            </table>
        </div>

    <% } %>

</div>

</body>
</html>