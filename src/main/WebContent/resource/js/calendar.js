const MONTHS = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
const DAYS = ['일','월','화','수','목','금','토'];

let today = new Date();
let curY = today.getFullYear();
let curM = today.getMonth();
let events = [];
let editIdx = -1;
let currentFilter = 'all';

// =====================
// 서버에서 데이터 불러오기
// =====================
function loadEvents() {
  const el = document.getElementById('evtProjectId');
  const projectId = el ? el.value : '';
  fetch(contextPath + "/event?action=list&projectId=" + projectId)
    .then(res => res.json())
    .then(data => { events = data; renderCal(); })
    .catch(() => { events = []; renderCal(); });
}

let calProjectMembers = [];

function loadCalMembers() {
  const el = document.getElementById('evtProjectId');
  const projectId = el ? el.value : '';
  if (!projectId) return Promise.resolve();
  return fetch(contextPath + "/event?action=members&projectId=" + projectId)
    .then(r => r.json())
    .then(data => { calProjectMembers = data; })
    .catch(() => { calProjectMembers = []; });
}

function populateCalAssigneeSelect(selectedId) {
  const sel = document.getElementById('evtAssignee');
  sel.innerHTML = '<option value="">-- 담당자 선택 --</option>';
  calProjectMembers.forEach(m => {
    const opt = document.createElement('option');
    opt.value = m.id;
    opt.textContent = m.name ? m.name + ' (' + m.id + ')' : m.id;
    if (m.id === selectedId) opt.selected = true;
    sel.appendChild(opt);
  });
}

// =====================
// 캘린더 렌더링
// =====================
const monthSel = document.getElementById('monthSel');
const yearSel  = document.getElementById('yearSel');

MONTHS.forEach((m,i) => {
  const o = document.createElement('option');
  o.value = i;
  o.textContent = m;
  monthSel.appendChild(o);
});

for (let y = today.getFullYear()-10; y <= today.getFullYear()+10; y++) {
  const o = document.createElement('option');
  o.value = y;
  o.textContent = y + '년';
  yearSel.appendChild(o);
}

function renderCal() {
  monthSel.value = curM;
  yearSel.value  = curY;
  document.getElementById('calTitle').textContent = curY + '년 ' + MONTHS[curM];

  const grid = document.getElementById('calGrid');
  grid.innerHTML = '';

  DAYS.forEach(d => {
    const el = document.createElement('div');
    el.className = 'day-label';
    el.textContent = d;
    grid.appendChild(el);
  });

  const first = new Date(curY, curM, 1).getDay();
  const last  = new Date(curY, curM + 1, 0).getDate();

  for (let i = 0; i < first; i++) {
    const empty = document.createElement('div');
    empty.className = 'day-cell';
    grid.appendChild(empty);
  }

  for (let d = 1; d <= last; d++) {
    const cell = document.createElement('div');
    cell.className = 'day-cell';

    const num = document.createElement('div');
    num.textContent = d;
    cell.appendChild(num);

    const dateStr   = formatDate(curY, curM, d);
    const dayEvents = events.filter(e => e.date === dateStr);

    // 최대 2개만 표시
    dayEvents.slice(0, 2).forEach(e => {
      const ev = document.createElement('div');
      ev.className = 'event-dot cat-' + e.cat;
      ev.textContent = (e.time ? e.time.substring(0,5) + ' ' : '') + e.title;
      ev.onclick = (event) => {
        event.stopPropagation();
        openEdit(events.indexOf(e));
      };
      cell.appendChild(ev);
    });

    // +N 더보기 버튼
    if (dayEvents.length > 2) {
      const more = document.createElement('div');
      more.className = 'more-btn';
      more.textContent = '+' + (dayEvents.length - 2) + ' 더보기';
      more.onclick = (event) => {
        event.stopPropagation();
        openMorePopup(dateStr, dayEvents);
      };
      cell.appendChild(more);
    }

    cell.onclick = () => openNew(curY, curM, d);
    grid.appendChild(cell);
  }
}

// =====================
// +N 더보기 팝업
// =====================
function openMorePopup(dateStr, dayEvents) {
  document.getElementById('morePopupDate').textContent = dateStr + ' 일정';

  const list = document.getElementById('morePopupList');
  list.innerHTML = '';

  dayEvents.forEach(e => {
    const item = document.createElement('div');
    item.className = 'more-popup-item cat-' + e.cat;

    const badge = e.taskStatus
      ? `<span class="task-badge status-${e.taskStatus.replace(/ /g,'-')}">${e.taskStatus}</span>`
      : '';

    item.innerHTML = `
      <span class="more-item-time">${e.time ? e.time.substring(0,5) : ''}</span>
      <span class="more-item-title">${e.title}</span>
      ${badge}
    `;
    item.onclick = () => {
      closeMorePopup();
      openEdit(events.indexOf(e));
    };
    list.appendChild(item);
  });

  document.getElementById('morePopupBg').classList.add('open');
}

function closeMorePopup() {
  document.getElementById('morePopupBg').classList.remove('open');
}

