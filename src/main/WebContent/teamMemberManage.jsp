<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.LoginDTO" %>
<%@ page import="model.ProjectDAO" %>
<%@ page import="model.ProjectDTO" %>
<%@ page import="model.ProjectMemberDAO" %>
<%@ page import="model.ProjectMemberDTO" %>
<!-- 테스트 -->
<%
String projectIdStr = request.getParameter("projectId");
int projectId = 0;

if (projectIdStr == null || projectIdStr.trim().isEmpty() || "null".equals(projectIdStr)) {
    String lastProjectId = (String) session.getAttribute("lastProjectId");

    if (lastProjectId != null && !lastProjectId.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/teamMemberManage.jsp?projectId=" + lastProjectId);
        return;
    } else {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
}

projectId = Integer.parseInt(projectIdStr);
session.setAttribute("lastProjectId", String.valueOf(projectId));
%>
<%
Object loginUser = session.getAttribute("loginUser");
if (loginUser == null && session.getAttribute("id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String msg = request.getParameter("msg");

String loginId = null;
if (session.getAttribute("id") != null) {
    loginId = (String) session.getAttribute("id");
} else if (session.getAttribute("loginUser") != null) {
    LoginDTO loginDTO = (LoginDTO) session.getAttribute("loginUser");
    if (loginDTO != null) {
        loginId = loginDTO.getId();
    }
}

ProjectMemberDAO dao = new ProjectMemberDAO();
List<ProjectMemberDTO> memberList = dao.getMembersByProject(projectId);
List<ProjectMemberDTO> receivedInviteList = dao.getReceivedInvitations(loginId);

ProjectDAO projectDao = new ProjectDAO();
ProjectDTO project = projectDao.getById(projectId);

String teamLeaderId = null;
if (project != null) {
    try {
        teamLeaderId = project.getTeam_leader();
    } catch (Exception e) {
        // 프로젝트 DTO의 getter 이름이 다르면 이 부분만 맞게 수정
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>팀원 관리</title>
<style>
    body {
        margin: 0;
        padding: 30px;
        padding-left: 260px;
        background: #f5f7fb;
        font-family: Arial, sans-serif;
    }

    .wrapper {
        max-width: 1100px;
        margin: 0 auto;
    }

    .card {
        background: #ffffff;
        border-radius: 18px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        padding: 28px;
        margin-bottom: 24px;
    }

    h1, h2 {
        color: #2f6fed;
        margin-top: 0;
    }

    .message {
        margin: 14px 0 20px;
        padding: 12px 14px;
        background: #eef4ff;
        color: #2f6fed;
        border-radius: 10px;
        font-size: 14px;
    }

    .form-row {
        display: flex;
        gap: 10px;
        margin-bottom: 24px;
    }

    .form-row input[type="text"] {
        flex: 1;
        padding: 14px;
        border: 1px solid #d9e1f2;
        border-radius: 10px;
        font-size: 14px;
        outline: none;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 12px;
        background: white;
    }

    th, td {
        border-bottom: 1px solid #edf1f7;
        padding: 14px 10px;
        text-align: center;
        font-size: 14px;
    }

    th {
        background: #f3f6fb;
        color: #3a4b6a;
        font-weight: 700;
    }

    .inline-form {
        display: inline-block;
        margin: 2px;
    }

    .btn {
        border: none;
        border-radius: 10px;
        padding: 10px 14px;
        color: white;
        font-size: 13px;
        cursor: pointer;
        font-weight: 700;
    }

    .btn-blue {
        background: #2f6fed;
    }

    .btn-yellow {
        background: #f4a300;
    }

    .btn-red {
        background: #ef4444;
    }

    .btn-green {
        background: #22c55e;
    }

    .btn-gray {
        background: #6b7280;
    }

    .status-invited {
        color: #2563eb;
        font-weight: 700;
    }

    .status-accepted {
        color: #16a34a;
        font-weight: 700;
    }

    .status-rejected {
        color: #dc2626;
        font-weight: 700;
    }

    .status-excluded {
        color: #dc2626;
        font-weight: 700;
    }

    .leader-badge {
        color: #f59e0b;
        font-weight: 700;
    }

    .muted {
        color: #94a3b8;
    }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/css/calendar.css?v=1.0">
</head>
<body>
<jsp:include page="sidebar.jsp"/>
<div class="wrapper">

    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center;">
            <h1 style="margin:0;">팀원 관리</h1>
        </div>

        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="message"><%= msg %></div>
        <% } %>

        <h2>팀원 초대</h2>
        <form action="<%=request.getContextPath()%>/teamMemberAction" method="post" class="form-row">
            <input type="hidden" name="action" value="invite">
            <input type="hidden" name="projectId" value="<%= projectId %>">
            <input type="text" name="memberId" placeholder="초대할 회원 아이디를 입력하세요" required>
            <button type="submit" class="btn btn-blue">초대하기</button>
        </form>

        <h2>현재 팀원 / 초대 목록</h2>
        <table>
            <tr>
                <th>번호</th>
                <th>회원 아이디</th>
                <th>이름</th>
                <th>역할</th>
                <th>상태</th>
                <th>초대일</th>
                <th>관리</th>
            </tr>

            <% if (memberList != null && !memberList.isEmpty()) { %>
                <% for (ProjectMemberDTO dto : memberList) { %>
                    <%
                    boolean isMe = loginId != null && loginId.equals(dto.getMemberId());
                    boolean isLeader = teamLeaderId != null && teamLeaderId.equals(dto.getMemberId());
                    boolean amILeader = loginId != null && loginId.equals(teamLeaderId);
                    %>
                    <tr>
                        <td><%= dto.getPmNo() %></td>
                        <td><%= dto.getMemberId() %></td>
                        <td><%= dto.getName() != null ? dto.getName() : "-" %></td>
                        <td>
                            <% if (isLeader) { %>
                                <span class="leader-badge">팀장</span>
                            <% } else { %>
                                <%= dto.getRole() != null ? dto.getRole() : "팀원" %>
                            <% } %>
                        </td>
                        <td class="status-<%= dto.getStatus() %>"><%= dto.getStatus() %></td>
                        <td><%= dto.getInvitedAt() != null ? dto.getInvitedAt() : "-" %></td>
                        <td>
                            <% if (amILeader && "accepted".equals(dto.getStatus()) && !isLeader && !isMe) { %>
                                <form action="<%=request.getContextPath()%>/teamMemberAction" method="post" class="inline-form">
                                    <input type="hidden" name="action" value="setLeader">
                                    <input type="hidden" name="projectId" value="<%= dto.getProjectId() %>">
                                    <input type="hidden" name="memberId" value="<%= dto.getMemberId() %>">
                                    <button type="submit" class="btn btn-yellow">팀장 지정</button>
                                </form>
                            <% } %>

                            <% if (amILeader && !isLeader && !isMe) { %>
                                <form action="<%=request.getContextPath()%>/teamMemberAction" method="post" class="inline-form">
                                    <input type="hidden" name="action" value="remove">
                                    <input type="hidden" name="projectId" value="<%= dto.getProjectId() %>">
                                    <input type="hidden" name="memberId" value="<%= dto.getMemberId() %>">
                                    <button type="submit" class="btn btn-red">팀원 제외</button>
                                </form>
                            <% } %>

                            <% if (!amILeader || isLeader || isMe) { %>
                                <span class="muted">-</span>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            <% } else { %>
                <tr>
                    <td colspan="7">등록된 팀원 또는 초대 내역이 없습니다.</td>
                </tr>
            <% } %>
        </table>
    </div>

</div>
</body>
</html>