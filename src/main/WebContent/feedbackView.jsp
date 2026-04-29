<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.FeedbackDTO, model.FeedbackCommentDTO, model.LoginDTO" %>
<%
    int projectId             = (Integer) request.getAttribute("projectId");
    String myRole             = (String)  request.getAttribute("myRole");
    FeedbackDTO feedback      = (FeedbackDTO) request.getAttribute("feedback");
    List<FeedbackCommentDTO> comments = (List<FeedbackCommentDTO>) request.getAttribute("comments");
    LoginDTO loginUser        = (LoginDTO) request.getAttribute("loginUser");

    boolean isProfessor = "professor".equals(myRole);
    boolean isAuthor    = loginUser.getId().equals(feedback.getAuthorId());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>피드백 상세 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
.fb-wrap { max-width: 860px; width:100%; margin: 28px 0; }

/* 뒤로가기 */
.back-btn { display:inline-flex; align-items:center; gap:6px; color:var(--muted);
            font-size:13px; font-weight:600; cursor:pointer; margin-bottom:16px;
            background:none; border:none; padding:0; }
.back-btn:hover { color:var(--blue); }

/* 피드백 본문 */
.fb-box { background:#fff; border:1px solid var(--border); border-radius:14px;
          padding:28px; box-shadow:var(--shadow-sm); margin-bottom:16px; }
.fb-box-title { font-family:'Plus Jakarta Sans',sans-serif; font-size:20px;
                font-weight:800; color:var(--text); margin-bottom:12px; }
.fb-box-meta  { font-size:12px; color:var(--muted); display:flex; gap:12px;
                align-items:center; margin-bottom:20px; padding-bottom:16px;
                border-bottom:1px solid var(--border); }
.badge-prof { background:#eff6ff; color:var(--blue); font-size:11px; font-weight:700;
              padding:2px 8px; border-radius:20px; }
.fb-box-content { font-size:14px; color:var(--text2); line-height:1.8; white-space:pre-wrap; }

/* 수정 폼 */
.edit-form { display:none; }
.edit-form.open { display:block; }
.edit-form input, .edit-form textarea {
    width:100%; padding:10px 14px; border:1.5px solid var(--border);
    border-radius:8px; font-size:14px; font-family:inherit;
    outline:none; transition:border-color .2s; box-sizing:border-box;
}
.edit-form input:focus, .edit-form textarea:focus { border-color:var(--blue); }
.edit-form textarea { min-height:140px; resize:vertical; margin-top:10px; }

/* 버튼 */
.btn-row { display:flex; gap:8px; justify-content:flex-end; margin-top:16px; }
.btn-edit { background:var(--blue-soft); color:var(--blue); border:none; border-radius:8px;
            padding:8px 18px; font-size:13px; font-weight:700; cursor:pointer; }
.btn-del  { background:var(--red-light); color:var(--red); border:none; border-radius:8px;
            padding:8px 18px; font-size:13px; font-weight:700; cursor:pointer; }
.btn-save { background:var(--blue); color:#fff; border:none; border-radius:8px;
            padding:9px 22px; font-size:13px; font-weight:700; cursor:pointer; }
.btn-cancel { background:#fff; color:var(--muted); border:1px solid var(--border);
              border-radius:8px; padding:9px 18px; font-size:13px; font-weight:600; cursor:pointer; }

/* 댓글 영역 */
.comment-section { background:#fff; border:1px solid var(--border); border-radius:14px;
                   padding:24px; box-shadow:var(--shadow-sm); }
.comment-title { font-size:14px; font-weight:700; color:var(--text2); margin-bottom:16px; }

.comment-item { padding:14px 0; border-bottom:1px solid var(--border); }
.comment-item:last-child { border-bottom:none; }
.comment-meta { display:flex; align-items:center; gap:10px; margin-bottom:6px; }
.comment-author { font-size:13px; font-weight:700; color:var(--text); }
.comment-time   { font-size:11px; color:var(--muted); }
.comment-content { font-size:13px; color:var(--text2); line-height:1.7; }
.comment-del { margin-left:auto; background:none; border:none; color:var(--muted2);
               font-size:12px; cursor:pointer; padding:2px 6px; border-radius:4px; }
.comment-del:hover { color:var(--red); background:var(--red-light); }

/* 댓글 입력 */
.comment-form { margin-top:16px; display:flex; gap:10px; align-items:flex-end; }
.comment-form textarea { flex:1; padding:10px 14px; border:1.5px solid var(--border);
    border-radius:8px; font-size:13px; font-family:inherit; outline:none;
    resize:none; height:60px; transition:border-color .2s; }
.comment-form textarea:focus { border-color:var(--blue); }
.btn-comment { background:var(--blue); color:#fff; border:none; border-radius:8px;
               padding:10px 20px; font-size:13px; font-weight:700; cursor:pointer;
               white-space:nowrap; height:60px; }
