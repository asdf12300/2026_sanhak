var MONTHS = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
var DAYS = ['일','월','화','수','목','금','토'];

var today = new Date();
var curY = today.getFullYear();
var curM = today.getMonth();
var events = [];
var editIdx = -1;
var calProjectMembers = [];

// =====================
// 서버에서 데이터 불러오기
// =====================
function loadEvents() {
  var el = document.getElementById('evtProjectId');
  var projectId = el ? el.value : '';
  fetch(contextPath + "/event?action=list&projectId=" + projectId)
    .then(function(res) { return res.json(); })
    .then(function(data) {
      events = data.map(function(e) {
        return {
          id: e.id, title: e.title,
          date: e.date ? e.date.substring(0, 10) : '',
          time: e.time, cat: e.cat, memo: e.memo,
          taskId: e.taskId, taskStatus: e.taskStatus,
          taskAssignee: e.taskAssignee, assignee: e.assignee
        };
      });
      renderCal();
    })
    .catch(function() { events = []; renderCal(); });
}

function loadCalMembers() {
  var el = document.getElementById('evtProjectId');
  var projectId = el ? el.value : '';
  if (!projectId) return Promise.resolve();
  return fetch(contextPath + "/event?action=members&projectId=" + projectId)
    .then(function(r) { return r.json(); })
    .then(function(data) { calProjectMembers = data; })
    .catch(function() { calProjectMembers = []; });
}

function populateCalAssigneeSelect(selectedId) {
  var sel = document.getElementById('evtAssignee');
  sel.innerHTML = '<option value="">-- 담당자 선택 --</option>';
  for (var i = 0; i < calProjectMembers.length; i++) {
    var m = calProjectMembers[i];
    var opt = document.createElement('option');
    opt.value = m.id;
    opt.textContent = m.name ? m.name + ' (' + m.id + ')' : m.id;
    if (m.id === selectedId) opt.selected = true;
    sel.appendChild(opt);
  }
}

// =====================
// 캘린더 렌더링
// =====================
var monthSel = document.getElementById('monthSel');
var yearSel  = document.getElementById('yearSel');

for (var mi = 0; mi < MONTHS.length; mi++) {
  var mo = document.createElement('option');
  mo.value = mi;
  mo.textContent = MONTHS[mi];
  monthSel.appendChild(mo);
}

for (var y = today.getFullYear() - 10; y <= today.getFullYear() + 10; y++) {
  var yo = document.createElement('option');
  yo.value = y;
  yo.textContent = y + '년';
  yearSel.appendChild(yo);
}

function pad2(n) { return n < 10 ? '0' + n : '' + n; }

function formatDate(y, m, d) {
  return y + '-' + pad2(m + 1) + '-' + pad2(d);
}

function renderCal() {
  monthSel.value = curM;
  yearSel.value  = curY;
  document.getElementById('calTitle').textContent = curY + '년 ' + MONTHS[curM];

  var grid = document.getElementById('calGrid');
  grid.innerHTML = '';

  for (var di = 0; di < DAYS.length; di++) {
    var dl = document.createElement('div');
    dl.className = 'day-label';
    dl.textContent = DAYS[di];
    grid.appendChild(dl);
  }

  var first = new Date(curY, curM, 1).getDay();
  var last  = new Date(curY, curM + 1, 0).getDate();

  for (var ei = 0; ei < first; ei++) {
    var empty = document.createElement('div');
    empty.className = 'day-cell';
    grid.appendChild(empty);
  }

  for (var d = 1; d <= last; d++) {
    (function(day) {
      var cell = document.createElement('div');
      cell.className = 'day-cell';

      var num = document.createElement('div');
      num.textContent = day;
      cell.appendChild(num);

      var dateStr = formatDate(curY, curM, day);
      var dayEvents = [];
      for (var i = 0; i < events.length; i++) {
        if (events[i].date === dateStr) dayEvents.push(events[i]);
      }

      var shown = dayEvents.slice(0, 2);
      for (var si = 0; si < shown.length; si++) {
        (function(ev, evIdx) {
          var dot = document.createElement('div');
          dot.className = 'event-dot cat-' + ev.cat;
          dot.textContent = (ev.time ? ev.time.substring(0, 5) + ' ' : '') + ev.title;
          dot.onclick = function(e) {
            e.stopPropagation();
            openEdit(evIdx);
          };
          cell.appendChild(dot);
        })(shown[si], events.indexOf(shown[si]));
      }

      if (dayEvents.length > 2) {
        var more = document.createElement('div');
        more.className = 'more-btn';
        more.textContent = '+' + (dayEvents.length - 2) + ' 더보기';
        more.onclick = function(e) {
          e.stopPropagation();
          openMorePopup(dateStr, dayEvents);
        };
        cell.appendChild(more);
      }

      cell.onclick = function() { openNew(curY, curM, day); };
      grid.appendChild(cell);
    })(d);
  }

  renderMonthList();
}

