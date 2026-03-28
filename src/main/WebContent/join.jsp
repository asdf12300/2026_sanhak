<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>회원가입</title>
<link rel="stylesheet" href="resource/css/join.css">
<script type="text/javascript" src="resource/js/join.js" defer></script>
</head>
<body>
	<div class="container">
		<h1>회원가입</h1>
		<script type="text/javascript" src="resource/js/verify.js" defer></script>
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
				<label for="tel">휴대폰번호</label> <input type="tel" name="tel" id="tel"
					placeholder="휴대폰번호를 입력하세요.">
				<button type="button" id="verify">인증하기</button>
			</div>
			<div class="form-group">
				<input type="submit" value="회원가입">
			</div>
		</form>
	</div>
</body>
</html>
