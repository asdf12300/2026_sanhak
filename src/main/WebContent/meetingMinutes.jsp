<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.*, model.*" %>
<%
    ProjectDTO project = (ProjectDTO) request.getAttribute("project");
    List<MeetingMinutesDTO> minutesList = (List<MeetingMinutesDTO>) request.getAttribute("minutesList");
    
    if (project == null) {
        response.sendRedirect("projects.jsp");
        return;
    }
    
    int projectId = project.getId();
    session.setAttribute("currentProjectId", projectId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>회의록 — ProjectOS</title>
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="resource/css/sidebar.css">
<link rel="stylesheet" href="resource/css/meetingMinutes.css">
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
    <div class="minutes-header">
        <h1 class="minutes-title">📝 회의록</h1>
        <button class="btn-create" onclick="openCreateModal()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <line x1="12" y1="5" x2="12" y2="19"/>
                <line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            새 회의록 작성
        </button>
    </div>
    
    <div class="content-container">
        <% if (minutesList != null && !minutesList.isEmpty()) { %>
        <div class="minutes-grid">
            <% 
            request.setAttribute("minutesList", minutesList);
            for (MeetingMinutesDTO minutes : minutesList) { 
                request.setAttribute("currentMinutes", minutes);
            %>
            <div class="minutes-card" onclick="openViewModal(<%= minutes.getId() %>, <%= projectId %>)">
                <div class="minutes-card-header">
                    <div class="minutes-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                            <polyline points="14 2 14 8 20 8"/>
                        </svg>
                    </div>
                    <div class="minutes-card-info">
                        <div class="minutes-card-title"><c:out value="${currentMinutes.title}" /></div>
                        <div class="minutes-card-date">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2"/>
                                <line x1="16" y1="2" x2="16" y2="6"/>
                                <line x1="8" y1="2" x2="8" y2="6"/>
                                <line x1="3" y1="10" x2="21" y2="10"/>
                            </svg>
                            <c:out value="${currentMinutes.meetingDate}" />
                        </div>
                    </div>
                </div>
                
                <div class="minutes-card-meta">
                    <div class="meta-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                        <c:out value="${currentMinutes.createdByName != null ? currentMinutes.createdByName : currentMinutes.createdBy}" />
                    </div>
                    <% if (minutes.getLastModifiedBy() != null) { %>
                    <div class="meta-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="10"/>
                            <polyline points="12 6 12 12 16 14"/>
                        </svg>
                        <%= String.format("%tm/%<td %<tH:%<tM", minutes.getLastModifiedAt()) %>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="empty-state">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
            </svg>
            <h3>작성된 회의록이 없습니다</h3>
            <p>첫 회의록을 작성해보세요</p>
        </div>
        <% } %>
    </div>
</div>

<!-- 회의록 작성 모달 -->
<div class="modal-overlay" id="createModal" onclick="closeModalOnOverlay(event)">
    <div class="modal-container">
        <div class="modal-header">
            <h2>📝 회의록 작성</h2>
            <p>프로젝트 회의 내용을 기록하세요</p>
        </div>
        
        <div class="modal-body">
            <form method="post" action="createMeetingMinutes" id="createForm">
                <input type="hidden" name="projectId" value="<%= projectId %>">
                
                <div class="form-group">
                    <label for="title">회의 제목</label>
                    <input type="text" id="title" name="title" required 
                           placeholder="예: 2024년 1분기 기획 회의">
                </div>
                
                <div class="form-group">
                    <label for="meetingDate">회의 날짜</label>
                    <input type="date" id="meetingDate" name="meetingDate" required>
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
                         data-placeholder="회의 내용을 자유롭게 작성하세요..."></div>
                    
                    <!-- 숨겨진 textarea (폼 제출용) - required 제거 -->
                    <textarea id="content" name="content" style="display: none;"></textarea>
                </div>
                
                <div class="modal-buttons">
                    <button type="button" class="modal-btn modal-btn-secondary" onclick="closeCreateModal()">
                        취소
                    </button>
                    <button type="submit" class="modal-btn modal-btn-primary">
                        작성 완료
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 회의록 상세보기 모달 -->
<div class="modal-overlay" id="viewModal" onclick="closeModalOnOverlay(event, 'viewModal')">
    <div class="modal-container" style="max-width: 1000px; background: transparent;">
        <iframe id="viewFrame" style="width: 100%; height: 80vh; border: none; background: transparent; border-radius: 20px; box-shadow: 0 25px 80px rgba(0,0,0,0.4);"></iframe>
    </div>
</div>

<script src="resource/js/meetingMinutes.js"></script>

</body>
</html>