.btn-comment:hover { background:var(--blue-dark); }

.empty-comment { text-align:center; padding:24px; color:var(--muted); font-size:13px; }
</style>
</head>
<body>
<jsp:include page="sidebar.jsp"/>

<div class="main" style="display:flex; align-items:flex-start; justify-content:center;">
<div class="fb-wrap">

  <!-- 뒤로가기 -->
  <button class="back-btn" onclick="history.back()">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
      <polyline points="15 18 9 12 15 6"/>
    </svg>
    피드백 목록으로
  </button>

  <!-- 피드백 본문 -->
  <div class="fb-box">

    <!-- 보기 모드 -->
    <div id="viewMode">
      <div class="fb-box-title"><%= feedback.getTitle() %></div>
      <div class="fb-box-meta">
        <span class="badge-prof">교수</span>
        <span><%= feedback.getAuthorName() != null ? feedback.getAuthorName() : feedback.getAuthorId() %></span>
        <span><%= feedback.getCreatedAt() %></span>
        <% if (feedback.getUpdatedAt() != null) { %>
          <span style="color:#93c5fd">(수정됨 · <%= feedback.getUpdatedAt() %>)</span>
        <% } %>
      </div>
      <div class="fb-box-content"><%= feedback.getContent() %></div>

      <!-- 교수 본인만 수정/삭제 버튼 표시 -->
      <% if (isProfessor && isAuthor) { %>
      <div class="btn-row">
        <button class="btn-edit" onclick="toggleEdit()">수정</button>
        <form action="feedback" method="post" style="display:inline"
              onsubmit="return confirm('피드백을 삭제하시겠습니까?')">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="projectId" value="<%= projectId %>">
          <input type="hidden" name="id" value="<%= feedback.getId() %>">
          <button type="submit" class="btn-del">삭제</button>
        </form>
      </div>
      <% } %>
    </div>

    <!-- 수정 모드 (교수 본인만) -->
    <% if (isProfessor && isAuthor) { %>
    <div class="edit-form" id="editForm">
      <form action="feedback" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="projectId" value="<%= projectId %>">
        <input type="hidden" name="id" value="<%= feedback.getId() %>">
        <input type="text" name="title" value="<%= feedback.getTitle() %>" required>
        <textarea name="content" required><%= feedback.getContent() %></textarea>
        <div class="btn-row">
          <button type="button" class="btn-cancel" onclick="toggleEdit()">취소</button>
          <button type="submit" class="btn-save">저장</button>
        </div>
      </form>
    </div>
    <% } %>

  </div>

  <!-- 댓글 영역 -->
  <div class="comment-section">
    <div class="comment-title">댓글 <%= comments != null ? comments.size() : 0 %>개</div>

    <!-- 댓글 목록 -->
    <% if (comments == null || comments.isEmpty()) { %>
      <div class="empty-comment">아직 댓글이 없습니다. 첫 댓글을 남겨보세요.</div>
    <% } else { %>
      <% for (FeedbackCommentDTO c : comments) { %>
      <div class="comment-item">
        <div class="comment-meta">
          <span class="comment-author"><%= c.getAuthorName() != null ? c.getAuthorName() : c.getAuthorId() %></span>
          <span class="comment-time"><%= c.getCreatedAt() %></span>
          <% if (loginUser.getId().equals(c.getAuthorId())) { %>
          <form action="feedback" method="post" style="margin-left:auto"
                onsubmit="return confirm('댓글을 삭제하시겠습니까?')">
            <input type="hidden" name="action" value="deleteComment">
            <input type="hidden" name="projectId" value="<%= projectId %>">
            <input type="hidden" name="feedbackId" value="<%= feedback.getId() %>">
            <input type="hidden" name="commentId" value="<%= c.getId() %>">
            <button type="submit" class="comment-del">삭제</button>
          </form>
          <% } %>
        </div>
        <div class="comment-content"><%= c.getContent() %></div>
      </div>
      <% } %>
    <% } %>

    <!-- 댓글 입력 (모든 프로젝트 멤버) -->
    <form action="feedback" method="post" class="comment-form">
      <input type="hidden" name="action" value="comment">
      <input type="hidden" name="projectId" value="<%= projectId %>">
      <input type="hidden" name="feedbackId" value="<%= feedback.getId() %>">
      <textarea name="content" placeholder="댓글을 입력하세요..." required></textarea>
      <button type="submit" class="btn-comment">등록</button>
    </form>
  </div>

</div>
</div>

<script>
function toggleEdit() {
  document.getElementById('viewMode').style.display =
    document.getElementById('viewMode').style.display === 'none' ? '' : 'none';
  document.getElementById('editForm').classList.toggle('open');
}
</script>
</body>
</html>
