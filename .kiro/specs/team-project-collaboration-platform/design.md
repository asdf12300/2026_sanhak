# 기술 설계 문서: Team Project Collaboration Platform (ProjectOS)

## 개요 (Overview)

ProjectOS는 대학생 팀 프로젝트 협업을 위한 통합 웹 플랫폼이다. 기존에 구현된 로그인/회원가입 기능을 기반으로, 대시보드·캘린더·칸반보드·팀 채팅·회의록·파일 공유·알림 기능을 추가 구현한다. 또한 교직원(Instructor) 역할을 지원하여, 교직원은 팀장으로부터 초대받은 프로젝트를 읽기 전용으로 모니터링하고 피드백을 작성할 수 있다. 채팅은 교직원에게 비공개이다.

**기술 스택**
- Backend: Java Servlet (Jakarta EE 4.0), JSP
- Frontend: HTML5, CSS3, JavaScript (ES6+), Bootstrap 5
- Database: MySQL 5.x
- Libraries: cos.jar (파일 업로드), jstl-1.2.jar, mysql-connector-java-5.1.49.jar

**설계 원칙**
- 기존 MVC 패턴(controller / model / view) 유지 및 확장
- 각 기능 모듈은 독립적인 Servlet + DAO + DTO + JSP 세트로 구성
- 모든 보호된 페이지는 세션 인증 필터를 통해 접근 제어
- DB 연결은 기존 `DBConnection` 클래스를 재사용

---

## 아키텍처 (Architecture)

### 전체 구조

```
MVC Pattern
┌─────────────────────────────────────────────────────────┐
│  View (JSP / HTML / CSS / JS)                           │
│  dashboard.jsp, kanban.jsp, calendar.jsp, chat.jsp,     │
│  meeting.jsp, files.jsp, notification.jsp,              │
│  instructor_dashboard.jsp, feedback/*.jsp               │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP Request/Response
┌────────────────────▼────────────────────────────────────┐
│  Controller (Servlet)                                   │
│  DashboardServlet, ProjectServlet, KanbanServlet,       │
│  CalendarServlet, ChatServlet, MeetingServlet,          │
│  FileServlet, NotificationServlet, LogoutServlet,       │
│  InstructorDashboardServlet, FeedbackServlet            │
└────────────────────┬────────────────────────────────────┘
                     │ DAO 호출
┌────────────────────▼────────────────────────────────────┐
│  Model (DAO / DTO)                                      │
│  ProjectDAO/DTO, TaskDAO/DTO, CalendarDAO/DTO,          │
│  ChatDAO/DTO, MeetingDAO/DTO, FileDAO/DTO,              │
│  NotificationDAO/DTO, InstructorDAO/DTO,                │
│  FeedbackDAO/DTO                                        │
└────────────────────┬────────────────────────────────────┘
                     │ JDBC
┌────────────────────▼────────────────────────────────────┐
│  Database (MySQL)                                       │
│  member(+user_type), project, project_member, task,    │
│  schedule, chat_message, meeting_note, file_info,      │
│  notification, feedback                                 │
└─────────────────────────────────────────────────────────┘
```

### 요청 흐름

```
Browser → Servlet (doGet/doPost)
        → 세션 인증 확인 (AuthFilter)
        → DAO 메서드 호출
        → DBConnection.getConnection()
        → MySQL 쿼리 실행
        → DTO 반환
        → request.setAttribute() 또는 JSON 응답
        → JSP forward 또는 redirect
```

### 인증 필터 (AuthFilter)

`AuthFilter`는 `javax.servlet.Filter`를 구현하며, 로그인 세션이 없는 요청을 `login.jsp`로 리다이렉트한다. `/login`, `/JoinServlet`, `/resource/` 경로는 필터에서 제외한다. 또한 세션의 `userType` 값을 확인하여 교직원이 학생 전용 수정/삭제 엔드포인트에 접근하는 경우 403 오류를 반환한다. 교직원의 채팅 페이지(`/chat`) 접근도 차단한다.

---

## 컴포넌트 및 인터페이스 (Components and Interfaces)

### 패키지 구조

