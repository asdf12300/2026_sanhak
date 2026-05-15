USE ProjectOS_DB;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS chat_room_members;
DROP TABLE IF EXISTS chat_rooms;
DROP TABLE IF EXISTS file_share;
DROP TABLE IF EXISTS feedback_comment;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS meeting_minutes_history;
DROP TABLE IF EXISTS meeting_minutes;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS project_member;
DROP TABLE IF EXISTS board;
DROP TABLE IF EXISTS folder;
DROP TABLE IF EXISTS member;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE member (
    id     VARCHAR(50)  NOT NULL,
    name   VARCHAR(50)  NOT NULL,
    pw     VARCHAR(100) NULL,
    email  VARCHAR(100) NOT NULL,
    role   VARCHAR(20)  NOT NULL DEFAULT 'student',
    PRIMARY KEY (id),
    UNIQUE KEY uk_member_email (email),
    CONSTRAINT chk_member_role CHECK (role IN ('student', 'professor'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_member_role ON member(role);

CREATE TABLE folder (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    owner_id   VARCHAR(50)  NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_folder_owner
        FOREIGN KEY (owner_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_folder_owner ON folder(owner_id);

CREATE TABLE board (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    content     TEXT,
    deadline    DATE,
    team_leader VARCHAR(50),
    folder_id   INT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_board_leader
        FOREIGN KEY (team_leader) REFERENCES member(id) ON DELETE SET NULL,
    CONSTRAINT fk_board_folder
        FOREIGN KEY (folder_id) REFERENCES folder(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_board_team_leader ON board(team_leader);
CREATE INDEX idx_board_folder ON board(folder_id);

CREATE TABLE project_member (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    member_id  VARCHAR(50) NOT NULL,
    role       VARCHAR(50) NOT NULL DEFAULT '팀원',
    status     VARCHAR(20) NOT NULL DEFAULT 'invited',
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_member_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    CONSTRAINT fk_project_member_member
        FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE,
    CONSTRAINT chk_project_member_status CHECK (status IN ('invited', 'accepted', 'rejected'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX uk_project_member_project_member ON project_member(project_id, member_id);
CREATE INDEX idx_project_member_member ON project_member(member_id);
CREATE INDEX idx_project_member_status ON project_member(status);

CREATE TABLE task (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    title      VARCHAR(200) NOT NULL,
    content    TEXT,
    assignee   VARCHAR(50) NULL,
    status     ENUM('To Do', 'In Progress', 'Done') NOT NULL DEFAULT 'To Do',
    deadline   DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    CONSTRAINT fk_task_assignee
        FOREIGN KEY (assignee) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_task_project ON task(project_id);
CREATE INDEX idx_task_assignee ON task(assignee);
CREATE INDEX idx_task_deadline ON task(deadline);
CREATE INDEX idx_task_status ON task(status);

CREATE TABLE calendar (
    event_id   INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    task_id    INT NULL,
    event_date DATE NOT NULL,
    event_time TIME NULL,
    title      VARCHAR(100) NOT NULL,
    category   TINYINT NOT NULL DEFAULT 0,
    memo       VARCHAR(500),
    assignee   VARCHAR(50) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_calendar_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    CONSTRAINT fk_calendar_task
        FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE SET NULL,
    CONSTRAINT fk_calendar_assignee
        FOREIGN KEY (assignee) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_calendar_project_date ON calendar(project_id, event_date);
CREATE INDEX idx_calendar_task ON calendar(task_id);
CREATE INDEX idx_calendar_assignee ON calendar(assignee);

CREATE TABLE meeting_minutes (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    project_id       INT NOT NULL,
    title            VARCHAR(200) NOT NULL,
    meeting_date     DATE NOT NULL,
    content          TEXT NOT NULL,
    created_by       VARCHAR(50) NOT NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified_by VARCHAR(50) NULL,
    last_modified_at TIMESTAMP NULL,
    CONSTRAINT fk_meeting_minutes_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    CONSTRAINT fk_meeting_minutes_created_by
        FOREIGN KEY (created_by) REFERENCES member(id) ON DELETE RESTRICT,
    CONSTRAINT fk_meeting_minutes_modified_by
        FOREIGN KEY (last_modified_by) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_meeting_minutes_project ON meeting_minutes(project_id);
CREATE INDEX idx_meeting_minutes_created_by ON meeting_minutes(created_by);

CREATE TABLE meeting_minutes_history (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    minutes_id     INT NOT NULL,
    modified_by    VARCHAR(50) NOT NULL,
    modified_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content_before TEXT,
    CONSTRAINT fk_meeting_minutes_history_minutes
        FOREIGN KEY (minutes_id) REFERENCES meeting_minutes(id) ON DELETE CASCADE,
    CONSTRAINT fk_meeting_minutes_history_modified_by
        FOREIGN KEY (modified_by) REFERENCES member(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_meeting_minutes_history_minutes ON meeting_minutes_history(minutes_id);

CREATE TABLE feedback (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    author_id  VARCHAR(50) NOT NULL,
    title      VARCHAR(200) NOT NULL,
    content    TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_author
        FOREIGN KEY (author_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_feedback_project ON feedback(project_id);
CREATE INDEX idx_feedback_author ON feedback(author_id);

CREATE TABLE feedback_comment (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    feedback_id INT NOT NULL,
    author_id   VARCHAR(50) NOT NULL,
    content     TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_comment_feedback
        FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_comment_author
        FOREIGN KEY (author_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_feedback_comment_feedback ON feedback_comment(feedback_id);
CREATE INDEX idx_feedback_comment_author ON feedback_comment(author_id);

CREATE TABLE file_share (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    project_id    INT NOT NULL,
    uploader_id   VARCHAR(50) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    saved_name    VARCHAR(255) NOT NULL,
    file_size     BIGINT NOT NULL DEFAULT 0,
    storage_type  VARCHAR(20) NOT NULL DEFAULT 's3',
    s3_bucket     VARCHAR(255) NULL,
    s3_key        VARCHAR(700) NULL,
    content_type  VARCHAR(255) NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_file_share_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    CONSTRAINT fk_file_share_uploader
        FOREIGN KEY (uploader_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_file_share_project ON file_share(project_id);
CREATE INDEX idx_file_share_uploader ON file_share(uploader_id);
CREATE INDEX idx_file_share_s3_key ON file_share(s3_key);

CREATE TABLE chat_rooms (
    room_id    INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    room_name  VARCHAR(100) NOT NULL,
    room_type  ENUM('personal', 'team') NOT NULL DEFAULT 'team',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_rooms_project
        FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_chat_rooms_project ON chat_rooms(project_id);
CREATE INDEX idx_chat_rooms_type ON chat_rooms(room_type);

CREATE TABLE chat_room_members (
    room_member_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id        INT NOT NULL,
    member_id      VARCHAR(50) NOT NULL,
    joined_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_at   TIMESTAMP NULL,
    CONSTRAINT fk_chat_room_members_room
        FOREIGN KEY (room_id) REFERENCES chat_rooms(room_id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_room_members_member
        FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE,
    UNIQUE KEY uk_chat_room_member (room_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_chat_room_members_member ON chat_room_members(member_id);
CREATE INDEX idx_chat_room_members_last_read ON chat_room_members(last_read_at);

CREATE TABLE chat_messages (
    message_id   INT AUTO_INCREMENT PRIMARY KEY,
    room_id      INT NOT NULL,
    sender_id    VARCHAR(50) NULL,
    sender_name  VARCHAR(50) NOT NULL,
    message      TEXT NOT NULL,
    message_type ENUM('text', 'file', 'system') NOT NULL DEFAULT 'text',
    sent_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_messages_room
        FOREIGN KEY (room_id) REFERENCES chat_rooms(room_id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_messages_sender
        FOREIGN KEY (sender_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_chat_messages_room ON chat_messages(room_id);
CREATE INDEX idx_chat_messages_sent_at ON chat_messages(sent_at);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);

-- Optional development seed data. Remove these rows on production if not needed.
INSERT INTO member (id, name, pw, email, role) VALUES
('yk123', '김유경', '1234', 'yk123@gmail.com', 'student'),
('dr123', '최대로', '1234', 'dr123@gmail.com', 'student'),
('sh123', '차소희', '1234', 'sh123@gmail.com', 'student'),
('cy123', '김채연', '1234', 'cy123@gmail.com', 'student'),
('mj123', '이민제', '1234', 'mj123@gmail.com', 'student')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    pw = VALUES(pw),
    email = VALUES(email),
    role = VALUES(role);

-- Existing server DB migration for chat system messages.
ALTER TABLE chat_messages MODIFY sender_id VARCHAR(50) NULL;

