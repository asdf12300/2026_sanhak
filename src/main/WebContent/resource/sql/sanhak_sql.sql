create table member(
name varchar(20) NOT NULL,
id varchar(20) NOT NULL,
pw varchar(20) NOT NULL,
email varchar(30) NOT NULL,
tel varchar(15) NOT NULL
)

ALTER TABLE member DROP COLUMN tel;
desc member;
ALTER TABLE member ADD PRIMARY KEY (id);

INSERT INTO member VALUES ('홍길동', 'hong123', '1234', 'hong@email.com', '010-1234-5678');

select * from member;

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
    status VARCHAR(20) DEFAULT 'invited', -- invited / accepted / rejected
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);

<<<<<<< HEAD
CREATE TABLE calendar_event (
    event_id    INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
    event_date  DATE          NOT NULL,
    event_time  TIME,
    title       VARCHAR(100)  NOT NULL,
    category    TINYINT       DEFAULT 0,      -- 0:일반 1:중요 2:개인 3:업무 (숫자로 저장해야 DB 용량이 작아 효율적.)
    memo        VARCHAR(500),
    created_at  DATETIME      DEFAULT NOW()
);

INSERT INTO calendar_event (event_date, event_time, title, category, memo)
VALUES ('2026-04-06', '14:00:00', '팀 회의', 1, '주간 보고');

SELECT * FROM calendar_event
WHERE YEAR(event_date) = 2026
  AND MONTH(event_date) = 4
ORDER BY event_date, event_time;

=======
TRUNCATE TABLE board;
>>>>>>> 69901bb5220221456d0359ce3bbb4e1e1622da3e
select * from project_member;
select * from member;
select * from board;
