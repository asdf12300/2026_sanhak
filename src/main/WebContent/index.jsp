<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ProjectOS — 대시보드</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
  :root {
    --bg:          #f0f4fb;
    --bg2:         #e6edf8;
    --surface:     #ffffff;
    --surface2:    #f7f9fd;
    --border:      #dce6f5;
    --border2:     #c8d9f0;
    --blue:        #2563eb;
    --blue-mid:    #3b82f6;
    --blue-light:  #eff6ff;
    --blue-soft:   #dbeafe;
    --blue-dark:   #1d4ed8;
    --teal:        #0d9488;
    --teal-light:  #f0fdfa;
    --orange:      #f59e0b;
    --orange-light:#fffbeb;
    --red:         #ef4444;
    --red-light:   #fef2f2;
    --violet:      #7c3aed;
    --violet-light:#f5f3ff;
    --text:        #0f172a;
    --text2:       #334155;
    --muted:       #64748b;
    --muted2:      #94a3b8;
    --shadow-sm:   0 1px 3px rgba(37,99,235,.08), 0 1px 2px rgba(0,0,0,.04);
    --shadow:      0 4px 16px rgba(37,99,235,.10), 0 1px 4px rgba(0,0,0,.04);
    --radius:      14px;
    --radius-sm:   9px;
    --radius-xs:   6px;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: var(--bg); color: var(--text); font-family: 'Noto Sans KR', sans-serif; font-size: 13px; min-height: 100vh; }

  /* SIDEBAR */
  .sidebar {
    position: fixed; left: 0; top: 0; bottom: 0; width: 224px;
    background: var(--surface); border-right: 1px solid var(--border);
    display: flex; flex-direction: column; padding: 24px 0 20px;
    z-index: 100; box-shadow: var(--shadow-sm);
  }
  .logo {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 19px; font-weight: 800; color: var(--blue);
    padding: 0 22px 26px; letter-spacing: -.5px;
    display: flex; align-items: center; gap: 9px;
  }
  .logo-icon {
    width: 32px; height: 32px; border-radius: 9px;
    background: linear-gradient(135deg, var(--blue), #60a5fa);
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  }
  .logo-icon svg { width: 16px; height: 16px; stroke: #fff; }
  .nav-sec { padding: 0 10px 6px; }
  .nav-label { font-size: 10px; font-weight: 700; letter-spacing: 1.4px; color: var(--muted2); text-transform: uppercase; padding: 2px 12px 8px; }
  .nav-item { display: flex; align-items: center; gap: 9px; padding: 9px 12px; border-radius: var(--radius-sm); color: var(--muted); cursor: pointer; transition: all .16s; font-size: 13px; font-weight: 500; }
  .nav-item:hover { background: var(--blue-light); color: var(--blue); }
  .nav-item.active { background: var(--blue-light); color: var(--blue); font-weight: 600; }
  .nav-item svg { width: 16px; height: 16px; flex-shrink: 0; }
  .nav-badge { margin-left: auto; background: var(--blue); color: #fff; font-size: 10px; font-weight: 700; padding: 1px 6px; border-radius: 10px; min-width: 18px; text-align: center; }
  .nav-badge.red { background: var(--red); }
  .sdiv { height: 1px; background: var(--border); margin: 10px 16px; }
  .sidebar-bot { margin-top: auto; padding: 14px 10px 0; border-top: 1px solid var(--border); }
  .av-row { display: flex; align-items: center; gap: 10px; padding: 9px 12px; border-radius: var(--radius-sm); cursor: pointer; transition: background .16s; }
  .av-row:hover { background: var(--blue-light); }
  .av { width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, var(--blue), #60a5fa); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px; color: #fff; flex-shrink: 0; box-shadow: 0 2px 8px rgba(37,99,235,.25); }
  .av-name { font-size: 13px; font-weight: 600; color: var(--text); }
  .av-role { font-size: 11px; color: var(--muted); }

  /* MAIN */
  .main { margin-left: 224px; padding: 28px 28px 48px; min-height: 100vh; }
  .topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
  .page-title { font-family: 'Plus Jakarta Sans', sans-serif; font-size: 22px; font-weight: 800; color: var(--text); letter-spacing: -.5px; }
  .page-sub { font-size: 12px; color: var(--muted); margin-top: 3px; }
  .topbar-r { display: flex; align-items: center; gap: 10px; }
  .btn { display: flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: var(--radius-sm); font-size: 12px; font-weight: 600; cursor: pointer; border: none; transition: all .16s; font-family: inherit; }
  .btn-p { background: var(--blue); color: #fff; box-shadow: 0 2px 8px rgba(37,99,235,.30); }
  .btn-p:hover { background: var(--blue-dark); transform: translateY(-1px); }
  .btn-g { background: var(--surface); color: var(--muted); border: 1px solid var(--border); box-shadow: var(--shadow-sm); }
  .btn-g:hover { color: var(--blue); border-color: var(--blue-mid); background: var(--blue-light); }
  .notif-btn { position: relative; width: 36px; height: 36px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all .16s; box-shadow: var(--shadow-sm); }
  .notif-btn:hover { border-color: var(--blue-mid); background: var(--blue-light); }
  .notif-dot { position: absolute; top: 7px; right: 7px; width: 7px; height: 7px; border-radius: 50%; background: var(--red); border: 1.5px solid #fff; animation: blink 2s infinite; }
  @keyframes blink { 0%,100%{opacity:1}50%{opacity:.4} }

  /* GRID */
  .grid { display: grid; grid-template-columns: repeat(12,1fr); gap: 16px; }
  .c3{grid-column:span 3} .c4{grid-column:span 4} .c5{grid-column:span 5}
  .c6{grid-column:span 6} .c7{grid-column:span 7} .c8{grid-column:span 8} .c12{grid-column:span 12}

  /* CARD */
  .card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 20px; box-shadow: var(--shadow-sm); animation: fadeUp .38s ease both; }
  @keyframes fadeUp { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
  .card:nth-child(1){animation-delay:.00s} .card:nth-child(2){animation-delay:.06s} .card:nth-child(3){animation-delay:.12s}
  .card:nth-child(4){animation-delay:.18s} .card:nth-child(5){animation-delay:.24s} .card:nth-child(6){animation-delay:.30s}
  .card-hd { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
  .card-t { font-family: 'Plus Jakarta Sans', sans-serif; font-size: 13px; font-weight: 700; color: var(--text2); }

  /* BADGE */
  .badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 20px; font-size: 10px; font-weight: 700; }
  .b-bl { background: var(--blue-soft); color: var(--blue); }
  .b-tl { background: var(--teal-light); color: var(--teal); }
  .b-or { background: var(--orange-light); color: var(--orange); }
  .b-rd { background: var(--red-light); color: var(--red); }
  .b-vi { background: var(--violet-light); color: var(--violet); }
  .b-gy { background: var(--surface2); color: var(--muted); border: 1px solid var(--border); }

  /* STAT */
  .stat-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 14px; margin-bottom: 16px; }
  .stat-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 18px 20px; box-shadow: var(--shadow-sm); display: flex; align-items: flex-start; gap: 14px; animation: fadeUp .38s ease both; }
  .s-icon { width: 42px; height: 42px; border-radius: 11px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
  .s-icon svg { width: 20px; height: 20px; }
  .s-label { font-size: 11px; color: var(--muted); margin-bottom: 4px; font-weight: 500; }
  .s-num { font-family: 'Plus Jakarta Sans', sans-serif; font-size: 24px; font-weight: 800; line-height: 1; letter-spacing: -1px; }
  .s-delta { font-size: 11px; margin-top: 3px; font-weight: 500; }
  .up{color:var(--teal)} .dn{color:var(--red)} .fl{color:var(--muted)}

  /* DONUT */
  .donut-wrap { display: flex; flex-direction: column; align-items: center; gap: 16px; }
  .donut-svg { position: relative; width: 148px; height: 148px; }
  .donut-label { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; }
  .donut-pct { font-family: 'Plus Jakarta Sans', sans-serif; font-size: 30px; font-weight: 800; color: var(--blue); line-height: 1; letter-spacing: -1px; }
  .donut-sub { font-size: 11px; color: var(--muted); margin-top: 2px; font-weight: 500; }
  .donut-leg { width: 100%; display: flex; flex-direction: column; gap: 8px; }
  .leg-row { display: flex; align-items: center; justify-content: space-between; }
  .leg-l { display: flex; align-items: center; gap: 8px; }
  .leg-dot { width: 8px; height: 8px; border-radius: 3px; }
  .leg-name { font-size: 12px; color: var(--muted); }
  .leg-val { font-size: 12px; font-weight: 700; color: var(--text2); }

  /* WORK STATUS */
  .ws-list { display: flex; flex-direction: column; gap: 12px; }
  .ws-row { display: flex; justify-content: space-between; margin-bottom: 5px; }
  .ws-name { font-size: 12px; color: var(--text2); font-weight: 500; }
  .ws-pct { font-size: 12px; font-weight: 700; }
  .ws-bar { height: 7px; background: var(--bg2); border-radius: 4px; overflow: hidden; }
  .ws-fill { height: 100%; border-radius: 4px; }

  /* SCHEDULE */
  .sched-list { display: flex; flex-direction: column; gap: 8px; }
  .sched-item { display: flex; align-items: center; gap: 12px; padding: 10px 13px; border-radius: var(--radius-sm); background: var(--surface2); border: 1px solid var(--border); cursor: pointer; transition: all .16s; }
  .sched-item:hover { border-color: var(--blue-mid); background: var(--blue-light); transform: translateX(2px); }
  .sched-item.urgent { border-left: 3px solid var(--red); }
  .sched-item.done { opacity: .42; }
  .sdot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
  .stime { font-size: 11px; color: var(--muted); width: 42px; flex-shrink: 0; font-weight: 600; }
  .stitle { flex: 1; font-size: 13px; color: var(--text2); }
  .swho { font-size: 10px; color: var(--muted); background: var(--surface); padding: 2px 7px; border-radius: 10px; border: 1px solid var(--border); font-weight: 600; }

  /* KANBAN */
  .kanban { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; }
  .kb-col { background: var(--surface2); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 14px; }
  .kb-hd { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
  .kb-t { font-size: 12px; font-weight: 700; }
  .kb-cnt { width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 700; background: var(--surface); border: 1px solid var(--border); color: var(--muted); }
  .kb-cards { display: flex; flex-direction: column; gap: 8px; }
  .kb-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 11px 13px; cursor: pointer; transition: all .16s; box-shadow: var(--shadow-sm); }
  .kb-card:hover { box-shadow: var(--shadow); transform: translateY(-2px); border-color: var(--blue-mid); }
  .kb-card-t { font-size: 12px; line-height: 1.5; margin-bottom: 9px; color: var(--text2); font-weight: 500; }
  .kb-card-m { display: flex; align-items: center; justify-content: space-between; }
  .kb-tags { display: flex; gap: 4px; flex-wrap: wrap; }
  .kb-tag { font-size: 10px; padding: 2px 7px; border-radius: 4px; font-weight: 700; }
  .kb-avs { display: flex; }
  .kav { width: 22px; height: 22px; border-radius: 50%; border: 2px solid var(--surface); font-size: 8px; font-weight: 700; display: flex; align-items: center; justify-content: center; margin-left: -6px; color: #fff; }
  .kav:first-child { margin-left: 0; }

  /* CALENDAR */
  .cal-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
  .cal-m { font-family: 'Plus Jakarta Sans', sans-serif; font-size: 15px; font-weight: 700; color: var(--text); }
  .cal-btns { display: flex; gap: 4px; }
  .cal-btn { width: 28px; height: 28px; border-radius: var(--radius-xs); background: var(--surface2); border: 1px solid var(--border); color: var(--muted); cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 14px; transition: all .15s; }
  .cal-btn:hover { background: var(--blue); color: #fff; border-color: var(--blue); }
  .cal-grid { display: grid; grid-template-columns: repeat(7,1fr); gap: 3px; }
  .cal-dn { text-align: center; font-size: 10px; font-weight: 700; color: var(--muted2); padding: 3px 0; }
  .cal-day { aspect-ratio: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; border-radius: 7px; font-size: 12px; font-weight: 500; cursor: pointer; transition: background .15s; position: relative; color: var(--text2); }
  .cal-day:hover { background: var(--blue-light); color: var(--blue); }
  .cal-day.oth { color: var(--muted2); }
  .cal-day.tod { background: var(--blue); color: #fff; font-weight: 700; }
  .cal-day.tod:hover { background: var(--blue-dark); }
  .cal-day.ev::after { content: ''; position: absolute; bottom: 2px; width: 4px; height: 4px; border-radius: 50%; background: var(--teal); }
  .cal-day.tod.ev::after { background: rgba(255,255,255,.8); }

  /* TODAY */
  .today-list { display: flex; flex-direction: column; gap: 9px; }
  .today-item { padding: 12px 14px; border-radius: var(--radius-sm); border-left: 3px solid; }
  .t-time { font-size: 10px; font-weight: 700; letter-spacing: .3px; margin-bottom: 4px; }
  .t-name { font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 3px; }
  .t-where { font-size: 11px; color: var(--muted); }

  /* TODO */
  .todo-add { display: flex; gap: 8px; margin-bottom: 12px; }
  .todo-inp { flex: 1; background: var(--surface2); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 8px 12px; color: var(--text); font-size: 13px; font-family: inherit; outline: none; transition: border-color .2s; }
  .todo-inp:focus { border-color: var(--blue); background: var(--surface); }
  .todo-list { display: flex; flex-direction: column; gap: 6px; max-height: 230px; overflow-y: auto; }
  .todo-item { display: flex; align-items: center; gap: 10px; padding: 9px 12px; border-radius: var(--radius-sm); background: var(--surface2); border: 1px solid transparent; transition: all .16s; cursor: pointer; }
  .todo-item:hover { border-color: var(--border); background: var(--surface); }
  .todo-item.done .todo-txt { text-decoration: line-through; color: var(--muted2); }
  .todo-chk { width: 17px; height: 17px; border-radius: 5px; border: 2px solid var(--border2); flex-shrink: 0; display: flex; align-items: center; justify-content: center; transition: all .15s; font-size: 10px; color: #fff; }
  .todo-item.done .todo-chk { background: var(--teal); border-color: var(--teal); }
  .todo-txt { flex: 1; font-size: 13px; color: var(--text2); }
  .todo-del { color: var(--muted2); cursor: pointer; font-size: 15px; padding: 0 3px; transition: color .15s; }
  .todo-del:hover { color: var(--red); }

  /* CHAT */
  .chat-msgs { height: 210px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; padding-bottom: 12px; }
  .chat-msg { display: flex; gap: 9px; }
  .chat-msg.me { flex-direction: row-reverse; }
  .chat-av { width: 30px; height: 30px; border-radius: 50%; font-size: 10px; font-weight: 700; color: #fff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
  .chat-in { display: flex; flex-direction: column; }
  .chat-msg.me .chat-in { align-items: flex-end; }
  .chat-nm { font-size: 10px; color: var(--muted); margin-bottom: 3px; }
  .chat-bbl { max-width: 240px; padding: 9px 13px; border-radius: 10px; font-size: 12px; line-height: 1.55; }
  .chat-msg:not(.me) .chat-bbl { background: var(--surface2); border: 1px solid var(--border); color: var(--text2); border-radius: 3px 10px 10px 10px; }
  .chat-msg.me .chat-bbl { background: var(--blue); color: #fff; border-radius: 10px 3px 10px 10px; }
  .chat-foot { display: flex; gap: 8px; padding-top: 12px; border-top: 1px solid var(--border); }
  .chat-inp { flex: 1; background: var(--surface2); border: 1px solid var(--border); border-radius: 20px; padding: 8px 14px; color: var(--text); font-size: 12px; font-family: inherit; outline: none; transition: border-color .2s; }
  .chat-inp:focus { border-color: var(--blue); background: #fff; }
  .chat-send { width: 34px; height: 34px; border-radius: 50%; background: var(--blue); color: #fff; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0; box-shadow: 0 2px 8px rgba(37,99,235,.30); transition: all .15s; }
  .chat-send:hover { background: var(--blue-dark); transform: scale(1.06); }

  /* FILES */
  .file-list { display: flex; flex-direction: column; gap: 7px; }
  .file-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; background: var(--surface2); border: 1px solid var(--border); border-radius: var(--radius-sm); cursor: pointer; transition: all .16s; }
  .file-item:hover { border-color: var(--blue-mid); background: var(--blue-light); transform: translateX(2px); }
  .file-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
  .file-name { font-size: 12px; font-weight: 600; color: var(--text2); }
  .file-meta { font-size: 10px; color: var(--muted); margin-top: 1px; }
  .file-sz { font-size: 11px; color: var(--muted); flex-shrink: 0; }

  /* TABLE */
  .ttable { width: 100%; border-collapse: collapse; }
  .ttable th { text-align: left; font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .7px; padding: 0 14px 10px; border-bottom: 2px solid var(--border); }
  .ttable td { padding: 11px 14px; border-bottom: 1px solid var(--border); font-size: 13px; vertical-align: middle; }
  .ttable tr:last-child td { border-bottom: none; }
  .ttable tbody tr { transition: background .15s; }
  .ttable tbody tr:hover td { background: var(--blue-light); }
  .pdot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; }
  .bwrap { width: 84px; height: 7px; background: var(--bg2); border-radius: 4px; overflow: hidden; }
  .bfill { height: 100%; border-radius: 4px; background: linear-gradient(90deg, var(--blue), #60a5fa); }
  .chip { display: inline-flex; align-items: center; gap: 5px; padding: 3px 9px; border-radius: 20px; font-size: 10px; font-weight: 700; }
  .chip-dot { width: 6px; height: 6px; border-radius: 50%; }

  /* SEARCH */
  .s-input { background: var(--surface2); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 7px 12px 7px 30px; color: var(--text); font-size: 12px; outline: none; width: 160px; font-family: inherit; transition: all .2s; }
  .s-input:focus { border-color: var(--blue); background: var(--surface); width: 190px; }

  /* SCROLLBAR */
  ::-webkit-scrollbar { width: 4px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: var(--border2); border-radius: 4px; }
  ::-webkit-scrollbar-thumb:hover { background: var(--blue-mid); }
</style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
  <div class="logo">
    <div class="logo-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
    </div>
    ProjectOS
  </div>

  <div class="nav-sec">
    <div class="nav-label">메인</div>
    <div class="nav-item active">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
      대시보드
    </div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
      전체 업무 <span class="nav-badge">42</span>
    </div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
      캘린더
    </div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
      팀 멤버
    </div>
  </div>

  <div class="sdiv"></div>

  <div class="nav-sec">
    <div class="nav-label">협업 도구</div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
      팀 채팅 <span class="nav-badge red">2</span>
    </div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z"/><polyline points="13 2 13 9 20 9"/></svg>
      파일 공유
    </div>
    <div class="nav-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93a10 10 0 010 14.14M4.93 4.93a10 10 0 000 14.14"/></svg>
      설정
    </div>
  </div>

  <div class="sidebar-bot">
    <div class="av-row">
      <div class="av">KJ</div>
      <div>
        <div class="av-name">김지호</div>
        <div class="av-role">프로젝트 매니저</div>
      </div>
    </div>
  </div>
</aside>

<!-- ══ MAIN ══ -->
<main class="main">

  <!-- TOPBAR -->
  <div class="topbar">
    <div>
      <div class="page-title">대시보드</div>
      <div class="page-sub">2026년 3월 29일 일요일 &nbsp;·&nbsp; ProjectOS v2.4 &nbsp;·&nbsp; 스프린트 12 진행 중</div>
    </div>
    <div class="topbar-r">
      <div class="notif-btn">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
        <div class="notif-dot"></div>
      </div>
      <button class="btn btn-g">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>검색
      </button>
      <button class="btn btn-p">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>새 업무
      </button>
    </div>
  </div>

  <!-- STAT CARDS -->
  <div class="stat-grid">
    <div class="stat-card" style="animation-delay:.00s">
      <div class="s-icon" style="background:var(--blue-soft)">
        <svg viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
      </div>
      <div><div class="s-label">전체 업무</div><div class="s-num" style="color:var(--blue)">42</div><div class="s-delta up">▲ 5 이번 주 추가</div></div>
    </div>
    <div class="stat-card" style="animation-delay:.05s">
      <div class="s-icon" style="background:var(--teal-light)">
        <svg viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
      </div>
      <div><div class="s-label">완료</div><div class="s-num" style="color:var(--teal)">27</div><div class="s-delta up">▲ 3 오늘 완료</div></div>
    </div>
    <div class="stat-card" style="animation-delay:.10s">
      <div class="s-icon" style="background:var(--orange-light)">
        <svg viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
      </div>
      <div><div class="s-label">진행 중</div><div class="s-num" style="color:var(--orange)">11</div><div class="s-delta fl">→ 변화 없음</div></div>
    </div>
    <div class="stat-card" style="animation-delay:.15s">
      <div class="s-icon" style="background:var(--red-light)">
        <svg viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
      </div>
      <div><div class="s-label">지연</div><div class="s-num" style="color:var(--red)">4</div><div class="s-delta dn">▼ 2 이번 주 해결</div></div>
    </div>
  </div>

  <!-- ROW 2 -->
  <div class="grid" style="margin-bottom:16px">

    <!-- 진행률 도넛 -->
    <div class="card c3">
      <div class="card-hd"><div class="card-t">프로젝트 진행률</div><span class="badge b-tl">On Track</span></div>
      <div class="donut-wrap">
        <div class="donut-svg">
          <svg width="148" height="148" viewBox="0 0 148 148">
            <circle cx="74" cy="74" r="56" fill="none" stroke="#e6edf8" stroke-width="14"/>
            <circle cx="74" cy="74" r="56" fill="none" stroke="url(#dg)" stroke-width="14"
              stroke-dasharray="351.9" stroke-dashoffset="87.97" stroke-linecap="round"
              transform="rotate(-90 74 74)" style="transition:stroke-dashoffset 1.2s ease"/>
            <defs>
              <linearGradient id="dg" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stop-color="#2563eb"/><stop offset="100%" stop-color="#60a5fa"/>
              </linearGradient>
            </defs>
          </svg>
          <div class="donut-label"><div class="donut-pct">75%</div><div class="donut-sub">완료율</div></div>
        </div>
        <div class="donut-leg">
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--blue)"></div><span class="leg-name">완료</span></div><span class="leg-val">27건</span></div>
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--orange)"></div><span class="leg-name">진행 중</span></div><span class="leg-val">11건</span></div>
          <div class="leg-row"><div class="leg-l"><div class="leg-dot" style="background:var(--red)"></div><span class="leg-name">지연</span></div><span class="leg-val">4건</span></div>
        </div>
      </div>
    </div>

    <!-- 주요 일정 -->
    <div class="card c5">
      <div class="card-hd"><div class="card-t">주요 일정</div><span class="badge b-or">5개 예정</span></div>
      <div class="sched-list">
        <div class="sched-item urgent"><div class="sdot" style="background:var(--red)"></div><div class="stime">09:00</div><div class="stitle">디자인 시스템 최종 검토 회의</div><div class="swho">UX팀</div></div>
        <div class="sched-item"><div class="sdot" style="background:var(--blue)"></div><div class="stime">11:30</div><div class="stitle">스프린트 플래닝 세션 #12</div><div class="swho">전체</div></div>
        <div class="sched-item"><div class="sdot" style="background:var(--violet)"></div><div class="stime">14:00</div><div class="stitle">클라이언트 데모 발표</div><div class="swho">PM팀</div></div>
        <div class="sched-item"><div class="sdot" style="background:var(--teal)"></div><div class="stime">16:00</div><div class="stitle">API 연동 테스트 완료 체크</div><div class="swho">개발팀</div></div>
        <div class="sched-item done"><div class="sdot" style="background:var(--muted2)"></div><div class="stime">08:00</div><div class="stitle">데일리 스탠드업</div><div class="swho">전체</div></div>
      </div>
    </div>

    <!-- 업무 현황 -->
    <div class="card c4">
      <div class="card-hd"><div class="card-t">업무 현황</div><span class="badge b-bl">이번 주</span></div>
      <div class="ws-list">
        <div><div class="ws-row"><span class="ws-name">프론트엔드 개발</span><span class="ws-pct" style="color:var(--blue)">88%</span></div><div class="ws-bar"><div class="ws-fill" style="width:88%;background:linear-gradient(90deg,var(--blue),#60a5fa)"></div></div></div>
        <div><div class="ws-row"><span class="ws-name">백엔드 API</span><span class="ws-pct" style="color:var(--teal)">72%</span></div><div class="ws-bar"><div class="ws-fill" style="width:72%;background:linear-gradient(90deg,var(--teal),#2dd4bf)"></div></div></div>
        <div><div class="ws-row"><span class="ws-name">QA 테스트</span><span class="ws-pct" style="color:var(--orange)">55%</span></div><div class="ws-bar"><div class="ws-fill" style="width:55%;background:linear-gradient(90deg,var(--orange),#fbbf24)"></div></div></div>
        <div><div class="ws-row"><span class="ws-name">UI 디자인</span><span class="ws-pct" style="color:var(--violet)">34%</span></div><div class="ws-bar"><div class="ws-fill" style="width:34%;background:linear-gradient(90deg,var(--violet),#a78bfa)"></div></div></div>
        <div><div class="ws-row"><span class="ws-name">배포 준비</span><span class="ws-pct" style="color:var(--muted)">20%</span></div><div class="ws-bar"><div class="ws-fill" style="width:20%;background:var(--muted2)"></div></div></div>
      </div>
    </div>
  </div>

  <!-- ROW 3: KANBAN -->
  <div class="card" style="margin-bottom:16px">
    <div class="card-hd">
      <div class="card-t">칸반 보드</div>
      <div style="display:flex;gap:6px"><span class="badge b-rd">TODO 5</span><span class="badge b-or">IN PROGRESS 4</span><span class="badge b-tl">DONE 6</span></div>
    </div>
    <div class="kanban">
      <div class="kb-col">
        <div class="kb-hd"><div class="kb-t" style="color:var(--red)">📋 Todo</div><div class="kb-cnt">5</div></div>
        <div class="kb-cards">
          <div class="kb-card"><div class="kb-card-t">로그인 페이지 반응형 수정</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-rd">긴급</span><span class="kb-tag b-bl">FE</span></div><div class="kb-avs"><div class="kav" style="background:var(--blue)">KJ</div><div class="kav" style="background:var(--orange)">PH</div></div></div></div>
          <div class="kb-card"><div class="kb-card-t">결제 모듈 오류 수정 (#FIX-204)</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-or">보통</span><span class="kb-tag b-tl">BE</span></div><div class="kb-avs"><div class="kav" style="background:var(--teal)">LM</div></div></div></div>
          <div class="kb-card"><div class="kb-card-t">다국어(i18n) 지원 계획 수립</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-bl">낮음</span></div><div class="kb-avs"><div class="kav" style="background:var(--violet)">JS</div></div></div></div>
          <div class="kb-card"><div class="kb-card-t">알림 푸시 서비스 연동</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-or">보통</span></div><div class="kb-avs"><div class="kav" style="background:var(--blue)">KJ</div></div></div></div>
          <div class="kb-card"><div class="kb-card-t">사용자 대시보드 UI 개선안</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-bl">낮음</span></div><div class="kb-avs"><div class="kav" style="background:var(--orange)">PH</div></div></div></div>
        </div>
      </div>
      <div class="kb-col">
        <div class="kb-hd"><div class="kb-t" style="color:var(--orange)">⚡ In Progress</div><div class="kb-cnt">4</div></div>
        <div class="kb-cards">
          <div class="kb-card" style="border-top:3px solid var(--orange)"><div class="kb-card-t">메인 대시보드 개발 (index.jsp
          )</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-rd">긴급</span><span class="kb-tag b-bl">FE</span></div><div class="kb-avs"><div class="kav" style="background:var(--blue)">KJ</div><div class="kav" style="background:var(--teal)">LM</div></div></div></div>
          <div class="kb-card" style="border-top:3px solid var(--orange)"><div class="kb-card-t">REST API 최적화 및 캐시 적용</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-or">보통</span></div><div class="kb-avs"><div class="kav" style="background:var(--teal)">LM</div></div></div></div>
          <div class="kb-card" style="border-top:3px solid var(--orange)"><div class="kb-card-t">사용자 권한 관리 시스템</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">정상</span></div><div class="kb-avs"><div class="kav" style="background:var(--violet)">JS</div><div class="kav" style="background:var(--blue)">KJ</div></div></div></div>
          <div class="kb-card" style="border-top:3px solid var(--orange)"><div class="kb-card-t">테스트 자동화 스크립트 작성</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-bl">낮음</span></div><div class="kb-avs"><div class="kav" style="background:var(--orange)">PH</div></div></div></div>
        </div>
      </div>
      <div class="kb-col">
        <div class="kb-hd"><div class="kb-t" style="color:var(--teal)">✅ Done</div><div class="kb-cnt">6</div></div>
        <div class="kb-cards">
          <div class="kb-card" style="opacity:.5"><div class="kb-card-t" style="text-decoration:line-through;color:var(--muted2)">DB 스키마 설계 완료</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">완료</span></div><div class="kb-avs"><div class="kav" style="background:var(--teal)">LM</div></div></div></div>
          <div class="kb-card" style="opacity:.5"><div class="kb-card-t" style="text-decoration:line-through;color:var(--muted2)">로그인·회원가입 구현</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">완료</span></div><div class="kb-avs"><div class="kav" style="background:var(--blue)">KJ</div></div></div></div>
          <div class="kb-card" style="opacity:.5"><div class="kb-card-t" style="text-decoration:line-through;color:var(--muted2)">Git 브랜치 전략 정의</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">완료</span></div><div class="kb-avs"><div class="kav" style="background:var(--violet)">JS</div></div></div></div>
          <div class="kb-card" style="opacity:.5"><div class="kb-card-t" style="text-decoration:line-through;color:var(--muted2)">와이어프레임 최종 확정</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">완료</span></div><div class="kb-avs"><div class="kav" style="background:var(--orange)">PH</div></div></div></div>
          <div class="kb-card" style="opacity:.5"><div class="kb-card-t" style="text-decoration:line-through;color:var(--muted2)">CI/CD 파이프라인 구축</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">완료</span></div><div class="kb-avs"><div class="kav" style="background:var(--teal)">LM</div></div></div></div>
          <div class="kb-card" style="opacity:.5"><div class="kb-card-t" style="text-decoration:line-through;color:var(--muted2)">요구사항 명세서 작성</div><div class="kb-card-m"><div class="kb-tags"><span class="kb-tag b-tl">완료</span></div><div class="kb-avs"><div class="kav" style="background:var(--blue)">KJ</div></div></div></div>
        </div>
      </div>
    </div>
  </div>

  <!-- ROW 4: Today + Calendar + Todo -->
  <div class="grid" style="margin-bottom:16px">

    <!-- 오늘의 일정 -->
    <div class="card c4">
      <div class="card-hd"><div class="card-t">오늘의 일정</div><span class="badge b-bl">3월 29일 · 일</span></div>
      <div class="today-list">
        <div class="today-item" style="background:var(--blue-light);border-color:var(--blue)">
          <div class="t-time" style="color:var(--blue)">09:00 — 10:00</div>
          <div class="t-name">디자인 시스템 검토 회의</div>
          <div class="t-where">📹 화상회의 · Zoom</div>
        </div>
        <div class="today-item" style="background:var(--orange-light);border-color:var(--orange)">
          <div class="t-time" style="color:var(--orange)">11:30 — 12:30</div>
          <div class="t-name">스프린트 플래닝 #12</div>
          <div class="t-where">🏢 오프라인 · 3층 세미나실</div>
        </div>
        <div class="today-item" style="background:var(--violet-light);border-color:var(--violet)">
          <div class="t-time" style="color:var(--violet)">14:00 — 15:00</div>
          <div class="t-name">클라이언트 데모 발표</div>
          <div class="t-where">💻 온라인 · Google Meet</div>
        </div>
        <div class="today-item" style="background:var(--teal-light);border-color:var(--teal)">
          <div class="t-time" style="color:var(--teal)">16:00 — 17:00</div>
          <div class="t-name">API 연동 테스트 체크</div>
          <div class="t-where">🛠 개발팀 · 슬랙 채널</div>
        </div>
      </div>
    </div>

    <!-- 캘린더 -->
    <div class="card c4">
      <div class="cal-top">
        <div class="cal-m">2026년 3월</div>
        <div class="cal-btns"><div class="cal-btn">‹</div><div class="cal-btn">›</div></div>
      </div>
      <div class="cal-grid">
        <div class="cal-dn">일</div><div class="cal-dn">월</div><div class="cal-dn">화</div><div class="cal-dn">수</div><div class="cal-dn">목</div><div class="cal-dn">금</div><div class="cal-dn">토</div>
        <div class="cal-day oth">23</div><div class="cal-day oth">24</div><div class="cal-day oth">25</div><div class="cal-day oth">26</div><div class="cal-day oth">27</div><div class="cal-day oth">28</div><div class="cal-day oth">29</div>
        <div class="cal-day">1</div><div class="cal-day ev">2</div><div class="cal-day">3</div><div class="cal-day ev">4</div><div class="cal-day">5</div><div class="cal-day ev">6</div><div class="cal-day">7</div>
        <div class="cal-day">8</div><div class="cal-day ev">9</div><div class="cal-day">10</div><div class="cal-day">11</div><div class="cal-day ev">12</div><div class="cal-day">13</div><div class="cal-day">14</div>
        <div class="cal-day">15</div><div class="cal-day">16</div><div class="cal-day ev">17</div><div class="cal-day">18</div><div class="cal-day">19</div><div class="cal-day">20</div><div class="cal-day">21</div>
        <div class="cal-day">22</div><div class="cal-day ev">23</div><div class="cal-day">24</div><div class="cal-day">25</div><div class="cal-day">26</div><div class="cal-day">27</div><div class="cal-day">28</div>
        <div class="cal-day tod ev">29</div><div class="cal-day">30</div><div class="cal-day">31</div>
        <div class="cal-day oth">1</div><div class="cal-day oth">2</div><div class="cal-day oth">3</div><div class="cal-day oth">4</div>
      </div>
    </div>

    <!-- Todo -->
    <div class="card c4">
      <div class="card-hd"><div class="card-t">나의 할 일</div><span class="badge b-or" id="todo-cnt">3개 남음</span></div>
      <div class="todo-add">
        <input class="todo-inp" id="todo-input" placeholder="새 할 일 입력 후 Enter...">
        <button class="btn btn-p" onclick="addTodo()" style="padding:8px 14px;font-size:16px;line-height:1">+</button>
      </div>
      <div class="todo-list" id="todo-list">
        <div class="todo-item" onclick="toggleTodo(this)">
          <div class="todo-chk"></div><div class="todo-txt">index.jsp 대시보드 완성</div><div class="todo-del" onclick="delTodo(event,this)">×</div>
        </div>
        <div class="todo-item" onclick="toggleTodo(this)">
          <div class="todo-chk"></div><div class="todo-txt">클라이언트 발표 자료 준비</div><div class="todo-del" onclick="delTodo(event,this)">×</div>
        </div>
        <div class="todo-item done" onclick="toggleTodo(this)">
          <div class="todo-chk">✓</div><div class="todo-txt">스프린트 회고 문서 작성</div><div class="todo-del" onclick="delTodo(event,this)">×</div>
        </div>
        <div class="todo-item" onclick="toggleTodo(this)">
          <div class="todo-chk"></div><div class="todo-txt">API 문서 업데이트</div><div class="todo-del" onclick="delTodo(event,this)">×</div>
        </div>
      </div>
    </div>
  </div>

  <!-- ROW 5: Chat + Files -->
  <div class="grid" style="margin-bottom:16px">
    <!-- 팀채팅 -->
    <div class="card c7">
      <div class="card-hd">
        <div class="card-t">팀 채팅</div>
        <div style="display:flex;align-items:center;gap:6px"><div style="width:7px;height:7px;border-radius:50%;background:var(--teal)"></div><span style="font-size:11px;color:var(--teal);font-weight:600">4명 접속 중</span></div>
      </div>
      <div class="chat-msgs" id="chat-messages">
        <div class="chat-msg">
          <div class="chat-av" style="background:var(--teal)">LM</div>
          <div class="chat-in"><div class="chat-nm">이민준 · 오전 9:02</div><div class="chat-bbl">안녕하세요! 오늘 스프린트 플래닝 준비됐나요?</div></div>
        </div>
        <div class="chat-msg me">
          <div class="chat-av" style="background:var(--blue)">KJ</div>
          <div class="chat-in"><div class="chat-nm">나 · 오전 9:05</div><div class="chat-bbl">네! 자료 다 준비했어요. 11:30 세미나실에서 봐요 😊</div></div>
        </div>
        <div class="chat-msg">
          <div class="chat-av" style="background:var(--violet)">JS</div>
          <div class="chat-in"><div class="chat-nm">장수연 · 오전 9:08</div><div class="chat-bbl">저도 준비 완료! 클라이언트 데모 자료도 공유드릴게요 📎</div></div>
        </div>
        <div class="chat-msg">
          <div class="chat-av" style="background:var(--orange)">PH</div>
          <div class="chat-in"><div class="chat-nm">박현우 · 오전 9:15</div><div class="chat-bbl">로그인 페이지 버그 찾았어요. PR 올릴게요!</div></div>
        </div>
        <div class="chat-msg me">
          <div class="chat-av" style="background:var(--blue)">KJ</div>
          <div class="chat-in"><div class="chat-nm">나 · 오전 9:18</div><div class="chat-bbl">수고했어요 현우씨! 리뷰 바로 달게요 👍</div></div>
        </div>
      </div>
      <div class="chat-foot">
        <input class="chat-inp" id="chat-input" placeholder="메시지를 입력하세요..." onkeydown="if(event.key==='Enter')sendChat()">
        <button class="chat-send" onclick="sendChat()">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
        </button>
      </div>
    </div>

    <!-- 파일 공유 -->
    <div class="card c5">
      <div class="card-hd">
        <div class="card-t">파일 공유</div>
        <button class="btn btn-g" style="font-size:11px;padding:5px 10px">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>업로드
        </button>
      </div>
      <div class="file-list">
        <div class="file-item"><div class="file-icon" style="background:var(--red-light)">📄</div><div style="flex:1"><div class="file-name">요구사항_명세서_v3.pdf</div><div class="file-meta">장수연 · 2시간 전</div></div><div class="file-sz">2.4 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--violet-light)">🎨</div><div style="flex:1"><div class="file-name">디자인시스템_최종.fig</div><div class="file-meta">박현우 · 5시간 전</div></div><div class="file-sz">18.7 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--blue-light)">📊</div><div style="flex:1"><div class="file-name">스프린트12_계획.xlsx</div><div class="file-meta">김지호 · 어제</div></div><div class="file-sz">384 KB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--orange-light)">📝</div><div style="flex:1"><div class="file-name">API_명세서_v2.1.docx</div><div class="file-meta">이민준 · 어제</div></div><div class="file-sz">1.1 MB</div></div>
        <div class="file-item"><div class="file-icon" style="background:var(--teal-light)">🎬</div><div style="flex:1"><div class="file-name">데모_시연영상_v2.mp4</div><div class="file-meta">김지호 · 3일 전</div></div><div class="file-sz">94.2 MB</div></div>
      </div>
    </div>
  </div>

  <!-- ROW 6: 전체 업무 목록 -->
  <div class="card">
    <div class="card-hd">
      <div class="card-t">전체 업무 목록</div>
      <div style="display:flex;gap:8px;align-items:center">
        <div style="position:relative">
          <svg style="position:absolute;left:9px;top:50%;transform:translateY(-50%);pointer-events:none" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          <input class="s-input" placeholder="업무 검색...">
        </div>
        <button class="btn btn-g" style="font-size:11px;padding:6px 11px">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>필터
        </button>
      </div>
    </div>
    <table class="ttable">
      <thead>
        <tr>
          <th style="width:30px">P</th><th>업무명</th><th>담당자</th><th>상태</th><th>마감일</th><th>진행률</th><th>태그</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><div class="pdot" style="background:var(--red)"></div></td>
          <td style="font-weight:500">로그인 페이지 반응형 수정</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--blue);width:24px;height:24px;font-size:9px">KJ</div><span style="color:var(--text2)">김지호</span></div></td>
          <td><span class="chip" style="background:var(--red-light);color:var(--red)"><div class="chip-dot" style="background:var(--red)"></div>지연</span></td>
          <td style="color:var(--red);font-weight:600;font-size:12px">2026.03.28</td>
          <td><div class="bwrap"><div class="bfill" style="width:40%"></div></div></td>
          <td><span class="badge b-bl">FE</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--red)"></div></td>
          <td style="font-weight:500">메인 대시보드 개발 (index.jsp)</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--blue);width:24px;height:24px;font-size:9px">KJ</div><span style="color:var(--text2)">김지호</span></div></td>
          <td><span class="chip" style="background:var(--orange-light);color:var(--orange)"><div class="chip-dot" style="background:var(--orange)"></div>진행 중</span></td>
          <td style="font-size:12px">2026.03.30</td>
          <td><div class="bwrap"><div class="bfill" style="width:80%"></div></div></td>
          <td><span class="badge b-bl">FE</span><span class="badge b-or" style="margin-left:3px">UI</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--orange)"></div></td>
          <td style="font-weight:500">REST API 최적화 및 캐시 적용</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--teal);width:24px;height:24px;font-size:9px">LM</div><span style="color:var(--text2)">이민준</span></div></td>
          <td><span class="chip" style="background:var(--orange-light);color:var(--orange)"><div class="chip-dot" style="background:var(--orange)"></div>진행 중</span></td>
          <td style="font-size:12px">2026.04.02</td>
          <td><div class="bwrap"><div class="bfill" style="width:60%"></div></div></td>
          <td><span class="badge b-tl">BE</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--orange)"></div></td>
          <td style="font-weight:500">결제 모듈 오류 수정 (#FIX-204)</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--teal);width:24px;height:24px;font-size:9px">LM</div><span style="color:var(--text2)">이민준</span></div></td>
          <td><span class="chip" style="background:var(--blue-soft);color:var(--blue)"><div class="chip-dot" style="background:var(--blue)"></div>대기</span></td>
          <td style="font-size:12px">2026.04.05</td>
          <td><div class="bwrap"><div class="bfill" style="width:10%"></div></div></td>
          <td><span class="badge b-tl">BE</span><span class="badge b-rd" style="margin-left:3px">BUG</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--blue)"></div></td>
          <td style="font-weight:500">사용자 권한 관리 시스템</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--violet);width:24px;height:24px;font-size:9px">JS</div><span style="color:var(--text2)">장수연</span></div></td>
          <td><span class="chip" style="background:var(--orange-light);color:var(--orange)"><div class="chip-dot" style="background:var(--orange)"></div>진행 중</span></td>
          <td style="font-size:12px">2026.04.08</td>
          <td><div class="bwrap"><div class="bfill" style="width:55%"></div></div></td>
          <td><span class="badge b-bl">FE</span><span class="badge b-tl" style="margin-left:3px">BE</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--muted2)"></div></td>
          <td style="font-weight:500">다국어(i18n) 지원 계획 수립</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--violet);width:24px;height:24px;font-size:9px">JS</div><span style="color:var(--text2)">장수연</span></div></td>
          <td><span class="chip" style="background:var(--blue-soft);color:var(--blue)"><div class="chip-dot" style="background:var(--blue)"></div>대기</span></td>
          <td style="font-size:12px">2026.04.15</td>
          <td><div class="bwrap"><div class="bfill" style="width:5%"></div></div></td>
          <td><span class="badge b-or">기획</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--muted2)"></div></td>
          <td style="font-weight:500">테스트 자동화 스크립트 작성</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--orange);width:24px;height:24px;font-size:9px">PH</div><span style="color:var(--text2)">박현우</span></div></td>
          <td><span class="chip" style="background:var(--orange-light);color:var(--orange)"><div class="chip-dot" style="background:var(--orange)"></div>진행 중</span></td>
          <td style="font-size:12px">2026.04.10</td>
          <td><div class="bwrap"><div class="bfill" style="width:30%"></div></div></td>
          <td><span class="badge b-vi">QA</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--teal)"></div></td>
          <td style="font-weight:500;color:var(--muted)">DB 스키마 설계 완료</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--teal);width:24px;height:24px;font-size:9px">LM</div><span style="color:var(--muted2)">이민준</span></div></td>
          <td><span class="chip" style="background:var(--teal-light);color:var(--teal)"><div class="chip-dot" style="background:var(--teal)"></div>완료</span></td>
          <td style="font-size:12px;color:var(--muted2)">2026.03.20</td>
          <td><div class="bwrap"><div class="bfill" style="width:100%"></div></div></td>
          <td><span class="badge b-tl">DB</span></td>
        </tr>
        <tr>
          <td><div class="pdot" style="background:var(--teal)"></div></td>
          <td style="font-weight:500;color:var(--muted)">CI/CD 파이프라인 구축</td>
          <td><div style="display:flex;align-items:center;gap:7px"><div class="kav" style="background:var(--teal);width:24px;height:24px;font-size:9px">LM</div><span style="color:var(--muted2)">이민준</span></div></td>
          <td><span class="chip" style="background:var(--teal-light);color:var(--teal)"><div class="chip-dot" style="background:var(--teal)"></div>완료</span></td>
          <td style="font-size:12px;color:var(--muted2)">2026.03.22</td>
          <td><div class="bwrap"><div class="bfill" style="width:100%"></div></div></td>
          <td><span class="badge b-or">DevOps</span></td>
        </tr>
      </tbody>
    </table>
  </div>

