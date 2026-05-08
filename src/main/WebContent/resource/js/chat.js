// 전역 변수
let ws = null;
let currentRoomId = null;
let currentRoomType = null;
let rooms = [];

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    loadChatRooms();
    setupEventListeners();
});

// 이벤트 리스너 설정
function setupEventListeners() {
    // 팀 채팅방 만들기
    document.getElementById('createTeamChatBtn').addEventListener('click', function() {
        showModal('createTeamChatModal');
    });

    // 개인 채팅 시작
    document.getElementById('createPersonalChatBtn').addEventListener('click', function() {
        loadProjectMembers();
        showModal('createPersonalChatModal');
    });

    // 채팅방 정보
    document.getElementById('chatInfoBtn').addEventListener('click', function() {
        if (currentRoomId) {
            loadRoomInfo(currentRoomId);
        }
    });

    // 팀 채팅방 생성 확인
    document.getElementById('confirmCreateTeamChat').addEventListener('click', function() {
        const roomName = document.getElementById('teamChatName').value.trim();
        if (roomName) {
            createTeamChatRoom(roomName);
        } else {
            alert('채팅방 이름을 입력해주세요.');
        }
    });

    // 메시지 전송
    document.getElementById('sendMessageBtn').addEventListener('click', sendMessage);
    
    // Enter 키로 메시지 전송 (Shift+Enter는 줄바꿈)
    document.getElementById('messageInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // 모달 닫기
    document.querySelectorAll('.modal-close').forEach(btn => {
        btn.addEventListener('click', function() {
            const modal = this.closest('.modal');
            hideModal(modal.id);
        });
    });
	document.querySelectorAll('.btn-secondary').forEach(btn => {
	    btn.addEventListener('click', function() {
	        const modal = this.closest('.modal');
	        hideModal(modal.id);
	    });
	});

    // 모달 외부 클릭 시 닫기
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                hideModal(this.id);
            }
        });
    });

    // 팀원 검색
    document.getElementById('memberSearch').addEventListener('input', function(e) {
        const searchTerm = e.target.value.toLowerCase();
        const memberItems = document.querySelectorAll('.member-item');
        memberItems.forEach(item => {
            const name = item.querySelector('.member-name').textContent.toLowerCase();
            const id = item.querySelector('.member-id').textContent.toLowerCase();
            if (name.includes(searchTerm) || id.includes(searchTerm)) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    });
}

// 채팅방 목록 로드
function loadChatRooms() {
    fetch(`ChatServlet?action=getRooms&projectId=${projectId}`)
        .then(response => response.text())
        .then(text => {
            console.log('[loadChatRooms] 응답:', text);
            if (!text || text.trim() === '') {
                displayChatRooms([]);
                return;
            }
            const data = JSON.parse(text);
            rooms = data;
            displayChatRooms(data);
        })
        .catch(error => {
            console.error('채팅방 목록 로드 실패:', error);
            document.getElementById('roomList').innerHTML = '<div class="loading">채팅방을 불러올 수 없습니다.</div>';
        });
}

// 채팅방 목록 표시
function displayChatRooms(rooms) {
    const roomList = document.getElementById('roomList');
    
    if (rooms.length === 0) {
        roomList.innerHTML = '<div class="loading">채팅방이 없습니다.<br>새로운 채팅을 시작해보세요!</div>';
        return;
    }

    roomList.innerHTML = rooms.map(room => `
        <div class="room-item" data-room-id="${room.roomId}" onclick="selectRoom(${room.roomId})">
            <div class="room-item-header">
                <span class="room-name">${escapeHtml(room.roomName)}</span>
                <span class="room-time">${formatTime(room.lastMessageTime)}</span>
            </div>
            <div class="room-last-message">
                ${room.lastMessage ? escapeHtml(room.lastMessage) : '메시지가 없습니다'}
                ${room.unreadCount > 0 ? `<span class="room-unread">${room.unreadCount}</span>` : ''}
            </div>
        </div>
    `).join('');
}

// 채팅방 선택
function selectRoom(roomId) {
    if (currentRoomId === roomId) return;

    // WebSocket 연결 종료
    if (ws) {
        ws.close();
    }

    currentRoomId = roomId;
    const room = rooms.find(r => r.roomId === roomId);
    currentRoomType = room ? room.roomType : 'team';

    // UI 업데이트
    document.querySelectorAll('.room-item').forEach(item => {
        item.classList.remove('active');
    });
    document.querySelector(`[data-room-id="${roomId}"]`).classList.add('active');

    document.getElementById('chatEmpty').style.display = 'none';
    document.getElementById('chatActive').style.display = 'flex';
    document.getElementById('chatRoomName').textContent = room ? room.roomName : '채팅방';
    
    const typeBadge = document.getElementById('chatRoomType');
    typeBadge.textContent = currentRoomType === 'team' ? '팀 채팅' : '개인 채팅';
    typeBadge.className = `room-type-badge ${currentRoomType}`;

    // 메시지 로드
    loadMessages(roomId);

    // WebSocket 연결
    connectWebSocket(roomId);

    // 읽음 처리
    markAsRead(roomId);

    // 교수는 메시지 입력 비활성화
    const inputArea = document.getElementById('messageInput');
    const sendBtn = document.getElementById('sendMessageBtn');
    if (userRole === 'professor') {
        inputArea.disabled = true;
        inputArea.placeholder = '교수는 채팅방에서 메시지를 보낼 수 없습니다.';
        sendBtn.disabled = true;
    } else {
        inputArea.disabled = false;
        inputArea.placeholder = '메시지를 입력하세요...';
        sendBtn.disabled = false;
    }
}

// 메시지 로드
function loadMessages(roomId) {
    fetch(`ChatServlet?action=getMessages&roomId=${roomId}&limit=50`)
        .then(response => response.json())
        .then(messages => {
            displayMessages(messages); // ASC 정렬이므로 reverse 불필요
        })
        .catch(error => {
            console.error('메시지 로드 실패:', error);
        });
}

// 메시지 표시
function displayMessages(messages) {
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.innerHTML = messages.map(msg => createMessageElement(msg)).join('');
    scrollToBottom();
}

// 메시지 요소 생성
function createMessageElement(msg) {
    const isMine = msg.senderId === userId;
    const messageClass = msg.messageType === 'system' ? 'system' : (isMine ? 'mine' : 'other');
    
    if (msg.messageType === 'system') {
        return `
            <div class="message system">
                <div class="message-content">${escapeHtml(msg.message)}</div>
            </div>
        `;
    }
    
    return `
        <div class="message ${messageClass}">
            ${!isMine ? `<div class="message-sender">${escapeHtml(msg.senderName)}</div>` : ''}
            <div class="message-content">${escapeHtml(msg.message)}</div>
            <div class="message-time">${formatTime(msg.sentAt)}</div>
        </div>
    `;
}

// WebSocket 연결
function connectWebSocket(roomId) {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}${window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1))}/chat/${roomId}/${userId}`;
    
    ws = new WebSocket(wsUrl);

    ws.onopen = function() {
        console.log('WebSocket 연결됨');
    };

    ws.onmessage = function(event) {
        const message = JSON.parse(event.data);
        appendMessage(message);
    };

    ws.onerror = function(error) {
        console.error('WebSocket 오류:', error);
    };

    ws.onclose = function() {
        console.log('WebSocket 연결 종료');
    };
}

// 메시지 추가
function appendMessage(message) {
    const chatMessages = document.getElementById('chatMessages');
    const messageElement = createMessageElement(message);
    chatMessages.insertAdjacentHTML('beforeend', messageElement);
    scrollToBottom();

    // 채팅방 목록 업데이트
    loadChatRooms();
}

// 메시지 전송
function sendMessage() {
    const input = document.getElementById('messageInput');
    const message = input.value.trim();

    if (!message || !ws || ws.readyState !== WebSocket.OPEN) {
        return;
    }

    const messageData = {
        type: 'text',
        message: message,
        senderName: userName
    };

    ws.send(JSON.stringify(messageData));
    input.value = '';
    input.style.height = 'auto';
}

// 팀 채팅방 생성
function createTeamChatRoom(roomName) {
    const params = new URLSearchParams();
    params.append('action', 'createRoom');
    params.append('projectId', projectId);
    params.append('roomName', roomName);
    params.append('roomType', 'team');

    fetch('ChatServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(response => response.text())
    .then(text => {
        console.log('createRoom 응답:', text);
        if (!text || text.trim() === '') {
            throw new Error('서버에서 빈 응답이 왔습니다.');
        }
        const data = JSON.parse(text);
        if (data.success) {
            hideModal('createTeamChatModal');
            document.getElementById('teamChatName').value = '';
            loadChatRooms();
            setTimeout(() => selectRoom(data.roomId), 500);
        } else {
            alert('채팅방 생성 실패: ' + (data.message || '알 수 없는 오류'));
        }
    })
    .catch(error => {
        console.error('채팅방 생성 실패:', error);
        alert('채팅방 생성에 실패했습니다: ' + error.message);
    });
}

// 프로젝트 멤버 로드 (학생만, 교수 제외)
function loadProjectMembers() {
    fetch(`projectMember?action=getMembers&projectId=${projectId}`)
        .then(response => response.json())
        .then(members => {
            // accepted 상태이고, 본인이 아니고, 학생인 멤버만 필터링
            const filteredMembers = members.filter(m =>
                m.status === 'accepted' &&
                m.memberId !== userId &&
                m.role !== 'professor'
            );
            displayMembers(filteredMembers);
        })
        .catch(error => {
            console.error('멤버 로드 실패:', error);
            document.getElementById('memberList').innerHTML = '<div class="loading">멤버를 불러올 수 없습니다.</div>';
        });
}

// 멤버 목록 표시
function displayMembers(members) {
    const memberList = document.getElementById('memberList');
    
    if (members.length === 0) {
        memberList.innerHTML = '<div class="loading">다른 팀원이 없습니다.</div>';
        return;
    }

    memberList.innerHTML = members.map(member => `
        <div class="member-item" onclick="startPersonalChat('${member.memberId}')">
            <div class="member-name">${escapeHtml(member.name)}</div>
            <div class="member-id">${escapeHtml(member.memberId)}</div>
        </div>
    `).join('');
}

// 개인 채팅 시작
function startPersonalChat(targetMemberId) {
    const params = new URLSearchParams();
    params.append('action', 'createPersonalChat');
    params.append('projectId', projectId);
    params.append('targetMemberId', targetMemberId);

    fetch('ChatServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(response => response.text())
    .then(text => {
        console.log('createPersonalChat 응답:', text);
        if (!text || text.trim() === '') {
            throw new Error('서버에서 빈 응답이 왔습니다.');
        }
        const data = JSON.parse(text);
        if (data.success) {
            hideModal('createPersonalChatModal');
            loadChatRooms();
            setTimeout(() => selectRoom(data.roomId), 500);
        } else {
            alert('채팅 시작 실패: ' + (data.message || '알 수 없는 오류'));
        }
    })
    .catch(error => {
        console.error('개인 채팅 시작 실패:', error);
        alert('채팅을 시작할 수 없습니다: ' + error.message);
    });
}

// 채팅방 정보 로드
function loadRoomInfo(roomId) {
    fetch(`ChatServlet?action=getRoomInfo&roomId=${roomId}`)
        .then(response => response.json())
        .then(data => {
            displayRoomInfo(data);
            showModal('chatInfoModal');
        })
        .catch(error => {
            console.error('채팅방 정보 로드 실패:', error);
        });
}

// 채팅방 정보 표시
function displayRoomInfo(data) {
    const content = document.getElementById('chatInfoContent');
    content.innerHTML = `
        <div style="margin-bottom: 16px;">
            <strong>채팅방 이름:</strong> ${escapeHtml(data.room.roomName)}
        </div>
        <div style="margin-bottom: 16px;">
            <strong>유형:</strong> ${data.room.roomType === 'team' ? '팀 채팅' : '개인 채팅'}
        </div>
        <div style="margin-bottom: 8px;">
            <strong>참여자 (${data.members.length}명):</strong>
        </div>
        <div style="padding-left: 16px;">
            ${data.members.map(m => `<div style="padding: 4px 0;">${escapeHtml(m)}</div>`).join('')}
        </div>
    `;
}

// 읽음 처리
function markAsRead(roomId) {
    const params = new URLSearchParams();
    params.append('action', 'markAsRead');
    params.append('roomId', roomId);

    fetch('ChatServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    }).catch(error => console.error('읽음 처리 실패:', error));
}

// 유틸리티 함수
function showModal(modalId) {
    document.getElementById(modalId).classList.add('show');
}

function hideModal(modalId) {
    document.getElementById(modalId).classList.remove('show');
}

function scrollToBottom() {
    const chatMessages = document.getElementById('chatMessages');
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatTime(timestamp) {
    if (!timestamp) return '';
    
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    // 1분 미만
    if (diff < 60000) {
        return '방금 전';
    }
    
    // 1시간 미만
    if (diff < 3600000) {
        return Math.floor(diff / 60000) + '분 전';
    }
    
    // 오늘
    if (date.toDateString() === now.toDateString()) {
        return date.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
    }
    
    // 어제
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    if (date.toDateString() === yesterday.toDateString()) {
        return '어제';
    }
    
    // 그 외
    return date.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
}

// 페이지 떠날 때 WebSocket 연결 종료
window.addEventListener('beforeunload', function() {
    if (ws) {
        ws.close();
    }
});
