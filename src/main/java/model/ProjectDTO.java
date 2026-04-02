package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class ProjectDTO {

	private String title;
	private String author;
	private String content;
	private int id;
	private Timestamp created_at;
	private String deadline;
	private String team_leader;

	
	public ProjectDTO() {
	}

	public ProjectDTO(String title, String author, String content) {
		this.title = title;
		this.author = author;
		this.content = content;
	}

	// Getter / Setter
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}
	
	public String getTeam_leader() { return team_leader; }
	public void setTeam_leader(String team_leader) { this.team_leader = team_leader; }

	public Timestamp getCreated_at() {
		return created_at;
	}

	public void setCreated_at(Timestamp created_at) {
		this.created_at = created_at;
	}

	public String getDeadline() {
		return deadline;
	}

	public void setDeadline(String deadline) {
		this.deadline = deadline;
	}

	// 분까지만 포맷해서 반환
	public String getFormattedCreatedAt() {
		if (created_at == null)
			return "";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		return sdf.format(created_at);
	}

}
