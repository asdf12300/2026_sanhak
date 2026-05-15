function joinCheck() {
    const name = document.getElementById('name').value.trim();
    const id = document.getElementById('id').value.trim();
    const pw = document.getElementById('pw').value.trim();
    const pwCheck = document.getElementById('pw_check').value.trim();
    const email = document.getElementById('email').value.trim();
    const role = document.querySelector('input[name="role"]:checked');

    if (name === "") {
        alert("이름을 입력해주세요.");
        return false;
    }

    if (id.length < 5 || id.length > 80) {
        alert("아이디를 확인해주세요.");
        return false;
    }

    if (pw.length < 8 || pw.length > 20) {
        alert("비밀번호는 8~20자 사이로 입력해주세요.");
        return false;
    }

    if (pw !== pwCheck) {
        alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        return false;
    }

    if (email === "") {
        alert("이메일을 입력해주세요.");
        return false;
    }

    if (!role) {
        alert("사용자 유형을 선택해주세요.");
        return false;
    }

    return true;
}
