<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ProjectOS - 회원가입</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<script type="text/javascript" src="resource/js/join.js" defer></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: 'Noto Sans KR', 'Plus Jakarta Sans', sans-serif;
    height: 100vh;
    display: flex;
    overflow: hidden;
  }

  /* ── 좌측 소개 패널 ── */
  .intro-panel {
    flex: 1;
    background: linear-gradient(135deg, #2563eb 0%, #3b82f6 50%, #60a5fa 100%);
    display: flex;
    flex-direction: column;
    padding: 2.5rem 3rem;
    color: #fff;
    position: relative;
    overflow: hidden;
  }

  .intro-panel::before {
    content: '';
    position: absolute;
    width: 500px; height: 500px;
    border-radius: 50%;
    background: rgba(255,255,255,0.08);
    top: -120px; right: -120px;
  }
  .intro-panel::after {
    content: '';
    position: absolute;
    width: 300px; height: 300px;
    border-radius: 50%;
    background: rgba(255,255,255,0.08);
    bottom: -80px; left: -60px;
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    font-size: 1.35rem;
    font-weight: 800;
    letter-spacing: -0.5px;
    color: #fff;
    z-index: 1;
    text-decoration: none;
  }
  .logo-icon {
    width: 36px; height: 36px;
    background: rgba(255,255,255,0.25);
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
  }
  .logo-icon svg {
    width: 20px; height: 20px;
    stroke: #fff;
  }

  .intro-body {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    z-index: 1;
    padding-bottom: 2rem;
  }

  .intro-body .tagline {
    font-size: 2rem;
    font-weight: 800;
    line-height: 1.3;
    margin-bottom: 1rem;
  }

  .intro-body .sub {
    font-size: 1rem;
    color: rgba(255,255,255,0.85);
    line-height: 1.7;
    margin-bottom: 2.5rem;
    max-width: 380px;
  }

  .step-list {
    display: flex;
    flex-direction: column;
    gap: 1.2rem;
  }

  .step-item {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
  }

  .step-num {
    width: 36px; height: 36px;
    min-width: 36px;
    background: rgba(255,255,255,0.2);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.85rem;
    font-weight: 800;
  }

  .step-text strong {
    display: block;
    font-size: 0.9rem;
    font-weight: 700;
    margin-bottom: 2px;
  }
  .step-text span {
    font-size: 0.8rem;
    color: rgba(255,255,255,0.75);
  }

  /* ── 우측 회원가입 패널 ── */
  .join-panel {
    flex: 1;
    background: #f8fafc;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem 2.5rem;
    overflow-y: auto;
  }

  .join-card {
    width: 100%;
    max-width: 440px;
    background: #fff;
    border-radius: 1.2rem;
    box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    padding: 2.5rem 2.8rem;
  }

  .join-card h2 {
    font-size: 1.6rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 0.4rem;
  }
  .join-card .welcome-sub {
    font-size: 0.9rem;
    color: #64748b;
    margin-bottom: 1.8rem;
  }

  .form-label {
    font-size: 0.85rem;
    font-weight: 600;
    color: #374151;
  }

  .form-control {
    border-radius: 0.6rem;
    border: 1.5px solid #e2e8f0;
    font-size: 0.95rem;
    padding: 0.75rem 1rem;
    transition: border-color 0.2s;
    width: 100%;
  }
  .form-control:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
    outline: none;
  }

  .btn-join {
    background: linear-gradient(135deg, #3b82f6, #60a5fa);
    border: none;
    border-radius: 0.6rem;
    color: #fff;
    font-weight: 700;
    font-size: 1rem;
    padding: 0.8rem;
    width: 100%;
    cursor: pointer;
    transition: opacity 0.2s, transform 0.1s;
    margin-top: 0.5rem;
  }
  .btn-join:hover { opacity: 0.9; transform: translateY(-1px); }
  .btn-join:active { transform: translateY(0); }

  .divider {
    text-align: center;
    color: #94a3b8;
    font-size: 0.8rem;
    margin: 1.2rem 0;
    position: relative;
  }
  .divider::before, .divider::after {
    content: '';
    position: absolute;
    top: 50%; width: 38%;
    height: 1px;
    background: #e2e8f0;
  }
  .divider::before { left: 0; }
  .divider::after { right: 0; }

  .login-link {
    text-align: center;
    font-size: 0.85rem;
    color: #64748b;
  }
  .login-link a {
    color: #3b82f6;
    font-weight: 600;
    text-decoration: none;
  }
  .login-link a:hover { text-decoration: underline; }

  .mb-3 { margin-bottom: 1rem; }

  @media (max-width: 768px) {
    .intro-panel { display: none; }
    .join-panel { width: 100%; }
  }
</style>
</head>
<body>

<!-- ── 좌측: 플랫폼 소개 ── -->
<div class="intro-panel">
  <a href="login.jsp" class="logo">
    <div class="logo-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
      </svg>
    </div>
    ProjectOS
  </a>

  <div class="intro-body">
    <p class="tagline">지금 바로<br>팀과 함께 시작하세요</p>
    <p class="sub">
      ProjectOS에 가입하고 팀 프로젝트를 더 효율적으로 관리해보세요.
      가입은 1분이면 충분합니다.
    </p>

    <div class="step-list">
      <div class="step-item">
        <div class="step-num">1</div>
        <div class="step-text">
          <strong>계정 만들기</strong>
          <span>이름, 아이디, 비밀번호로 간단하게 가입</span>
        </div>
      </div>
      <div class="step-item">
        <div class="step-num">2</div>
        <div class="step-text">
          <strong>프로젝트 생성 또는 참여</strong>
          <span>새 프로젝트를 만들거나 팀원 초대를 수락</span>
        </div>
      </div>
      <div class="step-item">
        <div class="step-num">3</div>
        <div class="step-text">
          <strong>협업 시작</strong>
          <span>업무 배정, 일정 관리, 회의록까지 한 번에</span>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ── 우측: 회원가입 폼 ── -->
<div class="join-panel">
  <div class="join-card">
    <h2>회원가입 ✏️</h2>
    <p class="welcome-sub">아래 정보를 입력하여 계정을 만드세요.</p>

    <form action="JoinServlet" method="post" onsubmit="return joinCheck()">
    <div class="mb-3">
        <label class="form-label">사용자 유형</label>
        <div style="display: flex; gap: 1.5rem; margin-top: 0.5rem;">
          <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
            <input type="radio" name="role" value="student" checked style="width: 18px; height: 18px; cursor: pointer;">
            <span style="font-size: 0.95rem; color: #374151;">학생</span>
          </label>
          <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
            <input type="radio" name="role" value="professor" style="width: 18px; height: 18px; cursor: pointer;">
            <span style="font-size: 0.95rem; color: #374151;">교수</span>
          </label>
        </div>
      </div>
      <div class="mb-3">
        <label class="form-label" for="name">이름</label>
        <input type="text" name="name" id="name" class="form-control" placeholder="이름을 입력하세요">
      </div>
      <div class="mb-3">
        <label class="form-label" for="id">아이디 (5~12자)</label>
        <input type="text" name="id" id="id" class="form-control" placeholder="아이디를 입력하세요">
      </div>
      <div class="mb-3">
        <label class="form-label" for="pw">비밀번호 (8~20자)</label>
        <input type="password" name="pw" id="pw" class="form-control" placeholder="비밀번호를 입력하세요">
      </div>
      <div class="mb-3">
        <label class="form-label" for="pw_check">비밀번호 확인</label>
        <input type="password" name="pw_check" id="pw_check" class="form-control" placeholder="비밀번호를 다시 입력하세요">
      </div>
      <div class="mb-3">
        <label class="form-label" for="email">이메일</label>
        <input type="email" name="email" id="email" class="form-control" placeholder="이메일을 입력하세요">
      </div>
      
      <button type="submit" class="btn-join">회원가입</button>
    </form>

    <div class="divider">또는</div>

    <div class="login-link">
      이미 계정이 있으신가요? <a href="login.jsp">로그인</a>
    </div>
  </div>
</div>

</body>
</html>
