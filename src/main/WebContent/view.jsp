<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.LoginDTO, model.*" %>
<%
  model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
  String userName = (loginUser != null) ? loginUser.getName() : "게스트";
  String userId   = (loginUser != null) ? loginUser.getId()   : "";
  String initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;
  String error = (String) request.getAttribute("error");
  model.ProjectDTO dto = (model.ProjectDTO) request.getAttribute("dto");

  List<LoginDTO> members = null;
  if (dto != null) {
      ProjectMemberDAO memberDAO = new ProjectMemberDAO();
      members = memberDAO.getMembersByProject(dto.getId());
  }
  String memberMsg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= dto != null ? dto.getTitle() : "프로젝트 상세" %> — ProjectOS</title>
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
    <button class="topbar-back" onclick="location.href='list'">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
        <polyline points="15 18 9 12 15 6"/>
      </svg>
    </button>
    <div>
      <div class="topbar-title"><%= dto != null ? dto.getTitle() : "프로젝트 상세" %></div>
      <div class="topbar-sub">프로젝트 상세 정보</div>
    </div>
    <% if (dto != null) { %>
    <div style="margin-left:auto;display:flex;gap:8px">
      <a href="editProject?id=<%= dto.getId() %>">
        <button class="btn btn-secondary btn-sm">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
            <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
          </svg>수정
        </button>
      </a>
      <button class="btn btn-danger btn-sm" onclick="document.getElementById('deleteModal').classList.add('open')">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/>
          <path d="M10 11v6"/><path d="M14 11v6"/>
        </svg>삭제
      </button>
    </div>
    <% } %>
  </div>
  <div class="page-content">
    <% if (error != null) { %>
      <div class="alert alert-danger"><%= error %></div>
    <% } else if (dto != null) { %>
    <div class="card">
      <div class="card-body">
        <div class="detail-meta">
          <div class="detail-meta-item"><strong>마감일</strong>&nbsp;<%= dto.getDeadline() != null && !dto.getDeadline().isEmpty() ? dto.getDeadline() : "미정" %></div>
          <div class="detail-meta-item"><strong>팀장</strong>&nbsp;<%= dto.getTeam_leader() != null && !dto.getTeam_leader().isEmpty() ? dto.getTeam_leader() : "-" %></div>
          <div class="detail-meta-item"><strong>등록일</strong>&nbsp;<%= dto.getFormattedCreatedAt() %></div>
        </div>
        <div class="detail-content"><%= dto.getContent() != null ? dto.getContent() : "" %></div>
      </div>
    </div>

    <!-- 팀원 관리 -->
    <div class="card" style="margin-top:16px">
      <div class="card-body">
        <div style="font-weight:600;font-size:15px;margin-bottom:14px">팀원 관리</div>

        <% if (memberMsg != null && !memberMsg.isEmpty()) { %>
          <div style="padding:10px 14px;background:#eff6ff;color:#2563eb;border-radius:8px;font-size:13px;margin-bottom:12px">
            <%= memberMsg %>
          </div>
        <% } %>

        <!-- 팀원 추가 폼 -->
        <form method="post" action="projectMember" style="display:flex;gap:8px;margin-bottom:16px">
          <input type="hidden" name="action" value="add">
          <input type="hidden" name="projectId" value="<%= dto.getId() %>">
          <input type="text" name="memberId" placeholder="추가할 팀원 아이디 입력"
                 style="flex:1;max-width:260px;padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:14px" required>
          <button type="submit" class="btn btn-primary btn-sm">+ 추가</button>
        </form>

        <!-- 팀원 목록 -->
        <% if (members == null || members.isEmpty()) { %>
          <p style="color:#94a3b8;font-size:14px">등록된 팀원이 없습니다.</p>
        <% } else { %>
          <table style="width:100%;border-collapse:collapse;font-size:14px">
            <thead>
              <tr style="border-bottom:1px solid #e2e8f0;color:#64748b;font-size:12px">
                <th style="padding:8px;text-align:left">이름</th>
                <th style="padding:8px;text-align:left">아이디</th>
                <th style="padding:8px"></th>
              </tr>
            </thead>
            <tbody>
            <% for (LoginDTO m : members) { %>
              <tr style="border-bottom:1px solid #f1f5f9">
                <td style="padding:10px 8px"><%= m.getName() %></td>
                <td style="padding:10px 8px;color:#64748b"><%= m.getId() %></td>
                <td style="padding:10px 8px;text-align:right">
                  <form method="post" action="projectMember" style="display:inline"
                        onsubmit="return confirm('<%= m.getName() %> 님을 팀에서 제외하시겠습니까?')">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="projectId" value="<%= dto.getId() %>">
                    <input type="hidden" name="memberId" value="<%= m.getId() %>">
                    <button type="submit" class="btn btn-danger btn-sm">제외</button>
                  </form>
                </td>
              </tr>
            <% } %>
            </tbody>
          </table>
        <% } %>
      </div>
    </div>
    <div class="modal-overlay" id="deleteModal">
      <div class="modal-box">
        <div class="modal-title">프로젝트 삭제</div>
        <div class="modal-desc">"<%= dto.getTitle() %>" 프로젝트를 삭제하면 복구할 수 없어요. 정말 삭제할까요?</div>
        <div class="modal-actions">
          <button class="btn btn-secondary" onclick="document.getElementById('deleteModal').classList.remove('open')">취소</button>
          <form action="deleteProject" method="post" style="display:inline">
            <input type="hidden" name="id" value="<%= dto.getId() %>">
            <button type="submit" class="btn btn-danger">삭제</button>
          </form>
        </div>
      </div>
    </div>
    <% } %>
  </div>
</div>
</body>
</html>
