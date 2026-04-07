<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>회원가입</title>
<link rel="stylesheet" href="resource/css/join.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="resource/css/index.css">
<script type="text/javascript" src="resource/js/join.js" defer></script>
</head>
<body>
	<div class="container" style="position:relative;">
		<a href="login.jsp" style="position:absolute;top:16px;left:16px;color:#343a40;text-decoration:none;">
			<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
				<polyline points="15 18 9 12 15 6"/>
			</svg>
		</a>
		<h1>회원가입</h1>
		<form action="JoinServlet" method="post" onsubmit="return joinCheck()">
			<div class="form-group">
				<label for="name">이름</label> <input type="text" name="name"
					id="name" placeholder="이름을 입력하세요.">
			</div>
			<div class="form-group">
				<label for="id">아이디(5~12자)</label> <input type="text" name="id"
					id="id" placeholder="아이디를 입력하세요.">
			</div>
			<div class="form-group">
				<label for="pw">비밀번호(8~20자)</label> <input type="password" name="pw"
					id="pw" placeholder="비밀번호를 입력하세요.">
			</div>
			<div class="form-group">
				<label for="pw_check">비밀번호 확인</label> <input type="password"
					name="pw_check" id="pw_check" placeholder="비밀번호를 확인하세요.">
			</div>
			<div class="form-group">
				<label for="email">이메일</label> <input type="email" name="email"
					id="email" placeholder="이메일을 입력하세요.">
			</div>
			<div class="form-group">
				<input type="submit" value="회원가입">
			</div>
		</form>
	</div>
</body>
</html>
