<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%String projectIdParam = request.getParameter("projectId"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>캘린더</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/css/calendar.css?v=2.0">
<script>
  const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="resource/js/calendar.js?v=3" defer></script>
</head>
<body>
<jsp:include page="sidebar.jsp"/>

<div class="cal-wrap">
  <div class="cal-layout">

    <!-- 왼쪽: 캘린더 -->
    <div class="cal-main">
      <div class="cal-header">
        <button class="nav-btn" id="prevBtn">&#8249;</button>
        <span class="cal-title" id="calTitle"></span>
        <button class="nav-btn" id="nextBtn">&#8250;</button>
        <select id="monthSel"></select>
        <select id="yearSel"></select>
        <button class="nav-btn" id="todayBtn" style="font-size:12px;">오늘</button>
      </div>
      <div class="cal-grid" id="calGrid"></div>
    </div>

    <!-- 오른쪽: 이달의 일정 -->
    <div class="cal-sidebar">
      <div class="cal-sidebar-title" id="sidebarTitle">이달의 일정</div>
      <div class="month-event-list" id="monthEventList">
        <div class="month-event-empty">일정이 없습니다.</div>
      </div>
    </div>

  </div>
</div>

<input type="hidden" id="evtProjectId" value="<%= projectIdParam != null ? projectIdParam : "" %>">

<!-- 일정 등록/수정 모달 -->
<div class="modal-bg" id="modalBg">
  <div class="modal">
    <h2 id="modalTitle">일정 등록</h2>

    <label>제목</label>
    <input type="text" id="evtTitle" />

    <label>날짜</label>
    <input type="date" id="evtDate" />

    <label>시간</label>
    <input type="time" id="evtTime" />

    <label>분류</label>
    <select id="evtCat">
      <option value="0">일반</option>
      <option value="1">중요</option>
      <option value="2">개인</option>
      <option value="3">업무</option>
    </select>

    <div id="assigneeWrap">
      <label>담당자</label>
      <select id="evtAssignee" disabled style="background:#f3f4f6;color:#9ca3af;cursor:not-allowed;">
        <option value="">-- 담당자 선택 --</option>
      </select>
    </div>

    <label>메모</label>
    <textarea id="evtMemo"></textarea>

    <div class="modal-actions">
      <button class="btn-del" id="delBtn" style="display:none;">삭제</button>
      <button class="btn-cancel" id="cancelBtn">취소</button>
      <button class="btn-save" id="saveBtn">저장</button>
    </div>
  </div>
</div>

<!-- +N 더보기 팝업 -->
<div class="more-popup-bg" id="morePopupBg">
  <div class="more-popup">
    <div class="more-popup-header">
      <span id="morePopupDate"></span>
      <button id="morePopupClose">✕</button>
    </div>
    <div id="morePopupList"></div>
  </div>
</div>

</body>
</html>
