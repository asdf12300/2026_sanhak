create table member(
name varchar(20) NOT NULL,
id varchar(20) NOT NULL,
pw varchar(20) NOT NULL,
email varchar(30) NOT NULL
)

-- 1. 외래키 제약 모두 제거
ALTER TABLE project_member DROP FOREIGN KEY project_member_ibfk_2;
ALTER TABLE task DROP FOREIGN KEY task_ibfk_2;
ALTER TABLE meeting_minutes DROP FOREIGN KEY meeting_minutes_ibfk_2;
ALTER TABLE meeting_minutes DROP FOREIGN KEY meeting_minutes_ibfk_3;
ALTER TABLE meeting_minutes_history DROP FOREIGN KEY meeting_minutes_history_ibfk_2;
ALTER TABLE feedback DROP FOREIGN KEY feedback_ibfk_2;
ALTER TABLE feedback_comment DROP FOREIGN KEY feedback_comment_ibfk_2;
ALTER TABLE folder DROP FOREIGN KEY folder_ibfk_1;

-- 2. member PRIMARY KEY 변경
ALTER TABLE member DROP PRIMARY KEY;
ALTER TABLE member ADD PRIMARY KEY (email);
ALTER TABLE member MODIFY id VARCHAR(20) NULL;
ALTER TABLE member MODIFY pw VARCHAR(20) NULL;

-- 2-2. 참조하는 테이블 데이터 전부 초기화
DELETE FROM feedback_comment;
DELETE FROM feedback;
DELETE FROM meeting_minutes_history;
DELETE FROM meeting_minutes;
DELETE FROM calendar;
DELETE FROM task;
DELETE FROM project_member;
DELETE FROM folder;
DELETE FROM board;
DELETE FROM member;

-- 3. 참조 컬럼을 email 기준으로 변경 후 외래키 재연결
ALTER TABLE project_member MODIFY member_id VARCHAR(30);
ALTER TABLE project_member ADD FOREIGN KEY (member_id) REFERENCES member(email) ON DELETE CASCADE;

ALTER TABLE task MODIFY assignee VARCHAR(30);
ALTER TABLE task ADD FOREIGN KEY (assignee) REFERENCES member(email) ON DELETE SET NULL;

ALTER TABLE meeting_minutes MODIFY created_by VARCHAR(30);
ALTER TABLE meeting_minutes MODIFY last_modified_by VARCHAR(30);
ALTER TABLE meeting_minutes ADD FOREIGN KEY (created_by) REFERENCES member(email) ON DELETE RESTRICT;
ALTER TABLE meeting_minutes ADD FOREIGN KEY (last_modified_by) REFERENCES member(email) ON DELETE SET NULL;

ALTER TABLE meeting_minutes_history MODIFY modified_by VARCHAR(30);
ALTER TABLE meeting_minutes_history ADD FOREIGN KEY (modified_by) REFERENCES member(email) ON DELETE RESTRICT;

ALTER TABLE feedback MODIFY author_id VARCHAR(30);
ALTER TABLE feedback ADD FOREIGN KEY (author_id) REFERENCES member(email) ON DELETE CASCADE;

ALTER TABLE feedback_comment MODIFY author_id VARCHAR(30);
ALTER TABLE feedback_comment ADD FOREIGN KEY (author_id) REFERENCES member(email) ON DELETE CASCADE;

ALTER TABLE folder MODIFY owner_id VARCHAR(30);
ALTER TABLE folder ADD FOREIGN KEY (owner_id) REFERENCES member(email) ON DELETE CASCADE;

-- 1. member 기본키 확인 (email이 PRI여야 함)
DESC member;

-- 2. 외래키 연결 확인
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'member'
AND TABLE_SCHEMA = 'sanhak';

-- 1. 각 테이블의 실제 외래키 이름 먼저 확인
SHOW CREATE TABLE project_member;
SHOW CREATE TABLE task;
SHOW CREATE TABLE meeting_minutes;
SHOW CREATE TABLE meeting_minutes_history;
SHOW CREATE TABLE feedback;
SHOW CREATE TABLE feedback_comment;
SHOW CREATE TABLE folder;

-- 2. 확인한 이름으로 외래키 제거
ALTER TABLE project_member DROP FOREIGN KEY /* project_member 테이블의 member_id 외래키 이름 */;
ALTER TABLE task DROP FOREIGN KEY /* task 테이블의 assignee 외래키 이름 */;
ALTER TABLE meeting_minutes DROP FOREIGN KEY /* meeting_minutes 테이블의 created_by 외래키 이름 */;
ALTER TABLE meeting_minutes DROP FOREIGN KEY /* meeting_minutes 테이블의 last_modified_by 외래키 이름 */;
ALTER TABLE meeting_minutes_history DROP FOREIGN KEY /* meeting_minutes_history 테이블의 modified_by 외래키 이름 */;
ALTER TABLE feedback DROP FOREIGN KEY /* feedback 테이블의 author_id 외래키 이름 */;
ALTER TABLE feedback_comment DROP FOREIGN KEY /* feedback_comment 테이블의 author_id 외래키 이름 */;
ALTER TABLE folder DROP FOREIGN KEY /* folder 테이블의 owner_id 외래키 이름 */;

