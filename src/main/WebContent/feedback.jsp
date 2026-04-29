<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.FeedbackDTO, model.LoginDTO" %>
<%
    int projectId = (Integer) request.getAttribute("projectId");
    String myRole = (String) request.getAttribute("myRole");
    List<FeedbackDTO> feedbackList = (List<FeedbackDTO>) request.getAttribute("feedbackList");
    LoginDTO loginUser = (LoginDTO) request.getAttribute("loginUser");
    boolean isProfessor = "professor".equals(myRole);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>피드백 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
.fb-wrap { max-width: 860px; width: 100%; margin: 28px 0; }

.fb-header { display:flex; align-items:center; justify-content:space-between; margin-bottom: 20px; }
.fb-title  { font-family:'Plus Jakarta Sans',sans-serif; font-size:20px; font-weight:800; color:var(--text); }

.btn-write { background:var(--blue); color:#fff; border:none; border-radius:8px;
             padding:9px 20px; font-size:13px; font-weight:700; cursor:pointer; }
.btn-write:hover { background:var(--blue-dark); }

/* 작성 폼 */
.write-form { background:#fff; border:1px solid var(--border); border-radius:14px;
              padding:24px; margin-bottom:20px; box-shadow:var(--shadow-sm); display:none; }
.write-form.open { display:block; }
.write-form h3 { font-size:15px; font-weight:700; margin-bottom:16px; color:var(--text); }
.write-form input, .write-form textarea {
    width:100%; padding:10px 14px; border:1.5px solid var(--border);
    border-radius:8px; font-size:14px; font-family:inherit;
    outline:none; transition:border-color .2s; box-sizing:border-box;
}
.write-form input:focus, .write-form textarea:focus { border-color:var(--blue); }
.write-form textarea { min-height:120px; resize:vertical; margin-top:10px; }
.form-actions { display:flex; gap:8px; justify-content:flex-end; margin-top:12px; }
.btn-save   { background:var(--blue); color:#fff; border:none; border-radius:8px; padding:9px 22px; font-size:13px; font-weight:700; cursor:pointer; }
.btn-cancel { background:#fff; color:var(--muted); border:1px solid var(--border); border-radius:8px; padding:9px 18px; font-size:13px; font-weight:600; cursor:pointer; }

/* 피드백 카드 */
.fb-card { background:#fff; border:1px solid var(--border); border-radius:14px;
           padding:20px 24px; margin-bottom:12px; cursor:pointer;
           box-shadow:var(--shadow-sm); transition:all .2s; }
.fb-card:hover { border-color:#93c5fd; box-shadow:0 4px 16px rgba(37,99,235,.1); transform:translateY(-2px); }
.fb-card-title { font-size:15px; font-weight:700; color:var(--text); margin-bottom:6px; }
.fb-card-meta  { font-size:12px; color:var(--muted); display:flex; gap:12px; align-items:center; }
.fb-card-preview { font-size:13px; color:var(--text2); margin-top:10px;
                   overflow:hidden; display:-webkit-box; -webkit-line-clamp:2;
                   -webkit-box-orient:vertical; line-height:1.6; }
.badge-prof { background:#eff6ff; color:var(--blue); font-size:11px; font-weight:700;
              padding:2px 8px; border-radius:20px; }

.empty { text-align:center; padding:60px 20px; color:var(--muted); font-size:14px; }
</style>
</head>
<body>
<jsp:include page="sidebar.jsp"/>

<div class="main" style="display:flex; align-items:flex-start; justify-content:center;">
<div class="fb-wrap">

  <div class="fb-header">
    <span class="fb-title">📋 피드백</span>
    <% if (isProfessor) { %>
      <button class="btn-write" onclick="toggleForm()">+ 피드백 작성</button>
    <% } %>
  </div>

  <!-- 교수 작성 폼 -->
  <% if (isProfessor) { %>
  <div class="write-form" id="writeForm">
    <h3>새 피드백 작성</h3>
    <form action="feedback" method="post">
      <input type="hidden" name="action" value="write">
      <input type="hidden" name="projectId" value="<%= projectId %>">
      <input type="text" name="title" placeholder="제목을 입력하세요" required>
      <textarea name="content" placeholder="피드백 내용을 입력하세요" required></textarea>
      <div class="form-actions">
        <button type="button" class="btn-cancel" onclick="toggleForm()">취소</button>
        <button type="submit" class="btn-save">등록</button>
      </div>
    </form>
  </div>
  <% } %>

  <!-- 피드백 목록 -->
  <% if (feedbackList == null || feedbackList.isEmpty()) { %>
    <div class="empty">아직 등록된 피드백이 없습니다.</div>
  <% } else { %>
    <% for (FeedbackDTO fb : feedbackList) { %>
    <div class="fb-card" onclick="location.href='feedback?action=view&projectId=<%= projectId %>&id=<%= fb.getId() %>'">
      <div class="fb-card-title"><%= fb.getTitle() %></div>
      <div class="fb-card-meta">
        <span class="badge-prof">교수</span>
        <span><%= fb.getAuthorName() != null ? fb.getAuthorName() : fb.getAuthorId() %></span>
        <span><%= fb.getCreatedAt() %></span>
        <% if (fb.getUpdatedAt() != null) { %><span style="color:#93c5fd">(수정됨)</span><% } %>
      </div>
      <div class="fb-card-preview"><%= fb.getContent() %></div>
    </div>
    <% } %>
  <% } %>

</div>
</div>

<script>
function toggleForm() {
  const f = document.getElementById('writeForm');
  f.classList.toggle('open');
}
</script>
</body>
</html>