```
src/main/java/
├── controller/
│   ├── LoginServlet.java        (기존)
│   ├── JoinServlet.java         (기존)
│   ├── LogoutServlet.java
│   ├── DashboardServlet.java
│   ├── ProjectServlet.java
│   ├── KanbanServlet.java
│   ├── CalendarServlet.java
│   ├── ChatServlet.java
│   ├── MeetingServlet.java
│   ├── FileServlet.java
│   ├── NotificationServlet.java
│   ├── InstructorDashboardServlet.java
│   └── FeedbackServlet.java
├── model/
│   ├── DBConnection.java        (기존)
│   ├── LoginDAO.java            (기존)
│   ├── LoginDTO.java            (기존)
│   ├── ProjectDAO.java
│   ├── ProjectDTO.java
│   ├── TaskDAO.java
│   ├── TaskDTO.java
│   ├── CalendarDAO.java
│   ├── CalendarDTO.java
│   ├── ChatDAO.java
│   ├── ChatDTO.java
│   ├── MeetingDAO.java
│   ├── MeetingDTO.java
│   ├── FileDAO.java
│   ├── FileDTO.java
│   ├── NotificationDAO.java
│   ├── NotificationDTO.java
│   ├── InstructorDAO.java
│   ├── InstructorDTO.java
│   ├── FeedbackDAO.java
│   └── FeedbackDTO.java
└── filter/
    └── AuthFilter.java

src/main/WebContent/
├── index.jsp                    (기존 → 대시보드로 리다이렉트)
├── login.jsp                    (기존)
├── join.jsp                     (기존, User_Type 선택 UI 추가)
├── success.jsp                  (기존)
├── dashboard.jsp
├── instructor_dashboard.jsp
├── project/
│   ├── list.jsp
│   ├── create.jsp
│   └── detail.jsp
├── kanban.jsp
├── calendar.jsp
├── chat.jsp
├── meeting/
│   ├── list.jsp
│   ├── form.jsp
│   └── detail.jsp
├── files.jsp
├── feedback/
│   ├── form.jsp
│   └── list.jsp
└── resource/
    ├── css/
    │   ├── common.css
    │   ├── dashboard.css
    │   ├── kanban.css
    │   ├── calendar.css
    │   ├── chat.css
    │   └── files.css
    └── js/
        ├── kanban.js
        ├── calendar.js
        └── chat.js
```

### Servlet URL 매핑

| Servlet | URL 패턴 | 메서드 | 설명 |
|---|---|---|---|
| LogoutServlet | `/logout` | GET | 세션 무효화 후 login.jsp 리다이렉트 |
| DashboardServlet | `/dashboard` | GET | 대시보드 통계 조회 |
| ProjectServlet | `/project` | GET/POST | 프로젝트 목록/생성/팀원 관리 |
| KanbanServlet | `/kanban` | GET/POST | Task CRUD, 상태 변경 |
| CalendarServlet | `/calendar` | GET/POST | 일정 조회/등록 |
| ChatServlet | `/chat` | GET/POST | 메시지 조회/전송 |
| MeetingServlet | `/meeting` | GET/POST/DELETE | 회의록 CRUD |
| FileServlet | `/file` | GET/POST/DELETE | 파일 업로드/다운로드/삭제 |
| NotificationServlet | `/notification` | GET/POST | 알림 조회/읽음 처리 |
| InstructorDashboardServlet | `/instructor/dashboard` | GET | 교직원 전용 초대받은 프로젝트 목록 조회 |
| FeedbackServlet | `/feedback` | GET/POST | 피드백 조회/작성 |

### 주요 DAO 인터페이스

**ProjectDAO**
```java
List<ProjectDTO> getProjectsByMember(String memberId);
int createProject(ProjectDTO project);
boolean addMember(int projectId, String memberId, String role);
boolean removeMember(int projectId, String memberId);
boolean memberExists(String memberId);
```

**TaskDAO**
```java
List<TaskDTO> getTasksByProject(int projectId);
int createTask(TaskDTO task);
boolean updateTaskStatus(int taskId, String status);
boolean deleteTask(int taskId);
Map<String, Integer> getTaskStats(int projectId);
```

**ChatDAO**
```java
List<ChatDTO> getMessagesByProject(int projectId);
int saveMessage(ChatDTO message);
boolean pinMessage(int messageId);
```

**FileDAO**
```java
List<FileDTO> getFilesByProject(int projectId);
int saveFile(FileDTO file);
boolean deleteFile(int fileId);
FileDTO getFileById(int fileId);
```

