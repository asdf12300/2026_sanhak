<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*" %>
<%@ page import="java.util.List" %>
<%
String selectedProjectId = request.getParameter("projectId");
if (selectedProjectId != null && !selectedProjectId.trim().isEmpty() && !"null".equals(selectedProjectId)) {
  session.setAttribute("lastProjectId", selectedProjectId);
}
%>
<%
model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
String userName = (loginUser != null) ? loginUser.getName() : "게스트";
String userId   = (loginUser != null) ? loginUser.getId()   : "";
String initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;

String projectIdParam = request.getParameter("projectId");
ProjectDTO currentProject = null;
boolean isLeader = false;

if (projectIdParam != null && !projectIdParam.isEmpty()) {
  try {
    int projectId = Integer.parseInt(projectIdParam);
    ProjectDAO projectDAO = new ProjectDAO();
    currentProject = projectDAO.getById(projectId);
    if (currentProject != null && loginUser != null) {
      isLeader = currentProject.getTeam_leader() != null &&
                 currentProject.getTeam_leader().equals(loginUser.getId());
    }
  } catch (Exception e) { }
}

String projectQuery = (projectIdParam != null && !projectIdParam.isEmpty())
  ? "?projectId=" + projectIdParam
  : "";
%>
<%

List<TaskDTO> alertList = null;