</main>

<script>
/* TODO */
function toggleTodo(el) {
  el.classList.toggle('done');
  el.querySelector('.todo-chk').textContent = el.classList.contains('done') ? '✓' : '';
  updateTodoCount();
}
function delTodo(e, btn) {
  e.stopPropagation();
  btn.closest('.todo-item').remove();
  updateTodoCount();
}
function addTodo() {
  const inp = document.getElementById('todo-input');
  const val = inp.value.trim();
  if (!val) return;
  const item = document.createElement('div');
  item.className = 'todo-item';
  item.onclick = function() { toggleTodo(this); };
  item.innerHTML = `<div class="todo-chk"></div><div class="todo-txt">${val}</div><div class="todo-del" onclick="delTodo(event,this)">×</div>`;
  document.getElementById('todo-list').appendChild(item);
  inp.value = '';
  updateTodoCount();
}
document.getElementById('todo-input').addEventListener('keydown', e => { if (e.key==='Enter') addTodo(); });
function updateTodoCount() {
  const all  = document.querySelectorAll('#todo-list .todo-item').length;
  const done = document.querySelectorAll('#todo-list .todo-item.done').length;
  document.getElementById('todo-cnt').textContent = (all - done) + '개 남음';
}

/* CHAT */
function sendChat() {
  const inp = document.getElementById('chat-input');
  const val = inp.value.trim();
  if (!val) return;
  const now  = new Date();
  const time = `오후 ${now.getHours()}:${String(now.getMinutes()).padStart(2,'0')}`;
  const msg  = document.createElement('div');
  msg.className = 'chat-msg me';
  msg.innerHTML = `<div class="chat-av" style="background:var(--blue)">KJ</div><div class="chat-in"><div class="chat-nm">나 · ${time}</div><div class="chat-bbl">${val}</div></div>`;
  const box = document.getElementById('chat-messages');
  box.appendChild(msg);
  box.scrollTop = box.scrollHeight;
  inp.value = '';
}
document.getElementById('chat-input').addEventListener('keydown', e => { if (e.key==='Enter') sendChat(); });
</script>
</body>
</html>