-- 3. 데이터 초기화
DELETE FROM feedback_comment;
DELETE FROM feedback;
DELETE FROM meeting_minutes_history;
DELETE FROM meeting_minutes;
DELETE FROM calendar;
DELETE FROM task;
DELETE FROM project_member;
DELETE FROM folder;
DELETE FROM board;
DELETE FROM member;

-- 4. member PK를 id로 복원
ALTER TABLE member DROP PRIMARY KEY;
ALTER TABLE member MODIFY id VARCHAR(20) NOT NULL;
ALTER TABLE member MODIFY pw VARCHAR(20) NOT NULL;
ALTER TABLE member ADD PRIMARY KEY (id);

-- 5. 참조 컬럼 복원 및 외래키 재연결
ALTER TABLE project_member MODIFY member_id VARCHAR(20);
ALTER TABLE project_member ADD CONSTRAINT fk_pm_member FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE;

ALTER TABLE task MODIFY assignee VARCHAR(20);
ALTER TABLE task ADD CONSTRAINT fk_task_assignee FOREIGN KEY (assignee) REFERENCES member(id) ON DELETE SET NULL;

ALTER TABLE meeting_minutes MODIFY created_by VARCHAR(20);
ALTER TABLE meeting_minutes MODIFY last_modified_by VARCHAR(20);
ALTER TABLE meeting_minutes ADD CONSTRAINT fk_mm_created_by FOREIGN KEY (created_by) REFERENCES member(id) ON DELETE RESTRICT;
ALTER TABLE meeting_minutes ADD CONSTRAINT fk_mm_modified_by FOREIGN KEY (last_modified_by) REFERENCES member(id) ON DELETE SET NULL;

ALTER TABLE meeting_minutes_history MODIFY modified_by VARCHAR(20);
ALTER TABLE meeting_minutes_history ADD CONSTRAINT fk_mmh_modified_by FOREIGN KEY (modified_by) REFERENCES member(id) ON DELETE RESTRICT;

ALTER TABLE feedback MODIFY author_id VARCHAR(20);
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_author FOREIGN KEY (author_id) REFERENCES member(id) ON DELETE CASCADE;

ALTER TABLE feedback_comment MODIFY author_id VARCHAR(20);
ALTER TABLE feedback_comment ADD CONSTRAINT fk_fc_author FOREIGN KEY (author_id) REFERENCES member(id) ON DELETE CASCADE;

ALTER TABLE folder MODIFY owner_id VARCHAR(20);
ALTER TABLE folder ADD CONSTRAINT fk_folder_owner FOREIGN KEY (owner_id) REFERENCES member(id) ON DELETE CASCADE;


DESC member;


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

-- role에 교수 추가 // 기존에 있던 db 멤버들 기본값을 student로
ALTER TABLE member ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'student';
-- role 검증하는 거 추가 (제약조건을 넣어서 학생하고 교수만 확인할 수 있게 했음, 그 외에 다른 role이 들어오면 안됨)
ALTER TABLE member ADD CONSTRAINT chk_member_role CHECK (role IN ('student', 'professor'));
-- role 기반으로 조회할 때 인덱스 최적화 넣기 (지금은 몇개 회원만 있으면 금방 찾으르 수 있지만 천,만 단위로 검색시에 느려짐)
CREATE INDEX idx_member_role ON member(role);

-- =============================================
-- 피드백 기능
-- =============================================

-- 피드백 테이블 (교수가 작성)
CREATE TABLE feedback (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    project_id  INT NOT NULL,
    author_id   VARCHAR(20) NOT NULL,
    title       VARCHAR(200) NOT NULL,
    content     TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES board(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id)  REFERENCES member(id) ON DELETE CASCADE
);

-- 피드백 댓글 테이블 (팀원/팀장이 작성)
CREATE TABLE feedback_comment (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    feedback_id INT NOT NULL,
    author_id   VARCHAR(20) NOT NULL,
    content     TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id)   REFERENCES member(id)   ON DELETE CASCADE
);
   
--폴더 생성
	CREATE TABLE folder (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    owner_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES member(id) ON DELETE CASCADE
);

ALTER TABLE board ADD COLUMN folder_id INT NULL;
ALTER TABLE board ADD FOREIGN KEY (folder_id) REFERENCES folder(id) ON DELETE SET NULL;

show tables;