if (loginUser != null) {
    TaskDAO taskDAO = new TaskDAO();
    alertList = taskDAO.getDeadlineAlerts(loginUser.getId());
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ProjectOS — 대시보드</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
.dash-modal-bg {
  display:none; position:fixed; inset:0;
  background:rgba(15,23,42,.45); z-index:999;
  align-items:center; justify-content:center;
}
.dash-modal-bg.open { display:flex; }
.dash-modal {
  background:#fff; border-radius:14px; padding:28px;
  width:360px; box-shadow:0 16px 48px rgba(0,0,0,.18);
  display:flex; flex-direction:column; gap:12px;
}
.dash-modal h2 { font-size:16px; font-weight:700; color:var(--text); }
.dash-modal label { font-size:12px; font-weight:600; color:var(--muted); margin-bottom:2px; display:block; }
.dash-modal input, .dash-modal select, .dash-modal textarea {
  width:100%; padding:8px 11px; border:1px solid var(--border);
  border-radius:8px; font-size:13px; font-family:inherit;
  background:var(--surface2); color:var(--text); outline:none;
}
.dash-modal input:focus, .dash-modal select:focus, .dash-modal textarea:focus {
  border-color:var(--blue); background:#fff;
}
.dash-modal textarea { resize:vertical; min-height:60px; }
.dash-modal-actions { display:flex; gap:8px; justify-content:flex-end; margin-top:4px; }
.dash-btn-save   { background:var(--blue); color:#fff; border:none; border-radius:8px; padding:8px 18px; font-size:13px; font-weight:600; cursor:pointer; }
.dash-btn-cancel { background:var(--surface2); color:var(--muted); border:1px solid var(--border); border-radius:8px; padding:8px 14px; font-size:13px; cursor:pointer; }
.dash-btn-del    { background:var(--red-light); color:var(--red); border:1px solid var(--red); border-radius:8px; padding:8px 14px; font-size:13px; cursor:pointer; margin-right:auto; }
.dash-popup-bg {
  display:none; position:fixed; inset:0;
  background:rgba(15,23,42,.35); z-index:999;
  align-items:center; justify-content:center;
}
.dash-popup-bg.open { display:flex; }
.dash-popup {
  background:#fff; border-radius:16px; padding:28px;
  width:400px; box-shadow:0 16px 48px rgba(0,0,0,.18);
  display:flex; flex-direction:column; gap:0;
}
.dash-popup-head {
  display:flex; align-items:center; justify-content:space-between;
  margin-bottom:16px; padding-bottom:14px; border-bottom:1px solid var(--border);
}
.dash-popup-head h2 { font-size:18px; font-weight:800; color:var(--text); }
.dash-popup-close {
  background:none; border:none; font-size:20px;
  color:var(--muted2); cursor:pointer; line-height:1; padding:4px;
}
.dash-popup-list { display:flex; flex-direction:column; gap:8px; max-height:360px; overflow-y:auto; }
.dash-popup-task {
  display:flex; align-items:center; justify-content:space-between;
  padding:12px 16px; border-radius:10px; border-left:4px solid var(--orange);
  background:var(--orange-light);
}
.dash-popup-task.done-item { background:var(--teal-light); border-left-color:var(--teal); }
.dash-popup-task.todo-item { background:var(--orange-light); border-left-color:var(--orange); }
.dash-popup-task.prog-item { background:var(--blue-light); border-left-color:var(--blue); }
.dash-popup-task-title { font-size:14px; font-weight:500; color:var(--text2); }
.dash-popup-task-badge {
  font-size:11px; font-weight:600; padding:3px 10px;
  border-radius:20px; background:var(--surface); color:var(--muted);
  border:1px solid var(--border); white-space:nowrap;
}
.dash-popup-evt {
  display:flex; align-items:center; gap:10px;
  padding:12px 16px; border-radius:10px; border-left:4px solid var(--blue);
  background:var(--surface2);
}
.dash-popup-evt-time { font-size:12px; color:var(--muted); width:44px; flex-shrink:0; }
.dash-popup-evt-title { font-size:14px; color:var(--text2); }
.dash-popup-empty { font-size:13px; color:var(--muted2); padding:8px 0; text-align:center; }
/* 전체 위치 */
.alarm-wrapper {
    position: absolute;
    top: 20px;
    right: 30px;
}

/* 🔔 아이콘 */
.alarm-icon {
    position: relative;
    cursor: pointer;
    font-size: 22px;
}

/* 🔴 알림 개수 */
.alarm-count {
    position: absolute;
    top: -6px;
    right: -10px;
    background: red;
    color: white;
    font-size: 12px;
    border-radius: 50%;
    padding: 2px 6px;
}

/* 📦 팝업 */
.alarm-popup {
    display: none;
    position: absolute;
    top: 35px;
    right: 0;

    width: 260px;
    background: white;
    border: 1px solid #ddd;
    border-radius: 10px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.15);
    z-index: 999;
}

/* 헤더 */
.alarm-header {
    padding: 10px;
    font-weight: bold;
    border-bottom: 1px solid #eee;
}

/* 항목 */
.alarm-item {
    padding: 10px;
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
}

.alarm-item:hover {
    background: #f7f9fc;
}

/* 비어있을 때 */
.alarm-empty {
    padding: 15px;
    text-align: center;
    color: #999;
}
.main {
    position: relative;
}
</style>
</head>
<body>
<jsp:include page="sidebar.jsp"/>
<main class="main">
<div class="alarm-wrapper">
    
    <div class="alarm-icon" onclick="toggleAlarm()">
        🔔
        <span class="alarm-count"><%= alertList != null ? alertList.size() : 0 %></span>
    </div>

    <div id="alarmPopup" class="alarm-popup">
        <div class="alarm-header">⏰ 마감일 알림</div>

        <% if (alertList != null && !alertList.isEmpty()) { %>
            <% for (TaskDTO task : alertList) { %>
                <div class="alarm-item">
                    <b><%= task.getTitle() %></b>
                    <div>마감일: <%= task.getDeadline() %></div>
                </div>
            <% } %>
        <% } else { %>
            <div class="alarm-empty">알림 없음</div>
        <% } %>
    </div>

</div>
  <% if (currentProject != null) { %>
  <div style="padding:20px 28px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">
    <h1 style="font-family:'Plus Jakarta Sans',sans-serif;font-size:26px;font-weight:800;color:var(--text);margin:0;line-height:1.2;letter-spacing:-0.5px;white-space:nowrap"><%= currentProject.getTitle() %></h1>
    <% if (currentProject.getContent() != null && !currentProject.getContent().isEmpty()) { %>
    <span style="font-size:13px;color:var(--text2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:300px"><%= currentProject.getContent() %></span>
    <% } %>
    <span style="color:var(--border)">·</span>
    <span style="display:flex;align-items:center;gap:4px;font-size:12px;color:var(--muted)">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
      마감일: <%= (currentProject.getDeadline() != null && !currentProject.getDeadline().isEmpty()) ? currentProject.getDeadline() : "미정" %>
    </span>
    <span style="color:var(--border)">·</span>
    <span style="display:flex;align-items:center;gap:4px;font-size:12px;padding:3px 8px;border-radius:12px;<%= isLeader ? "background:var(--blue-soft);color:var(--blue);font-weight:600" : "background:var(--surface2);color:var(--muted)" %>">
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
      <%= isLeader ? "팀장" : "팀원" %>
    </span>
    
  </div>
  <div style="height:1px;background:var(--border);margin:0 0 0 0"></div>
  <% } %>

  <div class="grid" style="margin-bottom:16px">
    <div class="card c3">
      <div class="card-hd"><div class="card-t">프로젝트 진행률</div><span class="badge b-tl">On Track</span></div>
      <div class="donut-wrap">
        <div class="donut-svg">
          <svg width="148" height="148" viewBox="0 0 148 148">
            <circle cx="74" cy="74" r="56" fill="none" stroke="#e6edf8" stroke-width="14"/>
            <circle cx="74" cy="74" r="56" fill="none" stroke="url(#dg)" stroke-width="14" stroke-dasharray="351.9" stroke-dashoffset="351.9" stroke-linecap="round" transform="rotate(-90 74 74)" style="transition:stroke-dashoffset 1.2s ease"/>
            <defs><linearGradient id="dg" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stop-color="#2563eb"/><stop offset="100%" stop-color="#60a5fa"/></linearGradient></defs>
          </svg>
          <div class="donut-label"><div class="donut-pct">0%</div><div class="donut-sub">완료율</div></div>
        </div>
        <div class="donut-leg">
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--blue)"></div><span class="leg-name">완료</span></div><span class="leg-val">0건</span></div>
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--orange)"></div><span class="leg-name">진행 중</span></div><span class="leg-val">0건</span></div>
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--red)"></div><span class="leg-name">지연</span></div><span class="leg-val">0건</span></div>
        </div>
      </div>
    </div>
    <div class="card c5">
      <div class="card-hd"><div class="card-t">주요 일정</div><span class="badge b-or" id="schedBadge"></span></div>
      <div class="sched-list" id="schedList"></div>
    </div>
    <div class="card c4">
  <div class="cal-top">
    <div class="cal-m" id="dashCalTitle"></div>
    <div class="cal-btns">
      <div class="cal-btn" id="dashPrev">‹</div>
      <div class="cal-btn" id="dashNext">›</div>
    </div>
  </div>
  <div class="cal-grid" id="dashCalGrid"></div>
