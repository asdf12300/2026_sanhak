let tasks = [];
let editId = -1;
let currentFilter = 'all';
let projectMembers = []; // 프로젝트 팀원 캐시

// ── 팀원 목록 로드 ──
function loadMembers() {
  return fetch("taskApi?projectId=" + PROJECT_ID + "&type=members")
    .then(r => r.json())
    .then(data => { projectMembers = data; })
    .catch(() => { projectMembers = []; });
}

// ── 담당자 드롭다운 채우기 ──
function populateAssigneeSelect(selectedId) {
  const sel = document.getElementById('taskAssignee');
  sel.innerHTML = '<option value="">-- 담당자 선택 --</option>';
  projectMembers.forEach(m => {
    const opt = document.createElement('option');
    opt.value = m.id;
    opt.textContent = m.name ? m.name + ' (' + m.id + ')' : m.id;
    if (m.id === selectedId) opt.selected = true;
    sel.appendChild(opt);
  });
}

// ── 데이터 로드 ──
function loadTasks() {
  fetch("taskApi?projectId=" + PROJECT_ID)
    .then(r => r.json())
    .then(data => { tasks = data; renderTable(); })
    .catch(() => { tasks = []; renderTable(); });
}

// ── 테이블 렌더링 ──
function renderTable() {
  const tbody = document.getElementById('taskBody');
  const filtered = currentFilter === 'all' ? tasks : tasks.filter(t => t.status === currentFilter);

  if (filtered.length === 0) {
    tbody.innerHTML = '<tr class="empty-row"><td colspan="6">등록된 업무가 없습니다.</td></tr>';
    return;
  }

  tbody.innerHTML = filtered.map(t => {
    const sc = t.status === 'In Progress' ? 's-inprogress' : t.status === 'Done' ? 's-done' : 's-todo';
    return `<tr>
      <td><strong>${t.title}</strong></td>
      <td>${t.assignee || '-'}</td>
      <td><span class="status-badge ${sc}">${t.status}</span></td>
      <td>${t.deadline || '-'}</td>
      <td style="color:#94a3b8;font-size:12px">${t.content || ''}</td>
      <td><div class="btn-row">
        ${IS_PROFESSOR ? '' : `<button class="btn-edit" onclick="openEdit(${t.id})">수정</button>
        <button class="btn-del" onclick="confirmDelete(${t.id})">삭제</button>`}
      </div></td>
    </tr>`;
  }).join('');
}

// ── 필터 ──
function setFilter(f, btn) {
  currentFilter = f;
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  renderTable();
}

// ── 모달 열기 ──
function openNew() {
  editId = -1;
  document.getElementById('modalTitle').textContent = '업무 추가';
  document.getElementById('taskTitle').value = '';
  document.getElementById('taskStatus').value = 'To Do';
  document.getElementById('taskDeadline').value = '';
  document.getElementById('taskContent').value = '';
  document.getElementById('delBtn').style.display = 'none';
  populateAssigneeSelect('');
  document.getElementById('modalBg').classList.add('open');
}

function openEdit(id) {
  const t = tasks.find(x => x.id === id);
  if (!t) return;
  editId = id;
  document.getElementById('modalTitle').textContent = '업무 수정';
  document.getElementById('taskTitle').value    = t.title;
  document.getElementById('taskStatus').value   = t.status;
  document.getElementById('taskDeadline').value = t.deadline || '';
  document.getElementById('taskContent').value  = t.content || '';
  document.getElementById('delBtn').style.display = '';
  populateAssigneeSelect(t.assignee || '');
  document.getElementById('modalBg').classList.add('open');
}

function closeModal() {
  document.getElementById('modalBg').classList.remove('open');
}

// ── 저장 / 수정 ──
function saveTask() {
  const title    = document.getElementById('taskTitle').value.trim();
  const deadline = document.getElementById('taskDeadline').value.trim();

  if (!title && !deadline) {
    alert('제목과 마감일을 입력하세요.');
    return;
  }
  if (!title) {
    alert('제목을 입력하세요.');
    return;
  }
  if (!deadline) {
    alert('마감일을 입력하세요.');
    return;
  }

  const params = new URLSearchParams({
    action:    editId >= 0 ? 'update' : 'save',
    projectId: PROJECT_ID,
    title:     title,
    assignee:  document.getElementById('taskAssignee').value,
    status:    document.getElementById('taskStatus').value,
    deadline:  document.getElementById('taskDeadline').value,
    content:   document.getElementById('taskContent').value
  });
  if (editId >= 0) params.append('id', editId);

  fetch('taskApi', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: params
  }).then(r => r.text()).then(res => {
    if (res.startsWith('error:')) {
      alert(res.replace('error:', ''));
    } else {
      closeModal();
      loadTasks();
    }
  });
}

// ── 삭제 ──
function confirmDelete(id) {
  if (!confirm('업무를 삭제하시겠습니까?')) return;
  fetch('taskApi', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ action: 'delete', id: id })
  }).then(() => loadTasks());
}

function deleteTask() {
  if (editId < 0) return;
  if (!confirm('업무를 삭제하시겠습니까?')) return;
  fetch('taskApi', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ action: 'delete', id: editId })
  }).then(() => { closeModal(); loadTasks(); });
}

// ── 이벤트 ──
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('modalBg').onclick = e => {
    if (e.target.id === 'modalBg') closeModal();
  };
  loadMembers().then(() => loadTasks());
});
