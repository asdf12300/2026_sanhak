<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*" %>
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
<title>내 프로젝트 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
  /* 프로젝트 선택 페이지 전용 스타일 */
  .projects-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 60px 28px;
  }
  
  .projects-header {
    text-align: center;
    margin-bottom: 48px;
  }
  
  .projects-title {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 36px;
    font-weight: 800;
    color: var(--text);
    letter-spacing: -1px;
    margin-bottom: 12px;
  }
  
  .projects-subtitle {
    font-size: 15px;
    color: var(--muted);
  }
  
  .projects-actions {
    display: flex;
    justify-content: center;
    gap: 12px;
    margin-bottom: 40px;
  }
  
  .project-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
  }
  
  .project-card {
    background: var(--surface);
    border: 2px solid var(--border);
    border-radius: var(--radius);
    padding: 24px;
    cursor: pointer;
    transition: all .2s;
    box-shadow: var(--shadow-sm);
    display: flex;
    flex-direction: column;
    gap: 12px;
    text-decoration: none;
    color: inherit;
  }
  
  .project-card:hover {
    border-color: var(--blue);
    box-shadow: var(--shadow);
    transform: translateY(-4px);
  }
  
  .project-card-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
  }
  
  .project-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    background: linear-gradient(135deg, var(--blue), #60a5fa);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  
  .project-icon svg {
    width: 24px;
    height: 24px;
    stroke: #fff;
  }
  
  .project-card-title {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 18px;
    font-weight: 700;
    color: var(--text);
    margin-bottom: 4px;
    line-height: 1.3;
  }
  
  .project-card-id {
    font-size: 11px;
    color: var(--muted2);
    font-weight: 600;
  }
  
  .project-card-content {
    font-size: 13px;
    color: var(--text2);
    line-height: 1.6;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  
  .project-card-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-top: 12px;
    border-top: 1px solid var(--border);
    margin-top: auto;
  }
  
  .project-deadline {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: var(--muted);
  }
  
  .project-deadline svg {
    width: 14px;
    height: 14px;
  }
  
  .project-role {
    font-size: 11px;
    padding: 4px 10px;
    border-radius: 20px;
    font-weight: 600;
  }
  
  .role-leader {
    background: var(--blue-soft);
    color: var(--blue);
  }
  
  .role-member {
    background: var(--surface2);
    color: var(--muted);
  }
  
  .project-delete-btn {
    position: absolute;
    top: 12px;
    right: 12px;
    width: 28px;
    height: 28px;
    border-radius: 6px;
    background: var(--surface2);
    border: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all .15s;
    opacity: 0;
    z-index: 2;
  }
  
  .project-card:hover .project-delete-btn {
    opacity: 1;
  }
  
  .project-delete-btn:hover {
    background: var(--red-light);
    border-color: var(--red);
    color: var(--red);
  }
  
  .project-delete-btn svg {
    width: 16px;
    height: 16px;
    stroke: var(--muted);
  }
  
  .project-delete-btn:hover svg {
    stroke: var(--red);
  }
  
  .project-card {
    position: relative;
  }
  
  .empty-projects {
    text-align: center;
    padding: 80px 20px;
  }
  
  .empty-projects svg {
    width: 64px;
    height: 64px;
    stroke: var(--muted2);
    margin-bottom: 20px;
    opacity: 0.5;
  }
  
  .empty-projects h3 {
    font-size: 20px;
    font-weight: 700;
    color: var(--text2);
    margin-bottom: 8px;
  }
  
  .empty-projects p {
    font-size: 14px;
    color: var(--muted);
    margin-bottom: 24px;
  }
  
  .user-header {
    position: fixed;
    top: 20px;
    right: 28px;
    display: flex;
    align-items: center;
    gap: 12px;
    background: var(--surface);
    padding: 10px 16px;
    border-radius: var(--radius-sm);
    border: 1px solid var(--border);
    box-shadow: var(--shadow-sm);
    z-index: 10;
  }
  
  .user-header .av {
    width: 32px;
    height: 32px;
    font-size: 11px;
  }
  
  .user-info {
    display: flex;
    flex-direction: column;
  }
  
  .user-info-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--text);
  }
  
  .user-info-id {
    font-size: 11px;
    color: var(--muted);
  }
  
  .btn-logout-header {
    padding: 6px 12px;
    font-size: 12px;
    background: var(--surface2);
    color: var(--muted);
    border: 1px solid var(--border);
    border-radius: var(--radius-xs);
    cursor: pointer;
    transition: all .15s;
    display: flex;
    align-items: center;
    gap: 4px;
  }
  
  .btn-logout-header:hover {
    background: var(--red-light);
    color: var(--red);
    border-color: var(--red);
  }
  
  .btn-logout-header svg {
    width: 13px;
    height: 13px;
  }
  
  /* 로고 스타일 */
  .projects-logo {
    position: fixed;
    top: 20px;
    left: 28px;
    display: flex;
    align-items: center;
    gap: 10px;
    z-index: 10;
    text-decoration: none;
    color: var(--text);
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 18px;
    font-weight: 800;
    letter-spacing: -0.5px;
  }
  
  .projects-logo-icon {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, var(--blue), #60a5fa);
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .projects-logo-icon svg {
    width: 20px;
    height: 20px;
    stroke: #fff;
  }
</style>
</head>
<body style="background: var(--bg);">

<!-- 로고 -->
<a href="projects.jsp" class="projects-logo">
  <div class="projects-logo-icon">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
      <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
    </svg>
  </div>
  ProjectOS
</a>

<!-- 사용자 정보 헤더 -->
<div class="user-header">
  <div class="av"><%= initials %></div>
  <div class="user-info">
    <div class="user-info-name"><%= userName %></div>
    <div class="user-info-id"><%= userId %></div>
  </div>
  <a href="logout" style="text-decoration: none;">
    <button class="btn-logout-header">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
        <polyline points="16 17 21 12 16 7"/>
        <line x1="21" y1="12" x2="9" y2="12"/>
      </svg>
      로그아웃
    </button>
  </a>
</div>

<div class="projects-container">
  <!-- 헤더 -->
  <div class="projects-header">
    <div class="projects-title">내 프로젝트</div>
    <div class="projects-subtitle">참여 중인 프로젝트를 선택하거나 새로운 프로젝트를 시작하세요</div>
  </div>
  
  <!-- 액션 버튼 -->
  <div class="projects-actions">
    <a href="createProject.jsp" style="text-decoration: none;">
      <button class="btn btn-p">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <line x1="12" y1="5" x2="12" y2="19"/>
          <line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        새 프로젝트 만들기
      </button>
    </a>
  </div>
  
  <%
    // 내가 속한 프로젝트 목록 가져오기
    ListDAO dao = new ListDAO();
    List<ProjectDTO> myProjects = dao.getMyProjects(userId);
    
    if (myProjects != null && !myProjects.isEmpty()) {
  %>
  <!-- 프로젝트 그리드 -->
  <div class="project-grid">
    <% for (ProjectDTO project : myProjects) { %>
    <% 
      boolean isLeader = project.getTeam_leader() != null && project.getTeam_leader().equals(userId);
    %>
    <a href="index.jsp?projectId=<%= project.getId() %>" class="project-card">
      <!-- 삭제 버튼 (모든 사용자) -->
      <button class="project-delete-btn" onclick="event.preventDefault(); event.stopPropagation(); if(confirm('정말 이 프로젝트를 삭제하시겠습니까?\n\n프로젝트와 관련된 모든 데이터(팀원, 업무, 일정)가 함께 삭제됩니다.')) { location.href='deleteProject?id=<%= project.getId() %>'; }">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="3 6 5 6 21 6"/>
          <path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/>
          <line x1="10" y1="11" x2="10" y2="17"/>
          <line x1="14" y1="11" x2="14" y2="17"/>
        </svg>
      </button>
      
      <div class="project-card-header">
        <div class="project-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 11l3 3L22 4"/>
            <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
          </svg>
        </div>
        <div style="flex: 1;">
          <div class="project-card-title"><%= project.getTitle() %></div>
        </div>
      </div>
      
      <% if (project.getContent() != null && !project.getContent().isEmpty()) { %>
      <div class="project-card-content">
        <%= project.getContent() %>
      </div>
      <% } %>
      
      <div class="project-card-footer">
        <div class="project-deadline">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/>
            <line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/>
          </svg>
          <span style="font-weight:600;color:var(--text2)">마감일:</span> <%= (project.getDeadline() != null && !project.getDeadline().isEmpty()) ? project.getDeadline() : "미정" %>
        </div>
        <span class="project-role <%= isLeader ? "role-leader" : "role-member" %>">
          <%= isLeader ? "팀장" : "팀원" %>
        </span>
      </div>
    </a>
    <% } %>
  </div>
  <% } else { %>
  <!-- 빈 상태 -->
  <div class="empty-projects">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M9 11l3 3L22 4"/>
      <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
    </svg>
    <h3>아직 참여 중인 프로젝트가 없어요</h3>
    <p>새로운 프로젝트를 만들거나 팀원 초대를 받아보세요</p>
    <a href="createProject.jsp" style="text-decoration: none;">
      <button class="btn btn-p">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <line x1="12" y1="5" x2="12" y2="19"/>
          <line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        첫 프로젝트 만들기
      </button>
    </a>
  </div>
  <% } %>
</div>

</body>
</html>
