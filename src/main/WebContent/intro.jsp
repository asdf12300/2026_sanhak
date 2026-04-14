<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ProjectOS | 팀 프로젝트 협업 플랫폼</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --blue: #3b82f6;
  --blue-dark: #2563eb;
  --blue-soft: #eff6ff;
  --text: #1e293b;
  --text2: #475569;
  --muted: #94a3b8;
  --border: #e2e8f0;
  --bg: #f8fafc;
  --surface: #ffffff;
}

body {
  font-family: 'Noto Sans KR', 'Plus Jakarta Sans', sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
}

a { text-decoration: none; color: inherit; }

/* ── NAV ── */
.nav {
  position: sticky; top: 0; z-index: 100;
  background: rgba(255,255,255,0.85);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
  padding: 0 5%;
  height: 64px;
  display: flex; align-items: center; justify-content: space-between;
}

.nav-logo {
  display: flex; align-items: center; gap: 0.55rem;
  font-size: 1.2rem; font-weight: 800; color: var(--text);
  letter-spacing: -0.5px;
}
.nav-logo-icon {
  width: 32px; height: 32px;
  background: linear-gradient(135deg, var(--blue-dark), var(--blue));
  border-radius: 9px;
  display: flex; align-items: center; justify-content: center;
}
.nav-logo-icon svg { width: 17px; height: 17px; stroke: #fff; }

.nav-actions { display: flex; align-items: center; gap: 0.6rem; }

.btn {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 9px 22px; border-radius: 8px;
  font-size: 0.875rem; font-weight: 600;
  cursor: pointer; border: none; transition: all 0.2s;
}
.btn-ghost {
  background: transparent; color: var(--text2);
  border: 1.5px solid var(--border);
}
.btn-ghost:hover { background: var(--bg); border-color: var(--blue); color: var(--blue); }
.btn-primary {
  background: linear-gradient(135deg, var(--blue-dark), var(--blue));
  color: #fff;
}
.btn-primary:hover { opacity: 0.9; transform: translateY(-1px); }

/* ── HERO ── */
.hero {
  padding: 100px 5% 80px;
  text-align: center;
  position: relative;
  overflow: hidden;
}
.hero::before {
  content: '';
  position: absolute; inset: 0;
  background: radial-gradient(ellipse 80% 60% at 50% 0%, rgba(59,130,246,0.1) 0%, transparent 70%);
  pointer-events: none;
}

.hero-badge {
  display: inline-flex; align-items: center; gap: 6px;
  background: var(--blue-soft); color: var(--blue-dark);
  border: 1px solid #bfdbfe;
  border-radius: 20px; padding: 5px 14px;
  font-size: 0.8rem; font-weight: 600;
  margin-bottom: 1.5rem;
}
.hero-badge span { width: 6px; height: 6px; border-radius: 50%; background: var(--blue); }

.hero h1 {
  font-size: clamp(2.2rem, 5vw, 3.5rem);
  font-weight: 800; line-height: 1.2;
  letter-spacing: -1px; color: var(--text);
  margin-bottom: 1.2rem;
}
.hero h1 em {
  font-style: normal;
  background: linear-gradient(135deg, var(--blue-dark), var(--blue));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero p {
  font-size: 1.1rem; color: var(--text2);
  max-width: 520px; margin: 0 auto 2.5rem;
  line-height: 1.8;
}

.hero-btns { display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap; }
.btn-lg { padding: 13px 32px; font-size: 1rem; border-radius: 10px; }

/* ── FEATURES ── */
.section {
  padding: 80px 5%;
  text-align: center;
}
.section-label {
  display: inline-block;
  font-size: 0.8rem; font-weight: 700; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--blue);
  margin-bottom: 0.75rem;
}
.section h2 {
  font-size: clamp(1.6rem, 3vw, 2.2rem);
  font-weight: 800; letter-spacing: -0.5px;
  color: var(--text); margin-bottom: 0.75rem;
}
.section .section-sub {
  font-size: 1rem; color: var(--text2);
  max-width: 480px; margin: 0 auto 3rem;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.25rem;
  max-width: 1100px; margin: 0 auto;
}

.feature-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 2rem 1.75rem;
  text-align: left;
  transition: box-shadow 0.25s, transform 0.25s, border-color 0.25s;
}
.feature-card:hover {
  box-shadow: 0 8px 32px rgba(59,130,246,0.12);
  transform: translateY(-4px);
  border-color: #bfdbfe;
}

