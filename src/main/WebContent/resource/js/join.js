function joinCheck() {
    const name = document.getElementById('name').value.trim();
    const id = document.getElementById('id').value.trim();
    const pw = document.getElementById('pw').value.trim();
    const pw_check = document.getElementById('pw_check').value.trim();
    const email = document.getElementById('email').value.trim();
    const role = document.querySelector('input[name="role"]:checked');

    if (name === "") {
        alert("이름을 입력해주세요.");
        return false;
    }

    if (id.length < 5 || id.length > 12) {
        alert("아이디는 5~12자 사이로 입력해주세요.");
        return false;
    }

    if (pw.length < 8 || pw.length > 20) {
        alert("비밀번호는 8~20자 사이로 입력해주세요.");
        return false;
    }

    if (pw !== pw_check) {
        alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        return false;
    }

    if (email === "") {
        alert("이메일을 입력해주세요.");
        return false;
    }

    if (!role) {
        alert("역할을 선택해주세요.");
        return false;
    }

    // 모든 검증 통과
    return true;
}