</div>
  </div>

  <!-- 칸반 보드 (taskApi 연동) -->
  <div class="card" style="margin-bottom:16px">
    <div class="card-hd">
      <div class="card-t">칸반 보드</div>
      <div style="display:flex;gap:6px">
        <span class="badge b-rd" id="kb-badge-todo">TODO 0</span>
        <span class="badge b-or" id="kb-badge-inprogress">IN PROGRESS 0</span>
        <span class="badge b-tl" id="kb-badge-done">DONE 0</span>
      </div>
    </div>
    <div class="kanban">
      <div class="kb-col">
        <div class="kb-hd"><div class="kb-t" style="color:var(--red)">📋 Todo</div><div class="kb-cnt" id="kb-cnt-todo">0</div></div>
        <div class="kb-cards" id="kb-col-todo"></div>
      </div>
      <div class="kb-col">
        <div class="kb-hd"><div class="kb-t" style="color:var(--orange)">⚡ In Progress</div><div class="kb-cnt" id="kb-cnt-inprogress">0</div></div>
        <div class="kb-cards" id="kb-col-inprogress"></div>
      </div>
      <div class="kb-col">
        <div class="kb-hd"><div class="kb-t" style="color:var(--teal)">✅ Done</div><div class="kb-cnt" id="kb-cnt-done">0</div></div>
        <div class="kb-cards" id="kb-col-done"></div>
      </div>
    </div>
  </div>

  <div class="grid" style="margin-bottom:16px">
    <div class="card c4">
      <div class="card-hd"><div class="card-t">오늘의 일정</div><span class="badge b-bl">3월 29일 · 일</span></div>
      <div class="today-list">
        <div class="today-item" style="background:var(--blue-light);border-color:var(--blue)"><div class="t-time" style="color:var(--blue)">09:00 — 10:00</div><div class="t-name">디자인 시스템 검토 회의</div><div class="t-where">📹 화상회의 · Zoom</div></div>
        <div class="today-item" style="background:var(--orange-light);border-color:var(--orange)"><div class="t-time" style="color:var(--orange)">11:30 — 12:30</div><div class="t-name">스프린트 플래닝 #12</div><div class="t-where">🏢 오프라인 · 3층 세미나실</div></div>
        <div class="today-item" style="background:var(--violet-light);border-color:var(--violet)"><div class="t-time" style="color:var(--violet)">14:00 — 15:00</div><div class="t-name">클라이언트 데모 발표</div><div class="t-where">💻 온라인 · Google Meet</div></div>
        <div class="today-item" style="background:var(--teal-light);border-color:var(--teal)"><div class="t-time" style="color:var(--teal)">16:00 — 17:00</div><div class="t-name">API 연동 테스트 체크</div><div class="t-where">🛠 개발팀 · 슬랙 채널</div></div>
      </div>
    </div>
    
    <div class="card c4">
      <div class="card-hd"><div class="card-t">나의 할 일</div><span class="badge b-or" id="todo-cnt">3개 남음</span></div>
      <div class="todo-add">
        <input class="todo-inp" id="todo-input" placeholder="새 할 일 입력 후 Enter...">
        <button class="btn btn-p" onclick="addTodo()" style="padding:8px 14px;font-size:16px;line-height:1">+</button>
      </div>
      <div class="todo-list" id="todo-list">
        <div class="todo-item" onclick="toggleTodo(this)"><div class="todo-chk"></div><div class="todo-txt">index.jsp 대시보드 완성</div><div class="todo-del" onclick="delTodo(event,this)">×</div></div>
        <div class="todo-item" onclick="toggleTodo(this)"><div class="todo-chk"></div><div class="todo-txt">클라이언트 발표 자료 준비</div><div class="todo-del" onclick="delTodo(event,this)">×</div></div>
        <div class="todo-item done" onclick="toggleTodo(this)"><div class="todo-chk">✓</div><div class="todo-txt">스프린트 회고 문서 작성</div><div class="todo-del" onclick="delTodo(event,this)">×</div></div>
        <div class="todo-item" onclick="toggleTodo(this)"><div class="todo-chk"></div><div class="todo-txt">API 문서 업데이트</div><div class="todo-del" onclick="delTodo(event,this)">×</div></div>
      </div>
    </div>
     <div class="card c4">
      <div class="card-hd"><div class="card-t">파일 공유</div><button class="btn btn-g" style="font-size:11px;padding:5px 10px"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>업로드</button></div>
      <div class="file-list">
        <div class="file-item"><div class="file-icon" style="background:var(--red-light)">📄</div><div style="flex:1"><div class="file-name">요구사항_명세서_v3.pdf</div><div class="file-meta">장수연 · 2시간 전</div></div><div class="file-sz">2.4 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--violet-light)">🎨</div><div style="flex:1"><div class="file-name">디자인시스템_최종.fig</div><div class="file-meta">박현우 · 5시간 전</div></div><div class="file-sz">18.7 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--blue-light)">📊</div><div style="flex:1"><div class="file-name">스프린트12_계획.xlsx</div><div class="file-meta">김지호 · 어제</div></div><div class="file-sz">384 KB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--orange-light)">📝</div><div style="flex:1"><div class="file-name">API_명세서_v2.1.docx</div><div class="file-meta">이민준 · 어제</div></div><div class="file-sz">1.1 MB</div></div>
      </div>
    </div>
  </div>

  <div class="grid" style="margin-bottom:16px">
     <div class="card c12">
      <div class="card-hd"><div class="card-t">팀 채팅</div><div style="display:flex;align-items:center;gap:6px"><div style="width:7px;height:7px;border-radius:50%;background:var(--teal)"></div><span style="font-size:11px;color:var(--teal);font-weight:600">4명 접속 중</span></div></div>
      <div class="chat-msgs" id="chat-messages">
        <div class="chat-msg"><div class="chat-av" style="background:var(--teal)">LM</div><div class="chat-in"><div class="chat-nm">이민준 · 오전 9:02</div><div class="chat-bbl">안녕하세요! 오늘 스프린트 플래닝 준비됐나요?</div></div></div>
        <div class="chat-msg me"><div class="chat-av" style="background:var(--blue)">KJ</div><div class="chat-in"><div class="chat-nm">나 · 오전 9:05</div><div class="chat-bbl">네! 자료 다 준비했어요. 11:30 세미나실에서 봐요 😊</div></div></div>
        <div class="chat-msg"><div class="chat-av" style="background:var(--violet)">JS</div><div class="chat-in"><div class="chat-nm">장수연 · 오전 9:08</div><div class="chat-bbl">저도 준비 완료! 클라이언트 데모 자료도 공유드릴게요 📎</div></div></div>
        <div class="chat-msg"><div class="chat-av" style="background:var(--orange)">PH</div><div class="chat-in"><div class="chat-nm">박현우 · 오전 9:15</div><div class="chat-bbl">로그인 페이지 버그 찾았어요. PR 올릴게요!</div></div></div>
      </div>
      <div class="chat-foot">
        <input class="chat-inp" id="chat-input" placeholder="메시지를 입력하세요..." onkeydown="if(event.key==='Enter')sendChat()">
        <button class="chat-send" onclick="sendChat()"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg></button>
      </div>
    </div>
  </div>