.feature-icon {
  width: 48px; height: 48px;
  border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 1.1rem;
}
.feature-icon svg { width: 22px; height: 22px; }

.feature-card h3 {
  font-size: 1rem; font-weight: 700;
  color: var(--text); margin-bottom: 0.5rem;
}
.feature-card p {
  font-size: 0.875rem; color: var(--text2); line-height: 1.7;
}

/* ── HOW IT WORKS ── */
.how { background: var(--surface); }

.steps {
  display: flex; gap: 0; justify-content: center;
  max-width: 900px; margin: 0 auto;
  position: relative;
}
.steps::before {
  content: '';
  position: absolute; top: 28px; left: 15%; right: 15%;
  height: 2px; background: var(--border); z-index: 0;
}

.step {
  flex: 1; text-align: center; padding: 0 1.5rem;
  position: relative; z-index: 1;
}
.step-circle {
  width: 56px; height: 56px; border-radius: 50%;
  background: linear-gradient(135deg, var(--blue-dark), var(--blue));
  color: #fff; font-size: 1.1rem; font-weight: 800;
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 1rem;
  box-shadow: 0 4px 16px rgba(59,130,246,0.3);
}
.step h3 { font-size: 0.95rem; font-weight: 700; margin-bottom: 0.4rem; }
.step p { font-size: 0.82rem; color: var(--text2); line-height: 1.6; }