**NotificationDAO**
```java
List<NotificationDTO> getUnreadByMember(String memberId);
int countUnread(String memberId);
boolean markAsRead(int notificationId);
int createNotification(NotificationDTO noti);
```

**InstructorDAO**
```java
List<ProjectDTO> getInvitedProjects(String instructorId);          // 초대받은 프로젝트 목록 (교직원 대시보드용)
ProjectDTO getProjectDetail(int projectId);                        // 특정 프로젝트 상세 (읽기 전용)
boolean inviteInstructor(int projectId, String instructorId);      // 교직원을 Observer로 등록
boolean isObserver(int projectId, String instructorId);            // Observer 여부 확인
```

**FeedbackDAO**
```java
int saveFeedback(FeedbackDTO feedback);                    // 피드백 저장
List<FeedbackDTO> getFeedbacksByProject(int projectId);    // 프로젝트별 피드백 목록 (작성 일시 내림차순)
```

---

## 데이터 모델 (Data Models)

### ERD 개요

```
member ──< project_member >── project
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
                  task       schedule    chat_message
                    │
               notification
                    │
                 member

project ──< meeting_note
project ──< file_info
project ──< feedback >── member(instructor)
```

### 테이블 정의

#### member (기존 확장)
```sql
CREATE TABLE member (
    id        VARCHAR(20) NOT NULL PRIMARY KEY,
    name      VARCHAR(20) NOT NULL,
    pw        VARCHAR(100) NOT NULL,
    email     VARCHAR(30) NOT NULL,
    tel       VARCHAR(15) NOT NULL,
    user_type ENUM('학생', '교직원') NOT NULL DEFAULT '학생'
);
```

#### project
```sql
CREATE TABLE project (
    project_id   INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    description  TEXT,
    deadline     DATE,
    created_by   VARCHAR(20) NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES member(id)
);
```

#### project_member
```sql
CREATE TABLE project_member (
    project_id  INT NOT NULL,
    member_id   VARCHAR(20) NOT NULL,
    role        ENUM('팀장', '팀원', 'Observer') NOT NULL DEFAULT '팀원',
    joined_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, member_id),
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (member_id) REFERENCES member(id)
);
```

#### task
```sql
CREATE TABLE task (
    task_id     INT AUTO_INCREMENT PRIMARY KEY,
    project_id  INT NOT NULL,
    title       VARCHAR(200) NOT NULL,
    assignee    VARCHAR(20),
    status      ENUM('To Do', 'In Progress', 'Done') NOT NULL DEFAULT 'To Do',
    deadline    DATE,
    sprint      VARCHAR(50),
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (assignee) REFERENCES member(id)
);
```

#### schedule
```sql
CREATE TABLE schedule (
    schedule_id  INT AUTO_INCREMENT PRIMARY KEY,
    project_id   INT NOT NULL,
    title        VARCHAR(200) NOT NULL,
    event_date   DATE NOT NULL,
    assignee     VARCHAR(20),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (assignee) REFERENCES member(id)
);
```

#### chat_message
```sql
CREATE TABLE chat_message (
    message_id  INT AUTO_INCREMENT PRIMARY KEY,
    project_id  INT NOT NULL,
    sender_id   VARCHAR(20) NOT NULL,
    content     TEXT NOT NULL,
    is_notice   TINYINT(1) DEFAULT 0,
    sent_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (sender_id) REFERENCES member(id)
);
```

#### meeting_note
```sql
CREATE TABLE meeting_note (
    note_id      INT AUTO_INCREMENT PRIMARY KEY,
    project_id   INT NOT NULL,
    title        VARCHAR(200) NOT NULL,
    meeting_date DATE NOT NULL,
    attendees    VARCHAR(500),
    content      TEXT,
    decisions    TEXT,
    author_id    VARCHAR(20) NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (author_id) REFERENCES member(id)
);
```

#### file_info
```sql
CREATE TABLE file_info (
    file_id       INT AUTO_INCREMENT PRIMARY KEY,
    project_id    INT NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    saved_name    VARCHAR(255) NOT NULL,
    uploader_id   VARCHAR(20) NOT NULL,
    file_size     BIGINT NOT NULL,
    uploaded_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (uploader_id) REFERENCES member(id)
);
```

