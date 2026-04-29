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
  
/*  model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
  
  String userName = "";
  String userId = "";
  String initials = "";
  
  if (loginUser == null) {
    // 테스트용 임시값
    userName = "교수님";
    userId = "prof123";
    initials = "교수";
  } else {
    userName = loginUser.getName();
    userId = loginUser.getId();
    initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;
  } */
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
  /* 사용자 헤더 스타일 */
  .user-header {
    position: fixed;
    top: 20px;
    right: 28px;
    display: flex;
    align-items: center;
    gap: 12px;
    background: white;
    padding: 12px 16px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    z-index: 100;
  }
  
  .av {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--blue), #60a5fa);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 700;
    font-size: 14px;
  }
  
  .user-info {
    display: flex;
    flex-direction: column;
  }
  
  .user-info-name {
    font-size: 14px;
    font-weight: 600;
    color: var(--text);
  }
  
  .user-info-id {
    font-size: 12px;
    color: var(--muted);
  }
  
  .btn-logout-header {
    background: transparent;
    border: 1px solid var(--border);
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 13px;
    color: var(--text2);
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    transition: all 0.2s;
  }
  
  .btn-logout-header:hover {
    background: var(--bg);
    border-color: var(--red);
    color: var(--red);
  }
  
  .btn-logout-header svg {
    width: 16px;
    height: 16px;
  }
  
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
    min-height: 160px;
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
    line-clamp: 2;
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
  
  .project-edit-btn {
  position: absolute; top: 12px; right: 48px;
  width: 28px; height: 28px; border-radius: 6px;
  background: var(--surface2); border: 1px solid var(--border);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; transition: all .15s; opacity: 0; z-index: 2;
  padding: 0;
}
.project-card:hover .project-edit-btn { opacity: 1; }
.project-edit-btn svg { width: 14px; height: 14px; stroke: var(--muted); }
.project-edit-btn:hover { background: var(--blue-soft); border-color: var(--blue); }
.project-edit-btn:hover svg { stroke: var(--blue); }
  
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
  
  .project-add-card {
    border: 2px dashed var(--border) !important;
    background: var(--bg) !important;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .project-add-card:hover {
    border-color: var(--primary) !important;
    background: var(--surface) !important;
    transform: translateY(-2px);
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
  
  /* 알림 드롭다운 스타일 */
  .notification-wrapper {
    position: relative;
  }
  
  .notification-btn {
    position: relative;
    background: transparent;
    border: none;
    cursor: pointer;
    padding: 8px;
    border-radius: 8px;
    transition: background 0.2s;
  }
  
  .notification-btn:hover {
    background: rgba(47, 111, 237, 0.1);
  }
  
  .notification-btn svg {
    width: 20px;
    height: 20px;
    stroke: var(--text);
  }
  
  .notification-badge {
    position: absolute;
    top: 4px;
    right: 4px;
    background: #ef4444;
    color: white;
    font-size: 10px;
    font-weight: 700;
    padding: 2px 5px;
    border-radius: 10px;
    min-width: 16px;
    text-align: center;
  }
  
  .notification-dropdown {
    display: none;
    position: fixed;
    top: 90px;
    right: 28px;
    background: white;
    border: 1px solid var(--border);
    border-radius: 12px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.12);
    width: 380px;
    max-height: 500px;
    overflow: hidden;
    z-index: 1000;
  }
  
  .notification-dropdown.show {
    display: block;
  }
  
  .notification-header {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .notification-header h3 {
    font-size: 16px;
    font-weight: 700;
    color: var(--text);
    margin: 0;
  }
  
  .notification-count {
    font-size: 12px;
    color: var(--muted);
    background: var(--bg);
    padding: 4px 8px;
    border-radius: 6px;
  }
  
  .notification-list {
    max-height: 400px;
    overflow-y: auto;
  }
  
  .notification-item {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border);
    display: flex;
    gap: 12px;
    align-items: center;
  }
  
  .notification-item:last-child {
    border-bottom: none;
  }
  
  .notification-item-content {
    flex: 1;
  }
  
  .notification-item-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--text);
    margin-bottom: 4px;
  }
  
  .notification-item-meta {
    font-size: 12px;
    color: var(--muted);
  }
  
  .notification-item-actions {
    display: flex;
    gap: 6px;
  }
  
  .btn-notification-accept,
  .btn-notification-reject {
    border: none;
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .btn-notification-accept {
    background: #22c55e;
    color: white;
  }
  
  .btn-notification-accept:hover {
    background: #16a34a;
  }
  
  .btn-notification-reject {
    background: #ef4444;
    color: white;
  }
  
  .btn-notification-reject:hover {
    background: #dc2626;
  }
  
  .notification-empty {
    padding: 40px 20px;
    text-align: center;
    color: var(--muted);
    font-size: 14px;
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
  
  .edit-modal-bg {
  display:none; position:fixed; inset:0;
  background:rgba(15,23,42,.45); z-index:999;
  align-items:center; justify-content:center;
}
.edit-modal-bg.open { display:flex; }
.edit-modal {
  background:#fff; border-radius:14px; padding:28px;
  width:440px; box-shadow:0 16px 48px rgba(0,0,0,.18);
  display:flex; flex-direction:column; gap:14px;
}
.edit-modal h2 { font-size:17px; font-weight:700; color:var(--text); }
.edit-modal label { font-size:12px; font-weight:600; color:var(--muted); margin-bottom:4px; display:block; }
.edit-modal input, .edit-modal textarea {
  width:100%; padding:9px 12px; border:1px solid var(--border);
  border-radius:8px; font-size:13px; font-family:inherit;
  background:var(--surface2); color:var(--text); outline:none;
}
.edit-modal input:focus, .edit-modal textarea:focus { border-color:var(--blue); background:#fff; }
.edit-modal textarea { resize:vertical; min-height:80px; }
.edit-modal-actions { display:flex; gap:8px; justify-content:flex-end; }
.edit-btn-save { background:var(--blue); color:#fff; border:none; border-radius:8px; padding:9px 20px; font-size:13px; font-weight:600; cursor:pointer; }
.edit-btn-cancel { background:var(--surface2); color:var(--muted); border:1px solid var(--border); border-radius:8px; padding:9px 14px; font-size:13px; cursor:pointer; }

.folder-accordion { border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; margin-bottom: 16px; }
.folder-header { display:flex; align-items:center; justify-content:space-between; padding:14px 20px; background:var(--surface); cursor:pointer; }
.folder-header:hover { background: var(--surface2); }
.folder-title { display:flex; align-items:center; gap:10px; font-weight:700; font-size:15px; color:var(--text); }
.folder-body { display:none; padding:16px; background:var(--bg); }
.folder-body.open { display:block; }
</style>
</head>
<body style="background: var(--bg);">

<%
  // 받은 초대 목록 가져오기
  ProjectMemberDAO memberDAO = new ProjectMemberDAO();
  List<ProjectMemberDTO> receivedInvites = memberDAO.getReceivedInvitations(userId);
%>

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
  <!-- 알림 버튼 (독립) -->
  <div class="notification-wrapper">
    <button class="notification-btn" onclick="toggleNotifications()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
        <polyline points="22,6 12,13 2,6"/>
      </svg>
      <% if (receivedInvites != null && !receivedInvites.isEmpty()) { %>
      <span class="notification-badge"><%= receivedInvites.size() %></span>
      <% } %>
    </button>
    
    <!-- 드롭다운 -->
    <div class="notification-dropdown" id="notificationDropdown">
      <div class="notification-header">
        <h3>📨 받은 초대</h3>
        <% if (receivedInvites != null && !receivedInvites.isEmpty()) { %>
        <span class="notification-count"><%= receivedInvites.size() %>개</span>
        <% } %>
      </div>
      
      <div class="notification-list">
        <% if (receivedInvites != null && !receivedInvites.isEmpty()) { 
          ProjectDAO projectDAO = new ProjectDAO();
          for (ProjectMemberDTO invite : receivedInvites) { 
            ProjectDTO inviteProject = projectDAO.getById(invite.getProjectId());
            if (inviteProject != null) {
        %>
        <div class="notification-item">
          <div class="notification-item-content">
            <div class="notification-item-title"><%= inviteProject.getTitle() %></div>
            <div class="notification-item-meta">
              <%= invite.getRole() != null ? invite.getRole() : "팀원" %> · 
              <%= invite.getInvitedAt() != null ? invite.getInvitedAt().substring(0, 10) : "-" %>
            </div>
          </div>
          <div class="notification-item-actions">
            <form action="teamMemberAction" method="post" style="display: inline;">
              <input type="hidden" name="action" value="accept">
              <input type="hidden" name="projectId" value="<%= invite.getProjectId() %>">
              <input type="hidden" name="pmNo" value="<%= invite.getPmNo() %>">
              <button type="submit" class="btn-notification-accept">수락</button>
            </form>
            <form action="teamMemberAction" method="post" style="display: inline;">
              <input type="hidden" name="action" value="reject">
              <input type="hidden" name="projectId" value="<%= invite.getProjectId() %>">
              <input type="hidden" name="pmNo" value="<%= invite.getPmNo() %>">
              <button type="submit" class="btn-notification-reject">거절</button>
            </form>
          </div>
        </div>
        <% 
            }
          } 
        } else { 
        %>
        <div class="notification-empty">받은 초대가 없습니다</div>
        <% } %>
      </div>
    </div>
  </div>
  
  <!-- 구분선 -->
  <div style="width: 1px; height: 36px; background: var(--border);"></div>
  
  <!-- 사용자 정보 -->
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
  
  
  <%
    ListDAO dao = new ListDAO();
    List<ProjectDTO> myProjects = dao.getMyProjectsWithFolder(userId);
  %>
  
  <%
  FolderDAO folderDAO = new FolderDAO();
  List<FolderDTO> folders = folderDAO.getFoldersByUser(userId);

  if (myProjects != null && !myProjects.isEmpty()) {
%>

<!-- 폴더 없는 프로젝트 -->
<div class="project-grid">
  <% for (ProjectDTO project : myProjects) {
       if (project.getFolderId() == 0) { %>
       <!-- 기존 project-card 코드 그대로 붙여넣기 -->
  <% } } %>
</div>

<!-- 폴더 아코디언 -->
<% for (FolderDTO folder : folders) { %>
<div class="folder-accordion">
  <div class="folder-header" onclick="toggleFolder(<%= folder.getId() %>)">
    <div class="folder-title">
      📁 <%= folder.getName() %>
    </div>
    <svg id="chevron-<%= folder.getId() %>" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:18px;height:18px;transition:transform .2s">
      <polyline points="6 9 12 15 18 9"/>
    </svg>
  </div>
  <div class="folder-body" id="folder-<%= folder.getId() %>">
    <div class="project-grid">
      <% for (ProjectDTO project : myProjects) {
           if (project.getFolderId() == folder.getId()) { %>
           <!-- 기존 project-card 코드 그대로 붙여넣기 -->
      <% } } %>
    </div>
  </div>
</div>
<% } %>

<% } else { %>
<div class="empty-projects">
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
    <path d="M9 11l3 3L22 4"/>
    <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
  </svg>
  <h3>아직 참여 중인 프로젝트가 없어요</h3>
  <p>팀원 초대를 받아 프로젝트에 참여해보세요</p>
</div>
<% } %>
</div>

<div class="edit-modal-bg" id="editModalBg">
  <div class="edit-modal">
    <h2>프로젝트 수정</h2>
    <input type="hidden" id="editProjectId">
    <div>
      <label>제목</label>
      <input type="text" id="editTitle">
    </div>
    <div>
      <label>설명</label>
      <textarea id="editContent"></textarea>
    </div>
    <div>
      <label>마감일</label>
      <input type="date" id="editDeadline">
    </div>
    <div class="edit-modal-actions">
      <button class="edit-btn-cancel" onclick="closeEditModal()">취소</button>
      <button class="edit-btn-save" onclick="saveEdit()">저장</button>
    </div>
  </div>
</div>

<script>
function openEditModal(id, title, content, deadline) {
	  document.getElementById('editProjectId').value = id;
	  document.getElementById('editTitle').value = title;
	  document.getElementById('editContent').value = content;
	  document.getElementById('editDeadline').value = deadline;
	  document.getElementById('editModalBg').classList.add('open');
	}
	function closeEditModal() {
	  document.getElementById('editModalBg').classList.remove('open');
	}
	document.getElementById('editModalBg').onclick = function(e) {
	  if (e.target.id === 'editModalBg') closeEditModal();
	};
	function saveEdit() {
	  var id       = document.getElementById('editProjectId').value;
	  var title    = document.getElementById('editTitle').value.trim();
	  var content  = document.getElementById('editContent').value.trim();
	  var deadline = document.getElementById('editDeadline').value;
	  if (!title) { alert('제목을 입력하세요.'); return; }
	  var form = new FormData();
	  form.append('id', id);
	  form.append('title', title);
	  form.append('content', content);
	  form.append('deadline', deadline);
	  var params = new URLSearchParams();
	  params.append('id', id);
	  params.append('title', title);
	  params.append('content', content);
	  params.append('deadline', deadline);
	  fetch('editProject', {
	    method: 'POST',
	    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	    body: params
	  }).then(function() { closeEditModal(); location.reload(); });
	}

function toggleNotifications() {
  const dropdown = document.getElementById('notificationDropdown');
  dropdown.classList.toggle('show');
}

// 드롭다운 외부 클릭 시 닫기
document.addEventListener('click', function(event) {
  const notificationWrapper = document.querySelector('.notification-wrapper');
  const dropdown = document.getElementById('notificationDropdown');
  
  if (notificationWrapper && !notificationWrapper.contains(event.target)) {
    dropdown.classList.remove('show');
  }
});

function toggleFolder(id) {
	  const body = document.getElementById('folder-' + id);
	  const chevron = document.getElementById('chevron-' + id);
	  body.classList.toggle('open');
	  if (body.classList.contains('open')) {
	    chevron.style.transform = 'rotate(180deg)';
	  } else {
	    chevron.style.transform = 'rotate(0deg)';
	  }
	}
</script>

</body>
</html>
