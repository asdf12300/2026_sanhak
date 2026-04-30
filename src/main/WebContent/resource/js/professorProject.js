// ── 알림 ──
function toggleNotifications() {
  document.getElementById('notificationDropdown').classList.toggle('show');
}
document.addEventListener('click', function(e) {
  const wrapper = document.querySelector('.notification-wrapper');
  const dropdown = document.getElementById('notificationDropdown');
  if (wrapper && !wrapper.contains(e.target)) dropdown.classList.remove('show');
});

// ── 모달 배경 클릭 시 닫기 ──
document.querySelectorAll('.modal-bg').forEach(function(modal) {
  modal.addEventListener('click', function(e) {
    if (e.target === modal) modal.classList.remove('open');
  });
});

// ── 드래그앤드롭 ──
let draggedProjectId = null;

function onProjectDragStart(event, projectId) {
  draggedProjectId = projectId;
  event.currentTarget.classList.add('dragging');
  event.dataTransfer.effectAllowed = 'move';
  event.dataTransfer.setData('text/plain', projectId);
}

function onProjectDragEnd(event) {
  event.currentTarget.classList.remove('dragging');
  // 모든 폴더 행 강조 제거
  document.querySelectorAll('.folder-row').forEach(function(row) {
    row.classList.remove('drag-over');
  });
}

function onFolderDragOver(event, folderCard) {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
  folderCard.classList.add('drag-over');
}

function onFolderDragLeave(folderCard) {
  folderCard.classList.remove('drag-over');
}

function onFolderDrop(event, folderId) {
  event.preventDefault();
  const folderCard = event.currentTarget;
  folderCard.classList.remove('drag-over');

  if (draggedProjectId === null) return;

  // 서버에 폴더 지정 요청
  const params = new URLSearchParams();
  params.append('action', 'assign');
  params.append('projectId', draggedProjectId);
  params.append('folderId', folderId);

  fetch('folderAction', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: params
  }).then(function(res) {
    if (res.ok) {
      location.reload();
    } else {
      alert('폴더 이동에 실패했습니다.');
    }
  }).catch(function() {
    alert('오류가 발생했습니다.');
  });

  draggedProjectId = null;
}

function toggleFolderProjects(folderId) {
  const children = document.getElementById('fp-' + folderId);
  const chevron  = document.getElementById('chevron-' + folderId);
  const row      = document.getElementById('folder-row-' + folderId);
  if (!children) return;

  const isOpen = children.classList.toggle('open');
  if (chevron) chevron.classList.toggle('expanded', isOpen);
  if (row)     row.classList.toggle('expanded', isOpen);
}