</main>
<div class="dash-popup-bg" id="dashPopupBg">
  <div class="dash-popup">
    <div class="dash-popup-head">
      <h2 id="dashPopupTitle"></h2>
      <button class="dash-popup-close" onclick="dashClosePopup()">×</button>
    </div>
    <div class="dash-popup-list" id="dashPopupList"></div>
  </div>
</div>

<div class="dash-modal-bg" id="dashModalBg">
  <div class="dash-modal">
    <h2 id="dashModalTitle">일정 등록</h2>
    <div><label>제목</label><input type="text" id="dashEvtTitle"></div>
    <div><label>날짜</label><input type="date" id="dashEvtDate"></div>
    <div><label>시간</label><input type="time" id="dashEvtTime"></div>
    <div>
      <label>분류</label>
      <select id="dashEvtCat">
        <option value="0">일반</option>
        <option value="1">중요</option>
        <option value="2">개인</option>
        <option value="3">업무</option>
      </select>
    </div>
    <div><label>메모</label><textarea id="dashEvtMemo"></textarea></div>
    <div class="dash-modal-actions">
      <button class="dash-btn-del" id="dashDelBtn" style="display:none" onclick="dashDeleteEvt()">삭제</button>
      <button class="dash-btn-cancel" onclick="dashCloseModal()">취소</button>
      <button class="dash-btn-save" onclick="dashSaveEvt()">저장</button>
    </div>
  </div>
