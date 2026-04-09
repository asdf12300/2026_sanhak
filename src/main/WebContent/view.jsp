<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.*" %>
<%@ include file="session.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

String error = (String) request.getAttribute("error");
ProjectDTO dto = (ProjectDTO) request.getAttribute("dto");
List<ProjectMemberDTO> members = (List<ProjectMemberDTO>) request.getAttribute("members");
String msg = request.getParameter("msg");

%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>프로젝트 상세</title>
<link rel="stylesheet" href="resource/css/app.css">
</head>

<body>
<jsp:include page="sidebar.jsp"/>

<div class="main">
<div class="page-content">

<% if (error != null) { %>
    <div class="alert alert-danger"><%= error %></div>
<% } else if (dto != null) { %>

<!-- 프로젝트 정보 -->
<div class="card">
    <h2><%= dto.getTitle() %></h2>

    <p>마감일: <%= dto.getDeadline() != null ? dto.getDeadline() : "-" %></p>
    <p>팀장: <%= dto.getTeam_leader() != null ? dto.getTeam_leader() : "-" %></p>
    <p>작성일: <%= dto.getFormattedCreatedAt() %></p>

    <div><%= dto.getContent() %></div>
</div>

<!-- 팀원 관리 -->
<div class="card" style="margin-top:20px">
    <h3>팀원 관리</h3>

    <% if (msg != null) { %>
        <div style="color:blue"><%= msg %></div>
    <% } %>

    <!-- 팀원 추가 -->
    <form method="post" action="projectMember">
        <input type="hidden" name="action" value="add">
        <input type="hidden" name="projectId" value="<%= dto.getId() %>">
        <input type="text" name="memberId" placeholder="아이디 입력" required>
        <button type="submit">추가</button>
    </form>

    <br>

    <table border="1" width="100%">
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
            팀장
        <% } else if (isMe) { %>
            나
        <% } else { %>
            팀원
        <% } %>
    </td>

    <td>

        <!-- 팀장만 버튼 보이게 -->
        <% if (amILeader && !isLeader) { %>
            <form method="post" action="projectMember" style="display:inline">
                <input type="hidden" name="action" value="setLeader">
                <input type="hidden" name="projectId" value="<%= dto.getId() %>">
                <input type="hidden" name="memberId" value="<%= m.getMemberId() %>">
                <button type="submit">팀장 지정</button>
            </form>
        <% } %>

        <% if (amILeader && !isLeader && !isMe) { %>
            <form method="post" action="projectMember" style="display:inline">
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="projectId" value="<%= dto.getId() %>">
                <input type="hidden" name="memberId" value="<%= m.getMemberId() %>">
                <button type="submit">제외</button>
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
    <td colspan="4">팀원이 없습니다</td>
</tr>
<%
}
%>

    </table>
</div>

<% } %>

</div>
</div>

</body>
</html>