create table member(
name varchar(20) NOT NULL,
id varchar(20) NOT NULL,
pw varchar(20) NOT NULL,
email varchar(30) NOT NULL,
tel varchar(15) NOT NULL
);

ALTER TABLE member
ADD PRIMARY KEY (id);

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
member_id VARCHAR(20) NOT NULL,
status VARCHAR(20) DEFAULT 'invited',
invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);

select * from project_member;
select * from member;
select * from board;