<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
  String userName = (loginUser != null) ? loginUser.getName() : "게스트";
  String userId   = (loginUser != null) ? loginUser.getId()   : "";
  String initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;
  model.ProjectDTO dto = (model.ProjectDTO) request.getAttribute("dto");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>프로젝트 수정 — ProjectOS</title>
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
    <button class="topbar-back" onclick="history.back()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
        <polyline points="15 18 9 12 15 6"/>
      </svg>
    </button>
    <div>
      <div class="topbar-title">프로젝트 수정</div>
      <div class="topbar-sub">내용을 수정하세요</div>
    </div>
  </div>

  <div class="page-content">
    <div class="card" style="max-width:680px">
      <div class="card-header">
        <span class="card-title">프로젝트 수정</span>
      </div>
      <div class="card-body">
        <% if (dto != null) { %>
        <form action="editProject" method="post">
          <input type="hidden" name="id" value="<%= dto.getId() %>">
          <div class="form-group">
            <label class="form-label">프로젝트명 *</label>
            <input type="text" name="title" class="form-control" value="<%= dto.getTitle() != null ? dto.getTitle() : "" %>" required>
          </div>
          <div class="form-group">
            <label class="form-label">프로젝트 설명 *</label>
            <textarea name="content" class="form-control" rows="6" required><%= dto.getContent() != null ? dto.getContent() : "" %></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">마감일</label>
            <input type="date" name="deadline" class="form-control" value="<%= dto.getDeadline() != null ? dto.getDeadline() : "" %>">
          </div>
          <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:8px">
            <button type="button" class="btn btn-secondary" onclick="history.back()">취소</button>
            <button type="submit" class="btn btn-primary">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v14a2 2 0 01-2 2z"/>
                <polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>
              </svg>저장
            </button>
          </div>
        </form>
        <% } else { %>
          <div class="alert alert-danger">프로젝트를 찾을 수 없습니다.</div>
        <% } %>
      </div>
    </div>
  </div>
</div>

</body>
</html>
