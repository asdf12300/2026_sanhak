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
                    <textarea id="content" name="content" required 
                              placeholder="회의 내용을 자유롭게 작성하세요..."></textarea>
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
