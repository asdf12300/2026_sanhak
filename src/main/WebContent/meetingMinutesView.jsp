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
    boolean isProfessor = loginUser != null && "professor".equals(loginUser.getRole());
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
        
        /* 텍스트 에디터 스타일 */
        .editor-toolbar {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            padding: 12px;
            background: #f8f9fa;
            border: 2px solid #e0e0e0;
            border-bottom: none;
            border-radius: 8px 8px 0 0;
            align-items: center;
        }
        
        .editor-toolbar button {
            padding: 8px 12px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 36px;
            height: 36px;
        }
        
        .editor-toolbar button:hover {
            background: #e9ecef;
            border-color: #667eea;
        }
        
        .editor-toolbar button.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .editor-toolbar select {
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background: white;
            cursor: pointer;
            font-size: 13px;
            height: 36px;
        }
        
        .toolbar-divider {
            width: 1px;
            height: 24px;
            background: #ddd;
            margin: 0 4px;
        }
        
        /* 색상 선택 버튼 */
        .color-picker-wrapper {
            position: relative;
            display: inline-block;
        }
        
        .color-btn {
            padding: 6px 10px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 6px;
            height: 36px;
        }
        
        .color-btn:hover {
            background: #e9ecef;
            border-color: #667eea;
        }
        
        .color-icon {
            width: 20px;
            height: 20px;
            border: 1px solid #ddd;
            border-radius: 3px;
            display: inline-block;
        }
        
        .color-palette {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            margin-top: 4px;
            background: white;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 1000;
            width: 280px;
        }
        
        .color-palette.show {
            display: block;
        }
        
        .color-grid {
            display: grid;
            grid-template-columns: repeat(10, 1fr);
            gap: 4px;
            margin-bottom: 8px;
        }
        
        .color-item {
            width: 24px;
            height: 24px;
            border: 1px solid #ddd;
            border-radius: 3px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .color-item:hover {
            transform: scale(1.2);
            border-color: #667eea;
        }
        
        .color-item.no-color {
            background: linear-gradient(to top right, transparent 0%, transparent calc(50% - 1px), #ff0000 50%, transparent calc(50% + 1px), transparent 100%);
        }
        
        .color-more {
            display: flex;
            align-items: center;
            gap: 8px;
            padding-top: 8px;
            border-top: 1px solid #e0e0e0;
        }
        
        .color-more label {
            font-size: 12px;
            color: #666;
        }
        
        .color-more input[type="color"] {
            width: 40px;
            height: 28px;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .editor-content {
            min-height: 300px;
            padding: 16px;
            border: 2px solid #e0e0e0;
            border-radius: 0 0 8px 8px;
            background: white;
            font-size: 15px;
            line-height: 1.6;
            overflow-y: auto;
            max-height: 500px;
        }
        
        .editor-content:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .editor-content:empty:before {
            content: attr(data-placeholder);
            color: #999;
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
                    <% if (!isProfessor) { %>
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
                    <% } %>
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
            <div class="view-mode" id="viewMode"><%= minutes.getContent() %></div>
            
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
                        
                        <!-- 텍스트 에디터 툴바 -->
                        <div class="editor-toolbar">
                            <!-- 글씨 크기 (11~40) -->
                            <select id="fontSize" onchange="changeFontSize(this.value)">
                                <option value="15" selected>15</option>
                                <option value="11">11</option>
                                <option value="13">13</option>
                                <option value="16">16</option>
                                <option value="19">19</option>
                                <option value="24">24</option>
                                <option value="28">28</option>
                                <option value="30">30</option>
                                <option value="34">34</option>
                                <option value="38">38</option>
                            </select>
                            
                            <div class="toolbar-divider"></div>
                            
                            <!-- 굵게 -->
                            <button type="button" onclick="formatDoc('bold')" title="굵게 (Ctrl+B)">
                                <strong style="font-size: 16px;">B</strong>
                            </button>
                            
                            <!-- 기울임 -->
                            <button type="button" onclick="formatDoc('italic')" title="기울임 (Ctrl+I)">
                                <em style="font-size: 16px; font-style: italic;">I</em>
                            </button>
                            
                            <!-- 밑줄 -->
                            <button type="button" onclick="formatDoc('underline')" title="밑줄 (Ctrl+U)">
                                <span style="text-decoration: underline; font-size: 16px;">U</span>
                            </button>
                            
                            <!-- 취소선 -->
                            <button type="button" onclick="formatDoc('strikeThrough')" title="취소선">
                                <span style="text-decoration: line-through; font-size: 16px;">S</span>
                            </button>
                            
                            <div class="toolbar-divider"></div>
                            
                            <!-- 왼쪽 정렬 -->
                            <button type="button" onclick="formatDoc('justifyLeft')" title="왼쪽 정렬">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <line x1="3" y1="6" x2="21" y2="6"/>
                                    <line x1="3" y1="12" x2="15" y2="12"/>
                                    <line x1="3" y1="18" x2="18" y2="18"/>
                                </svg>
                            </button>
                            
                            <!-- 가운데 정렬 -->
                            <button type="button" onclick="formatDoc('justifyCenter')" title="가운데 정렬">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <line x1="3" y1="6" x2="21" y2="6"/>
                                    <line x1="6" y1="12" x2="18" y2="12"/>
                                    <line x1="4" y1="18" x2="20" y2="18"/>
                                </svg>
                            </button>
                            
                            <!-- 오른쪽 정렬 -->
                            <button type="button" onclick="formatDoc('justifyRight')" title="오른쪽 정렬">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <line x1="3" y1="6" x2="21" y2="6"/>
                                    <line x1="9" y1="12" x2="21" y2="12"/>
                                    <line x1="6" y1="18" x2="21" y2="18"/>
                                </svg>
                            </button>
                            
                            <div class="toolbar-divider"></div>
                            
                            <!-- 글자 색 -->
                            <div class="color-picker-wrapper">
                                <button type="button" class="color-btn" onclick="toggleColorPalette('textColor')" title="글자 색">
                                    <span style="font-size: 16px; font-weight: bold;">A</span>
                                    <span class="color-icon" id="textColorIcon" style="background: #000000; border-bottom: 3px solid #000000;"></span>
                                </button>
                                <div class="color-palette" id="textColorPalette">
                                    <div class="color-grid" id="textColorGrid"></div>
                                    <div class="color-more">
                                        <label>더보기</label>
                                        <input type="color" id="textColorPicker" value="#000000" onchange="applyCustomColor('text', this.value)">
                                    </div>
                                </div>
                            </div>
                            
                            <!-- 배경 색 -->
                            <div class="color-picker-wrapper">
                                <button type="button" class="color-btn" onclick="toggleColorPalette('bgColor')" title="배경 색">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/>
                                    </svg>
                                    <span class="color-icon" id="bgColorIcon" style="background: #ffff00;"></span>
                                </button>
                                <div class="color-palette" id="bgColorPalette">
                                    <div class="color-grid" id="bgColorGrid"></div>
                                    <div class="color-more">
                                        <label>더보기</label>
                                        <input type="color" id="bgColorPicker" value="#ffff00" onchange="applyCustomColor('bg', this.value)">
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 에디터 영역 -->
                        <div id="editor" class="editor-content" contenteditable="true" 
                             data-placeholder="회의 내용을 자유롭게 작성하세요..."><%= minutes.getContent() %></div>
                        
                        <!-- 숨겨진 textarea (폼 제출용) -->
                        <textarea id="content" name="content" required style="display: none;"><%= minutes.getContent() %></textarea>
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
        document.getElementById('editForm').addEventListener('submit', function(e) {
            const editorContent = editor.innerHTML.trim();
            
            if (!editorContent || editorContent === '') {
                e.preventDefault();
                alert('회의 내용을 입력해주세요.');
                editor.focus();
                return false;
            }
            
            contentField.value = editorContent;
        });
        
        // 키보드 단축키 지원
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
        
        function toggleEdit() {
            const viewMode = document.getElementById('viewMode');
            const editMode = document.getElementById('editMode');
            
            if (editMode.classList.contains('active')) {
                editMode.classList.remove('active');
                viewMode.style.display = 'block';
            } else {
                editMode.classList.add('active');
                viewMode.style.display = 'none';
                // 에디터 모드로 전환 시 색상 팔레트 초기화
                if (!document.getElementById('textColorGrid').hasChildNodes()) {
                    initColorPalette();
                }
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
