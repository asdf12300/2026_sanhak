<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.LoginDTO" %>
<%
    LoginDTO user = (LoginDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 교수는 채팅 접근 불가
    if ("professor".equals(user.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }

    String projectIdParam = request.getParameter("projectId");
    if (projectIdParam == null) {
        response.sendRedirect("list.jsp");
        return;
    }
    int projectId = Integer.parseInt(projectIdParam);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>실시간 채팅</title>
    <link rel="stylesheet" href="resource/css/index.css">
    <link rel="stylesheet" href="resource/css/chat.css">
</head>
<body>
<jsp:include page="sidebar.jsp"/>
    <div class="chat-container">
        <!-- 채팅방 목록 사이드바 -->
        <div class="chat-sidebar">
            <div class="sidebar-header">
                <h2>채팅</h2>
                <div class="header-buttons">
                    <button id="createTeamChatBtn" class="btn-icon" title="팀 채팅방 만들기">
                        <span>👥</span>
                    </button>
                    <button id="createPersonalChatBtn" class="btn-icon" title="개인 채팅 시작">
                        <span>💬</span>
                    </button>
                </div>
            </div>
            
            <div class="room-list" id="roomList">
                <div class="loading">채팅방을 불러오는 중...</div>
            </div>
        </div>

        <!-- 메인: 채팅 영역 -->
        <div class="chat-main">
            <div class="chat-empty" id="chatEmpty">
                <div class="empty-icon">💬</div>
                <p>채팅방을 선택하거나 새로 만들어보세요</p>
            </div>

            <div class="chat-active" id="chatActive" style="display: none;">
                <div class="chat-header">
                    <div class="chat-info">
                        <h3 id="chatRoomName">채팅방</h3>
                        <span id="chatRoomType" class="room-type-badge"></span>
                    </div>
                    <div class="header-actions">
                        <button id="chatInfoBtn" class="btn-icon" title="채팅방 정보">
                            <span>≡</span>
                        </button>
                    </div>
                </div>

                <div class="chat-messages" id="chatMessages">
                    <!-- 메시지가 여기에 표시됩니다 -->
                </div>

                <div class="chat-input-container">
                    <input type="file" id="imageFileInput" accept="image/*" style="display:none;">
                    <button id="imageUploadBtn" class="btn-img-upload" title="이미지 전송">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="3" width="18" height="18" rx="2"/>
                            <circle cx="8.5" cy="8.5" r="1.5"/>
                            <polyline points="21 15 16 10 5 21"/>
                        </svg>
                    </button>
                    <textarea id="messageInput" placeholder="메시지를 입력하세요..." rows="1"></textarea>
                    <button id="sendMessageBtn" class="btn-send">전송</button>
                </div>
            </div>
        </div>
    </div><!-- /.chat-container -->

    <!-- 팀 채팅방 생성 모달 -->
    <div id="createTeamChatModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>팀 채팅방 만들기</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <label for="teamChatName">채팅방 이름</label>
                <input type="text" id="teamChatName" placeholder="예: 프로젝트 전체 회의" />
            </div>
            <div class="modal-footer">
                <button id="confirmCreateTeamChat" class="btn-primary">만들기</button>
                <button class="btn-secondary">취소</button>
            </div>
        </div>
    </div>

    <!-- 개인 채팅 시작 모달 -->
    <div id="createPersonalChatModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>개인 채팅 시작</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                
                <div id="memberList" class="member-list">
                    <!-- 팀원 목록이 여기에 표시됩니다 -->
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary">취소</button>
            </div>
        </div>
    </div>

    <!-- 채팅방 정보 모달 -->
    <div id="chatInfoModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>채팅방 정보</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <!-- 채팅방 이름 변경 섹션 -->
                <div class="info-section">
                    <div class="info-section-title">채팅방 이름</div>
                    <div class="info-rename-row">
                        <input type="text" id="infoRoomNameInput" placeholder="채팅방 이름" />
                        <button id="infoConfirmRename" class="btn-primary btn-sm">변경</button>
                    </div>
                </div>

                <!-- 채팅방 유형 -->
                <div class="info-section">
                    <div class="info-section-title">유형</div>
                    <div id="infoRoomType" class="info-value"></div>
                </div>

                <!-- 참여자 목록 -->
                <div class="info-section">
                    <div class="info-section-title">참여자 <span id="infoMemberCount" class="info-count"></span></div>
                    <div id="infoMemberList" class="info-member-list"></div>
                </div>
            </div>
            <div class="modal-footer info-footer">
                <button id="infoLeaveRoom" class="btn-danger"> 채팅방 나가기</button>
                <button class="btn-secondary">닫기</button>
            </div>
        </div>
    </div>

    <!-- 채팅방 이름 변경 모달 -->
    <div id="renameRoomModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>채팅방 이름 변경</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <label for="newRoomName">새 채팅방 이름</label>
                <input type="text" id="newRoomName" placeholder="새 이름을 입력하세요" />
            </div>
            <div class="modal-footer">
                <button id="confirmRenameRoom" class="btn-primary">변경</button>
                <button class="btn-secondary">취소</button>
            </div>
        </div>
    </div>

    <!-- 채팅방 나가기 확인 모달 -->
    <div id="leaveRoomModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>채팅방 나가기</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <p>채팅방을 나가면 대화 내용을 볼 수 없게 됩니다.<br>정말 나가시겠습니까?</p>
            </div>
            <div class="modal-footer">
                <button id="confirmLeaveRoom" class="btn-danger">나가기</button>
                <button class="btn-secondary">취소</button>
            </div>
        </div>
    </div>

    <script>
        const projectId = <%= projectId %>;
        const userId = '<%= user.getId() %>';
        const userName = '<%= user.getName() %>';
        const userRole = '<%= user.getRole() %>';
    </script>
    <script src="resource/js/chat.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
