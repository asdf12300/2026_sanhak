<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
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
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="resource/css/app.css">
</head>
<body>

<jsp:include page="session.jsp"/>
<jsp:include page="sidebar.jsp"/>

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
