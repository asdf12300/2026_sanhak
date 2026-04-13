<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.*, model.*" %>
<%!
    // XSS 방어를 위한 HTML 이스케이프 함수
    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;");
    }
    
    // 줄바꿈을 <br> 태그로 변환하면서 HTML 이스케이프
    private String escapeHtmlWithBreaks(String text) {
        if (text == null) return "";
        // 먼저 HTML 이스케이프
        String escaped = escapeHtml(text);
        // 그 다음 줄바꿈을 <br>로 변환
        return escaped.replace("\r\n", "<br>").replace("\n", "<br>").replace("\r", "<br>");
    }
%>
<%
    LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    MeetingMinutesDTO minutes = (MeetingMinutesDTO) request.getAttribute("minutes");
    List<MeetingMinutesDTO> history = (List<MeetingMinutesDTO>) request.getAttribute("history");
    String projectId = (String) request.getAttribute("projectId");
    
    if (minutes == null || projectId == null) {
        response.sendRedirect("projects.jsp");
        return;
    }
    
    boolean isEditing = "true".equals(request.getParameter("edit"));
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= minutes.getTitle() %> - 회의록</title>
    <style>
        :root {
            --blue: #2563eb;
            --blue-dark: #1d4ed8;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            min-height: 100vh;
            margin: 0;
            padding: 0;
            background: white;
        }
        
        .container {
            max-width: 100%;
            width: 100%;
            background: white;
            overflow: visible;
            border-radius: 20px;
        }
        
        .header {
            background: linear-gradient(135deg, var(--blue) 0%, #60a5fa 100%);
            color: white;
            padding: 32px 40px;
            border-radius: 20px 20px 0 0;
        }
        
        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }
        
        .back-btn {
            background: rgba(255,255,255,0.2);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .header-actions {
            display: flex;
            gap: 8px;
        }
        
        .btn-icon {
            background: rgba(255,255,255,0.2);
            color: white;
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .btn-icon:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .btn-icon.delete:hover {
            background: rgba(239, 68, 68, 0.9);
        }
        
        .header h1 {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        
        .header-meta {
            display: flex;
            gap: 24px;
            font-size: 14px;
            opacity: 0.9;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .content-area {
            padding: 40px;
            background: white;
            border-radius: 0 0 20px 20px;
        }
        
        .view-mode {
            line-height: 1.8;
            color: #334155;
            white-space: pre-line;
            word-wrap: break-word;
            background: #f8fafc;
            padding: 24px;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            min-height: 200px;
            font-size: 15px;
        }
        
        .edit-mode {
            display: none;
        }
        
        .edit-mode.active {
            display: block;
        }
        
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: inherit;
        }
        
        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-group textarea {
            min-height: 300px;
            resize: vertical;
        }
        
        .button-group {
            display: flex;
            gap: 12px;
            margin-top: 32px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--blue) 0%, #60a5fa 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #f5f5f5;
            color: #666;
        }
        
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        
        .history-section {
            margin-top: 48px;
            padding-top: 32px;
            border-top: 2px solid #f0f0f0;
        }
        
        .history-title {
            font-size: 18px;
            font-weight: 700;
            color: #333;
            margin-bottom: 16px;
        }
        
        .history-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .history-item {
            background: #f8f9fa;
            padding: 16px;
            border-radius: 8px;
            font-size: 14px;
            color: #666;
        }
        
        .history-item strong {
            color: #333;
        }
        
        .empty-history {
            text-align: center;
            padding: 32px;
            color: #999;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-top">
                <button class="back-btn" onclick="goBack()">
                    ← 목록으로
                </button>
                <div class="header-actions">
                    <button class="btn-icon" onclick="toggleEdit()" id="editBtn" title="수정">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
                            <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
                        </svg>
                    </button>
                    <button class="btn-icon delete" onclick="confirmDelete()" title="삭제">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="3 6 5 6 21 6"/>
                            <path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/>
                        </svg>
                    </button>
                </div>
            </div>
            
            <h1 id="viewTitle"><%= minutes.getTitle() %></h1>
            
            <div class="header-meta">
                <div class="meta-item">
                    📅 <span id="viewDate"><%= minutes.getMeetingDate() %></span>
                </div>
                <div class="meta-item">
                    ✍️ <%= minutes.getCreatedByName() != null ? minutes.getCreatedByName() : minutes.getCreatedBy() %>
                </div>
                <% if (minutes.getLastModifiedBy() != null) { %>
                <div class="meta-item">
                    🕐 수정: <%= String.format("%tY-%<tm-%<td %<tH:%<tM", minutes.getLastModifiedAt()) %>
                </div>
                <% } %>
            </div>
        </div>
        
        <div class="content-area">
            <div class="view-mode" id="viewMode"><%= escapeHtml(minutes.getContent()) %></div>
            
            <div class="edit-mode" id="editMode">
                <form method="post" action="updateMeetingMinutes" id="editForm">
                    <input type="hidden" name="id" value="<%= minutes.getId() %>">
                    <input type="hidden" name="projectId" value="<%= projectId %>">
                    
                    <div class="form-group">
                        <label for="title">회의 제목</label>
                        <input type="text" id="title" name="title" value="<%= minutes.getTitle() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="meetingDate">회의 날짜</label>
                        <input type="date" id="meetingDate" name="meetingDate" value="<%= minutes.getMeetingDate() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="content">회의 내용</label>
                        <textarea id="content" name="content" required><%= minutes.getContent() %></textarea>
                    </div>
                    
                    <div class="button-group">
                        <button type="button" class="btn btn-secondary" onclick="toggleEdit()">
                            취소
                        </button>
                        <button type="submit" class="btn btn-primary">
                            저장
                        </button>
                    </div>
                </form>
            </div>
            
            <% if (history != null && !history.isEmpty()) { %>
            <div class="history-section">
                <div class="history-title">📜 수정 이력</div>
                <div class="history-list">
                    <% for (MeetingMinutesDTO h : history) { %>
                    <div class="history-item">
                        <strong><%= h.getModifiedByName() != null ? h.getModifiedByName() : h.getModifiedBy() %></strong>님이 
                        <%= String.format("%tY년 %<tm월 %<td일 %<tH:%<tM", h.getModifiedAt()) %>에 수정
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </div>
    
    <form id="deleteForm" method="post" action="deleteMeetingMinutes" style="display:none;">
        <input type="hidden" name="id" value="<%= minutes.getId() %>">
        <input type="hidden" name="projectId" value="<%= projectId %>">
    </form>
    
    <script>
        function toggleEdit() {
            const viewMode = document.getElementById('viewMode');
            const editMode = document.getElementById('editMode');
            
            if (editMode.classList.contains('active')) {
                editMode.classList.remove('active');
                viewMode.style.display = 'block';
            } else {
                editMode.classList.add('active');
                viewMode.style.display = 'none';
            }
        }
        
        function confirmDelete() {
            if (confirm('정말 이 회의록을 삭제하시겠습니까?')) {
                document.getElementById('deleteForm').submit();
            }
        }
        
        function goBack() {
            if (window.parent !== window) {
                // iframe 안에 있으면 부모에게 메시지 전송
                window.parent.postMessage('closeModal', '*');
            } else {
                // 일반 페이지면 목록으로 이동
                location.href = 'meetingMinutes?projectId=<%= projectId %>';
            }
        }
    </script>
</body>
</html>
