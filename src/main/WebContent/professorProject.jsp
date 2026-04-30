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

  ProjectMemberDAO memberDAO = new ProjectMemberDAO();
  List<ProjectMemberDTO> receivedInvites = memberDAO.getReceivedInvitations(userId);

  ListDAO dao = new ListDAO();
  List<ProjectDTO> myProjects = dao.getMyProjectsWithFolder(userId);
  FolderDAO folderDAO = new FolderDAO();
  List<FolderDTO> folders = folderDAO.getFoldersByUser(userId);

  int totalCount = myProjects != null ? myProjects.size() : 0;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>프로젝트 관리 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="resource/css/professorProject.css">
</head>
<body style="background: var(--bg);">

<!-- ── 상단 바 ── -->
<div class="top-bar">
  <a href="professorProject.jsp" class="projects-logo">
    <div class="projects-logo-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
      </svg>
    </div>
    ProjectOS
  </a>

  <div class="top-bar-right">
    <div class="notification-wrapper">
      <button class="notification-btn" onclick="toggleNotifications()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
          <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
          <polyline points="22,6 12,13 2,6"/>
        </svg>
        <% if (receivedInvites != null && !receivedInvites.isEmpty()) { %>
        <span class="notification-badge"><%= receivedInvites.size() %></span>
        <% } %>
      </button>
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
                 if (inviteProject != null) { %>
          <div class="notification-item">
            <div class="notification-item-content">
              <div class="notification-item-title"><%= inviteProject.getTitle() %></div>
              <div class="notification-item-meta">
                <%= invite.getRole() != null ? invite.getRole() : "교수" %> ·
                <%= invite.getInvitedAt() != null ? invite.getInvitedAt().substring(0,10) : "-" %>
              </div>
            </div>
            <div class="notification-item-actions">
              <form action="teamMemberAction" method="post" style="display:inline;">
                <input type="hidden" name="action" value="accept">
                <input type="hidden" name="projectId" value="<%= invite.getProjectId() %>">
                <input type="hidden" name="pmNo" value="<%= invite.getPmNo() %>">
                <button type="submit" class="btn-notification-accept">수락</button>
              </form>
              <form action="teamMemberAction" method="post" style="display:inline;">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="projectId" value="<%= invite.getProjectId() %>">
                <input type="hidden" name="pmNo" value="<%= invite.getPmNo() %>">
                <button type="submit" class="btn-notification-reject">거절</button>
              </form>
            </div>
          </div>
          <% } } } else { %>
          <div class="notification-empty">받은 초대가 없습니다</div>
          <% } %>
        </div>
      </div>
    </div>

    <div style="width:1px;height:28px;background:var(--border);"></div>

    <div class="av"><%= initials %></div>
    <div>
      <div class="user-info-name"><%= userName %></div>
      <div class="user-info-id"><%= userId %></div>
    </div>

    <a href="logout" style="text-decoration:none;">
      <button class="btn-logout-header">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
          <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
          <polyline points="16 17 21 12 16 7"/>
          <line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
        로그아웃
      </button>
    </a>
  </div>
</div>

