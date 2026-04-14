<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ProjectOS - 로그인</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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

  /* 로고 */
  .logo {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    font-size: 1.35rem;
    font-weight: 800;
    letter-spacing: -0.5px;
    color: #fff;
    z-index: 1;
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

  /* 소개 본문 */
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
    color: rgba(255,255,255,0.8);
    line-height: 1.7;
    margin-bottom: 2.5rem;
    max-width: 380px;
  }

  .feature-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .feature-item {
    display: flex;
    align-items: flex-start;
    gap: 0.85rem;
  }

  .feature-icon {
    width: 38px; height: 38px;
    min-width: 38px;
    background: rgba(255,255,255,0.15);
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
  }
  .feature-icon svg {
    width: 18px; height: 18px;
    stroke: #fff;
  }

  .feature-text strong {
    display: block;
    font-size: 0.9rem;
    font-weight: 700;
    margin-bottom: 2px;
  }
  .feature-text span {
    font-size: 0.8rem;
    color: rgba(255,255,255,0.75);
  }

  /* ── 우측 로그인 패널 ── */
  .login-panel {
    flex: 1;
    background: #f8fafc;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2.5rem 2.5rem;
  }

  .login-card {
    width: 100%;
    max-width: 440px;
    background: #fff;
    border-radius: 1.2rem;
    box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    padding: 3rem 2.8rem;
  }

  .login-card h2 {
    font-size: 1.6rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 0.4rem;
  }
  .login-card .welcome-sub {
    font-size: 0.9rem;
    color: #64748b;
    margin-bottom: 2rem;
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
  }
  .form-control:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
  }

  .btn-login {
    background: linear-gradient(135deg, #3b82f6, #60a5fa);
    border: none;
    border-radius: 0.6rem;
    color: #fff;
    font-weight: 700;
    font-size: 1rem;
    padding: 0.8rem;
    width: 100%;
    transition: opacity 0.2s, transform 0.1s;
  }
  .btn-login:hover { opacity: 0.9; transform: translateY(-1px); }
  .btn-login:active { transform: translateY(0); }

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

  .join-link {
    text-align: center;
    font-size: 0.85rem;
    color: #64748b;
  }
  .join-link a {
    color: #2563eb;
    font-weight: 600;
    text-decoration: none;
  }
  .join-link a:hover { text-decoration: underline; }

  /* 반응형 */
  @media (max-width: 768px) {
    .intro-panel { display: none; }
    .login-panel { width: 100%; min-width: unset; background: #f8fafc; }
  }
</style>
</head>
<body>

<!-- ── 좌측: 플랫폼 소개 ── -->
<div class="intro-panel">
  <!-- 로고 (좌상단) -->
  <div class="logo">
    <div class="logo-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
      </svg>
    </div>
    ProjectOS
  </div>

  <!-- 소개 본문 -->
  <div class="intro-body">
    <p class="tagline">팀 프로젝트를<br>더 스마트하게</p>
    <p class="sub">
      ProjectOS는 팀의 업무, 일정, 회의록을 한 곳에서 관리하는
      올인원 프로젝트 협업 플랫폼입니다.
    </p>

    <div class="feature-list">
      <div class="feature-item">
        <div class="feature-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/>
            <line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/>
          </svg>
        </div>
        <div class="feature-text">
          <strong>업무 &amp; 일정 관리</strong>
          <span>태스크 배정부터 마감일 추적까지 한눈에</span>
        </div>
      </div>

      <div class="feature-item">
        <div class="feature-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
          </svg>
        </div>
        <div class="feature-text">
          <strong>회의록 자동 정리</strong>
          <span>회의 내용을 기록하고 팀원과 즉시 공유</span>
        </div>
      </div>

      <div class="feature-item">
        <div class="feature-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 00-3-3.87"/>
            <path d="M16 3.13a4 4 0 010 7.75"/>
          </svg>
        </div>
        <div class="feature-text">
          <strong>팀원 초대 &amp; 권한 관리</strong>
          <span>프로젝트별 멤버를 손쉽게 구성하고 관리</span>
        </div>
      </div>

      <div class="feature-item">
        <div class="feature-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="7" height="7"/>
            <rect x="14" y="3" width="7" height="7"/>
            <rect x="14" y="14" width="7" height="7"/>
            <rect x="3" y="14" width="7" height="7"/>
          </svg>
        </div>
        <div class="feature-text">
          <strong>대시보드 한눈에 보기</strong>
          <span>프로젝트 현황을 실시간으로 파악</span>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ── 우측: 로그인 폼 ── -->
<div class="login-panel">
  <div class="login-card">
    <h2>다시 오셨군요 👋</h2>
    <p class="welcome-sub">계정에 로그인하여 팀과 함께 시작하세요.</p>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div class="alert alert-danger py-2 mb-3" style="font-size:0.85rem;"><%= error %></div>
    <% } %>

    <form action="login" method="post">
      <div class="mb-3">
        <label class="form-label">아이디</label>
        <input type="text" name="userid" class="form-control" placeholder="아이디를 입력하세요" required>
      </div>
      <div class="mb-3">
        <label class="form-label">비밀번호</label>
        <input type="password" name="password" class="form-control" placeholder="비밀번호를 입력하세요" required>
      </div>
      <button type="submit" class="btn-login mt-1">로그인</button>
    </form>

    <div class="divider">또는</div>

    <div class="join-link">
      계정이 없으신가요? <a href="join.jsp">회원가입</a>
    </div>
  </div>
</div>

</body>
</html>
