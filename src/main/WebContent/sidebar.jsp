<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="session.jsp" %>

<%
    // 현재 URL 경로 가져오기
    String path = request.getRequestURI(); // 예: /ProjectOS/list.jsp
    String activeDashboard = path.endsWith("index.jsp") ? "active" : "";
    String activeList      = path.endsWith("list") || path.endsWith("list.jsp") ? "active" : "";
    String activeCalendar  = path.endsWith("calendar.jsp") ? "active" : "";
    String activeTeam      = path.endsWith("team.jsp") ? "active" : "";
%>

<aside class="sidebar">
  <!-- 로고 -->
  <a href="./index.jsp" class="logo">
    <div class="logo">
      <div class="logo-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
          <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
        </svg>
      </div>
      ProjectOS
    </div>
  </a>

  <!-- 메인 네비게이션 -->
  <div class="nav-sec">
    <div class="nav-label">메인</div>

    <a href="./list" class="nav-item <%= activeList %>">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M9 11l3 3L22 4"/>
        <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
      </svg>
      프로젝트
    </a>

    <div class="nav-item <%= activeCalendar %>">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="4" width="18" height="18" rx="2"/>
        <line x1="16" y1="2" x2="16" y2="6"/>
        <line x1="8" y1="2" x2="8" y2="6"/>
        <line x1="3" y1="10" x2="21" y2="10"/>
      </svg>
      캘린더
    </div>

    <div class="nav-item <%= activeTeam %>">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
        <circle cx="9" cy="7" r="4"/>
        <path d="M23 21v-2a4 4 0 00-3-3.87"/>
        <path d="M16 3.13a4 4 0 010 7.75"/>
      </svg>
      팀 멤버
    </div>
    
    <a href="<%= request.getContextPath() %>/inviteMembers" class="nav-item">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
        <circle cx="8.5" cy="7" r="4"/>
        <path d="M20 8v6"/>
        <path d="M17 11h6"/>
    </svg>
       팀원 초대
    </a>
   <a href="<%= request.getContextPath() %>/inviteMembers?type=received" class="nav-item">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
        <circle cx="8.5" cy="7" r="4"/>
        <path d="M20 8v6"/>
        <path d="M17 11h6"/>
    </svg>
       초대 목록
    </a>
    
  </div>

  <!-- 협업 도구 -->
  <div class="nav-sec">
    <div class="nav-label">협업 도구</div>

    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
      </svg>
      팀 채팅 <span class="nav-badge red">2</span>
    </div>

    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z"/>
        <polyline points="13 2 13 9 20 9"/>
      </svg>
      파일 공유
    </div>

    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="3"/>
        <path d="M19.07 4.93a10 10 0 010 14.14M4.93 4.93a10 10 0 000 14.14"/>
      </svg>
      설정
    </div>
  </div>

  <!-- 사용자 영역 -->
  <div class="sidebar-bot">
    <div class="av-row">
      <div class="av"><%= initials %></div>
      <div>
        <div class="av-name"><%= userName %></div>
        <div class="av-role"><%= userId %></div>
      </div>
    </div>

    <% if (loginUser != null) { %>
      <a href="logout" style="text-decoration:none">
        <div class="nav-item" style="margin-top:8px;color:#ef4444">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
          로그아웃
        </div>
      </a>
    <% } else { %>
      <a href="login.jsp" style="text-decoration:none">
        <div class="nav-item" style="margin-top:8px;color:#2563eb">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
          로그인
        </div>
      </a>
    <% } %>
  </div>
</aside>