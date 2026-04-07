const MONTHS = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
const DAYS = ['일','월','화','수','목','금','토'];

let today = new Date();
let curY = today.getFullYear();
let curM = today.getMonth();

let events = [];
let editIdx = -1;

// =====================
//  서버에서 데이터 불러오기
// =====================
function loadEvents() {
  const el = document.getElementById('evtProjectId');
  const projectId = el ? el.value : '';
  fetch(contextPath + "/event?action=list&projectId=" + projectId)
    .then(res => res.json())
    .then(data => {
      events = data;
      renderCal();
    })
    .catch(() => {
      events = [];
      renderCal();
    });
}

// =====================
// 캘린더 렌더링
// =====================
const monthSel = document.getElementById('monthSel');
const yearSel = document.getElementById('yearSel');

MONTHS.forEach((m,i)=>{
  const o=document.createElement('option');
  o.value=i;
  o.textContent=m;
  monthSel.appendChild(o);
});

for(let y=today.getFullYear()-10; y<=today.getFullYear()+10; y++){
  const o=document.createElement('option');
  o.value=y;
  o.textContent=y+'년';
  yearSel.appendChild(o);
}

function renderCal(){
  monthSel.value = curM;
  yearSel.value = curY;

  document.getElementById('calTitle').textContent =
    curY+'년 '+MONTHS[curM];

  const grid = document.getElementById('calGrid');
  grid.innerHTML='';

  DAYS.forEach(d=>{
    const el=document.createElement('div');
    el.className='day-label';
    el.textContent=d;
    grid.appendChild(el);
  });

  const first=new Date(curY,curM,1).getDay();
  const last=new Date(curY,curM+1,0).getDate();

  for(let i=0;i<first;i++){
    const empty=document.createElement('div');
    empty.className='day-cell';
    grid.appendChild(empty);
  }

  for(let d=1; d<=last; d++){
    const cell=document.createElement('div');
    cell.className='day-cell';

    const num=document.createElement('div');
    num.textContent=d;
    cell.appendChild(num);

    const dateStr = formatDate(curY,curM,d);

    const dayEvents = events.filter(e => e.date === dateStr);

    dayEvents.slice(0,2).forEach(e=>{
      const ev=document.createElement('div');
      ev.className='event-dot cat-'+e.cat;
      ev.textContent=(e.time?e.time.substring(0,5)+' ':'')+e.title;

      ev.onclick=(event)=>{
        event.stopPropagation();
        openEdit(events.indexOf(e));
      };

      cell.appendChild(ev);
    });

    if(dayEvents.length>2){
      const more=document.createElement('div');
      more.textContent='+'+(dayEvents.length-2);
      cell.appendChild(more);
    }

    cell.onclick=()=>openNew(curY,curM,d);
    grid.appendChild(cell);
  }
}

// =====================
// 날짜 포맷
// =====================
function formatDate(y,m,d){
  return y+'-'+String(m+1).padStart(2,'0')+'-'+String(d).padStart(2,'0');
}

// =====================
// 모달
// =====================
function openNew(y,m,d){
  editIdx=-1;

  document.getElementById('modalTitle').textContent='일정 등록';
  document.getElementById('evtTitle').value='';
  document.getElementById('evtDate').value=formatDate(y,m,d);
  document.getElementById('evtTime').value='';
  document.getElementById('evtCat').value='0';
  document.getElementById('evtMemo').value='';

  document.getElementById('delBtn').style.display='none';
  document.getElementById('modalBg').classList.add('open');
}

function openEdit(idx){
  editIdx=idx;
  const e=events[idx];

  document.getElementById('modalTitle').textContent='일정 수정';
  document.getElementById('evtTitle').value=e.title;
  document.getElementById('evtDate').value=e.date;
  document.getElementById('evtTime').value=e.time||'';
  document.getElementById('evtCat').value=e.cat;
  document.getElementById('evtMemo').value=e.memo||'';

  document.getElementById('delBtn').style.display='';
  document.getElementById('modalBg').classList.add('open');
}

function closeModal(){
  document.getElementById('modalBg').classList.remove('open');
}

// =====================
//  저장 / 수정
// =====================
document.getElementById('saveBtn').onclick=()=>{
  const title=document.getElementById('evtTitle').value.trim();
  if(!title)return;

  const params = new URLSearchParams({
    action: editIdx>=0 ? "update" : "save",
    title: title,
    project_id: document.getElementById('evtProjectId').value,
    date: document.getElementById('evtDate').value,
    time: document.getElementById('evtTime').value,
    cat: parseInt(document.getElementById('evtCat').value),
    memo: document.getElementById('evtMemo').value
  });

  if(editIdx>=0){
    params.append("id", events[editIdx].id);
  }

  fetch(contextPath + "/event", {
    method:"POST",
    headers:{"Content-Type":"application/x-www-form-urlencoded"},
    body:params
  })
  .then(()=> {
    closeModal();
    loadEvents();
  });
};

// =====================
//  삭제
// =====================
document.getElementById('delBtn').onclick=()=>{
  if(editIdx>=0){
    fetch(contextPath + "/event", {
      method:"POST",
      headers:{"Content-Type":"application/x-www-form-urlencoded"},
      body:new URLSearchParams({
        action:"delete",
        id: events[editIdx].id
      })
    })
    .then(()=>{
      closeModal();
      loadEvents();
    });
  }
};

// =====================
// 이벤트
// =====================
document.getElementById('cancelBtn').onclick=closeModal;
document.getElementById('modalBg').onclick=e=>{
  if(e.target.id==='modalBg') closeModal();
};

document.getElementById('prevBtn').onclick=()=>{
  curM--; if(curM<0){curM=11;curY--;} loadEvents();
};
document.getElementById('nextBtn').onclick=()=>{
  curM++; if(curM>11){curM=0;curY++;} loadEvents();
};
document.getElementById('todayBtn').onclick=()=>{
  curY=today.getFullYear();
  curM=today.getMonth();
  loadEvents();
};

monthSel.onchange=()=>{ curM=parseInt(monthSel.value); loadEvents(); };
yearSel.onchange=()=>{ curY=parseInt(yearSel.value); loadEvents(); };

// =====================
// 최초 실행
// =====================
loadEvents();