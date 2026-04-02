<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프로젝트 생성</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-4">

  <h2 class="mb-4">프로젝트 생성</h2>

  <!-- 프로젝트 생성 폼 -->
  <form action="writeProcess" method="post">
    <div class="mb-3">
      <label class="form-label">프로젝트명</label>
      <input type="text" name="title" class="form-control" required>
    </div>

    <div class="mb-3">
      <label class="form-label">프로젝트 설명</label>
      <textarea name="content" class="form-control" rows="10" required></textarea>
    </div>

    <div class="mb-3">
      <label>프로젝트 기한</label>
      <input type="date" name="deadline" class="form-control">
    </div>

    <button type="submit" class="btn btn-primary">등록</button>
    <button type="button" class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#inviteModal">
      팀원 초대
    </button>
  </form>

  <!-- 팀원 초대 모달 -->
  <div class="modal fade" id="inviteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">팀원 초대</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <!-- 검색 -->
          <input type="text" id="searchInput" placeholder="회원 이름 검색" class="form-control mb-2">
          <button type="button" id="searchBtn" class="btn btn-outline-primary mb-3">검색</button>
          <div id="searchResults"></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-primary" id="sendInviteBtn">초대 보내기</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
        </div>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
 <script>
  const contextPath = '<%= request.getContextPath() %>';

  // 회원 검색
  document.getElementById("searchBtn").addEventListener("click", function() {
    const keyword = document.getElementById("searchInput").value.trim();
    if(!keyword){
      alert("검색어를 입력하세요.");
      return;
    }

    fetch(contextPath + '/searchMembers?keyword=' + encodeURIComponent(keyword))
      .then(res => res.json())
      .then(data => {
        const container = document.getElementById("searchResults");
        container.innerHTML = "";

        if(data.length === 0){
          container.innerHTML = "<p>검색 결과가 없습니다.</p>";
          return;
        }

        data.forEach(m => {
        	  const div = document.createElement("div");
        	  div.classList.add("form-check");
        	  div.innerHTML = 
        	    '<input class="form-check-input member-checkbox" type="checkbox" value="' + m.id + '" id="member' + m.id + '">' +
        	    '<span style="margin-left:8px;">' + m.name + '</span>';
        	  container.appendChild(div);
        	});
      })
      .catch(err => {
        alert("회원 검색 중 오류가 발생했습니다.");
      });
  });

  // 초대 버튼 클릭
  document.getElementById("sendInviteBtn").addEventListener("click", function() {
    const checked = Array.from(document.querySelectorAll(".member-checkbox:checked")).map(cb => cb.value);
    if(checked.length === 0){
      alert("팀원을 선택해주세요.");
      return;
    }

    fetch(contextPath + '/inviteMembers', {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({memberIds: checked})
    })
    .then(res => res.json())
    .then(data => {
      if(data.success){
        alert("팀원 초대가 완료되었습니다.");
        const modal = bootstrap.Modal.getInstance(document.getElementById('inviteModal'));
        modal.hide();
        document.getElementById("searchResults").innerHTML = "";
        document.getElementById("searchInput").value = "";
      } else {
        alert("초대 실패: " + data.message);
      }
    })
    .catch(err => {
      alert("초대 중 오류가 발생했습니다.");
    });
  });
</script>
</body>
</html>