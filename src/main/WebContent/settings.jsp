<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.LoginDTO" %>
<%
String role = (String)session.getAttribute("role");
String movePage = "projects.jsp";

if ("professor".equals(role)) {
    movePage = "professorProject.jsp";
}
%>
<%
LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");

String userId = "";

if (loginUser != null && loginUser.getId() != null) {
    userId = loginUser.getId();
}

boolean isNaverUser = userId.startsWith("naver_");
%>
<!DOCTYPE html>
<html>
<head>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<meta charset="UTF-8">
<title>계정 설정</title>
<style>
body {
  margin: 0;
  font-family: 'Pretendard', 'Noto Sans KR', Arial, sans-serif;
  background: linear-gradient(135deg, #eef4ff, #f8fbff);
  min-height: 100vh;
}

.back-btn {
  position: fixed;
  top: 30px;
  left: 30px;
  background: #2F6FED;
  color: white;
  padding: 10px 18px;
  border-radius: 10px;
  text-decoration: none;
  font-size: 14px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  z-index: 999;
}

.back-btn:hover {
  background: #1f57d6;
}

.settings-wrapper {
  min-height: 100vh;

  display: flex;
  justify-content: center;
  align-items: center;

  gap: 0;
}

.settings-card {
  width: 390px;
  height: 620px;

  background: #fff;
  padding: 38px;

  border: 1px solid #dbe3f0;
  box-shadow: 0 20px 45px rgba(47,111,237,.12);

  box-sizing: border-box;

  display: flex;
  flex-direction: column;
  justify-content: flex-start;
}

.settings-card:first-child {
  border-radius: 22px 0 0 22px;
}

.settings-card:last-child {
  border-radius: 0 22px 22px 0;
  border-left: none;
}

h2 {
  margin: 0 0 8px;
  font-size: 28px;
  color: #1f2937;
}

.desc {
  color: #6b7280;
  font-size: 14px;
  margin-bottom: 28px;
}

label {
  display: block;
  margin-top: 18px;
  margin-bottom: 7px;
  font-size: 14px;
  font-weight: 700;
  color: #374151;
}

input {
  width: 100%;
  height: 48px;
  border: 1px solid #dbe3f0;
  border-radius: 12px;
  padding: 0 14px;
  font-size: 14px;
  box-sizing: border-box;
}

input:focus {
  outline: none;
  border-color: #2F6FED;
  box-shadow: 0 0 0 3px rgba(47,111,237,.12);
}

.update-btn,
.delete-btn {
  width: 100%;
  height: 52px;
  margin-top: 24px;
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 15px;
  font-weight: 800;
  cursor: pointer;
  text-decoration: none;
}

.update-btn {
  background: #2F6FED;
}

.update-btn:hover {
  background: #245bd0;
}

.delete-btn {
  background: #dc2626;
}

.delete-btn:hover {
  background: #b91c1c;
}

.warning {
  color: red;
  font-size: 13px;
  line-height: 1.6;
  margin-bottom: 24px;
}

.error,
.success {
  position: fixed;
  left: 50%;
  bottom: 30px;
  transform: translateX(-50%);
  padding: 12px 18px;
  border-radius: 10px;
  font-size: 14px;
  z-index: 1000;
}

.error {
  background: #fff1f2;
  color: #e11d48;
}

.success {
  background: #ecfdf5;
  color: #059669;
}
.email-check-row {
  display: flex;
  gap: 8px;
}

.email-check-row input {
  flex: 1;
}

.email-code-btn {
  width: 120px;
  border: none;
  border-radius: 12px;
  background: #374151;
  color: white;
  font-weight: bold;
  cursor: pointer;
}
.update-btn {
  margin-top: 28px;
}

.delete-btn {
  margin-top: 32px;
}
</style>
</head>
<body>
<a href="<%=request.getContextPath()%>/<%=movePage%>" class="back-btn">
   ← 프로젝트 목록으로 돌아가기
</a>

<div class="settings-wrapper">

  <!-- 왼쪽: 계정 설정 -->
  <div class="settings-card">
    <h2>계정 설정</h2>
    <p class="desc">이메일 또는 비밀번호를 변경할 수 있습니다.</p>

    <form action="<%=request.getContextPath()%>/settings/update" method="post">
      <label>새 이메일</label>
      <input type="email" name="email" placeholder="변경할 이메일">

      <label>새 비밀번호</label>
      <input type="password" name="newPw" placeholder="변경할 비밀번호">

      <label>새 비밀번호 확인</label>
      <input type="password" name="newPwCheck" placeholder="비밀번호 확인">

      <button class="update-btn" type="submit">변경하기</button>
    </form>
  </div>

  <!-- 오른쪽: 계정 탈퇴 -->
  <div class="settings-card delete-card">
    <h2>계정 탈퇴</h2>
    <p class="warning">
      계정 탈퇴 시 되돌릴 수 없습니다.<br>
      팀장인 경우 팀장을 다른 팀원에게 넘긴 후 탈퇴할 수 있습니다.
    </p>

    <form action="<%= request.getContextPath() %>/deleteAccount" method="post"
          onsubmit="return confirm('정말 탈퇴하시겠습니까?');">

      <label>탈퇴 확인 문구</label>
      <input type="text" name="confirmText" placeholder="탈퇴합니다" required>
      <% if (!isNaverUser) { %>
      <label>비밀번호 확인</label>
      <input type="password" name="password" required>
      <% } %>
      <label>이메일 인증</label>
      <div class="email-check-row">
      <input type="text" name="deleteCode" placeholder="인증번호 입력" required>
      <button type="button"
        class="email-code-btn"
        onclick="sendDeleteCode()">
        인증번호 발송
      </button>
    </div>
      <button type="submit" class="delete-btn">계정 탈퇴</button>
    </form>
  </div>

</div>

<% if (request.getAttribute("deleteError") != null) { %>
  <div class="error"><%= request.getAttribute("deleteError") %></div>
<% } %>

<% if (request.getAttribute("error") != null) { %>
  <div class="error"><%= request.getAttribute("error") %></div>
<% } %>

<% if (request.getAttribute("success") != null) { %>
  <div class="success"><%= request.getAttribute("success") %></div>
<% } %>

<% if ("1".equals(request.getParameter("success"))) { %>
  <div class="success">회원 정보가 변경되었습니다.</div>
<% } %>

<% if ("pw".equals(request.getParameter("error"))) { %>
  <div class="error">비밀번호가 일치하지 않습니다.</div>
<% } %>
<script>
function sendDeleteCode() {
  fetch("<%=request.getContextPath()%>/delete/sendCode", {
    method: "POST"
  })
  .then(res => res.text())
  .then(msg => {
    alert(msg);
  })
  .catch(err => {
    alert("인증번호 발송 중 오류가 발생했습니다.");
  });
}
</script>
</body>
</html>