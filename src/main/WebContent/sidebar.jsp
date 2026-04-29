<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="session.jsp" %>
<%
    String path = request.getRequestURI();
    String activeDashboard = path.endsWith("index.jsp") ? "active" : "";
    String activeList      = path.endsWith("list") || path.endsWith("list.jsp") ? "active" : "";
    String activeTask      = path.endsWith("task.jsp") ? "active" : "";
    String activeCalendar  = path.endsWith("calendar.jsp") ? "active" : "";
    String activeMeetingMinutes = path.contains("meetingMinutes") ? "active" : "";
    String activeTeam      = path.endsWith("team.jsp") ? "active" : "";
    String activeTeamMember = path.contains("/teamMemberManage.jsp") ? "active" : "";
    String activeBookRecommend = path.contains("bookRecommend") ? "active" : "";
    
    Integer currentProjectId = (Integer) session.getAttribute("currentProjectId");
    String projectParam = request.getParameter("projectId");
    if (projectParam != null && !projectParam.isEmpty()) {
        try {
            currentProjectId = Integer.parseInt(projectParam);
        } catch (NumberFormatException e) { }
    }
    String projectQuery = (currentProjectId != null) ? "?projectId=" + currentProjectId : "";

    // projectId 처리
    String sidebarProjectId = request.getParameter("id");
    if (sidebarProjectId == null || sidebarProjectId.trim().isEmpty()) {
        sidebarProjectId = request.getParameter("projectId");
    }
    if (sidebarProjectId == null || sidebarProjectId.trim().isEmpty()) {
        Object pidObj = request.getAttribute("projectId");
        if (pidObj != null) {
            sidebarProjectId = String.valueOf(pidObj);
        }
    }
%>

<aside class="sidebar">
  <a href="./index.jsp<%= projectQuery %>" class="logo">
    <div class="logo">
      <div class="logo-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
          <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
        </svg>
      </div>
      ProjectOS
    </div>
  </a>

  <div class="nav-sec">
    <div class="nav-label">메인</div>
    <a href="./index.jsp<%= projectQuery %>" class="nav-item <%= activeDashboard %>">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="3" width="7" height="7"/>
        <rect x="14" y="3" width="7" height="7"/>
        <rect x="14" y="14" width="7" height="7"/>
        <rect x="3" y="14" width="7" height="7"/>
      </svg>
      대시보드
    </a>
<%
String lastProjectId = (String) session.getAttribute("lastProjectId");
String teamMemberUrl;

if (lastProjectId != null && !lastProjectId.trim().isEmpty()) {
    teamMemberUrl = request.getContextPath() + "/teamMemberManage.jsp?projectId=" + lastProjectId;
} else {
    teamMemberUrl = "javascript:alert('먼저 프로젝트를 선택하세요.')";
}
%>
   <a href="<%= teamMemberUrl %>" class="nav-item <%= activeTeamMember %>">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
       <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
       <circle cx="9" cy="7" r="4"/>
       <path d="M23 21v-2a4 4 0 00-3-3.87"/>
       <path d="M16 3.13a4 4 0 010 7.75"/>
     </svg>
     팀원 관리
    </a>
    <a href="task.jsp<%= projectQuery %>" class="nav-item">

      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="4" width="18" height="18" rx="2"/>
        <line x1="16" y1="2" x2="16" y2="6"/>
        <line x1="8" y1="2" x2="8" y2="6"/>
        <line x1="3" y1="10" x2="21" y2="10"/>
      </svg>
      업무 관리
    </a>
    <a href="calendar.jsp<%= projectQuery %>" class="nav-item <%= activeCalendar %>">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="4" width="18" height="18" rx="2"/>
        <line x1="16" y1="2" x2="16" y2="6"/>
        <line x1="8" y1="2" x2="8" y2="6"/>
        <line x1="3" y1="10" x2="21" y2="10"/>
      </svg>
      일정 관리
      </a>
    <a href="meetingMinutes<%= projectQuery %>" class="nav-item <%= activeMeetingMinutes %>">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
        <polyline points="14 2 14 8 20 8"/>
        <line x1="16" y1="13" x2="8" y2="13"/>
        <line x1="16" y1="17" x2="8" y2="17"/>
        <polyline points="10 9 9 9 8 9"/>
      </svg>
      회의록
    </a>
    <a href="feedback<%= projectQuery %>" class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
        <line x1="9" y1="10" x2="15" y2="10"/>
        <line x1="9" y1="14" x2="13" y2="14"/>
      </svg>
      피드백
    </a>
    <a href="bookRecommend" class="nav-item <%= activeBookRecommend %>">
	  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
	    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
	  </svg>
	  도서 추천
	</a>
    <% if (loginUser == null || !"professor".equals(loginUser.getRole())) { %>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
      </svg>
      팀 채팅 <span class="nav-badge red">2</span>
    </div>
    <% } %>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z"/>
        <polyline points="13 2 13 9 20 9"/>
      </svg>
      파일 공유
    </div>
  </div>

  <div class="nav-sec">
    <div class="nav-label">설정</div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="3"/>
        <path d="M19.07 4.93a10 10 0 010 14.14M4.93 4.93a10 10 0 000 14.14"/>
      </svg>
      설정
    </div>
  </div>

  <div class="sidebar-bot">
    <div class="av-row">
      <div class="av"><%= initials %></div>
      <div>
        <div class="av-name"><%= userName %></div>
        <div class="av-role"><%= userId %></div>
      </div>
    </div>
    <% if (loginUser != null) { %>
      <%
        String projectListUrl = "professor".equals(loginUser.getRole()) ? "professorProject.jsp" : "projects.jsp";
      %>
      <a href="<%= projectListUrl %>" style="text-decoration:none">
        <div class="nav-item" style="margin-top:8px;color:#2563eb">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/>
          </svg>
          프로젝트 목록
        </div>
      </a>
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