document.getElementById('morePopupClose').onclick = closeMorePopup;
document.getElementById('morePopupBg').onclick = (e) => {
  if (e.target.id === 'morePopupBg') closeMorePopup();
};

// =====================
// 날짜 포맷
// =====================
function formatDate(y,m,d) {
  return y + '-' + String(m+1).padStart(2,'0') + '-' + String(d).padStart(2,'0');
}

// =====================
// 모달
// =====================
function openNew(y,m,d) {
  editIdx = -1;
  document.getElementById('modalTitle').textContent = '일정 등록';
  document.getElementById('evtTitle').value = '';
  document.getElementById('evtDate').value = formatDate(y,m,d);
  document.getElementById('evtTime').value = '';
  document.getElementById('evtCat').value = '0';
  const sel = document.getElementById('evtAssignee');
  sel.value = '';
  sel.disabled = true;
  sel.style.background = '#f3f4f6';
  sel.style.color = '#9ca3af';
  sel.style.cursor = 'not-allowed';
  document.getElementById('evtMemo').value = '';
  document.getElementById('delBtn').style.display = 'none';
  document.getElementById('modalBg').classList.add('open');
}

function openEdit(idx) {
  editIdx = idx;
  const e = events[idx];
  document.getElementById('modalTitle').textContent = '일정 수정';
  document.getElementById('evtTitle').value = e.title;
  document.getElementById('evtDate').value = e.date;
  document.getElementById('evtTime').value = e.time || '';
  document.getElementById('evtCat').value = e.cat;
  const sel = document.getElementById('evtAssignee');
  const currentAssignee = e.assignee || e.taskAssignee || '';
  if (e.cat == 3) {
    sel.disabled = false;
    sel.style.background = '';
    sel.style.color = '';
    sel.style.cursor = '';
    populateCalAssigneeSelect(currentAssignee);
  } else {
    sel.disabled = true;
    sel.style.background = '#f3f4f6';
    sel.style.color = '#9ca3af';
    sel.style.cursor = 'not-allowed';
    sel.innerHTML = '<option value="">-- 담당자 선택 --</option>';
  }
  document.getElementById('evtMemo').value = e.memo || '';
  document.getElementById('delBtn').style.display = '';
  document.getElementById('modalBg').classList.add('open');
}

function closeModal() {
  document.getElementById('modalBg').classList.remove('open');
}

// =====================
// 저장 / 수정
// =====================
document.getElementById('saveBtn').onclick = () => {
  const title = document.getElementById('evtTitle').value.trim();
  if (!title) return;

  const params = new URLSearchParams({
    action: editIdx >= 0 ? "update" : "save",
    title: title,
    project_id: document.getElementById('evtProjectId').value,
    date: document.getElementById('evtDate').value,
    time: document.getElementById('evtTime').value,
    cat: parseInt(document.getElementById('evtCat').value),
    memo: document.getElementById('evtMemo').value,
    assignee: document.getElementById('evtAssignee').value || ''
  });

  if (editIdx >= 0) {
    params.append("id", events[editIdx].id);
    if (events[editIdx].taskId != null) {
      params.append("taskId", events[editIdx].taskId);
    }
  }

  fetch(contextPath + "/event", {
    method: "POST",
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: params
  }).then(() => { closeModal(); loadEvents(); });
};

// =====================
// 삭제
// =====================
document.getElementById('delBtn').onclick = () => {
  if (editIdx >= 0) {
    fetch(contextPath + "/event", {
      method: "POST",
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: new URLSearchParams({ action: "delete", id: events[editIdx].id })
    }).then(() => { closeModal(); loadEvents(); });
  }
};

// =====================
// 이벤트
// =====================
document.getElementById('cancelBtn').onclick = closeModal;
document.getElementById('modalBg').onclick = e => {
  if (e.target.id === 'modalBg') closeModal();
};

document.getElementById('prevBtn').onclick = () => {
  curM--;
  if (curM < 0) { curM = 11; curY--; }
  loadEvents();
};

document.getElementById('nextBtn').onclick = () => {
  curM++;
  if (curM > 11) { curM = 0; curY++; }
  loadEvents();
};

document.getElementById('todayBtn').onclick = () => {
  curY = today.getFullYear();
  curM = today.getMonth();
  loadEvents();
};

monthSel.onchange = () => { curM = parseInt(monthSel.value); loadEvents(); };
yearSel.onchange = () => { curY = parseInt(yearSel.value); loadEvents(); };

document.getElementById('evtCat').addEventListener('change', function() {
  const sel = document.getElementById('evtAssignee');
  if (this.value === '3') {
    sel.disabled = false;
    sel.style.background = '';
    sel.style.color = '';
    sel.style.cursor = '';
    populateCalAssigneeSelect('');
  } else {
    sel.disabled = true;
    sel.innerHTML = '<option value="">-- 담당자 선택 --</option>';
    sel.style.background = '#f3f4f6';
    sel.style.color = '#9ca3af';
    sel.style.cursor = 'not-allowed';
  }
});

// =====================
// 최초 실행
// =====================
loadCalMembers().then(() => loadEvents());