#### notification
```sql
CREATE TABLE notification (
    noti_id     INT AUTO_INCREMENT PRIMARY KEY,
    member_id   VARCHAR(20) NOT NULL,
    message     VARCHAR(500) NOT NULL,
    is_read     TINYINT(1) DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member(id)
);
```

#### feedback
```sql
CREATE TABLE feedback (
    feedback_id    INT AUTO_INCREMENT PRIMARY KEY,
    project_id     INT NOT NULL,
    instructor_id  VARCHAR(20) NOT NULL,
    content        TEXT NOT NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES project(project_id),
    FOREIGN KEY (instructor_id) REFERENCES member(id)
);
```

### DTO 클래스 구조

**TaskDTO**
```java
public class TaskDTO {
    private int taskId;
    private int projectId;
    private String title;
    private String assignee;
    private String status;   // "To Do" | "In Progress" | "Done"
    private Date deadline;
    private String sprint;
    private Timestamp createdAt;
    // getters/setters
}
```

**ChatDTO**
```java
public class ChatDTO {
    private int messageId;
    private int projectId;
    private String senderId;
    private String senderName;
    private String content;
    private boolean isNotice;
    private Timestamp sentAt;
    // getters/setters
}
```

**NotificationDTO**
```java
public class NotificationDTO {
    private int notiId;
    private String memberId;
    private String message;
    private boolean isRead;
    private Timestamp createdAt;
    // getters/setters
}
```

**InstructorDTO**
```java
public class InstructorDTO {
    private String id;
    private String name;
    private String email;
    // getters/setters
}
```

**FeedbackDTO**
```java
public class FeedbackDTO {
    private int feedbackId;
    private int projectId;
    private String instructorId;
    private String instructorName;  // JOIN으로 조회
    private String content;
    private Timestamp createdAt;
    // getters/setters
}
```

---

## 정확성 속성 (Correctness Properties)

*속성(Property)이란 시스템의 모든 유효한 실행에서 참이어야 하는 특성 또는 동작이다. 즉, 시스템이 무엇을 해야 하는지에 대한 형식적 명세이다. 속성은 사람이 읽을 수 있는 명세와 기계가 검증할 수 있는 정확성 보장 사이의 다리 역할을 한다.*

### Property 1: 유효한 자격증명 로그인 시 세션 생성

*For any* 유효한 아이디와 비밀번호 쌍에 대해, 로그인 요청 후 세션에 `loginUser` 속성이 존재해야 한다.

**Validates: Requirements 1.1**

### Property 2: 잘못된 자격증명 로그인 시 오류 반환

*For any* DB에 존재하지 않는 아이디/비밀번호 조합에 대해, 로그인 시도 시 세션이 생성되지 않고 오류 응답이 반환되어야 한다.

**Validates: Requirements 1.2**

### Property 3: 입력 길이 유효성 검사

*For any* 아이디(5자 미만 또는 12자 초과) 또는 비밀번호(8자 미만 또는 20자 초과)에 대해, 회원가입 유효성 검사 함수는 해당 입력을 거부해야 한다. 반대로 범위 내의 임의 문자열은 통과해야 한다.

**Validates: Requirements 1.3, 1.4**

### Property 4: 중복 아이디 가입 차단

*For any* 이미 DB에 존재하는 아이디로 회원가입을 시도하면, 시스템은 가입을 거부하고 오류 메시지를 반환해야 한다.

**Validates: Requirements 1.5**

### Property 5: 로그인/로그아웃 라운드트립

*For any* 로그인된 세션에 대해, 로그아웃 요청 후 해당 세션에서 `loginUser` 속성이 존재하지 않아야 한다.

**Validates: Requirements 1.6**

### Property 6: 미인증 접근 차단

*For any* 보호된 URL에 대해, 세션에 `loginUser`가 없는 요청은 로그인 페이지로 리다이렉트되어야 한다.

**Validates: Requirements 1.7**

### Property 7: 프로젝트 생성 및 팀장 등록

*For any* 유효한 프로젝트 데이터(이름, 설명, 마감일)와 생성자 아이디에 대해, 프로젝트 생성 후 `project_member` 테이블에서 해당 생성자의 역할이 '팀장'으로 조회되어야 한다.

**Validates: Requirements 2.1**

### Property 8: 팀원 추가/제거 라운드트립

*For any* 프로젝트와 유효한 멤버 아이디에 대해, 팀원 추가 후 멤버 목록에 포함되어야 하며, 제거 후에는 목록에서 사라져야 한다.

