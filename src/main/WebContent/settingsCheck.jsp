<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    boolean isNaverUser = Boolean.TRUE.equals(request.getAttribute("naverUser"));
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>설정 확인</title>
<style>
body {
  margin: 0;
  font-family: 'Pretendard', 'Noto Sans KR', Arial, sans-serif;
  background: linear-gradient(135deg, #eef4ff, #f8fbff);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
}

.card {
  width: 420px;
  background: #fff;
  border-radius: 22px;
  padding: 38px;
  box-shadow: 0 20px 45px rgba(47,111,237,.12);
}

h2 {
  margin: 0 0 10px;
  font-size: 26px;
  color: #1f2937;
}

p {
  color: #6b7280;
  font-size: 14px;
  margin-bottom: 26px;
}

.input {
  width: 100%;
  height: 48px;
  border: 1px solid #dbe3f0;
  border-radius: 12px;
  padding: 0 14px;
  font-size: 14px;
  box-sizing: border-box;
}

.input:focus {
  outline: none;
  border-color: #2F6FED;
  box-shadow: 0 0 0 3px rgba(47,111,237,.12);
}

.btn {
  width: 100%;
  height: 50px;
  margin-top: 16px;
  border: none;
  border-radius: 12px;
  background: #2F6FED;
  color: white;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
}

.btn:hover {
  background: #245bd0;
}

.error {
  margin-top: 16px;
  padding: 12px;
  border-radius: 10px;
  background: #fff1f2;
  color: #e11d48;
  font-size: 14px;
}

.email-check-row {
  display: flex;
  gap: 8px;
}

.email-check-row .input {
  flex: 1;
}

.email-code-btn {
  width: 120px;
  border: none;
  border-radius: 12px;
  background: #374151;
  color: #fff;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}

.email-code-btn:hover {
  background: #1f2937;
}
</style>
</head>
<body data-context="<%=request.getContextPath()%>">

<div class="card">
  <h2>설정 페이지 접근 확인</h2>
  <p><%= isNaverUser ? "네이버 로그인 사용자는 이메일 인증 후 설정 변경이 가능합니다." : "개인정보 변경을 위해 현재 비밀번호를 입력하세요." %></p>

  <form action="<%=request.getContextPath()%>/settings/check" method="post">
    <% if (isNaverUser) { %>
      <div class="email-check-row">
        <input class="input" type="text" name="settingsCode" placeholder="인증번호 입력" required>
        <button class="email-code-btn" type="button" onclick="sendSettingsCode()">인증번호 발송</button>
      </div>
    <% } else { %>
      <input class="input" type="password" name="currentPw" placeholder="현재 비밀번호" required>
    <% } %>
    <button class="btn" type="submit">확인</button>
  </form>

  <% if (request.getAttribute("error") != null) { %>
    <div class="error"><%= request.getAttribute("error") %></div>
  <% } %>
</div>

<script>
function sendSettingsCode() {
  var contextPath = document.body.dataset.context || '';
  fetch(contextPath + '/delete/sendCode?mode=settings', {
    method: 'POST'
  })
  .then(function(res) {
    return res.text();
  })
  .then(function(msg) {
    alert(msg);
  })
  .catch(function() {
    alert('인증번호 발송 중 오류가 발생했습니다.');
  });
}
</script>
</body>
</html>
