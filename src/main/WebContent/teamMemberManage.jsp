<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.LoginDTO" %>
<%@ page import="model.ProjectDAO" %>
<%@ page import="model.ProjectDTO" %>
<%@ page import="model.ProjectMemberDAO" %>
<%@ page import="model.ProjectMemberDTO" %>
<%
String projectIdStr = request.getParameter("projectId");
int projectId = 0;

if (projectIdStr == null || projectIdStr.trim().isEmpty() || "null".equals(projectIdStr)) {
    String lastProjectId = (String) session.getAttribute("lastProjectId");
    if (lastProjectId != null && !lastProjectId.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/teamMemberManage.jsp?projectId=" + lastProjectId);
        return;
    } else {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
}

projectId = Integer.parseInt(projectIdStr);
session.setAttribute("lastProjectId", String.valueOf(projectId));

Object loginUserObj = session.getAttribute("loginUser");
if (loginUserObj == null && session.getAttribute("id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String msg     = request.getParameter("msg");
String profMsg = request.getParameter("profMsg");

String loginId = null;
if (session.getAttribute("id") != null) {
    loginId = (String) session.getAttribute("id");
} else if (loginUserObj != null) {
    LoginDTO loginDTO = (LoginDTO) loginUserObj;
    loginId = loginDTO.getId();
}

ProjectMemberDAO dao = new ProjectMemberDAO();
List<ProjectMemberDTO> studentList   = dao.getStudentsByProject(projectId);
List<ProjectMemberDTO> professorList = dao.getProfessorsByProject(projectId);

ProjectDAO projectDao = new ProjectDAO();
ProjectDTO project = projectDao.getById(projectId);

String teamLeaderId = null;
if (project != null) teamLeaderId = project.getTeam_leader();

boolean amILeader = loginId != null && loginId.equals(teamLeaderId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>팀원 관리 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
  .tm-wrap { max-width: 900px; margin: 28px auto; padding: 0 8px; }

  .section-card {
    background: #fff;
    border: 1px solid var(--border);
    border-radius: 14px;
    box-shadow: var(--shadow-sm);
    padding: 24px 28px;
    margin-bottom: 20px;
  }

  .section-head {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 18px;
  }
  .section-title {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 16px; font-weight: 800; color: var(--text);
    display: flex; align-items: center; gap: 8px;
  }
  .section-title .cnt {
    font-size: 12px; font-weight: 700;
    background: var(--blue-soft); color: var(--blue);
    padding: 2px 8px; border-radius: 20px;
  }
  .section-title.prof-title .cnt {
    background: #faf5ff; color: #7c3aed;
  }

  /* 메시지 */
  .msg-box {
    padding: 11px 16px; border-radius: 8px; font-size: 13px;
    margin-bottom: 16px;
    background: var(--blue-soft); color: var(--blue);
    border: 1px solid #bfdbfe;
  }

  /* 초대 폼 */
  .invite-row {
    display: flex; gap: 10px; margin-bottom: 0;
  }
  .invite-row input[type="text"] {
    flex: 1; padding: 10px 14px;
    border: 1.5px solid var(--border); border-radius: 8px;
    font-size: 13px; font-family: inherit; outline: none;
    transition: border-color .2s;
  }
  .invite-row input[type="text"]:focus { border-color: var(--blue); }
  .btn-invite {
    background: var(--blue); color: #fff; border: none;
    border-radius: 8px; padding: 10px 20px;
    font-size: 13px; font-weight: 700; cursor: pointer; white-space: nowrap;
  }
  .btn-invite:hover { background: var(--blue-dark); }
  .btn-invite.prof {
    background: #7c3aed;
  }
  .btn-invite.prof:hover { background: #6d28d9; }

  /* 테이블 */
  .tm-table { width: 100%; border-collapse: collapse; margin-top: 18px; font-size: 13px; }
  .tm-table th {
    text-align: left; padding: 9px 12px;
    font-size: 11px; font-weight: 700; color: var(--muted);
    text-transform: uppercase; letter-spacing: .6px;
    border-bottom: 2px solid var(--border);
  }
  .tm-table td {
    padding: 12px 12px; border-bottom: 1px solid var(--border);
    color: var(--text2); vertical-align: middle;
  }
  .tm-table tr:last-child td { border-bottom: none; }
  .tm-table tbody tr:hover td { background: var(--blue-light); }

  /* 배지 */
  .badge-leader { background: #fffbeb; color: #d97706; font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 20px; }
  .badge-student { background: var(--blue-soft); color: var(--blue); font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 20px; }
  .badge-prof   { background: #faf5ff; color: #7c3aed; font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 20px; }

  .status-invited  { color: #2563eb; font-weight: 600; }
  .status-accepted { color: #16a34a; font-weight: 600; }
  .status-rejected { color: #dc2626; font-weight: 600; }

  /* 액션 버튼 */
  .btn-sm {
    border: none; border-radius: 6px; padding: 5px 12px;
    font-size: 12px; font-weight: 700; cursor: pointer;
  }
  .btn-yellow { background: #fffbeb; color: #d97706; border: 1px solid #fde68a; }
  .btn-yellow:hover { background: #fef3c7; }
  .btn-red    { background: var(--red-light); color: var(--red); border: 1px solid #fecaca; }
  .btn-red:hover { background: #fecaca; }

  .inline-form { display: inline-block; margin: 0 2px; }
  .muted { color: var(--muted2); font-size: 12px; }

  .empty-row td { text-align: center; color: var(--muted); padding: 28px; font-size: 13px; }

  /* 구분선 */
  .divider { height: 1px; background: var(--border); margin: 20px 0; }
</style>
</head>
<body>
<jsp:include page="sidebar.jsp"/>

<div class="main">
<div class="tm-wrap">

  <!-- 페이지 타이틀 -->
  <div style="margin-bottom:20px;">
    <h1 style="font-family:'Plus Jakarta Sans',sans-serif; font-size:24px; font-weight:800; color:var(--text); margin:0; letter-spacing:-0.5px;">팀원 관리</h1>
  </div>

  <!-- ── 팀원 섹션 ── -->
  <div class="section-card">
    <div class="section-head">
      <div class="section-title">
        👥 팀원 목록
        <span class="cnt"><%= studentList != null ? studentList.size() : 0 %>명</span>
      </div>
    </div>

    <!-- 팀원 초대 폼 (팀장만) -->
    <% if (amILeader) { %>
    <form action="<%= request.getContextPath() %>/teamMemberAction" method="post" class="invite-row">
      <input type="hidden" name="action" value="invite">
      <input type="hidden" name="projectId" value="<%= projectId %>">
      <input type="text" name="memberId" placeholder="초대할 학생 아이디를 입력하세요" required>
      <button type="submit" class="btn-invite">팀원 초대</button>
    </form>
    <% if (msg != null && !msg.trim().isEmpty()) { %>
      <div class="msg-box" style="margin-top:12px; margin-bottom:0;"><%= msg %></div>
    <% } %>
    <% } %>

    <!-- 팀원 테이블 -->
    <table class="tm-table">
      <thead>
        <tr>
          <th>이름</th>
          <th>아이디</th>
          <th>역할</th>
          <th>상태</th>
          <th>초대일</th>
          <% if (amILeader) { %><th>관리</th><% } %>
        </tr>
      </thead>
      <tbody>
        <% if (studentList == null || studentList.isEmpty()) { %>
          <tr class="empty-row"><td colspan="<%= amILeader ? 6 : 5 %>">등록된 팀원이 없습니다.</td></tr>
        <% } else {
             for (ProjectMemberDTO dto : studentList) {
               boolean isMe     = loginId != null && loginId.equals(dto.getMemberId());
               boolean isLeader = teamLeaderId != null && teamLeaderId.equals(dto.getMemberId());
        %>
        <tr>
          <td><strong><%= dto.getName() != null ? dto.getName() : "-" %></strong></td>
          <td style="color:var(--muted)"><%= dto.getMemberId() %></td>
          <td>
            <% if (isLeader) { %>
              <span class="badge-leader">팀장</span>
            <% } else { %>
              <span class="badge-student">팀원</span>
            <% } %>
          </td>
          <td><span class="status-<%= dto.getStatus() %>"><%= dto.getStatus() %></span></td>
          <td style="color:var(--muted);font-size:12px"><%= dto.getInvitedAt() != null ? dto.getInvitedAt().substring(0, 16) : "-" %></td>
          <% if (amILeader) { %>
          <td>
            <% if ("accepted".equals(dto.getStatus()) && !isLeader && !isMe) { %>
              <form action="<%= request.getContextPath() %>/teamMemberAction" method="post" class="inline-form">
                <input type="hidden" name="action" value="setLeader">
                <input type="hidden" name="projectId" value="<%= dto.getProjectId() %>">
                <input type="hidden" name="memberId" value="<%= dto.getMemberId() %>">
                <button type="submit" class="btn-sm btn-yellow">팀장 지정</button>
              </form>
            <% } %>
            <% if (!isLeader && !isMe) { %>
              <form action="<%= request.getContextPath() %>/teamMemberAction" method="post" class="inline-form"
                    onsubmit="return confirm('팀원을 제외하시겠습니까?')">
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="projectId" value="<%= dto.getProjectId() %>">
                <input type="hidden" name="memberId" value="<%= dto.getMemberId() %>">
                <button type="submit" class="btn-sm btn-red">제외</button>
              </form>
            <% } %>
            <% if (isLeader || isMe) { %><span class="muted">-</span><% } %>
          </td>
          <% } %>
        </tr>
        <% } } %>
      </tbody>
    </table>
  </div>

  <!-- ── 교수 섹션 (팀장에게만 표시) ── -->
  <% if (amILeader) { %>
  <div class="section-card">
    <div class="section-head">
      <div class="section-title prof-title">
        🎓 교수 목록
        <span class="cnt"><%= professorList != null ? professorList.size() : 0 %>명</span>
      </div>
    </div>

    <!-- 교수 초대 폼 -->
    <form action="<%= request.getContextPath() %>/teamMemberAction" method="post" class="invite-row">
      <input type="hidden" name="action" value="inviteProfessor">
      <input type="hidden" name="projectId" value="<%= projectId %>">
      <input type="text" name="memberId" placeholder="초대할 교수 아이디를 입력하세요" required>
      <button type="submit" class="btn-invite prof">교수 초대</button>
    </form>

    <% if (profMsg != null && !profMsg.trim().isEmpty()) { %>
      <div class="msg-box" style="margin-top:12px; margin-bottom:0;"><%= profMsg %></div>
    <% } %>

    <!-- 교수 테이블 -->
    <table class="tm-table">
      <thead>
        <tr>
          <th>이름</th>
          <th>아이디</th>
          <th>구분</th>
          <th>상태</th>
          <th>초대일</th>
          <th>관리</th>
        </tr>
      </thead>
      <tbody>
        <% if (professorList == null || professorList.isEmpty()) { %>
          <tr class="empty-row"><td colspan="6">초대된 교수가 없습니다.</td></tr>
        <% } else {
             for (ProjectMemberDTO dto : professorList) {
        %>
        <tr>
          <td><strong><%= dto.getName() != null ? dto.getName() : "-" %></strong></td>
          <td style="color:var(--muted)"><%= dto.getMemberId() %></td>
          <td><span class="badge-prof">교수</span></td>
          <td><span class="status-<%= dto.getStatus() %>"><%= dto.getStatus() %></span></td>
          <td style="color:var(--muted);font-size:12px"><%= dto.getInvitedAt() != null ? dto.getInvitedAt().substring(0, 16) : "-" %></td>
          <td>
            <form action="<%= request.getContextPath() %>/teamMemberAction" method="post" class="inline-form"
                  onsubmit="return confirm('교수를 제외하시겠습니까?')">
              <input type="hidden" name="action" value="remove">
              <input type="hidden" name="projectId" value="<%= dto.getProjectId() %>">
              <input type="hidden" name="memberId" value="<%= dto.getMemberId() %>">
              <button type="submit" class="btn-sm btn-red">제외</button>
            </form>
          </td>
        </tr>
        <% } } %>
      </tbody>
    </table>
  </div>
  <% } %>

  <!-- 팀원(비팀장)에게는 교수 목록만 읽기 전용으로 표시 -->
  <% if (!amILeader && professorList != null && !professorList.isEmpty()) { %>
  <div class="section-card">
    <div class="section-head">
      <div class="section-title prof-title">
        🎓 교수 목록
        <span class="cnt"><%= professorList.size() %>명</span>
      </div>
    </div>
    <table class="tm-table">
      <thead>
        <tr><th>이름</th><th>아이디</th><th>구분</th><th>상태</th></tr>
      </thead>
      <tbody>
        <% for (ProjectMemberDTO dto : professorList) { %>
        <tr>
          <td><strong><%= dto.getName() != null ? dto.getName() : "-" %></strong></td>
          <td style="color:var(--muted)"><%= dto.getMemberId() %></td>
          <td><span class="badge-prof">교수</span></td>
          <td><span class="status-<%= dto.getStatus() %>"><%= dto.getStatus() %></span></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>

</div>
</div>
</body>
</html>
