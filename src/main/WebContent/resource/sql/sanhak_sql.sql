create table member(
name varchar(20) NOT NULL,
id varchar(20) NOT NULL,
pw varchar(20) NOT NULL,
email varchar(30) NOT NULL,
tel varchar(15) NOT NULL
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
    member_id VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'invited',
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);
alter table project_member add column role varchar(50) default '팀원';

CREATE TABLE calendar (
    event_id    INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    project_id  INT NOT NULL,
    task_id     INT NULL,
    event_date  DATE NOT NULL,
    event_time  TIME,
    title       VARCHAR(100) NOT NULL,
    category    TINYINT DEFAULT 0,
    memo        VARCHAR(500),
    created_at  DATETIME DEFAULT NOW(),
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

INSERT INTO calendar (event_date, project_id, event_time, title, category, memo)
VALUES ('2026-04-06', 1, '14:00:00', '팀 회의', 1, '주간 보고');

SELECT * FROM calendar
WHERE YEAR(event_date) = 2026
AND MONTH(event_date) = 4
ORDER BY event_date, event_time;

--캘린더에 담당자를 지정하는 컬럼입니다. 실행해주세요--
ALTER TABLE calendar ADD COLUMN assignee VARCHAR(50) NULL;

TRUNCATE TABLE board;
truncate table project_member;

select * from project_member;
select * from member;
select * from board;
select * from calendar;
select * from task;

drop table task;