/* ── CTA ── */
.cta {
  padding: 80px 5%;
  text-align: center;
  background: linear-gradient(135deg, #1e3a8a 0%, var(--blue-dark) 50%, var(--blue) 100%);
  color: #fff;
  position: relative; overflow: hidden;
}
.cta::before {
  content: '';
  position: absolute; width: 600px; height: 600px; border-radius: 50%;
  background: rgba(255,255,255,0.05);
  top: -200px; right: -150px; pointer-events: none;
}
.cta h2 {
  font-size: clamp(1.6rem, 3vw, 2.2rem);
  font-weight: 800; letter-spacing: -0.5px;
  margin-bottom: 0.75rem;
}
.cta p { font-size: 1rem; color: rgba(255,255,255,0.8); margin-bottom: 2rem; }
.btn-white {
  background: #fff; color: var(--blue-dark);
  padding: 13px 36px; font-size: 1rem; border-radius: 10px;
  font-weight: 700;
}
.btn-white:hover { background: #f0f9ff; transform: translateY(-1px); }

/* ── FOOTER ── */
footer {
  background: var(--surface);
  border-top: 1px solid var(--border);
  padding: 28px 5%;
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 12px;
}
.footer-logo {
  display: flex; align-items: center; gap: 0.5rem;
  font-size: 1rem; font-weight: 800; color: var(--text);
}
.footer-logo-icon {
  width: 26px; height: 26px;
  background: linear-gradient(135deg, var(--blue-dark), var(--blue));
  border-radius: 7px;
  display: flex; align-items: center; justify-content: center;
}
.footer-logo-icon svg { width: 13px; height: 13px; stroke: #fff; }
footer p { font-size: 0.8rem; color: var(--muted); }
</style>
</head>
<body>

<!-- NAV -->
<nav class="nav">
  <a href="intro.jsp" class="nav-logo">
    <div class="nav-logo-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
      </svg>
    </div>
    ProjectOS
  </a>
  <div class="nav-actions">
    <a href="login.jsp" class="btn btn-ghost">로그인</a>
    <a href="join.jsp" class="btn btn-primary">회원가입</a>
  </div>
</nav>

<!-- HERO -->
<section class="hero">
  <div class="hero-badge"><span></span> 팀 협업 플랫폼</div>
  <h1>팀 프로젝트의<br><em>새로운 기준</em></h1>
  <p>흩어진 업무, 일정, 회의록을 하나의 흐름으로 연결하세요.<br>ProjectOS와 함께라면 팀 협업이 훨씬 쉬워집니다.</p>
  <div class="hero-btns">
    <a href="join.jsp" class="btn btn-primary btn-lg">시작하기</a>
    <a href="login.jsp" class="btn btn-ghost btn-lg">로그인</a>
  </div>
</section>



<!-- FEATURES -->
<section class="section">
  <div class="section-label">Features</div>
  <h2>필요한 모든 것이 한 곳에</h2>
  <p class="section-sub">프로젝트 관리에 필요한 핵심 기능을 하나의 플랫폼에서 경험하세요.</p>

  <div class="features">
    <div class="feature-card">
      <div class="feature-icon" style="background:#eff6ff;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2">
          <rect x="3" y="4" width="18" height="18" rx="2"/>
          <line x1="16" y1="2" x2="16" y2="6"/>
          <line x1="8" y1="2" x2="8" y2="6"/>
          <line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
      </div>
      <h3>일정 관리</h3>
      <p>캘린더 기반으로 팀 일정을 한눈에 파악하고, 마감일을 놓치지 않도록 관리하세요.</p>
    </div>

    <div class="feature-card">
      <div class="feature-icon" style="background:#f0fdf4;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2">
          <polyline points="9 11 12 14 22 4"/>
          <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
        </svg>
      </div>
      <h3>업무 관리</h3>
      <p>칸반 보드로 업무를 시각화하고, 팀원별 진행 상황을 실시간으로 추적하세요.</p>
    </div>

    <div class="feature-card">
      <div class="feature-icon" style="background:#fff7ed;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2">
          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
          <polyline points="14 2 14 8 20 8"/>
          <line x1="16" y1="13" x2="8" y2="13"/>
          <line x1="16" y1="17" x2="8" y2="17"/>
        </svg>
      </div>
      <h3>회의록</h3>
      <p>회의 내용을 바로 기록하고 팀원과 공유하세요. 중요한 결정 사항을 놓치지 않습니다.</p>
    </div>

    <div class="feature-card">
      <div class="feature-icon" style="background:#faf5ff;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2">
          <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 00-3-3.87"/>
          <path d="M16 3.13a4 4 0 010 7.75"/>
        </svg>
      </div>
      <h3>팀원 관리</h3>
      <p>프로젝트별 팀원을 초대하고 역할을 지정하세요. 팀장과 팀원 권한을 구분해 관리합니다.</p>
    </div>

    <div class="feature-card">
      <div class="feature-icon" style="background:#fff1f2;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2">
          <rect x="3" y="3" width="7" height="7"/>
          <rect x="14" y="3" width="7" height="7"/>
          <rect x="14" y="14" width="7" height="7"/>
          <rect x="3" y="14" width="7" height="7"/>
        </svg>
      </div>
      <h3>대시보드</h3>
      <p>프로젝트 진행률, 업무 현황, 주요 일정을 대시보드 하나로 한눈에 파악하세요.</p>
    </div>

    <div class="feature-card">
      <div class="feature-icon" style="background:#ecfdf5;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2">
          <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
        </svg>
      </div>
      <h3>팀 채팅</h3>
      <p>프로젝트 내에서 팀원과 실시간으로 소통하고 파일을 공유하세요.</p>
    </div>
  </div>
</section>

<!-- HOW IT WORKS -->
<section class="section how">
  <div class="section-label">How it works</div>
  <h2>3단계로 바로 시작</h2>
  <p class="section-sub">복잡한 설정 없이 바로 팀 협업을 시작할 수 있습니다.</p>

  <div class="steps">
    <div class="step">
      <div class="step-circle">1</div>
      <h3>계정 만들기</h3>
      <p>이름과 아이디만으로<br>1분 안에 가입 완료</p>
    </div>
    <div class="step">
      <div class="step-circle">2</div>
      <h3>프로젝트 생성</h3>
      <p>프로젝트를 만들고<br>팀원을 초대하세요</p>
    </div>
    <div class="step">
      <div class="step-circle">3</div>
      <h3>협업 시작</h3>
      <p>업무 배정, 일정 관리,<br>회의록까지 한 번에</p>
    </div>
  </div>
</section>

<!-- CTA -->
<section class="cta">
  <h2>지금 바로 팀과 함께 시작하세요</h2>
  <p>무료로 모든 기능을 사용할 수 있습니다.</p>
  <a href="join.jsp" class="btn btn-white">회원가입 →</a>
</section>

<!-- FOOTER -->
<footer>
  <div class="footer-logo">
    <div class="footer-logo-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
      </svg>
    </div>
    ProjectOS
  </div>
  <p>© 2026 ProjectOS. All rights reserved.</p>
</footer>

</body>
</html>
