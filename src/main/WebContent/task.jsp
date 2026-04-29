<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
  boolean isProfessor = loginUser != null && "professor".equals(loginUser.getRole());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>업무 관리 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="resource/css/calendar.css">
<style>
.task-wrap {
  padding: 1.5rem;
  max-width: 860px;
  width: 100%;
  margin: 20px 0;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,.1);
}
.task-header { display:flex; align-items:center; gap:10px; margin-bottom:1.2rem; flex-wrap:wrap; }
.task-title { font-size:20px; font-weight:700; color:#111; flex:1; }
.btn-new { background:#378ADD; color:#fff; border:none; border-radius:6px; padding:8px 16px; cursor:pointer; font-size:14px; font-weight:600; }
.btn-new:hover { background:#2563eb; }

.filter-bar { display:flex; gap:8px; margin-bottom:1rem; flex-wrap:wrap; }
.filter-btn { background:#fff; border:1px solid #d1d5db; border-radius:6px; padding:5px 14px; cursor:pointer; font-size:13px; transition:all .15s; }
.filter-btn.active, .filter-btn:hover { background:#378ADD; color:#fff; border-color:#378ADD; }

.task-table { width:100%; border-collapse:collapse; font-size:14px; }
.task-table th { padding:10px 12px; text-align:left; font-size:12px; color:#64748b; border-bottom:2px solid #e2e8f0; font-weight:600; }
.task-table td { padding:11px 12px; border-bottom:1px solid #f1f5f9; color:#334155; vertical-align:middle; }
.task-table tr:hover td { background:#f8fafc; }

.status-badge { padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600; white-space:nowrap; }
.s-todo       { background:#fee2e2; color: #ef4444; }
.s-inprogress { background:#fef3c7; color:#d97706; }
.s-done       { background:#dcfce7; color:#16a34a; }

.btn-row { display:flex; gap:6px; }
.btn-edit { background:#e0f2fe; color:#0284c7; border:none; border-radius:6px; padding:5px 12px; cursor:pointer; font-size:12px; font-weight:500; }
.btn-del  { background:#fee2e2; color:#ef4444; border:none; border-radius:6px; padding:5px 12px; cursor:pointer; font-size:12px; font-weight:500; }
.btn-edit:hover { background:#bae6fd; }
.btn-del:hover  { background:#fecaca; }

.empty-row td { text-align:center; color:#94a3b8; padding:32px; }
</style>
</head>
<body>
<jsp:include page="sidebar.jsp"/>

<div class="main" style="display:flex; align-items:flex-start; justify-content:center;">
<div class="task-wrap">
  <div class="task-header">
    <span class="task-title">업무 관리</span>
    <% if (!isProfessor) { %>
    <button class="btn-new" onclick="openNew()">+ 업무 추가</button>
    <% } %>
  </div>

  <!-- 상태 필터 -->
  <div class="filter-bar">
    <button class="filter-btn active" onclick="setFilter('all', this)">전체</button>
    <button class="filter-btn" onclick="setFilter('To Do', this)">To Do</button>
    <button class="filter-btn" onclick="setFilter('In Progress', this)">In Progress</button>
    <button class="filter-btn" onclick="setFilter('Done', this)">Done</button>
  </div>

  <!-- 업무 목록 테이블 -->
  <table class="task-table">
    <thead>
      <tr>
        <th>제목</th>
        <th>담당자</th>
        <th>상태</th>
        <th>마감일</th>
        <th>메모</th>
        <th style="width:100px"></th>
      </tr>
    </thead>
    <tbody id="taskBody"></tbody>
  </table>
  </div>
</div>

<!-- 모달 -->
<div class="modal-bg" id="modalBg">
  <div class="modal">
    <h2 id="modalTitle">업무 추가</h2>

    <label>제목</label>
    <input type="text" id="taskTitle">

    <label>담당자</label>
    <select id="taskAssignee">
      <option value="">-- 담당자 선택 --</option>
    </select>

    <label>상태</label>
    <select id="taskStatus">
      <option value="To Do">To Do</option>
      <option value="In Progress">In Progress</option>
      <option value="Done">Done</option>
    </select>

    <label>마감일</label>
    <input type="date" id="taskDeadline">

    <label>내용</label>
    <textarea id="taskContent" rows="3"></textarea>

    <div class="modal-actions">
      <button class="btn-del" id="delBtn" style="display:none" onclick="deleteTask()">삭제</button>
      <button class="btn-cancel" onclick="closeModal()">취소</button>
      <button class="btn-save" onclick="saveTask()">저장</button>
    </div>
  </div>
</div>

<script>
const PROJECT_ID = <%= request.getParameter("projectId") != null ? request.getParameter("projectId") : "1" %>;
const IS_PROFESSOR = <%= isProfessor %>;
</script>
<script src="resource/js/task.js"></script>
</body>
</html>
