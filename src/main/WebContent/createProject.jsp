<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
  if (loginUser == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String userName = loginUser.getName();
  String userId = loginUser.getId();
  String initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>새 프로젝트 만들기 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="resource/css/app.css">
</head>
<body>

<div class="main" style="margin-left: 0;">
  <!-- Topbar -->
  <div class="topbar">
    <a href="projects.jsp" class="topbar-back">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="19" y1="12" x2="5" y2="12"/>
        <polyline points="12 19 5 12 12 5"/>
      </svg>
    </a>
    <div style="flex: 1;">
      <div class="topbar-title">새 프로젝트 만들기</div>
      <div class="topbar-sub">프로젝트 정보를 입력하고 팀원을 초대하세요</div>
    </div>
  </div>

  <!-- Page Content -->
  <div class="page-content">
    <div style="max-width: 720px; margin: 0 auto;">
      <div class="card">
        <div class="card-body">
          <!-- 프로젝트 생성 폼 -->
          <form action="writeProcess" method="post">
            <div class="form-group">
              <label class="form-label">프로젝트명</label>
              <input type="text" name="title" class="form-control" placeholder="예: 웹 개발 프로젝트" required>
            </div>

            <div class="form-group">
              <label class="form-label">프로젝트 설명</label>
              <textarea name="content" class="form-control" rows="8" placeholder="프로젝트에 대한 설명을 입력하세요" required></textarea>
            </div>

            <div class="form-group">
              <label class="form-label">프로젝트 마감일</label>
              <input type="date" name="deadline" class="form-control">
            </div>

            <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 24px;">
              <a href="projects.jsp" style="text-decoration: none;">
                <button type="button" class="btn btn-secondary">취소</button>
              </a>
              <button type="submit" class="btn btn-primary">프로젝트 생성</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>


</body>
</html>