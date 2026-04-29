create table member(
name varchar(20) NOT NULL,
id varchar(20) NOT NULL,
pw varchar(20) NOT NULL,
email varchar(30) NOT NULL
)

ALTER TABLE member ADD PRIMARY KEY (id);
INSERT INTO member VALUES ('홍길동', 'hong123', '1234', 'hong@email.com', '010-1234-5678');

CREATE TABLE board (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    deadline DATE,
    team_leader varchar(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE project_member (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    member_id VARCHAR(20) NOT NULL,     -- member.id 참조
    role VARCHAR(20) DEFAULT '팀원',     -- 팀원 역할
    status VARCHAR(20) DEFAULT 'invited', -- invited / accepted / rejected
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);
alter table project_member add column role varchar(50) default '팀원';

-- 기존 테이블에 role 컬럼이 없다면 추가
-- ALTER TABLE project_member ADD COLUMN role VARCHAR(20) DEFAULT '팀원' AFTER member_id;

CREATE TABLE calendar (
    event_id    INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    project_id  INT NOT NULL,
    task_id     INT NULL,                          -- ← task 연동 (없으면 NULL)
    event_date  DATE NOT NULL,
    event_time  TIME,
    title       VARCHAR(100) NOT NULL,
    category    TINYINT DEFAULT 0,                -- 0:일반 1:중요 2:개인 3:업무
    memo        VARCHAR(500),
    created_at  DATETIME DEFAULT NOW(),
    assignee    VARCHAR(50) NULL,                 -- 담당자
    FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id)    REFERENCES task(id)  ON DELETE SET NULL
);

CREATE TABLE task (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT NOT NULL,
  title      VARCHAR(200) NOT NULL,
  content    TEXT,
  assignee   VARCHAR(20),
  status     ENUM('To Do', 'In Progress', 'Done') NOT NULL DEFAULT 'To Do',
  deadline   DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES board(id)   ON DELETE CASCADE,
  FOREIGN KEY (assignee)   REFERENCES member(id)  ON DELETE SET NULL
);

ALTER TABLE calendar ADD COLUMN task_id INT NULL;
ALTER TABLE calendar ADD FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE SET NULL;

ALTER TABLE calendar ADD COLUMN assignee VARCHAR(50) NULL;

INSERT INTO calendar (event_date, project_id, event_time, title, category, memo)
VALUES ('2026-04-06', 1, '14:00:00', '팀 회의', 1, '주간 보고');

SELECT * FROM calendar
WHERE YEAR(event_date) = 2026
AND MONTH(event_date) = 4
ORDER BY event_date, event_time;

select * from project_member;
select * from member;
select * from board;
select * from calendar;
select * from task;

-- 회의록 테이블
CREATE TABLE meeting_minutes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    meeting_date DATE NOT NULL,
    content TEXT NOT NULL,
    created_by VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified_by VARCHAR(20),
    last_modified_at TIMESTAMP NULL,
    
    FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES member(id) ON DELETE RESTRICT,
    FOREIGN KEY (last_modified_by) REFERENCES member(id) ON DELETE SET NULL
);

-- 회의록 수정 이력 테이블
CREATE TABLE meeting_minutes_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    minutes_id INT NOT NULL,
    modified_by VARCHAR(20) NOT NULL,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content_before TEXT,
    
    
    FOREIGN KEY (minutes_id) REFERENCES meeting_minutes(id) ON DELETE CASCADE,
    FOREIGN KEY (modified_by) REFERENCES member(id) ON DELETE RESTRICT
);

	INSERT INTO member VALUES ('김유경', 'yk123', '1234', 'yk123@gmail.com');
	INSERT INTO member VALUES ('최대로', 'dr123', '1234', 'dr123@gmail.com');
	INSERT INTO member VALUES ('차소희', 'sh123', '1234', 'sh123@gmail.com');
	INSERT INTO member VALUES ('김채연', 'cy123', '1234', 'cy123@gmail.com');
	INSERT INTO member VALUES ('이민제', 'mj123', '1234', 'mj123@gmail.com');
	
	desc member;
	select * from member;
    
	CREATE TABLE folder (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    owner_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES member(id) ON DELETE CASCADE
);

ALTER TABLE board ADD COLUMN folder_id INT NULL;
ALTER TABLE board ADD FOREIGN KEY (folder_id) REFERENCES folder(id) ON DELETE SET NULL;
