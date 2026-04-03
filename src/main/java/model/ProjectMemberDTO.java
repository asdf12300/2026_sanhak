package model;

public class ProjectMemberDTO {
    private int pmNo;
    private int projectId;
    private String memberId;
    private String name;
    private String email;
    private String tel;
    private String role;
    private String status;
    private String invitedAt;

    public int getPmNo() {
        return pmNo;
    }

    public void setPmNo(int pmNo) {
        this.pmNo = pmNo;
    }

    public int getProjectId() {
        return projectId;
    }

    public void setProjectId(int projectId) {
        this.projectId = projectId;
    }

    public String getMemberId() {
        return memberId;
    }

    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTel() {
        return tel;
    }

    public void setTel(String tel) {
        this.tel = tel;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getInvitedAt() {
        return invitedAt;
    }

    public void setInvitedAt(String invitedAt) {
        this.invitedAt = invitedAt;
    }
}