</div>

<script>
var DASH_PROJECT_ID = <%= currentProject != null ? currentProject.getId() : 0 %>;
var DASH_CONTEXT    = '<%= request.getContextPath() %>';
var dashEvents      = [];
var dashCurY, dashCurM;
(function(){ var n=new Date(); dashCurY=n.getFullYear(); dashCurM=n.getMonth(); })();

function dashLoadEvents() {
  if (!DASH_PROJECT_ID) { dashRenderCal(); renderSchedList([]); return; }
  fetch(DASH_CONTEXT + '/event?action=list&projectId=' + DASH_PROJECT_ID)
    .then(function(r){ return r.json(); })
    .then(function(data){ dashEvents=data; dashRenderCal(); renderSchedList(data); })
    .catch(function(){ dashEvents=[]; dashRenderCal(); renderSchedList([]); });
}

function dashRenderCal() {
  var months=['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
  var days=['일','월','화','수','목','금','토'];
  document.getElementById('dashCalTitle').textContent = dashCurY+'년 '+months[dashCurM];
  var grid=document.getElementById('dashCalGrid');
  grid.innerHTML='';
  days.forEach(function(d){ var el=document.createElement('div'); el.className='cal-dn'; el.textContent=d; grid.appendChild(el); });
  var today=new Date();
  var todayStr=today.getFullYear()+'-'+('0'+(today.getMonth()+1)).slice(-2)+'-'+('0'+today.getDate()).slice(-2);
  var firstDay=new Date(dashCurY,dashCurM,1).getDay();
  var lastDate=new Date(dashCurY,dashCurM+1,0).getDate();
  for(var i=0;i<firstDay;i++){ var e=document.createElement('div'); e.className='cal-day'; grid.appendChild(e); }
  for(var d=1;d<=lastDate;d++){
    var ds=dashCurY+'-'+('0'+(dashCurM+1)).slice(-2)+'-'+('0'+d).slice(-2);
    var hasEv=dashEvents.some(function(e){ return e.date===ds; });
    var cell=document.createElement('div');
    cell.className='cal-day'+(ds===todayStr?' tod':'')+(hasEv?' ev':'');
    cell.textContent=d;
    cell.onclick=(function(s){ return function(){ dashOpenPopup(s); }; })(ds);
    grid.appendChild(cell);
  }
}

document.getElementById('dashPrev').onclick=function(){ dashCurM--; if(dashCurM<0){dashCurM=11;dashCurY--;} dashLoadEvents(); };
document.getElementById('dashNext').onclick=function(){ dashCurM++; if(dashCurM>11){dashCurM=0;dashCurY++;} dashLoadEvents(); };

function dashOpenPopup(dateStr) {
  var catColor={0:'var(--blue)',1:'var(--red)',2:'var(--teal)',3:'var(--orange)'};
  var dayEvts=dashEvents.filter(function(e){ return e.date===dateStr; });
  var dayTasks=(window._kanbanTasks||[]).filter(function(t){ return t.deadline===dateStr; });
  document.getElementById('dashPopupTitle').textContent=dateStr+' 일정';
  var html='';
  dayTasks.forEach(function(t){
    var cls=t.status==='Done'?'done-item':t.status==='In Progress'?'prog-item':'todo-item';
    html+='<div class="dash-popup-task '+cls+'"><span class="dash-popup-task-title">'+escHtml(t.title)+'</span><span class="dash-popup-task-badge">'+t.status+'</span></div>';
  });
  dayEvts.forEach(function(e){
    var color=catColor[e.cat]||'var(--blue)';
    html+='<div class="dash-popup-evt" style="border-left-color:'+color+';"><span class="dash-popup-evt-time">'+(e.time?e.time.substring(0,5):'—')+'</span><span class="dash-popup-evt-title">'+escHtml(e.title)+'</span></div>';
  });
  if(!html) html='<div class="dash-popup-empty">이 날 등록된 일정이 없어요</div>';
  document.getElementById('dashPopupList').innerHTML=html;
  document.getElementById('dashPopupBg').classList.add('open');
}
function dashClosePopup(){ document.getElementById('dashPopupBg').classList.remove('open'); }
document.getElementById('dashPopupBg').onclick=function(e){ if(e.target.id==='dashPopupBg') dashClosePopup(); };

function renderSchedList(data) {
  var today=new Date();
  var yyyy=today.getFullYear(), mm=('0'+(today.getMonth()+1)).slice(-2), dd=('0'+today.getDate()).slice(-2);
  var todayStr=yyyy+'-'+mm+'-'+dd;
  var lastStr=yyyy+'-'+mm+'-'+('0'+new Date(yyyy,today.getMonth()+1,0).getDate()).slice(-2);
  var catColor={0:'var(--blue)',1:'var(--red)',2:'var(--teal)',3:'var(--orange)'};
  var filtered=data.filter(function(e){ return e.date>=todayStr&&e.date<=lastStr; })
    .sort(function(a,b){ return a.date!==b.date?a.date.localeCompare(b.date):(a.time||'').localeCompare(b.time||''); })
    .slice(0,4);
  document.getElementById('schedBadge').textContent=filtered.length+'개 예정';
  if(filtered.length===0){ document.getElementById('schedList').innerHTML='<div class="sched-item"><div class="stitle">이번달 남은 일정이 없습니다</div></div>'; return; }
  var nowTime=('0'+today.getHours()).slice(-2)+':'+('0'+today.getMinutes()).slice(-2);
  document.getElementById('schedList').innerHTML=filtered.map(function(e,i){
    var timeStr=e.time?e.time.substring(0,5):e.date.substring(5).replace('-','/');
    var isPast=e.date===todayStr&&e.time&&e.time.substring(0,5)<nowTime;
    var cls=isPast?'done':(i===0?'urgent':'');
    var color=catColor[e.cat]||'var(--blue)';
    return '<div class="sched-item '+cls+'" style="border-left:3px solid '+color+';">'
      +'<div class="sdot" style="background:'+color+'"></div>'
      +'<div class="stime">'+timeStr+'</div>'
      +'<div class="stitle">'+e.title+'</div>'
      +'<div class="swho">'+(e.taskAssignee||'')+'</div></div>';
  }).join('');
}

var KANBAN_PROJECT_ID = <%= currentProject != null ? currentProject.getId() : 0 %>;
function loadKanban() {
  if(!KANBAN_PROJECT_ID) return;
  fetch('taskApi?projectId='+KANBAN_PROJECT_ID)
    .then(function(r){ return r.json(); })
    .then(function(tasks){ renderKanban(tasks); })
    .catch(function(){ renderKanban([]); });
}
function renderKanban(tasks) {
  window._kanbanTasks=tasks;
  var cols={'To Do':[],'In Progress':[],'Done':[]};
  tasks.forEach(function(t){ if(cols[t.status]) cols[t.status].push(t); else cols['To Do'].push(t); });
  var colMap={
    'To Do':{el:'kb-col-todo',cnt:'kb-cnt-todo',badge:'kb-badge-todo',label:'TODO'},
    'In Progress':{el:'kb-col-inprogress',cnt:'kb-cnt-inprogress',badge:'kb-badge-inprogress',label:'IN PROGRESS'},
    'Done':{el:'kb-col-done',cnt:'kb-cnt-done',badge:'kb-badge-done',label:'DONE'}
  };
//진행률 계산
  var total = tasks.length;
  if (total > 0) {
    var doneCount = cols['Done'].length;
    var progCount = cols['In Progress'].length;
    var pct = Math.round((doneCount * 1.0 + progCount * 0.5) / total * 100);

    // 도넛 차트 업데이트
    document.querySelector('.donut-pct').textContent = pct + '%';

    // SVG 원 업데이트 (둘레 351.9 기준)
    var offset = 351.9 * (1 - pct / 100);
    document.querySelector('circle[stroke="url(#dg)"]').setAttribute('stroke-dashoffset', offset);

    // 범례 숫자 업데이트
    var legVals = document.querySelectorAll('.leg-val');
    if (legVals[0]) legVals[0].textContent = doneCount + '건';
    if (legVals[1]) legVals[1].textContent = progCount + '건';
    if (legVals[2]) legVals[2].textContent = cols['To Do'].length + '건';
  }

  Object.keys(colMap).forEach(function(status){
    var list=cols[status], m=colMap[status];
    document.getElementById(m.cnt).textContent=list.length;
    document.getElementById(m.badge).textContent=m.label+' '+list.length;
    var isDone=status==='Done';
    var borderStyle=status==='In Progress'?'border-top:3px solid var(--orange);':'';
    if(list.length===0){ document.getElementById(m.el).innerHTML='<div style="text-align:center;color:var(--muted2);font-size:12px;padding:20px 0;">업무 없음</div>'; return; }
    document.getElementById(m.el).innerHTML=list.map(function(t){
      var initials=t.assignee?t.assignee.substring(0,2).toUpperCase():'';
      var avatarHtml=initials?'<div class="kb-avs"><div class="kav" style="background:var(--blue)">'+initials+'</div></div>':'';
      var deadlineHtml=t.deadline?'<span style="font-size:11px;color:var(--muted)">'+t.deadline+'</span>':'';
      var doneStyle=isDone?'opacity:.5;':'';
      var titleStyle=isDone?'text-decoration:line-through;color:var(--muted2);':'';
      return '<div class="kb-card" style="'+borderStyle+doneStyle+'">'
        +'<div class="kb-card-t" style="'+titleStyle+'">'+escHtml(t.title)+'</div>'
        +'<div class="kb-card-m"><div class="kb-tags">'+deadlineHtml+'</div>'+avatarHtml+'</div>'
        +'</div>';
    }).join('');
  });
}
function escHtml(s){ if(!s)return''; return s.replace(/&/g,'&').replace(/</g,'<').replace(/>/g,'>').replace(/"/g,'"'); }

function toggleTodo(el){ el.classList.toggle('done'); el.querySelector('.todo-chk').textContent=el.classList.contains('done')?'✓':''; updateTodoCount(); }
function delTodo(e,btn){ e.stopPropagation(); btn.closest('.todo-item').remove(); updateTodoCount(); }
function addTodo(){
  var inp=document.getElementById('todo-input'), val=inp.value.trim();
  if(!val)return;
  var item=document.createElement('div'); item.className='todo-item'; item.onclick=function(){ toggleTodo(this); };
  item.innerHTML='<div class="todo-chk"></div><div class="todo-txt">'+val+'</div><div class="todo-del" onclick="delTodo(event,this)">×</div>';
  document.getElementById('todo-list').appendChild(item); inp.value=''; updateTodoCount();
}
document.getElementById('todo-input').addEventListener('keydown',function(e){ if(e.key==='Enter')addTodo(); });
function updateTodoCount(){
  var all=document.querySelectorAll('#todo-list .todo-item').length;
  var done=document.querySelectorAll('#todo-list .todo-item.done').length;
  document.getElementById('todo-cnt').textContent=(all-done)+'개 남음';
}
function sendChat(){
  var inp=document.getElementById('chat-input'), val=inp.value.trim();
  if(!val)return;
  var now=new Date(), time='오후 '+now.getHours()+':'+('0'+now.getMinutes()).slice(-2);
  var msg=document.createElement('div'); msg.className='chat-msg me';
  msg.innerHTML='<div class="chat-av" style="background:var(--blue)">나</div><div class="chat-in"><div class="chat-nm">나 · '+time+'</div><div class="chat-bbl">'+val+'</div></div>';
  var box=document.getElementById('chat-messages'); box.appendChild(msg); box.scrollTop=box.scrollHeight; inp.value='';
}
document.getElementById('chat-input').addEventListener('keydown',function(e){ if(e.key==='Enter')sendChat(); });

dashLoadEvents();
loadKanban();
</script>
<script>
function toggleAlarm() {
    const popup = document.getElementById("alarmPopup");
    popup.style.display = (popup.style.display === "block") ? "none" : "block";
}

/* 바깥 클릭 시 닫기 */
document.addEventListener("click", function(e) {
    const wrapper = document.querySelector(".alarm-wrapper");
    if (!wrapper.contains(e.target)) {
        document.getElementById("alarmPopup").style.display = "none";
    }
});
</script>
</body>
</html>