**Validates: Requirements 2.2, 2.4**

### Property 9: 존재하지 않는 사용자 초대 차단

*For any* DB에 존재하지 않는 아이디로 팀원 초대를 시도하면, 시스템은 초대를 거부하고 오류를 반환해야 한다.

**Validates: Requirements 2.3**

### Property 10: 프로젝트 멤버 수 제한

*For any* 이미 20명의 멤버가 있는 프로젝트에 추가 멤버를 초대하면, 시스템은 초대를 거부해야 한다.

**Validates: Requirements 2.5**

### Property 11: 대시보드 통계 정확성

*For any* 프로젝트의 Task 집합에 대해, 통계 계산 함수는 전체 수, 완료 수, 진행 중 수, 지연 수를 정확히 반환해야 하며, 완료율은 `(완료 수 / 전체 수) * 100`과 일치해야 한다. Task 상태 변경 후 통계를 재조회하면 갱신된 값이 반환되어야 한다.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

### Property 12: 일정 저장/조회 라운드트립

*For any* 유효한 일정 데이터(제목, 날짜, 담당자)에 대해, 저장 후 해당 월 일정 조회 시 저장한 일정이 포함되어야 한다.

**Validates: Requirements 4.2**

### Property 13: 월별 일정 필터링

*For any* 연도/월 파라미터에 대해, 일정 조회 결과는 해당 연월에 속하는 일정만 포함해야 한다.

**Validates: Requirements 4.3**

### Property 14: 마감 임박 및 지연 알림 생성

*For any* Task에 대해, 마감일까지 3일 이하가 남은 경우 알림 생성 함수는 해당 담당자에게 알림을 생성해야 하며, 마감일이 오늘을 초과한 경우 지연 알림을 생성해야 한다.

**Validates: Requirements 4.4, 4.5, 9.2**

### Property 15: 일정 날짜 필드 필수 검증

*For any* 날짜 필드가 비어 있는 일정 저장 시도에 대해, 시스템은 저장을 거부해야 한다.

**Validates: Requirements 4.6**

### Property 16: 칸반 Task 상태 분류 및 컬럼 카운트

*For any* Task 집합에 대해, 상태별 분류 함수는 각 Task를 정확히 하나의 컬럼(To Do / In Progress / Done)에 배치해야 하며, 각 컬럼의 카운트는 해당 상태의 Task 수와 일치해야 한다.

**Validates: Requirements 5.1, 5.4**

### Property 17: Task 생성 시 초기 상태

*For any* 새로 생성된 Task에 대해, 초기 상태는 반드시 "To Do"여야 한다.

**Validates: Requirements 5.2**

### Property 18: Task 상태 변경 라운드트립

*For any* Task와 유효한 상태값(To Do / In Progress / Done)에 대해, 상태 변경 후 조회 시 변경된 상태가 반환되어야 하며, 대시보드 통계도 갱신되어야 한다.

**Validates: Requirements 5.3, 5.7**

### Property 19: Task 삭제

*For any* 존재하는 Task에 대해, 삭제 후 해당 프로젝트의 Task 목록 조회 시 해당 Task가 포함되지 않아야 한다.

**Validates: Requirements 5.5**

### Property 20: Sprint 필터링

*For any* Sprint 값에 대해, 해당 Sprint로 필터링한 Task 목록은 해당 Sprint에 속하는 Task만 포함해야 한다.

**Validates: Requirements 5.6**

### Property 21: 메시지 저장/조회 라운드트립

*For any* 유효한 채팅 메시지에 대해, 저장 후 해당 프로젝트의 메시지 목록 조회 시 해당 메시지가 포함되어야 한다.

**Validates: Requirements 6.1**

### Property 22: 메시지 표시 형식 및 시간 순서 정렬

*For any* 채팅 메시지 집합에 대해, 조회 결과의 각 메시지는 전송자 이름, 전송 시각, 내용을 포함해야 하며, 목록은 전송 시각 오름차순으로 정렬되어야 한다.

**Validates: Requirements 6.2, 6.4**

### Property 23: 공지 메시지 고정

*For any* 공지(is_notice=true)로 등록된 메시지에 대해, 메시지 목록 조회 시 공지 메시지는 일반 메시지보다 앞에 위치해야 한다.

**Validates: Requirements 6.3**

### Property 24: 빈 메시지 차단