<!-- ── 메인 ── -->
<div class="prof-main">
  <div class="prof-container">

    <div class="prof-header">
      <div class="prof-title">프로젝트 관리</div>
      <button class="btn-new-folder" onclick="document.getElementById('folderModal').classList.add('open')">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
          <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        새 폴더
      </button>
    </div>

    <!-- 폴더 섹션 -->
    <% if (folders != null && !folders.isEmpty()) { %>
    <div class="section-label">폴더</div>
    <div class="folder-list">
      <% for (FolderDTO folder : folders) {
           int cnt = 0;
           if (myProjects != null) for (ProjectDTO p : myProjects) if (p.getFolderId() == folder.getId()) cnt++;
      %>
      <!-- 폴더 행 -->
      <div class="folder-row"
           id="folder-row-<%= folder.getId() %>"
           ondragover="onFolderDragOver(event, this)"
           ondragleave="onFolderDragLeave(this)"
           ondrop="onFolderDrop(event, <%= folder.getId() %>)">

        <!-- 폴더 헤더 (클릭 시 토글) -->
        <div class="folder-header" onclick="toggleFolderProjects(<%= folder.getId() %>)">
          <div class="folder-header-left">
            <span class="folder-chevron" id="chevron-<%= folder.getId() %>">
              <!-- chevron right -->
              <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="9 18 15 12 9 6"/>
              </svg>
            </span>
            <div class="folder-icon-wrap">
              <!-- folder icon -->
              <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/>
              </svg>
            </div>

            <div class="folder-text">
  				<div class="folder-name"><%= folder.getName() %></div>
  				<div class="folder-meta">속한 프로젝트 : <%= cnt %></div>
			</div>
          </div>
          <div class="folder-header-right">
            <span class="folder-drag-hint">드래그하여 추가</span>
            <button class="folder-delete-btn"
                    onclick="event.stopPropagation(); if(confirm('폴더를 삭제하시겠습니까?\n프로젝트는 삭제되지 않습니다.')) { location.href='folderAction?action=delete&folderId=<%= folder.getId() %>'; }">
              <!-- trash icon -->
              <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="3 6 5 6 21 6"/>
                <path d="M19 6l-1 14H6L5 6"/>
                <path d="M10 11v6M14 11v6"/>
                <path d="M9 6V4h6v2"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- 폴더 내 프로젝트 (기본 숨김) -->
        <div class="folder-children" id="fp-<%= folder.getId() %>">
          <% if (myProjects != null) { for (ProjectDTO p : myProjects) {
               if (p.getFolderId() == folder.getId()) { %>
          <div class="folder-child-row">
            <div class="child-indent-line"></div>
            <a href="index.jsp?projectId=<%= p.getId() %>" class="project-card child-project-card">
              <button class="project-delete-btn"
                      onclick="event.preventDefault(); event.stopPropagation(); if(confirm('이 프로젝트에서 나가시겠습니까?')) { location.href='leaveProject?id=<%= p.getId() %>'; }">
                <!-- leave icon -->
                <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
                  <polyline points="16 17 21 12 16 7"/>
                  <line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
              </button>
              <button class="project-folder-out-btn"
                      onclick="event.preventDefault(); event.stopPropagation(); if(confirm('폴더에서 꺼내시겠습니까?')) { location.href='folderAction?action=remove&projectId=<%= p.getId() %>'; }">
                꺼내기
              </button>
              <div class="project-card-header">
                <div class="project-icon">
                  <!-- project icon -->
                  <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 11l3 3L22 4"/>
                    <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
                  </svg>
                </div>
                <div style="flex:1;">
                  <div class="project-card-title"><%= p.getTitle() %></div>
                </div>
              </div>
              <% if (p.getContent() != null && !p.getContent().isEmpty()) { %>
              <div class="project-card-content"><%= p.getContent() %></div>
              <% } %>
              <div class="project-card-footer">
                <div class="project-deadline">
                  <!-- calendar icon -->
                  <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="4" width="18" height="18" rx="2"/>
                    <line x1="16" y1="2" x2="16" y2="6"/>
                    <line x1="8" y1="2" x2="8" y2="6"/>
                    <line x1="3" y1="10" x2="21" y2="10"/>
                  </svg>
                  <span style="font-weight:600;color:var(--text2)">마감일:</span>
                  <%= (p.getDeadline() != null && !p.getDeadline().isEmpty()) ? p.getDeadline() : "미정" %>
                </div>
                <span class="project-role role-prof">교수</span>
              </div>
            </a>
          </div>
          <% } } } %>
          <% if (cnt == 0) { %>
          <div class="folder-empty-hint">이 폴더에 프로젝트가 없습니다</div>
          <% } %>
        </div>
      </div>
      <% } %>
    </div>
    <% } %>

    <!-- 폴더에 속하지 않은 프로젝트 섹션 -->
    <%
      int freeCount = 0;
      if (myProjects != null) for (ProjectDTO p : myProjects) if (p.getFolderId() == 0) freeCount++;
    %>
    <% if (freeCount > 0 || (myProjects == null || myProjects.isEmpty())) { %>
    <div class="section-label" style="margin-top:<%= (folders != null && !folders.isEmpty()) ? "36px" : "0" %>;">
      프로젝트 (<%= freeCount %>)
    </div>
    <% } %>

    <% if (myProjects != null && freeCount > 0) { %>
    <div class="project-grid">
      <% for (ProjectDTO project : myProjects) {
           if (project.getFolderId() != 0) continue;
      %>
      <a href="index.jsp?projectId=<%= project.getId() %>"
         class="project-card"
         draggable="true"
         data-project-id="<%= project.getId() %>"
         ondragstart="onProjectDragStart(event, <%= project.getId() %>)"
         ondragend="onProjectDragEnd(event)">

        <button class="project-delete-btn"
                onclick="event.preventDefault(); event.stopPropagation(); if(confirm('이 프로젝트에서 나가시겠습니까?')) { location.href='leaveProject?id=<%= project.getId() %>'; }">
          <!-- leave icon -->
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
        </button>

        <div class="project-card-header">
          <div class="project-icon">
            <!-- project icon -->
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 11l3 3L22 4"/>
              <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
            </svg>
          </div>
          <div style="flex:1;">
            <div class="project-card-title"><%= project.getTitle() %></div>
          </div>
        </div>

        <% if (project.getContent() != null && !project.getContent().isEmpty()) { %>
        <div class="project-card-content"><%= project.getContent() %></div>
        <% } %>

        <div class="project-card-footer">
          <div class="project-deadline">
            <!-- calendar icon -->
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2"/>
              <line x1="16" y1="2" x2="16" y2="6"/>
              <line x1="8" y1="2" x2="8" y2="6"/>
              <line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
            <span style="font-weight:600;color:var(--text2)">마감일:</span>
            <%= (project.getDeadline() != null && !project.getDeadline().isEmpty()) ? project.getDeadline() : "미정" %>
          </div>
          <span class="project-role role-prof">교수</span>
        </div>
      </a>
      <% } %>
    </div>

    <% if (folders != null && !folders.isEmpty()) { %>
    <div class="drag-hint">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2" style="width:13px;height:13px;">
        <path d="M5 9l4-4 4 4M9 5v14M19 15l-4 4-4-4M15 19V5"/>
      </svg>
      프로젝트 카드를 폴더로 드래그하여 이동할 수 있습니다
    </div>
    <% } %>

    <% } else if (myProjects == null || myProjects.isEmpty()) { %>
    <div class="empty-projects">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="1.5">
        <path d="M9 11l3 3L22 4"/>
        <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
      </svg>
      <h3>아직 초대받은 프로젝트가 없어요</h3>
      <p>팀장의 초대를 기다려주세요</p>
    </div>
    <% } %>

  </div>
</div>

<!-- 폴더 만들기 모달 -->
<div id="folderModal" class="modal-bg">
  <div class="modal-box">
    <h3>새 폴더 만들기</h3>
    <form action="<%= request.getContextPath() %>/folderAction" method="post">
      <input type="hidden" name="action" value="create">
      <input type="text" name="folderName" placeholder="폴더 이름을 입력하세요" required>
      <div class="modal-actions">
        <button type="button" class="btn-modal-cancel"
                onclick="document.getElementById('folderModal').classList.remove('open')">취소</button>
        <button type="submit" class="btn-modal-ok">만들기</button>
      </div>
    </form>
  </div>
</div>

<script src="resource/js/professorProject.js"></script>
</body>
</html>
