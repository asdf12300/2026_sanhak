<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 상세보기</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-4">

<%
    String error = (String) request.getAttribute("error");
    model.ProjectDTO dto = (model.ProjectDTO) request.getAttribute("dto");

    if (error != null) {
%>
    <div class="alert alert-danger"><%= error %></div>
<%
    } else if (dto != null) {
%>

<h2 class="mb-3"><%= dto.getTitle() %></h2>

<p>
    <strong>팀장:</strong> <%= dto.getTeam_leader() != null ? dto.getTeam_leader() : "-" %> |
    <strong>마감일:</strong> <%= dto.getDeadline() != null ? dto.getDeadline() : "미정" %>
</p>

<hr>

<div>
    <%= dto.getContent() != null ? dto.getContent() : "" %>
</div>

<a href="list" class="btn btn-secondary mt-3">목록</a>

<%
    }
%>

</body>
</html>