*For any* 내용이 비어 있거나 공백만으로 구성된 메시지 전송 시도에 대해, 시스템은 저장을 거부해야 한다.

**Validates: Requirements 6.5**

### Property 25: 프로젝트별 데이터 격리

*For any* 두 개의 서로 다른 프로젝트에 대해, 프로젝트 A의 채팅 메시지/파일 조회 결과에 프로젝트 B의 데이터가 포함되지 않아야 한다.

**Validates: Requirements 6.6, 8.5**

### Property 26: 회의록 저장/조회 라운드트립

*For any* 유효한 회의록 데이터(제목, 날짜, 내용)에 대해, 저장 후 조회 시 저장한 전체 내용이 반환되어야 한다.

**Validates: Requirements 7.1, 7.3**

### Property 27: 회의록 날짜 내림차순 정렬

*For any* 회의록 집합에 대해, 목록 조회 결과는 회의 날짜 내림차순으로 정렬되어야 한다.

**Validates: Requirements 7.2**

### Property 28: 회의록 수정

*For any* 존재하는 회의록에 대해, 수정 후 조회 시 변경된 내용이 반환되어야 하며 `updated_at` 값이 갱신되어야 한다.

**Validates: Requirements 7.4**

### Property 29: 회의록 삭제

*For any* 존재하는 회의록에 대해, 삭제 후 목록 조회 시 해당 회의록이 포함되지 않아야 한다.

**Validates: Requirements 7.5**

### Property 30: 회의록 필수 필드 검증

*For any* 제목 또는 날짜가 비어 있는 회의록 저장 시도에 대해, 시스템은 저장을 거부해야 한다.

**Validates: Requirements 7.6**

### Property 31: 파일 업로드 및 메타데이터 저장

*For any* 유효한 파일(50MB 이하)에 대해, 업로드 후 파일 목록 조회 시 파일명, 업로더, 업로드 일시, 파일 크기가 포함된 레코드가 존재해야 한다.

**Validates: Requirements 8.1**

### Property 32: 파일 목록 날짜 내림차순 정렬

*For any* 파일 집합에 대해, 목록 조회 결과는 업로드 일시 내림차순으로 정렬되어야 한다.

**Validates: Requirements 8.2**

### Property 33: 파일 업로드/다운로드 라운드트립

*For any* 업로드된 파일에 대해, 다운로드 요청 시 업로드한 파일과 동일한 바이트 스트림이 반환되어야 한다.

**Validates: Requirements 8.3**

### Property 34: 파일 크기 제한

*For any* 크기가 50MB를 초과하는 파일 업로드 시도에 대해, 시스템은 업로드를 거부해야 한다.

**Validates: Requirements 8.4**

### Property 35: 파일 삭제

*For any* 존재하는 파일에 대해, 삭제 후 파일 목록 조회 시 해당 파일이 포함되지 않아야 하며 서버 저장 파일도 제거되어야 한다.

**Validates: Requirements 8.6**

### Property 36: Task 할당 알림 생성

*For any* Task가 특정 멤버에게 할당될 때, 해당 멤버의 미확인 알림 목록에 새 알림이 추가되어야 한다.

**Validates: Requirements 9.1**

### Property 37: 채팅 알림 카운트

*For any* 프로젝트에 새 메시지가 전송될 때, 해당 프로젝트 팀원의 미확인 알림 카운트가 증가해야 한다.

**Validates: Requirements 9.3**

### Property 38: 알림 읽음 처리 및 미확인 카운트

*For any* 미확인 알림에 대해, 읽음 처리 후 해당 알림의 `is_read` 값이 true가 되어야 하며, 미확인 알림 카운트가 감소해야 한다.

**Validates: Requirements 9.4, 9.5**

### Property 39: 교직원 계정 등록 시 user_type 저장

*For any* 회원가입 요청에서 User_Type이 "교직원"으로 선택된 경우, 가입 완료 후 member 테이블에서 해당 계정의 `user_type` 컬럼 값이 "교직원"으로 조회되어야 한다.

**Validates: Requirements 1.8, 10.1**

### Property 40: 교직원 로그인 시 세션 userType 기록 및 리다이렉트

*For any* `user_type`이 "교직원"인 계정으로 로그인하면, 세션에 `userType` 속성이 "교직원"으로 기록되어야 하며 교직원 대시보드(`/instructor/dashboard`)로 리다이렉트되어야 한다.

