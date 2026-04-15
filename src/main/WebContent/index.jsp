<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*" %>
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
</head>
<body>
<jsp:include page="sidebar.jsp"/>
<main class="main">
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
            <circle cx="74" cy="74" r="56" fill="none" stroke="url(#dg)" stroke-width="14" stroke-dasharray="351.9" stroke-dashoffset="87.97" stroke-linecap="round" transform="rotate(-90 74 74)" style="transition:stroke-dashoffset 1.2s ease"/>
            <defs><linearGradient id="dg" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stop-color="#2563eb"/><stop offset="100%" stop-color="#60a5fa"/></linearGradient></defs>
          </svg>
          <div class="donut-label"><div class="donut-pct">75%</div><div class="donut-sub">완료율</div></div>
        </div>
        <div class="donut-leg">
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--blue)"></div><span class="leg-name">완료</span></div><span class="leg-val">27건</span></div>
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--orange)"></div><span class="leg-name">진행 중</span></div><span class="leg-val">11건</span></div>
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--red)"></div><span class="leg-name">지연</span></div><span class="leg-val">4건</span></div>
        </div>
      </div>
    </div>
    <div class="card c5">
      <div class="card-hd"><div class="card-t">주요 일정</div><span class="badge b-or" id="schedBadge"></span></div>
      <div class="sched-list" id="schedList"><div style="color:var(--muted2);font-size:12px;">불러오는 중...</div></div>
    </div>
    <div class="card c4">
      <div class="cal-top">
        <div class="cal-m" id="dashCalTitle"></div>
        <div class="cal-btns">
          <div class="cal-btn" id="dashPrev">&#8249;</div>
          <div class="cal-btn" id="dashNext">&#8250;</div>
        </div>
      </div>
      <div class="cal-grid" id="dashCalGrid"></div>
    </div>
  </div>
  <div class="card" style="margin-bottom:16px">
    <div class="card-hd"><div class="card-t">칸반 보드</div><div style="display:flex;gap:6px"><span class="badge b-rd" id="kb-badge-todo">TODO 0</span><span class="badge b-or" id="kb-badge-inprogress">IN PROGRESS 0</span><span class="badge b-tl" id="kb-badge-done">DONE 0</span></div></div>
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
      <div class="cal-top"><div class="cal-m">2026년 3월</div><div class="cal-btns"><div class="cal-btn">‹</div><div class="cal-btn">›</div></div></div>
      <div class="cal-grid">
        <div class="cal-dn">일</div><div class="cal-dn">월</div><div class="cal-dn">화</div><div class="cal-dn">수</div><div class="cal-dn">목</div><div class="cal-dn">금</div><div class="cal-dn">토</div>
        <div class="cal-day">1</div><div class="cal-day ev">2</div><div class="cal-day">3</div><div class="cal-day ev">4</div><div class="cal-day">5</div><div class="cal-day ev">6</div><div class="cal-day">7</div>
        <div class="cal-day">8</div><div class="cal-day ev">9</div><div class="cal-day">10</div><div class="cal-day">11</div><div class="cal-day ev">12</div><div class="cal-day">13</div><div class="cal-day">14</div>
        <div class="cal-day">15</div><div class="cal-day">16</div><div class="cal-day ev">17</div><div class="cal-day">18</div><div class="cal-day">19</div><div class="cal-day">20</div><div class="cal-day">21</div>
        <div class="cal-day">22</div><div class="cal-day ev">23</div><div class="cal-day">24</div><div class="cal-day">25</div><div class="cal-day">26</div><div class="cal-day">27</div><div class="cal-day">28</div>
        <div class="cal-day tod ev">29</div><div class="cal-day">30</div><div class="cal-day">31</div>
      </div>
    </div>
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
    <div class="card c5">
      <div class="card-hd"><div class="card-t">파일 공유</div><button class="btn btn-g" style="font-size:11px;padding:5px 10px"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>업로드</button></div>
      <div class="file-list">
        <div class="file-item"><div class="file-icon" style="background:var(--red-light)">📄</div><div style="flex:1"><div class="file-name">요구사항_명세서_v3.pdf</div><div class="file-meta">장수연 · 2시간 전</div></div><div class="file-sz">2.4 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--violet-light)">🎨</div><div style="flex:1"><div class="file-name">디자인시스템_최종.fig</div><div class="file-meta">박현우 · 5시간 전</div></div><div class="file-sz">18.7 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--blue-light)">📊</div><div style="flex:1"><div class="file-name">스프린트12_계획.xlsx</div><div class="file-meta">김지호 · 어제</div></div><div class="file-sz">384 KB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--orange-light)">📝</div><div style="flex:1"><div class="file-name">API_명세서_v2.1.docx</div><div class="file-meta">이민준 · 어제</div></div><div class="file-sz">1.1 MB</div></div>
      </div>
    </div>
  </div>
</main>
<script>
function toggleTodo(el) { el.classList.toggle('done'); el.querySelector('.todo-chk').textContent = el.classList.contains('done') ? '✓' : ''; updateTodoCount(); }
function delTodo(e, btn) { e.stopPropagation(); btn.closest('.todo-item').remove(); updateTodoCount(); }
function addTodo() {
  var inp = document.getElementById('todo-input'), val = inp.value.trim();
  if (!val) return;
  var item = document.createElement('div'); item.className = 'todo-item'; item.onclick = function() { toggleTodo(this); };
  item.innerHTML = '<div class="todo-chk"></div><div class="todo-txt">' + val + '</div><div class="todo-del" onclick="delTodo(event,this)">×</div>';
  document.getElementById('todo-list').appendChild(item); inp.value = ''; updateTodoCount();
}
document.getElementById('todo-input').addEventListener('keydown', function(e) { if (e.key==='Enter') addTodo(); });
function updateTodoCount() {
  var all = document.querySelectorAll('#todo-list .todo-item').length;
  var done = document.querySelectorAll('#todo-list .todo-item.done').length;
  document.getElementById('todo-cnt').textContent = (all - done) + '개 남음';
}
function sendChat() {
  var inp = document.getElementById('chat-input'), val = inp.value.trim();
  if (!val) return;
  var now = new Date(), time = '오후 ' + now.getHours() + ':' + ('0' + now.getMinutes()).slice(-2);
  var msg = document.createElement('div'); msg.className = 'chat-msg me';
  msg.innerHTML = '<div class="chat-av" style="background:var(--blue)">나</div><div class="chat-in"><div class="chat-nm">나 · ' + time + '</div><div class="chat-bbl">' + val + '</div></div>';
  var box = document.getElementById('chat-messages'); box.appendChild(msg); box.scrollTop = box.scrollHeight; inp.value = '';
}
document.getElementById('chat-input').addEventListener('keydown', function(e) { if (e.key==='Enter') sendChat(); });
</script>
</body>
</html>
