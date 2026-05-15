// 전역 변수
let ws = null;
let currentRoomId = null;
let currentRoomType = null;
let rooms = [];
let messageOffset = 0;
const messageLimit = 30;

let isLoadingMessages = false;
let hasMoreMessages = true;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    loadChatRooms();

    try {
        setupEventListeners();
        console.log('[chat] 이벤트 리스너 등록 완료');
    } catch(e) {
        console.error('[chat] setupEventListeners 오류:', e);
    }

    // 채팅 스크롤 무한 로딩
    const chatMessages = document.getElementById('chatMessages');

    chatMessages.addEventListener('scroll', function() {
        // 스크롤이 맨 위 근처(100px 이내)에 도달하면 이전 메시지 로드
        if (chatMessages.scrollTop <= 100 && currentRoomId && !isLoadingMessages && hasMoreMessages) {
            loadMessages(currentRoomId, false);
        }
    });
});

// 이벤트 리스너 설정
function setupEventListeners() {

    function on(id, event, fn) {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener(event, fn);
        } else {
            console.warn('[chat] 요소를 찾을 수 없음: #' + id);
        }
    }

    // 팀 채팅방 만들기
    on('createTeamChatBtn', 'click', function() {
        showModal('createTeamChatModal');
    });

    // 개인 채팅 시작
    on('createPersonalChatBtn', 'click', function() {
        loadProjectMembers();
        showModal('createPersonalChatModal');
    });

    // 채팅방 정보
    on('chatInfoBtn', 'click', function() {
        console.log('[chat] 정보 버튼 클릭, currentRoomId=', currentRoomId);
        if (currentRoomId) {
            loadRoomInfo(currentRoomId);
        } else {
            alert('채팅방을 먼저 선택해주세요.');
        }
    });

    // 정보 모달 - 이름 변경
    on('infoConfirmRename', 'click', function() {
        const newName = document.getElementById('infoRoomNameInput').value.trim();
        if (!newName) { alert('채팅방 이름을 입력해주세요.'); return; }
        renameRoom(currentRoomId, newName);
    });

    // 정보 모달 - 나가기 버튼
    on('infoLeaveRoom', 'click', function() {
        hideModal('chatInfoModal');
        showModal('leaveRoomModal');
    });

    // 나가기 확인
    on('confirmLeaveRoom', 'click', function() {
        leaveRoom(currentRoomId);
    });

    // 팀 채팅방 생성 확인
    on('confirmCreateTeamChat', 'click', function() {
        const roomName = document.getElementById('teamChatName').value.trim();
        if (roomName) {
            createTeamChatRoom(roomName);
        } else {
            alert('채팅방 이름을 입력해주세요.');
        }
    });

    // 메시지 전송
    on('sendMessageBtn', 'click', sendMessage);

    // Enter 키로 메시지 전송 (Shift+Enter는 줄바꿈)
    on('messageInput', 'keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // 이미지 업로드 버튼
    on('imageUploadBtn', 'click', function() {
        document.getElementById('imageFileInput').click();
    });

    // 이미지 파일 선택
    const imageInput = document.getElementById('imageFileInput');
    if (imageInput) {
        imageInput.addEventListener('change', function() {
            if (this.files && this.files[0]) {
                uploadAndSendImage(this.files[0]);
                this.value = '';
            }
        });
    }

    // 모달 × 버튼 닫기
    document.querySelectorAll('.modal-close, .btn-secondary').forEach(function(btn) {
        btn.addEventListener('click', function() {
            const modal = this.closest('.modal');
            if (modal) hideModal(modal.id);
        });
    });

    // 모달 외부 클릭 시 닫기
    document.querySelectorAll('.modal').forEach(function(modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === this) hideModal(this.id);
        });
    });

    // 팀원 검색 (요소가 있을 때만)
    const memberSearchEl = document.getElementById('memberSearch');
    if (memberSearchEl) {
        memberSearchEl.addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            document.querySelectorAll('.member-item').forEach(function(item) {
                const name = item.querySelector('.member-name').textContent.toLowerCase();
                const id   = item.querySelector('.member-id').textContent.toLowerCase();
                item.style.display = (name.includes(searchTerm) || id.includes(searchTerm)) ? 'block' : 'none';
            });
        });
    }
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

	// 메시지 상태 초기화
	messageOffset = 0;
	hasMoreMessages = true;
	isLoadingMessages = false;

	// 메시지 로드
	loadMessages(roomId, true);

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
function loadMessages(roomId, firstLoad = false) {

    if (isLoadingMessages || !hasMoreMessages) return;

    isLoadingMessages = true;

    fetch(
        `ChatServlet?action=getMessages&roomId=${roomId}&limit=${messageLimit}&offset=${messageOffset}`
    )
        .then(response => response.json())
        .then(messages => {

            // 받은 개수가 limit보다 적으면 더 이상 불러올 메시지 없음
            if (messages.length < messageLimit) {
                hasMoreMessages = false;
            }

            // 서버는 DESC(최신순)로 내려주므로 화면 표시용으로 오래된 순 정렬
            messages.reverse();

            const chatMessages = document.getElementById('chatMessages');

            if (firstLoad) {
                // 첫 로드: 기존 내용 비우고 append, 맨 아래로 스크롤
                chatMessages.innerHTML = '';
                messages.forEach(msg => {
                    chatMessages.insertAdjacentHTML('beforeend', createMessageElement(msg));
                });
                requestAnimationFrame(() => {
                    chatMessages.scrollTop = chatMessages.scrollHeight;
                });
            } else {
                // 추가 로드: 현재 스크롤 높이 기억 → prepend → 스크롤 위치 보정
                const prevHeight = chatMessages.scrollHeight;
                const prevScrollTop = chatMessages.scrollTop;

                // 오래된 순으로 뒤집었으므로 역순으로 prepend해야 순서 유지
                for (let i = messages.length - 1; i >= 0; i--) {
                    chatMessages.insertAdjacentHTML('afterbegin', createMessageElement(messages[i]));
                }

                // 스크롤 위치 보정: 새로 추가된 높이만큼 아래로 밀기
                chatMessages.scrollTop = prevScrollTop + (chatMessages.scrollHeight - prevHeight);
            }

            // offset은 실제로 받은 개수만큼만 증가
            messageOffset += messages.length;

            isLoadingMessages = false;
        })
        .catch(error => {
            console.error('메시지 로드 실패:', error);
            isLoadingMessages = false;
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

    // 이미지 메시지 (type=image 또는 type=file이면서 URL이 이미지 확장자)
    const isImage = msg.messageType === 'image' ||
        (msg.messageType === 'file' && /\.(jpg|jpeg|png|gif|webp)$/i.test(msg.message));

    const contentHtml = isImage
        ? `<img src="${msg.message}" class="chat-img" onclick="openImageViewer('${msg.message}')" alt="이미지">`
        : `<div class="message-content">${escapeHtml(msg.message)}</div>`;

    return `
        <div class="message ${messageClass}">
            ${!isMine ? `<div class="message-sender">${escapeHtml(msg.senderName)}</div>` : ''}
            ${contentHtml}
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

        // 채팅방 이름 변경 알림 처리
        if (message.type === 'system' && message.renameRoom && message.newName) {
            document.getElementById('chatRoomName').textContent = message.newName;
            // rooms 배열도 업데이트
            const room = rooms.find(r => r.roomId === currentRoomId);
            if (room) room.roomName = message.newName;
        }

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
	// WebSocket 메시지는 'type' 필드, DB 메시지는 'messageType' 필드 → 통일
	if (!message.messageType && message.type) {
	    message.messageType = message.type;
	}
		
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

// 채팅방 나가기
function leaveRoom(roomId) {
    const params = new URLSearchParams();
    params.append('action', 'leaveRoom');
    params.append('roomId', roomId);

    fetch('ChatServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(response => response.text())
    .then(text => {
        const data = JSON.parse(text);
        if (data.success) {
            hideModal('leaveRoomModal');
            // WebSocket 연결 종료
            if (ws) { ws.close(); ws = null; }
            // 채팅 영역 초기화
            currentRoomId = null;
            currentRoomType = null;
            document.getElementById('chatActive').style.display = 'none';
            document.getElementById('chatEmpty').style.display = 'flex';
            // 채팅방 목록 갱신
            loadChatRooms();
        } else {
            alert('나가기 실패: ' + (data.message || '알 수 없는 오류'));
        }
    })
    .catch(error => {
        console.error('채팅방 나가기 실패:', error);
        alert('채팅방 나가기에 실패했습니다.');
    });
}

// 채팅방 이름 변경
function renameRoom(roomId, newName) {
    const params = new URLSearchParams();
    params.append('action', 'renameRoom');
    params.append('roomId', roomId);
    params.append('newName', newName);

    fetch('ChatServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(response => response.text())
    .then(text => {
        const data = JSON.parse(text);
        if (data.success) {
            hideModal('renameRoomModal');
            hideModal('chatInfoModal');
            // 헤더 이름 즉시 업데이트
            document.getElementById('chatRoomName').textContent = newName;
            // 채팅방 목록 갱신
            loadChatRooms();
        } else {
            alert('이름 변경 실패: ' + (data.message || '알 수 없는 오류'));
        }
    })
    .catch(error => {
        console.error('채팅방 이름 변경 실패:', error);
        alert('채팅방 이름 변경에 실패했습니다.');
    });
}

// 채팅방 정보 로드
function loadRoomInfo(roomId) {
    fetch(`ChatServlet?action=getRoomInfo&roomId=${roomId}`)
        .then(response => response.text())
        .then(text => {
            console.log('[getRoomInfo] 서버 응답:', text);
            if (!text || text.trim() === '') {
                alert('서버에서 빈 응답이 왔습니다.');
                return;
            }
            const data = JSON.parse(text);
            if (!data || !data.room) {
                alert('채팅방 정보를 불러올 수 없습니다: ' + text);
                return;
            }
            displayRoomInfo(data);
            // 초대 가능 멤버도 함께 로드
            loadInvitableMembers(roomId);
            showModal('chatInfoModal');
        })
        .catch(error => console.error('채팅방 정보 로드 실패:', error));
}

// 채팅방 정보 표시
function displayRoomInfo(data) {
    // 이름 입력창에 현재 이름 채우기
    document.getElementById('infoRoomNameInput').value = data.room.roomName;

    // 유형
    document.getElementById('infoRoomType').textContent =
        data.room.roomType === 'team' ? '👥 팀 채팅' : '💬 개인 채팅';

    // 참여자 수
    document.getElementById('infoMemberCount').textContent = data.members.length + '명';

    // 참여자 목록
    const list = document.getElementById('infoMemberList');
    list.innerHTML = data.members.map(m => {
        const isMe = m.memberId === userId;
        return `
            <div class="info-member-item ${isMe ? 'info-member-me' : ''}">
                <div class="info-member-avatar">${m.name.charAt(0)}</div>
                <div class="info-member-name">${escapeHtml(m.name)}</div>
                ${isMe ? '<span class="info-member-badge">나</span>' : ''}
            </div>
        `;
    }).join('');
}

// 초대 가능한 멤버 로드
function loadInvitableMembers(roomId) {
    const container = document.getElementById('infoInvitableList');
    container.innerHTML = '<div class="loading">불러오는 중...</div>';

    fetch(`ChatServlet?action=getInvitableMembers&roomId=${roomId}&projectId=${projectId}`)
        .then(r => r.json())
        .then(members => {
            if (members.length === 0) {
                container.innerHTML = '<div class="loading">초대할 수 있는 멤버가 없습니다.</div>';
                return;
            }
            container.innerHTML = members.map(m => `
                <div class="info-invitable-item">
                    <div class="info-member-avatar" style="background:#64748b;">${m.name.charAt(0)}</div>
                    <div class="info-member-name">${escapeHtml(m.name)}</div>
                    <button class="btn-invite" onclick="inviteMember(${roomId}, '${escapeHtml(m.memberId)}', '${escapeHtml(m.name)}', this)">
                        초대
                    </button>
                </div>
            `).join('');
        })
        .catch(() => {
            container.innerHTML = '<div class="loading">불러오기 실패</div>';
        });
}

// 멤버 초대
function inviteMember(roomId, targetMemberId, targetName, btn) {
    btn.disabled = true;
    btn.textContent = '초대 중...';

    const params = new URLSearchParams();
    params.append('action', 'addMember');
    params.append('roomId', roomId);
    params.append('targetMemberId', targetMemberId);
    params.append('targetName', targetName);

    fetch('ChatServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            // 해당 행을 "초대됨" 상태로 변경
            const item = btn.closest('.info-invitable-item');
            btn.textContent = '초대됨';
            btn.classList.add('btn-invite-done');
            // 참여자 수 갱신을 위해 정보 다시 로드
            loadRoomInfo(roomId);
        } else {
            btn.disabled = false;
            btn.textContent = '초대';
            alert('초대 실패: ' + (data.message || '알 수 없는 오류'));
        }
    })
    .catch(() => {
        btn.disabled = false;
        btn.textContent = '초대';
        alert('초대 중 오류가 발생했습니다.');
    });
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
    requestAnimationFrame(() => {
        chatMessages.scrollTop = chatMessages.scrollHeight;
    });
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

// 이미지 업로드 후 WebSocket으로 전송
function uploadAndSendImage(file) {
    if (!currentRoomId || !ws || ws.readyState !== WebSocket.OPEN) {
        alert('채팅방을 먼저 선택해주세요.');
        return;
    }

    const formData = new FormData();
    formData.append('action', 'uploadImage');
    formData.append('image', file);

    // 업로드 중 표시
    const chatMessages = document.getElementById('chatMessages');
    const loadingId = 'img-loading-' + Date.now();
    chatMessages.insertAdjacentHTML('beforeend',
        `<div id="${loadingId}" class="message mine"><div class="message-content" style="color:#999;font-size:12px;">이미지 업로드 중...</div></div>`
    );
    scrollToBottom();

    fetch('ChatServlet', { method: 'POST', body: formData })
        .then(r => r.json())
        .then(data => {
            const el = document.getElementById(loadingId);
            if (el) el.remove();

            if (data.success) {
                const messageData = {
                    type: 'image',
                    message: data.imageUrl,
                    senderName: userName
                };
                ws.send(JSON.stringify(messageData));
            } else {
                alert('이미지 업로드 실패: ' + (data.message || '알 수 없는 오류'));
            }
        })
        .catch(e => {
            const el = document.getElementById(loadingId);
            if (el) el.remove();
            alert('이미지 업로드 중 오류가 발생했습니다.');
        });
}

// 이미지 뷰어
function openImageViewer(src) {
    let viewer = document.getElementById('chatImageViewer');
    if (!viewer) {
        viewer = document.createElement('div');
        viewer.id = 'chatImageViewer';
        viewer.style.cssText = 'display:none;position:fixed;inset:0;background:rgba(0,0,0,.85);z-index:9999;align-items:center;justify-content:center;cursor:zoom-out;';
        viewer.innerHTML = '<img style="max-width:90vw;max-height:90vh;border-radius:8px;box-shadow:0 8px 32px rgba(0,0,0,.5);">';
        viewer.addEventListener('click', function() { this.style.display = 'none'; });
        document.body.appendChild(viewer);
    }
    viewer.querySelector('img').src = src;
    viewer.style.display = 'flex';
}
