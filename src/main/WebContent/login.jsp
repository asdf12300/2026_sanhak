<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<style>
    body {
        background-color: #f7f9fc;
        height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .login-card {
        width: 100%;
        max-width: 400px;
        padding: 2rem;
        border-radius: 1rem;
        box-shadow: 0 0 20px rgba(0,0,0,0.1);
        background-color: #ffffff;
    }
    .login-card h2 {
        text-align: center;
        margin-bottom: 1.5rem;
        font-weight: 600;
        color: #343a40;
    }
</style>
</head>
<body>
<div class="login-card">
    <h2>로그인</h2>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div class="alert alert-danger"><%= error %></div>
    <% } %>
    
    <form action="login" method="post">
      <div class="mb-3">
        <label class="form-label">아이디</label>
        <input type="text" name="userid" class="form-control" placeholder="아이디 입력" required>
      </div>

      <div class="mb-3">
        <label class="form-label">비밀번호</label>
        <input type="password" name="password" class="form-control" placeholder="비밀번호 입력" required>
      </div>

      <button type="submit" class="btn btn-primary w-100" style="text-align:center;justify-content:center;">로그인</button>
    </form>

    <div class="mt-3 text-center">
        <small class="text-muted">계정이 없으신가요? <a href="join.jsp">회원가입</a></small>
    </div>
</div>

</body>
</html>
