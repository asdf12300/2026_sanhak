<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
h2 { margin: 0 0 10px; font-size: 26px; color: #1f2937; }
p { color: #6b7280; font-size: 14px; margin-bottom: 26px; }
.input {
  width: 100%;
  height: 48px;
  border: 1px solid #dbe3f0;
  border-radius: 12px;
  padding: 0 14px;
  font-size: 14px;
  box-sizing: border-box;
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
.error {
  margin-top: 16px;
  padding: 12px;
  border-radius: 10px;
  background: #fff1f2;
  color: #e11d48;
  font-size: 14px;
}
</style>
</head>
<body>

<div class="card">
  <h2>설정 페이지 접근 확인</h2>
  <p>개인정보 변경을 위해 현재 비밀번호를 입력하세요.</p>

  <form action="<%=request.getContextPath()%>/settings/check" method="post">
    <input class="input" type="password" name="currentPw" placeholder="현재 비밀번호" required>
    <button class="btn" type="submit">확인</button>
  </form>

  <% if (request.getAttribute("error") != null) { %>
    <div class="error"><%= request.getAttribute("error") %></div>
  <% } %>
</div>

</body>
</html>