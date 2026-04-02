<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*" %>
<<<<<<< HEAD
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프로젝트 목록</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
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
=======
<%
  LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
  String userName = (loginUser != null) ? loginUser.getName() : "게스트";
  String userId   = (loginUser != null) ? loginUser.getId()   : "";
  String initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>프로젝트 목록 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/app.css">
</head>
<body>
<aside class="sidebar">
  <div class="sidebar-logo">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
      <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
    </svg>
    ProjectOS
  </div>
  <div class="nav-section">
    <div class="nav-label">메인</div>
    <a href="index.jsp" class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
        <rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
      </svg>대시보드
    </a>
    <a href="list" class="nav-item active">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
      </svg>프로젝트
    </a>
  </div>
  <div class="sidebar-bottom">
    <div class="user-row">
      <div class="avatar"><%= initials %></div>
      <div>
        <div class="user-name"><%= userName %></div>
        <div class="user-role"><%= userId %></div>
      </div>
    </div>
    <a href="logout"><button class="btn-logout">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
        <polyline points="16 17 21 12 16 7"/>
        <line x1="21" y1="12" x2="9" y2="12"/>
      </svg>로그아웃
    </button></a>
  </div>
</aside>
<div class="main">
  <div class="topbar">
    <div>
      <div class="topbar-title">프로젝트 목록</div>
      <div class="topbar-sub">전체 프로젝트를 관리하세요</div>
    </div>
    <div style="margin-left:auto">
      <a href="createProject.jsp"><button class="btn btn-primary">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>새 프로젝트
      </button></a>
    </div>
  </div>
  <div class="page-content">
    <%
      Object listObj = request.getAttribute("list");
      List<ProjectDTO> list = new ArrayList<>();
      if (listObj instanceof List<?>) {
        for (Object o : (List<?>)listObj) {
          if (o instanceof ProjectDTO) list.add((ProjectDTO)o);
        }
      }
      if (!list.isEmpty()) {
    %>
    <div class="project-grid">
      <% for (ProjectDTO dto : list) { %>
      <a href="view?id=<%= dto.getId() %>" class="project-card">
        <div class="project-card-title"><%= dto.getTitle() %></div>
        <div class="project-card-meta">
          <span style="display:flex;align-items:center;gap:4px">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/>
              <line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
            <%= dto.getDeadline() != null && !dto.getDeadline().isEmpty() ? dto.getDeadline() : "마감일 미정" %>
          </span>
          <span class="badge badge-blue">#<%= dto.getId() %></span>
        </div>
      </a>
      <% } %>
    </div>
    <%
      PagingVO p = (PagingVO) request.getAttribute("paging");
      if (p != null && p.getTotalPage() > 1) {
    %>
    <div class="pagination">
      <% if (p.getStartPage() > 1) { %>
        <a href="list?page=<%= p.getStartPage()-1 %>"><button class="page-btn">‹</button></a>
      <% } %>
      <% for (int i = p.getStartPage(); i <= p.getEndPage(); i++) { %>
        <a href="list?page=<%= i %>"><button class="page-btn <%= (i == p.getPage()) ? "active" : "" %>"><%= i %></button></a>
      <% } %>
      <% if (p.getEndPage() < p.getTotalPage()) { %>
        <a href="list?page=<%= p.getEndPage()+1 %>"><button class="page-btn">›</button></a>
      <% } %>
    </div>
    <% } %>
    <% } else { %>
    <div class="empty-state">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
        <path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
      </svg>
      <p>아직 등록된 프로젝트가 없어요.<br>새 프로젝트를 만들어보세요.</p>
    </div>
    <% } %>
  </div>
</div>
</body>
</html>
>>>>>>> origin/master
