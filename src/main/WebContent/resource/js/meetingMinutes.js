// 회의록 작성 모달 열기
function openCreateModal() {
    document.getElementById('createModal').classList.add('active');
    document.getElementById('meetingDate').valueAsDate = new Date();
    document.body.style.overflow = 'hidden';
}

// 회의록 작성 모달 닫기
function closeCreateModal() {
    document.getElementById('createModal').classList.remove('active');
    document.getElementById('createForm').reset();
    document.body.style.overflow = 'auto';
}

// 회의록 상세보기 모달 열기
function openViewModal(id, projectId) {
    const modal = document.getElementById('viewModal');
    const iframe = document.getElementById('viewFrame');
    iframe.src = 'meetingMinutesView?id=' + id + '&projectId=' + projectId;
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
}

// 회의록 상세보기 모달 닫기
function closeViewModal() {
    const modal = document.getElementById('viewModal');
    modal.classList.remove('active');
    document.getElementById('viewFrame').src = '';
    document.body.style.overflow = 'auto';
    // 페이지 새로고침하여 목록 업데이트
    location.reload();
}

// 오버레이 클릭 시 모달 닫기
function closeModalOnOverlay(event, modalId) {
    if (event.target.id === modalId || event.target.id === 'createModal') {
        if (modalId === 'viewModal') {
            closeViewModal();
        } else {
            closeCreateModal();
        }
    }
}

// ESC 키로 모달 닫기
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (document.getElementById('viewModal').classList.contains('active')) {
            closeViewModal();
        } else if (document.getElementById('createModal').classList.contains('active')) {
            closeCreateModal();
        }
    }
});

// iframe에서 메시지 받기 (삭제/수정 후 모달 닫기)
window.addEventListener('message', function(event) {
    if (event.data === 'closeModal') {
        closeViewModal();
    }
});