**Validates: Requirements 1.9, 10.2**

### Property 41: 교직원 대시보드 초대받은 프로젝트 조회

*For any* Instructor에 대해, 교직원 대시보드 조회 결과는 해당 Instructor가 Observer로 등록된 프로젝트만 포함해야 하며 각 항목에 프로젝트명, 팀원 수, 진행률이 포함되어야 한다.

**Validates: Requirements 10.2, 10.3**

### Property 41b: 교직원 초대(Observer 등록) 라운드트립

*For any* 팀장과 Instructor 아이디에 대해, 초대 요청 후 해당 Instructor의 초대받은 프로젝트 목록에 해당 프로젝트가 포함되어야 한다.

**Validates: Requirements 10.4**

### Property 41c: 교직원 채팅 접근 차단

*For any* 교직원 세션으로 채팅 페이지(`/chat`) 접근을 요청하면, 시스템은 해당 요청을 차단하고 채팅 내용을 반환하지 않아야 한다.

**Validates: Requirements 10.6**

### Property 42: 교직원의 팀 데이터 수정/삭제 차단

*For any* 교직원 세션으로 Task 생성·수정·삭제, 파일 삭제, 채팅 메시지 수정·삭제를 요청하면, 시스템은 해당 요청을 거부하고 오류 메시지를 반환해야 한다.

**Validates: Requirements 10.5, 10.8, 10.10**

### Property 43: 피드백 저장/조회 라운드트립

*For any* 교직원과 프로젝트에 대해, 피드백 저장 후 해당 프로젝트의 피드백 목록 조회 시 저장한 내용, 작성자 아이디, 작성 일시가 포함된 레코드가 존재해야 한다.

**Validates: Requirements 10.6**

### Property 44: 피드백 목록 작성 일시 내림차순 정렬

*For any* 피드백 집합에 대해, 프로젝트별 피드백 목록 조회 결과는 작성 일시 내림차순으로 정렬되어야 한다.

**Validates: Requirements 10.7**

### Property 45: 빈 피드백 차단

*For any* 내용이 비어 있거나 공백만으로 구성된 피드백 저장 시도에 대해, 시스템은 저장을 거부해야 한다.

**Validates: Requirements 10.9**

---

## 오류 처리 (Error Handling)

### 오류 분류 및 처리 전략

| 오류 유형 | 처리 방법 | 사용자 피드백 |
|---|---|---|
| DB 연결 실패 | `DBConnection`에서 RuntimeException 발생, Servlet에서 catch | 오류 메시지를 request attribute로 전달 후 JSP에 표시 |
| 유효성 검사 실패 | Servlet 또는 JS에서 검증 후 거부 | 해당 필드 옆에 인라인 오류 메시지 표시 |
| 인증 실패 | AuthFilter에서 리다이렉트 | login.jsp로 이동 |
| 파일 크기 초과 | FileServlet에서 cos.jar의 MultipartRequest 크기 제한 설정 | 오류 메시지 표시 |
| 존재하지 않는 리소스 | DAO에서 null 반환, Servlet에서 404 처리 | 오류 페이지 또는 메시지 표시 |
| 권한 없는 접근 | Servlet에서 세션 역할 확인 후 거부 | 403 오류 메시지 표시 |
| 교직원 수정/삭제 시도 | AuthFilter 또는 각 Servlet에서 `userType == "교직원"` 확인 후 거부 | "교직원은 팀 데이터를 수정하거나 삭제할 수 없습니다." 메시지 표시 |
| 교직원 채팅 접근 시도 | AuthFilter에서 `userType == "교직원"` && `/chat` 경로 확인 후 차단 | 403 오류 또는 교직원 대시보드로 리다이렉트 |
| 빈 피드백 저장 시도 | FeedbackServlet에서 content 공백 검증 후 거부 | "피드백 내용을 입력해 주세요." 메시지 표시 |

### 공통 오류 처리 패턴

모든 Servlet의 `doPost`/`doGet`은 최상위 try-catch로 감싸며, 예외 발생 시 `request.setAttribute("error", message)`로 오류를 전달하고 해당 JSP로 forward한다.

```java
try {
    // 비즈니스 로직
} catch (Exception e) {
    e.printStackTrace();
    request.setAttribute("error", "처리 중 오류가 발생했습니다.");
    request.getRequestDispatcher("error.jsp").forward(request, response);
}
```