// =====================
// 이달의 일정 리스트
// =====================
function renderMonthList() {
  var list = document.getElementById('monthEventList');
  var sidebarTitle = document.getElementById('sidebarTitle');
  if (!list) return;

  if (sidebarTitle) {
    sidebarTitle.textContent = curY + '년 ' + MONTHS[curM] + ' 일정';
  }

  var CAT_LABELS = ['일반', '중요', '개인', '업무'];
  var rows = [];

  for (var i = 0; i < events.length; i++) {
    var e = events[i];
    if (!e.date || e.date.length < 7) continue;
    var yy = parseInt(e.date.substring(0, 4), 10);
    var mm = parseInt(e.date.substring(5, 7), 10) - 1;
    if (yy === curY && mm === curM) {
      rows.push({ e: e, idx: i });
    }
  }

  rows.sort(function(a, b) {
    if (a.e.date < b.e.date) return -1;
    if (a.e.date > b.e.date) return 1;
    var ta = a.e.time || '';
    var tb = b.e.time || '';
    return ta < tb ? -1 : ta > tb ? 1 : 0;
  });

  if (rows.length === 0) {
    list.innerHTML = '<div class="month-event-empty">일정이 없습니다.</div>';
    return;
  }

  var html = '';
  for (var ri = 0; ri < rows.length; ri++) {
    var row = rows[ri];
    var ev = row.e;
    var idx = row.idx;
    var parts = ev.date.split('-');
    var dayNum = parseInt(parts[2], 10);
    var dayName = ['일','월','화','수','목','금','토'][new Date(parseInt(parts[0],10), parseInt(parts[1],10)-1, dayNum).getDay()];
    var catLabel = CAT_LABELS[ev.cat] !== undefined ? CAT_LABELS[ev.cat] : '';
    var badge = (ev.taskStatus && ev.taskStatus !== '')
      ? '<span class="task-badge status-' + ev.taskStatus.replace(/ /g,'-') + '">' + ev.taskStatus + '</span>'
      : '<span class="task-badge" style="background:#f1f5f9;color:#64748b">' + catLabel + '</span>';
    var timeStr = (ev.time && ev.time.length >= 5) ? '<span class="month-event-time">' + ev.time.substring(0,5) + '</span>' : '';
    html += '<div class="month-event-item cat-' + ev.cat + '" onclick="openEdit(' + idx + ')">'
          + '<div class="month-event-date">' + dayNum + '일 (' + dayName + ')</div>'
          + '<div class="month-event-title">' + ev.title + '</div>'
          + '<div class="month-event-meta">' + timeStr + badge + '</div>'
          + '</div>';
  }
  list.innerHTML = html;
}

// =====================
// +N 더보기 팝업
// =====================
function openMorePopup(dateStr, dayEvents) {
  document.getElementById('morePopupDate').textContent = dateStr + ' 일정';

  var list = document.getElementById('morePopupList');
  list.innerHTML = '';

  for (var i = 0; i < dayEvents.length; i++) {
    (function(ev) {
      var item = document.createElement('div');
      item.className = 'more-popup-item cat-' + ev.cat;

      var badge = (ev.taskStatus && ev.taskStatus !== '')
        ? '<span class="task-badge status-' + ev.taskStatus.replace(/ /g,'-') + '">' + ev.taskStatus + '</span>'
        : '';

      item.innerHTML = '<span class="more-item-time">' + (ev.time ? ev.time.substring(0,5) : '') + '</span>'
                     + '<span class="more-item-title">' + ev.title + '</span>'
                     + badge;
      item.onclick = function() {
        closeMorePopup();
        openEdit(events.indexOf(ev));
      };
      list.appendChild(item);
    })(dayEvents[i]);
  }

  document.getElementById('morePopupBg').classList.add('open');
}

