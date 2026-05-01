<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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
  display: flex;
  align-items: center;
  justify-content: center;
}
.card {
  width: 460px;
  background: #fff;
  border-radius: 22px;
  padding: 38px;
  box-shadow: 0 20px 45px rgba(47,111,237,.12);
}
h2 { margin: 0 0 8px; font-size: 28px; color: #1f2937; }
.desc { color: #6b7280; font-size: 14px; margin-bottom: 28px; }
.form-group { margin-bottom: 18px; }
label {
  display: block;
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
.btn {
  width: 100%;
  height: 52px;
  margin-top: 10px;
  border: none;
  border-radius: 12px;
  background: #2F6FED;
  color: white;
  font-size: 15px;
  font-weight: 800;
  cursor: pointer;
}
.btn:hover { background: #245bd0; }
.error, .success {
  margin-top: 16px;
  padding: 12px;
  border-radius: 10px;
  font-size: 14px;
}
.error { background: #fff1f2; color: #e11d48; }
.success { background: #ecfdf5; color: #059669; }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="card">
  <h2>계정 설정</h2>
  <p class="desc">이메일 또는 비밀번호를 변경할 수 있습니다.</p>

  <form action="<%=request.getContextPath()%>/settings/update" method="post">
    <div class="form-group">
      <label>새 이메일</label>
      <input type="email" name="email" placeholder="변경할 이메일">
    </div>

    <div class="form-group">
      <label>새 비밀번호</label>
      <input type="password" name="newPw" placeholder="변경할 비밀번호">
    </div>

    <div class="form-group">
      <label>새 비밀번호 확인</label>
      <input type="password" name="newPwCheck" placeholder="비밀번호 확인">
    </div>

    <button class="btn" type="submit">변경하기</button>
  </form>

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
</div>

</body>
</html>