### 세션 만료 처리

`AuthFilter`에서 세션 유효성을 확인하며, 세션이 없거나 만료된 경우 `login.jsp?expired=true`로 리다이렉트하여 만료 안내 메시지를 표시한다.

---

## 테스트 전략 (Testing Strategy)

### 이중 테스트 접근법

단위 테스트(Unit Test)와 속성 기반 테스트(Property-Based Test)를 함께 사용한다. 단위 테스트는 구체적인 예시와 경계값을 검증하고, 속성 기반 테스트는 임의의 입력에 대해 보편적 속성이 성립하는지 검증한다.

### 단위 테스트 (JUnit 5)

**대상**: DAO 메서드, 유효성 검사 로직, 통계 계산 함수

```
테스트 클래스 구조:
test/
├── model/
│   ├── LoginDAOTest.java
│   ├── TaskDAOTest.java
│   ├── ChatDAOTest.java
│   ├── MeetingDAOTest.java
│   ├── FileDAOTest.java
│   ├── NotificationDAOTest.java
│   ├── FeedbackDAOTest.java
│   └── InstructorDAOTest.java
└── util/
    └── ValidationUtilTest.java
```

단위 테스트 집중 영역:
- 특정 예시에 대한 올바른 동작 확인
- 경계값 (아이디 5자, 12자, 비밀번호 8자, 20자)
- 에러 조건 (null 입력, 빈 문자열, 50MB 초과 파일)
- 컴포넌트 간 통합 지점

### 속성 기반 테스트 (jqwik)

**라이브러리**: [jqwik](https://jqwik.net/) (JUnit 5 기반 Java PBT 라이브러리)

**설정**: 각 속성 테스트는 최소 100회 이상 반복 실행

```xml
<!-- pom.xml 또는 build.gradle에 추가 -->
<dependency>
    <groupId>net.jqwik</groupId>
    <artifactId>jqwik</artifactId>
    <version>1.8.1</version>
    <scope>test</scope>
</dependency>
```

**태그 형식**: 각 속성 테스트에 다음 형식의 주석을 포함한다.
`// Feature: team-project-collaboration-platform, Property {번호}: {속성 설명}`

**속성 테스트 예시**:

```java
// Feature: team-project-collaboration-platform, Property 3: 입력 길이 유효성 검사
@Property(tries = 100)
void idLengthValidation(@ForAll @StringLength(min = 1, max = 4) String shortId,
                         @ForAll @StringLength(min = 13, max = 50) String longId) {
    assertThat(ValidationUtil.isValidId(shortId)).isFalse();
    assertThat(ValidationUtil.isValidId(longId)).isFalse();
}

// Feature: team-project-collaboration-platform, Property 11: 대시보드 통계 정확성
@Property(tries = 100)
void dashboardStatsAccuracy(@ForAll List<@From("taskStatuses") String> statuses) {
    // Task 집합 생성 후 통계 계산 검증
    long done = statuses.stream().filter(s -> s.equals("Done")).count();
    long inProgress = statuses.stream().filter(s -> s.equals("In Progress")).count();
    TaskStats stats = DashboardUtil.calculateStats(statuses);
    assertThat(stats.getDoneCount()).isEqualTo(done);
    assertThat(stats.getInProgressCount()).isEqualTo(inProgress);
    assertThat(stats.getProgressPercent()).isEqualTo((int)(done * 100 / statuses.size()));
}

// Feature: team-project-collaboration-platform, Property 25: 프로젝트별 데이터 격리
@Property(tries = 100)
void projectDataIsolation(@ForAll int projectIdA, @ForAll int projectIdB) {
    Assume.that(projectIdA != projectIdB);
    List<ChatDTO> messagesA = chatDAO.getMessagesByProject(projectIdA);
    assertThat(messagesA).allMatch(m -> m.getProjectId() == projectIdA);
}
```

**각 Correctness Property에 대해 단일 속성 기반 테스트를 구현한다** (Property 1~45).

### 테스트 데이터 관리

- 테스트용 별도 MySQL 스키마 사용 (`projectos_test`)
- 각 테스트 메서드 실행 전 `@BeforeEach`로 테스트 데이터 초기화
- `DBConnection`의 `db.properties`에서 테스트 환경 분기 처리