function closeMorePopup() {
  document.getElementById('morePopupBg').classList.remove('open');
}

document.getElementById('morePopupClose').onclick = closeMorePopup;
document.getElementById('morePopupBg').onclick = function(e) {
  if (e.target.id === 'morePopupBg') closeMorePopup();
};

// =====================
// 모달
// =====================
function openNew(y, m, d) {
  if (typeof IS_PROFESSOR !== 'undefined' && IS_PROFESSOR) return;
  editIdx = -1;
  document.getElementById('modalTitle').textContent = '일정 등록';
  document.getElementById('evtTitle').value = '';
  document.getElementById('evtDate').value = formatDate(y, m, d);
  document.getElementById('evtTime').value = '';
  document.getElementById('evtCat').value = '0';
  var sel = document.getElementById('evtAssignee');
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
  if (typeof IS_PROFESSOR !== 'undefined' && IS_PROFESSOR) return;
  editIdx = idx;
  var e = events[idx];
  document.getElementById('modalTitle').textContent = '일정 수정';
  document.getElementById('evtTitle').value = e.title;
  document.getElementById('evtDate').value = e.date;
  document.getElementById('evtTime').value = e.time || '';
  document.getElementById('evtCat').value = e.cat;
  var sel = document.getElementById('evtAssignee');
  var currentAssignee = e.assignee || e.taskAssignee || '';
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
document.getElementById('saveBtn').onclick = function() {
  var title = document.getElementById('evtTitle').value.trim();
  if (!title) return;

  var params = new URLSearchParams();
  params.append('action', editIdx >= 0 ? 'update' : 'save');
  params.append('title', title);
  params.append('project_id', document.getElementById('evtProjectId').value);
  params.append('date', document.getElementById('evtDate').value);
  params.append('time', document.getElementById('evtTime').value);
  params.append('cat', parseInt(document.getElementById('evtCat').value, 10));
  params.append('memo', document.getElementById('evtMemo').value);
  params.append('assignee', document.getElementById('evtAssignee').value || '');

  if (editIdx >= 0) {
    params.append('id', events[editIdx].id);
    if (events[editIdx].taskId != null) {
      params.append('taskId', events[editIdx].taskId);
    }
  }

  fetch(contextPath + "/event", {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: params
  }).then(function() { closeModal(); loadEvents(); });
};

// =====================
// 삭제
// =====================
document.getElementById('delBtn').onclick = function() {
  if (editIdx >= 0) {
    var params = new URLSearchParams();
    params.append('action', 'delete');
    params.append('id', events[editIdx].id);
    fetch(contextPath + "/event", {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: params
    }).then(function() { closeModal(); loadEvents(); });
  }
};

// =====================
// 이벤트
// =====================
document.getElementById('cancelBtn').onclick = closeModal;
document.getElementById('modalBg').onclick = function(e) {
  if (e.target.id === 'modalBg') closeModal();
};

document.getElementById('prevBtn').onclick = function() {
  curM--;
  if (curM < 0) { curM = 11; curY--; }
  loadEvents();
};

document.getElementById('nextBtn').onclick = function() {
  curM++;
  if (curM > 11) { curM = 0; curY++; }
  loadEvents();
};

document.getElementById('todayBtn').onclick = function() {
  curY = today.getFullYear();
  curM = today.getMonth();
  loadEvents();
};

monthSel.onchange = function() { curM = parseInt(monthSel.value, 10); loadEvents(); };
yearSel.onchange  = function() { curY = parseInt(yearSel.value, 10);  loadEvents(); };

document.getElementById('evtCat').addEventListener('change', function() {
  var sel = document.getElementById('evtAssignee');
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
loadCalMembers().then(function() { loadEvents(); });
