package model;

public class FileShareDTO {
    private int id;
    private int projectId;
    private String uploaderId;
    private String uploaderName;
    private String originalName;
    private String savedName;
    private long fileSize;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public String getUploaderId() { return uploaderId; }
    public void setUploaderId(String uploaderId) { this.uploaderId = uploaderId; }

    public String getUploaderName() { return uploaderName; }
    public void setUploaderName(String uploaderName) { this.uploaderName = uploaderName; }

    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }

    public String getSavedName() { return savedName; }
    public void setSavedName(String savedName) { this.savedName = savedName; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    /** 파일 크기를 사람이 읽기 좋은 형태로 반환 */
    public String getFileSizeFormatted() {
        if (fileSize < 1024) return fileSize + " B";
        else if (fileSize < 1024 * 1024) return String.format("%.1f KB", fileSize / 1024.0);
        else return String.format("%.1f MB", fileSize / (1024.0 * 1024));
    }
}
