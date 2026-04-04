package model;

import java.sql.Timestamp;

public class ProjectMemberDTO {

    private int pmNo;
    private int projectId;
    private String memberId;
    private String role;
    private String status;
    private Timestamp invitedAt;

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

    public Timestamp getInvitedAt() {
        return invitedAt;
    }

    public void setInvitedAt(Timestamp invitedAt) {
        this.invitedAt = invitedAt;
    }
}