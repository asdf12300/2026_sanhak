<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, java.util.List" %>
<%
    LoginDTO loginUser = (LoginDTO) request.getAttribute("loginUser");
    if (loginUser == null) loginUser = (LoginDTO) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect("login.jsp"); return; }

    int projectId     = (Integer) request.getAttribute("projectId");
    boolean isProfessor = (Boolean) request.getAttribute("isProfessor");
    List<FileShareDTO> fileList = (List<FileShareDTO>) request.getAttribute("fileList");
    String userId = loginUser.getId();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>파일 공유 — ProjectOS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
.fs-wrap { max-width: 860px; margin: 32px auto; padding: 0 20px; }
.fs-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.fs-title { font-size: 22px; font-weight: 800; color: var(--text); font-family: 'Plus Jakarta Sans', sans-serif; }
.fs-upload-btn {
    display: flex; align-items: center; gap: 6px;
    background: var(--blue); color: #fff; border: none;
    border-radius: 10px; padding: 9px 18px; font-size: 13px;
    font-weight: 600; cursor: pointer; font-family: inherit;
}
.fs-upload-btn:hover { background: #1d4ed8; }
.fs-table-wrap {
    background: #fff; border-radius: 14px;
    border: 1px solid var(--border); overflow: hidden;
}
.fs-table { width: 100%; border-collapse: collapse; }
.fs-table th {
    background: var(--surface2); padding: 11px 16px;
    font-size: 12px; font-weight: 600; color: var(--muted);
    text-align: left; border-bottom: 1px solid var(--border);
}
.fs-table td {
    padding: 13px 16px; font-size: 13px; color: var(--text2);
    border-bottom: 1px solid var(--border); vertical-align: middle;
}
.fs-table tr:last-child td { border-bottom: none; }
.fs-table tr:hover td { background: var(--surface2); }
.fs-file-name {
    display: flex; align-items: center; gap: 10px;
    font-weight: 500; color: var(--text);
}
.fs-file-icon {
    width: 32px; height: 32px; border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    font-size: 16px; flex-shrink: 0;
}
.fs-download-btn {
    display: inline-flex; align-items: center; gap: 4px;
    background: var(--blue-light); color: var(--blue);
    border: 1px solid var(--blue); border-radius: 7px;
    padding: 5px 12px; font-size: 12px; font-weight: 600;
    text-decoration: none; cursor: pointer;
}
.fs-download-btn:hover { background: var(--blue); color: #fff; }
.fs-delete-btn {
    background: var(--red-light); color: var(--red);
    border: 1px solid var(--red); border-radius: 7px;
    padding: 5px 12px; font-size: 12px; font-weight: 600;
    cursor: pointer; margin-left: 6px;
}
.fs-delete-btn:hover { background: var(--red); color: #fff; }
.fs-empty {
    text-align: center; padding: 60px 20px;
    color: var(--muted2); font-size: 14px;
}
.fs-empty svg { width: 48px; height: 48px; margin-bottom: 12px; opacity: .35; }

/* 업로드 모달 */
.modal-bg {
    display: none; position: fixed; inset: 0;
    background: rgba(15,23,42,.45); z-index: 999;
    align-items: center; justify-content: center;
}
.modal-bg.open { display: flex; }
.modal-box {
    background: #fff; border-radius: 16px; padding: 28px;
    width: 420px; box-shadow: 0 16px 48px rgba(0,0,0,.18);
}
.modal-box h3 { font-size: 16px; font-weight: 700; margin-bottom: 16px; color: var(--text); }
.drop-zone {
    border: 2px dashed var(--border); border-radius: 12px;
    padding: 36px 20px; text-align: center; cursor: pointer;
    transition: border-color .2s, background .2s;
}
.drop-zone.drag-over { border-color: var(--blue); background: var(--blue-light); }
.drop-zone input[type=file] { display: none; }
.drop-zone-icon { font-size: 36px; margin-bottom: 8px; }
.drop-zone-text { font-size: 13px; color: var(--muted); }
.drop-zone-text b { color: var(--blue); }
.selected-file {
    margin-top: 12px; padding: 10px 14px;
    background: var(--surface2); border-radius: 8px;
    font-size: 13px; color: var(--text2); display: none;
}
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 20px; }
.btn-modal-ok {
    background: var(--blue); color: #fff; border: none;
    border-radius: 8px; padding: 9px 20px; font-size: 13px;
    font-weight: 600; cursor: pointer; font-family: inherit;
}
.btn-modal-cancel {
    background: var(--surface2); color: var(--muted);
    border: 1px solid var(--border); border-radius: 8px;
    padding: 9px 16px; font-size: 13px; cursor: pointer; font-family: inherit;
}
.prof-notice {
    display: flex; align-items: center; gap: 8px;
    background: #faf5ff; border: 1px solid #e9d5ff;
    border-radius: 10px; padding: 10px 16px;
    font-size: 13px; color: #7c3aed; margin-bottom: 20px;
}
</style>
</head>
<body>
<jsp:include page="sidebar.jsp"/>
<main class="main">
<div class="fs-wrap">

  <div class="fs-header">
    <div class="fs-title">📁 파일 공유</div>
    <% if (!isProfessor) { %>
    <button class="fs-upload-btn" onclick="document.getElementById('uploadModal').classList.add('open')">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
        <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
      </svg>
      파일 업로드
    </button>
    <% } %>
  </div>

  <% if (isProfessor) { %>
  <div class="prof-notice">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
    </svg>
    교수 계정은 파일을 열람하고 다운로드만 가능합니다.
  </div>
  <% } %>

  <div class="fs-table-wrap">
    <% if (fileList == null || fileList.isEmpty()) { %>
    <div class="fs-empty">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" display="block" style="margin:0 auto 12px">
        <path d="M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z"/>
        <polyline points="13 2 13 9 20 9"/>
      </svg>
      아직 공유된 파일이 없어요
    </div>
    <% } else { %>
    <table class="fs-table">
      <thead>
        <tr>
          <th>파일명</th>
          <th>업로더</th>
          <th>크기</th>
          <th>업로드 일시</th>
          <th>작업</th>
        </tr>
      </thead>
      <tbody>
        <% for (FileShareDTO f : fileList) {
             String ext = f.getOriginalName().contains(".")
               ? f.getOriginalName().substring(f.getOriginalName().lastIndexOf('.') + 1).toLowerCase()
               : "";
             String icon = "📄";
             String iconBg = "var(--surface2)";
             if (ext.equals("pdf"))  { icon = "📕"; iconBg = "var(--red-light)"; }
             else if (ext.equals("xlsx") || ext.equals("xls") || ext.equals("csv")) { icon = "📊"; iconBg = "var(--teal-light)"; }
             else if (ext.equals("docx") || ext.equals("doc")) { icon = "📝"; iconBg = "var(--blue-light)"; }
             else if (ext.equals("pptx") || ext.equals("ppt")) { icon = "📋"; iconBg = "var(--orange-light)"; }
             else if (ext.equals("zip") || ext.equals("rar") || ext.equals("7z")) { icon = "🗜️"; iconBg = "var(--violet-light)"; }
             else if (ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || ext.equals("gif") || ext.equals("svg")) { icon = "🖼️"; iconBg = "var(--violet-light)"; }
        %>
        <tr>
          <td>
            <div class="fs-file-name">
              <div class="fs-file-icon" style="background:<%= iconBg %>"><%= icon %></div>
              <%= f.getOriginalName() %>
            </div>
          </td>
          <td><%= f.getUploaderName() != null ? f.getUploaderName() : f.getUploaderId() %></td>
          <td><%= f.getFileSizeFormatted() %></td>
          <td><%= f.getCreatedAt() %></td>
          <td>
            <a class="fs-download-btn"
               href="fileShare?action=download&projectID=<%= projectId %>&id=<%= f.getId() %>">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/>
                <line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              다운로드
            </a>
            <% if (!isProfessor && f.getUploaderId().equals(userId)) { %>
            <form action="fileShare" method="post" style="display:inline;"
                  onsubmit="return confirm('파일을 삭제하시겠습니까?')">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="projectID" value="<%= projectId %>">
              <input type="hidden" name="id" value="<%= f.getId() %>">
              <button type="submit" class="fs-delete-btn">삭제</button>
            </form>
            <% } %>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
    <% } %>
  </div>

</div>
</main>

<!-- 업로드 모달 -->
<% if (!isProfessor) { %>
<div id="uploadModal" class="modal-bg">
  <div class="modal-box">
    <h3>📤 파일 업로드</h3>
    <form action="fileShare" method="post" enctype="multipart/form-data" id="uploadForm">
      <input type="hidden" name="action" value="upload">
      <input type="hidden" name="projectID" value="<%= projectId %>">

      <div class="drop-zone" id="dropZone" onclick="document.getElementById('fileInput').click()"
           ondragover="onDragOver(event)" ondragleave="onDragLeave(event)" ondrop="onDrop(event)">
        <input type="file" name="file" id="fileInput" onchange="onFileSelect(this)">
        <div class="drop-zone-icon">📂</div>
        <div class="drop-zone-text">클릭하거나 파일을 여기에 <b>드래그</b>하세요<br><span style="font-size:11px;color:var(--muted2)">최대 20MB</span></div>
      </div>
      <div class="selected-file" id="selectedFile"></div>

      <div class="modal-actions">
        <button type="button" class="btn-modal-cancel"
                onclick="document.getElementById('uploadModal').classList.remove('open')">취소</button>
        <button type="submit" class="btn-modal-ok">업로드</button>
      </div>
    </form>
  </div>
</div>
<% } %>

<script>
function onDragOver(e) { e.preventDefault(); document.getElementById('dropZone').classList.add('drag-over'); }
function onDragLeave(e) { document.getElementById('dropZone').classList.remove('drag-over'); }
function onDrop(e) {
  e.preventDefault();
  document.getElementById('dropZone').classList.remove('drag-over');
  var files = e.dataTransfer.files;
  if (files.length > 0) {
    document.getElementById('fileInput').files = files;
    showSelected(files[0].name);
  }
}
function onFileSelect(input) {
  if (input.files.length > 0) showSelected(input.files[0].name);
}
function showSelected(name) {
  var el = document.getElementById('selectedFile');
  el.style.display = 'block';
  el.textContent = '선택된 파일: ' + name;
}
// 모달 바깥 클릭 시 닫기
document.getElementById('uploadModal') && document.getElementById('uploadModal').addEventListener('click', function(e) {
  if (e.target === this) this.classList.remove('open');
});
</script>
</body>
</html>
