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

// 텍스트 에디터 기능
const editor = document.getElementById('editor');
const contentField = document.getElementById('content');

// 색상 팔레트 정의
const colors = [
    // 첫 번째 줄 - 없음, 회색, 파스텔
    'transparent', '#808080', '#ffcccc', '#ffe0cc', '#ffffcc', '#e0ffcc', '#ccffcc', '#ccffe0', '#ccffff', '#cce0ff', '#ccccff', '#e0ccff',
    // 두 번째 줄
    '#f0f0f0', '#999999', '#ffb3b3', '#ffd1b3', '#ffffb3', '#d1ffb3', '#b3ffb3', '#b3ffd1', '#b3ffff', '#b3d1ff', '#b3b3ff', '#d1b3ff',
    // 세 번째 줄
    '#d0d0d0', '#666666', '#ff9999', '#ffc299', '#ffff99', '#c2ff99', '#99ff99', '#99ffc2', '#99ffff', '#99c2ff', '#9999ff', '#c299ff',
    // 네 번째 줄
    '#b0b0b0', '#333333', '#ff6666', '#ffb366', '#ffff66', '#b3ff66', '#66ff66', '#66ffb3', '#66ffff', '#66b3ff', '#6666ff', '#b366ff',
    // 다섯 번째 줄
    '#909090', '#000000', '#ff0000', '#ff9900', '#ffff00', '#99ff00', '#00ff00', '#00ff99', '#00ffff', '#0099ff', '#0000ff', '#9900ff',
    // 여섯 번째 줄
    '#707070', '#000000', '#cc0000', '#cc7700', '#cccc00', '#77cc00', '#00cc00', '#00cc77', '#00cccc', '#0077cc', '#0000cc', '#7700cc'
];

// 색상 팔레트 생성
function initColorPalette() {
    const textGrid = document.getElementById('textColorGrid');
    const bgGrid = document.getElementById('bgColorGrid');
    
    if (!textGrid || !bgGrid) return;
    
    colors.forEach((color, index) => {
        // 글자 색 팔레트
        const textItem = document.createElement('div');
        textItem.className = 'color-item' + (index === 0 ? ' no-color' : '');
        if (color !== 'transparent') {
            textItem.style.background = color;
        }
        textItem.onclick = () => applyColor('text', color);
        textGrid.appendChild(textItem);
        
        // 배경 색 팔레트
        const bgItem = document.createElement('div');
        bgItem.className = 'color-item' + (index === 0 ? ' no-color' : '');
        if (color !== 'transparent') {
            bgItem.style.background = color;
        }
        bgItem.onclick = () => applyColor('bg', color);
        bgGrid.appendChild(bgItem);
    });
}

// 색상 팔레트 토글
function toggleColorPalette(type) {
    const palette = document.getElementById(type + 'Palette');
    const allPalettes = document.querySelectorAll('.color-palette');
    
    allPalettes.forEach(p => {
        if (p !== palette) p.classList.remove('show');
    });
    
    palette.classList.toggle('show');
}

// 색상 적용
function applyColor(type, color) {
    if (type === 'text') {
        if (color === 'transparent') {
            formatDoc('removeFormat');
        } else {
            formatDoc('foreColor', color);
            document.getElementById('textColorIcon').style.background = color;
            document.getElementById('textColorIcon').style.borderBottomColor = color;
        }
        document.getElementById('textColorPalette').classList.remove('show');
    } else {
        if (color === 'transparent') {
            formatDoc('removeFormat');
        } else {
            formatDoc('backColor', color);
            document.getElementById('bgColorIcon').style.background = color;
        }
        document.getElementById('bgColorPalette').classList.remove('show');
    }
}

// 커스텀 색상 적용
function applyCustomColor(type, color) {
    applyColor(type, color);
}

// 글씨 크기 변경 (px 단위)
function changeFontSize(size) {
    document.execCommand('fontSize', false, '7');
    const fontElements = editor.querySelectorAll('font[size="7"]');
    fontElements.forEach(element => {
        element.removeAttribute('size');
        element.style.fontSize = size + 'px';
    });
    editor.focus();
}

// 포맷 적용 함수
function formatDoc(cmd, value = null) {
    document.execCommand(cmd, false, value);
    editor.focus();
}

// 팔레트 외부 클릭 시 닫기
document.addEventListener('click', function(e) {
    if (!e.target.closest('.color-picker-wrapper')) {
        document.querySelectorAll('.color-palette').forEach(p => {
            p.classList.remove('show');
        });
    }
});

// 폼 제출 시 에디터 내용을 textarea에 복사
if (document.getElementById('createForm')) {
    document.getElementById('createForm').addEventListener('submit', function(e) {
        if (!editor) return;
        
        const editorContent = editor.innerHTML.trim();
        
        if (!editorContent || editorContent === '') {
            e.preventDefault();
            alert('회의 내용을 입력해주세요.');
            editor.focus();
            return false;
        }
        
        contentField.value = editorContent;
    });
}

// 키보드 단축키 지원
if (editor) {
    editor.addEventListener('keydown', function(e) {
        if (e.ctrlKey || e.metaKey) {
            switch(e.key.toLowerCase()) {
                case 'b':
                    e.preventDefault();
                    formatDoc('bold');
                    break;
                case 'i':
                    e.preventDefault();
                    formatDoc('italic');
                    break;
                case 'u':
                    e.preventDefault();
                    formatDoc('underline');
                    break;
            }
        }
    });
}

// 모달이 열릴 때 색상 팔레트 초기화
const originalOpenCreateModal = openCreateModal;
openCreateModal = function() {
    originalOpenCreateModal();
    // 약간의 지연 후 초기화 (DOM이 준비될 때까지)
    setTimeout(() => {
        if (document.getElementById('textColorGrid') && !document.getElementById('textColorGrid').hasChildNodes()) {
            initColorPalette();
        }
    }, 100);
};
