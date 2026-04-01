<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프로젝트 목록</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-4">

<h2>프로젝트 목록</h2>
<a href="createProject.jsp" class="btn btn-primary mb-3">프로젝트 생성</a>

<table class="table table-bordered table-hover">
  <thead>
    <tr class="table-primary">
      <th width="60">번호</th>
      <th>제목</th>
      <th width="150">팀장</th>
      <th width="200">마감일</th>
    </tr>
  </thead>
  <tbody>
  <%
    Object listObj = request.getAttribute("list");
    List<ProjectDTO> list = new ArrayList<>();
    if(listObj instanceof List<?>) {
        for(Object o : (List<?>)listObj) {
            if(o instanceof ProjectDTO) {
                list.add((ProjectDTO)o);
            }
        }
    }
    if (!list.isEmpty()) {
        for (ProjectDTO dto : list) {
  %>
    <tr>
      <td><%= dto.getId() %></td>
      <td><a href="view?id=<%= dto.getId() %>"><%= dto.getTitle() %></a></td>
      <td><%= dto.getTeam_leader() != null ? dto.getTeam_leader() : "-" %></td>
      <td><%= dto.getDeadline() != null ? dto.getDeadline() : "미정" %></td>
    </tr>
  <%
        }
    } else {
  %>
    <tr><td colspan="4" class="text-center">등록된 글이 없습니다</td></tr>
  <% } %>
  </tbody>
</table>

<%
PagingVO p = (PagingVO)request.getAttribute("paging");
if(p != null) {
%>
<div class="d-flex justify-content-center mt-3">
  <ul class="pagination">
    <% if(p.getStartPage() > 1){ %>
      <li class="page-item">
        <a class="page-link" href="list?page=<%=p.getStartPage()-1%>">이전</a>
      </li>
    <% } %>
    <% for(int i=p.getStartPage(); i<=p.getEndPage(); i++){ %>
      <li class="page-item <%= (i==p.getPage()) ? "active" : "" %>">
        <a class="page-link" href="list?page=<%=i%>"><%=i%></a>
      </li>
    <% } %>
    <% if(p.getEndPage() < p.getTotalPage()){ %>
      <li class="page-item">
        <a class="page-link" href="list?page=<%=p.getEndPage()+1%>">다음</a>
      </li>
    <% } %>
  </ul>
</div>
<% } %>

</body>
</html>