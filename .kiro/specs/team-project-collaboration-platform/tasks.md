# 구현 계획: Team Project Collaboration Platform (ProjectOS)

## 개요

기존 로그인/회원가입 기능을 기반으로, AuthFilter → 대시보드 → 프로젝트 관리 → 칸반보드 → 캘린더 → 채팅 → 회의록 → 파일 공유 → 알림 순서로 점진적으로 구현한다. 각 단계는 이전 단계의 결과물 위에 쌓이며, 고아 코드 없이 매 단계마다 동작 가능한 상태를 유지한다.

## Tasks

- [ ] 1. DB 스키마 및 공통 기반 구성
  - `resource/sql/sql.sql`에 project, project_member, task, schedule, chat_message, meeting_note, file_info, notification 테이블 DDL 추가 (member 테이블 PRIMARY KEY 포함 재정의)
  - member 테이블에 `user_type ENUM('학생', '교직원') NOT NULL DEFAULT '학생'` 컬럼 추가 (ALTER TABLE 또는 CREATE TABLE 재정의)
  - `resource/sql/sql.sql`에 feedback 테이블 DDL 추가: feedback_id, project_id, instructor_id, content, created_at
  - `src/main/java/util/ValidationUtil.java` 생성: 아이디(5~12자), 비밀번호(8~20자) 유효성 검사 정적 메서드 구현
  - `src/main/WebContent/resource/css/common.css` 생성: 공통 레이아웃, 내비게이션 바 스타일 정의
  - _Requirements: 1.3, 1.4, 1.8, 2.1, 10.1, 10.6_

  - [ ]* 1.1 ValidationUtil 속성 기반 테스트 작성
    - **Property 3: 입력 길이 유효성 검사**
    - **Validates: Requirements 1.3, 1.4**

- [ ] 2. 인증 필터 및 로그아웃 구현
  - [ ] 2.1 `filter/AuthFilter.java` 구현
    - `javax.servlet.Filter` 구현, `/login`, `/JoinServlet`, `/resource/` 경로 제외
    - 세션에 `loginUser` 없으면 `login.jsp?expired=true`로 리다이렉트
    - 세션의 `userType` 값이 "교직원"인 경우 Task 생성·수정·삭제, 파일 삭제, 채팅 수정·삭제 엔드포인트 접근 시 403 오류 반환
    - 세션의 `userType` 값이 "교직원"인 경우 `/chat` 경로 접근 차단
    - `web.xml`에 필터 매핑 등록 (`/*`)
    - _Requirements: 1.7, 10.6, 10.7, 10.10, 10.12_

  - [ ]* 2.2 AuthFilter 속성 기반 테스트 작성
    - **Property 6: 미인증 접근 차단**
    - **Validates: Requirements 1.7**

  - [ ]* 2.3 교직원 수정/삭제 차단 속성 기반 테스트 작성
    - **Property 42: 교직원의 팀 데이터 수정/삭제 차단**
    - **Validates: Requirements 10.7, 10.10, 10.12**

  - [ ] 2.4 `join.jsp` 수정: User_Type 선택 UI 추가
    - 라디오 버튼 또는 셀렉트 박스로 "학생" / "교직원" 선택 필드 추가
    - 기본값: "학생"
    - _Requirements: 1.8, 10.1_

  - [ ] 2.5 `JoinServlet.java` 수정: `user_type` 파라미터를 받아 member 테이블에 저장
    - _Requirements: 1.8, 10.1_

  - [ ]* 2.6 교직원 계정 등록 user_type 저장 속성 기반 테스트 작성
    - **Property 39: 교직원 계정 등록 시 user_type 저장**
    - **Validates: Requirements 1.8, 10.1**

  - [ ] 2.7 `LoginServlet.java` 수정: 로그인 성공 시 `user_type` 조회 후 세션에 `userType` 저장, 교직원이면 `/instructor/dashboard`로 리다이렉트
    - _Requirements: 1.9, 10.2_

  - [ ]* 2.8 교직원 로그인 리다이렉트 속성 기반 테스트 작성
    - **Property 40: 교직원 로그인 시 세션 userType 기록 및 리다이렉트**
    - **Validates: Requirements 1.9, 10.2**

  - [ ] 2.9 `controller/LogoutServlet.java` 구현
    - `@WebServlet("/logout")`, GET 요청 처리
    - `session.invalidate()` 후 `login.jsp`로 리다이렉트
    - _Requirements: 1.6_

  - [ ]* 2.10 로그아웃 라운드트립 속성 기반 테스트 작성
    - **Property 5: 로그인/로그아웃 라운드트립**
    - **Validates: Requirements 1.6**

  - [ ] 2.11 `login.jsp` 수정: `expired=true` 파라미터 수신 시 세션 만료 안내 메시지 표시
    - _Requirements: 1.7_

- [ ] 3. 체크포인트 - 인증 흐름 검증
  - 모든 테스트 통과 확인, 로그인 → 보호 페이지 접근 → 로그아웃 흐름이 정상 동작하는지 확인. 문제가 있으면 사용자에게 질문한다.

- [ ] 4. 프로젝트 생성 및 팀원 관리 구현
  - [ ] 4.1 `model/ProjectDTO.java` 생성
    - 필드: projectId, name, description, deadline, createdBy, createdAt, memberCount
    - getter/setter 구현
    - _Requirements: 2.1_

  - [ ] 4.2 `model/ProjectDAO.java` 구현
    - `getProjectsByMember(String memberId)`: project_member JOIN project 조회
    - `createProject(ProjectDTO project)`: INSERT 후 생성된 project_id 반환
    - `addMember(int projectId, String memberId, String role)`: project_member INSERT
    - `removeMember(int projectId, String memberId)`: project_member DELETE
    - `memberExists(String memberId)`: member 테이블 존재 여부 확인
    - `getMemberCount(int projectId)`: 현재 팀원 수 조회
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ]* 4.3 ProjectDAO 속성 기반 테스트 작성
    - **Property 7: 프로젝트 생성 및 팀장 등록**
    - **Validates: Requirements 2.1**

  - [ ]* 4.4 팀원 추가/제거 라운드트립 속성 기반 테스트 작성
    - **Property 8: 팀원 추가/제거 라운드트립**
    - **Validates: Requirements 2.2, 2.4**

  - [ ]* 4.5 존재하지 않는 사용자 초대 차단 속성 기반 테스트 작성
    - **Property 9: 존재하지 않는 사용자 초대 차단**
    - **Validates: Requirements 2.3**

  - [ ]* 4.6 프로젝트 멤버 수 제한 속성 기반 테스트 작성
    - **Property 10: 프로젝트 멤버 수 제한**
    - **Validates: Requirements 2.5**

  - [ ] 4.7 `controller/ProjectServlet.java` 구현
    - `@WebServlet("/project")`, GET(목록/상세), POST(생성/팀원 추가/제거) 처리
    - 팀원 초대 시 `memberExists` 확인, 20명 초과 시 오류 반환
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ] 4.8 프로젝트 JSP 뷰 구현
    - `project/list.jsp`: 내 프로젝트 목록 표시
    - `project/create.jsp`: 프로젝트 생성 폼
    - `project/detail.jsp`: 팀원 목록, 초대/제외 폼
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [ ] 5. 대시보드 구현
  - [ ] 5.1 `src/main/java/util/DashboardUtil.java` 구현
    - `calculateStats(List<String> statuses)`: 전체/완료/진행중/지연 수, 완료율 계산
    - 지연 판단: 마감일 < 오늘 AND 상태 != "Done"
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ]* 5.2 대시보드 통계 정확성 속성 기반 테스트 작성
    - **Property 11: 대시보드 통계 정확성**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

  - [ ] 5.3 `model/TaskDTO.java` 생성
    - 필드: taskId, projectId, title, assignee, status, deadline, sprint, createdAt
    - getter/setter 구현
    - _Requirements: 5.2_

  - [ ] 5.4 `model/TaskDAO.java` 구현
    - `getTasksByProject(int projectId)`: 전체 Task 조회
    - `createTask(TaskDTO task)`: INSERT, 초기 status = "To Do"
    - `updateTaskStatus(int taskId, String status)`: 상태 UPDATE
    - `deleteTask(int taskId)`: DELETE
    - `getTaskStats(int projectId)`: 상태별 카운트 반환
    - `getTasksByProjectAndSprint(int projectId, String sprint)`: Sprint 필터 조회
    - _Requirements: 3.1, 5.2, 5.3, 5.5, 5.6_

  - [ ] 5.5 `controller/DashboardServlet.java` 구현
    - `@WebServlet("/dashboard")`, GET 처리
    - 세션에서 loginUser 추출, 소속 프로젝트 조회, DashboardUtil로 통계 계산
    - `dashboard.jsp`로 forward
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 2.6_

  - [ ] 5.6 `dashboard.jsp` 구현
    - 통계 카드(전체/완료/진행중/지연), 진행률 차트(Bootstrap progress bar), 팀원별 완료율 progress bar
    - 공통 내비게이션 바 포함 (로그아웃, 알림 아이콘)
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ] 5.7 `index.jsp` 수정: 로그인 세션 있으면 `/dashboard`로 리다이렉트
    - _Requirements: 1.1_

- [ ] 6. 체크포인트 - 프로젝트/대시보드 검증
  - 모든 테스트 통과 확인, 프로젝트 생성 → 팀원 초대 → 대시보드 통계 표시 흐름 확인. 문제가 있으면 사용자에게 질문한다.

- [ ] 7. 칸반보드 구현
  - [ ] 7.1 `controller/KanbanServlet.java` 구현
    - `@WebServlet("/kanban")`, GET(Task 목록), POST(생성/상태변경/삭제) 처리
    - action 파라미터로 create/update/delete 분기
    - 상태 변경 후 알림 생성 로직 연동 (NotificationDAO 호출)
    - _Requirements: 5.1, 5.2, 5.3, 5.5, 5.6, 5.7_

  - [ ]* 7.2 Task 초기 상태 속성 기반 테스트 작성
    - **Property 17: Task 생성 시 초기 상태**
    - **Validates: Requirements 5.2**

  - [ ]* 7.3 Task 상태 변경 라운드트립 속성 기반 테스트 작성
    - **Property 18: Task 상태 변경 라운드트립**
    - **Validates: Requirements 5.3, 5.7**

  - [ ]* 7.4 Task 삭제 속성 기반 테스트 작성
    - **Property 19: Task 삭제**
    - **Validates: Requirements 5.5**

  - [ ]* 7.5 Sprint 필터링 속성 기반 테스트 작성
    - **Property 20: Sprint 필터링**
    - **Validates: Requirements 5.6**

  - [ ]* 7.6 칸반 컬럼 분류 속성 기반 테스트 작성
    - **Property 16: 칸반 Task 상태 분류 및 컬럼 카운트**
    - **Validates: Requirements 5.1, 5.4**

  - [ ] 7.7 `kanban.jsp` 및 `resource/js/kanban.js` 구현
    - 3컬럼 레이아웃(To Do / In Progress / Done), 컬럼 헤더에 Task 수 표시
    - Task 카드 드래그 또는 버튼으로 상태 변경 (fetch POST)
    - Sprint 필터 드롭다운
    - Task 생성 모달 폼 (제목, 담당자, 마감일, Sprint)
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 8. 캘린더 구현
  - [ ] 8.1 `model/CalendarDTO.java` 생성
    - 필드: scheduleId, projectId, title, eventDate, assignee, createdAt
    - getter/setter 구현
    - _Requirements: 4.2_

  - [ ] 8.2 `model/CalendarDAO.java` 구현
    - `getSchedulesByMonth(int projectId, int year, int month)`: 월별 일정 조회
    - `saveSchedule(CalendarDTO schedule)`: INSERT, 날짜 필드 필수 검증
    - _Requirements: 4.2, 4.3, 4.6_

  - [ ]* 8.3 일정 저장/조회 라운드트립 속성 기반 테스트 작성
    - **Property 12: 일정 저장/조회 라운드트립**
    - **Validates: Requirements 4.2**

  - [ ]* 8.4 월별 일정 필터링 속성 기반 테스트 작성
    - **Property 13: 월별 일정 필터링**
    - **Validates: Requirements 4.3**

  - [ ]* 8.5 일정 날짜 필드 필수 검증 속성 기반 테스트 작성
    - **Property 15: 일정 날짜 필드 필수 검증**
    - **Validates: Requirements 4.6**

  - [ ] 8.6 `controller/CalendarServlet.java` 구현
    - `@WebServlet("/calendar")`, GET(월별 조회), POST(일정 저장) 처리
    - year/month 파라미터 없으면 현재 월 기본값 사용
    - _Requirements: 4.1, 4.2, 4.3, 4.6_

  - [ ] 8.7 `calendar.jsp` 및 `resource/js/calendar.js` 구현
    - 월별 달력 그리드 렌더링 (JavaScript로 동적 생성)
    - 이전/다음 월 버튼, 일정 등록 폼 (제목, 날짜, 담당자)
    - 날짜 필드 빈 값 클라이언트 검증
    - _Requirements: 4.1, 4.2, 4.3, 4.6_

- [ ] 9. 알림 기반 구현 (Task 할당 및 마감 임박)
  - [ ] 9.1 `model/NotificationDTO.java` 생성
    - 필드: notiId, memberId, message, isRead, createdAt
    - getter/setter 구현
    - _Requirements: 9.1_

  - [ ] 9.2 `model/NotificationDAO.java` 구현
    - `getUnreadByMember(String memberId)`: 미확인 알림 목록 조회
    - `countUnread(String memberId)`: 미확인 알림 수 반환
    - `markAsRead(int notificationId)`: is_read = 1 UPDATE
    - `createNotification(NotificationDTO noti)`: INSERT
    - `createDeadlineNotifications()`: 마감 3일 이하 Task 담당자에게 알림 생성
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

  - [ ]* 9.3 Task 할당 알림 속성 기반 테스트 작성
    - **Property 36: Task 할당 알림 생성**
    - **Validates: Requirements 9.1**

  - [ ]* 9.4 마감 임박/지연 알림 속성 기반 테스트 작성
    - **Property 14: 마감 임박 및 지연 알림 생성**
    - **Validates: Requirements 4.4, 4.5, 9.2**

  - [ ]* 9.5 알림 읽음 처리 속성 기반 테스트 작성
    - **Property 38: 알림 읽음 처리 및 미확인 카운트**
    - **Validates: Requirements 9.4, 9.5**

  - [ ] 9.6 `controller/NotificationServlet.java` 구현
    - `@WebServlet("/notification")`, GET(미확인 목록 + 카운트 JSON 반환), POST(읽음 처리)
    - _Requirements: 9.4, 9.5_

  - [ ] 9.7 `common.css` 및 내비게이션 바에 알림 배지 연동
    - 페이지 로드 시 `/notification` GET 호출하여 미확인 수 배지 표시
    - _Requirements: 9.5_

- [ ] 10. 체크포인트 - 칸반/캘린더/알림 검증
  - 모든 테스트 통과 확인, Task 생성 → 상태 변경 → 알림 발생 → 캘린더 일정 등록 흐름 확인. 문제가 있으면 사용자에게 질문한다.

- [ ] 11. 팀 채팅 구현
  - [ ] 11.1 `model/ChatDTO.java` 생성
    - 필드: messageId, projectId, senderId, senderName, content, isNotice, sentAt
    - getter/setter 구현
    - _Requirements: 6.1_

  - [ ] 11.2 `model/ChatDAO.java` 구현
    - `getMessagesByProject(int projectId)`: 공지 우선, 전송 시각 오름차순 정렬 조회
    - `saveMessage(ChatDTO message)`: 빈 content 거부, INSERT
    - `pinMessage(int messageId)`: is_notice = 1 UPDATE
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

  - [ ]* 11.3 메시지 저장/조회 라운드트립 속성 기반 테스트 작성
    - **Property 21: 메시지 저장/조회 라운드트립**
    - **Validates: Requirements 6.1**

  - [ ]* 11.4 메시지 표시 형식 및 시간 순서 정렬 속성 기반 테스트 작성
    - **Property 22: 메시지 표시 형식 및 시간 순서 정렬**
    - **Validates: Requirements 6.2, 6.4**

  - [ ]* 11.5 공지 메시지 고정 속성 기반 테스트 작성
    - **Property 23: 공지 메시지 고정**
    - **Validates: Requirements 6.3**

  - [ ]* 11.6 빈 메시지 차단 속성 기반 테스트 작성
    - **Property 24: 빈 메시지 차단**
    - **Validates: Requirements 6.5**

  - [ ]* 11.7 프로젝트별 데이터 격리 속성 기반 테스트 작성
    - **Property 25: 프로젝트별 데이터 격리**
    - **Validates: Requirements 6.6, 8.5**

  - [ ] 11.8 `controller/ChatServlet.java` 구현
    - `@WebServlet("/chat")`, GET(메시지 목록 JSON), POST(메시지 전송/공지 설정)
    - 메시지 전송 시 프로젝트 팀원 전체에게 알림 생성 (NotificationDAO 호출)
    - _Requirements: 6.1, 6.2, 6.3, 6.5, 6.6, 9.3_

  - [ ]* 11.9 채팅 알림 카운트 속성 기반 테스트 작성
    - **Property 37: 채팅 알림 카운트**
    - **Validates: Requirements 9.3**

  - [ ] 11.10 `chat.jsp` 및 `resource/js/chat.js` 구현
    - 메시지 목록 영역 (공지 상단 고정, 일반 메시지 시간순)
    - 메시지 입력창: 빈 값이면 전송 버튼 비활성화 (JS)
    - 3초 폴링으로 새 메시지 조회 (fetch GET)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 12. 회의록 구현
  - [ ] 12.1 `model/MeetingDTO.java` 생성
    - 필드: noteId, projectId, title, meetingDate, attendees, content, decisions, authorId, createdAt, updatedAt
    - getter/setter 구현
    - _Requirements: 7.1_

  - [ ] 12.2 `model/MeetingDAO.java` 구현
    - `getMeetingsByProject(int projectId)`: 회의 날짜 내림차순 조회
    - `getMeetingById(int noteId)`: 단건 조회
    - `saveMeeting(MeetingDTO meeting)`: 제목/날짜 필수 검증 후 INSERT
    - `updateMeeting(MeetingDTO meeting)`: UPDATE, updated_at 자동 갱신
    - `deleteMeeting(int noteId)`: DELETE
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [ ]* 12.3 회의록 저장/조회 라운드트립 속성 기반 테스트 작성
    - **Property 26: 회의록 저장/조회 라운드트립**
    - **Validates: Requirements 7.1, 7.3**

  - [ ]* 12.4 회의록 날짜 내림차순 정렬 속성 기반 테스트 작성
    - **Property 27: 회의록 날짜 내림차순 정렬**
    - **Validates: Requirements 7.2**

  - [ ]* 12.5 회의록 수정 속성 기반 테스트 작성
    - **Property 28: 회의록 수정**
    - **Validates: Requirements 7.4**

  - [ ]* 12.6 회의록 삭제 속성 기반 테스트 작성
    - **Property 29: 회의록 삭제**
    - **Validates: Requirements 7.5**

  - [ ]* 12.7 회의록 필수 필드 검증 속성 기반 테스트 작성
    - **Property 30: 회의록 필수 필드 검증**
    - **Validates: Requirements 7.6**

  - [ ] 12.8 `controller/MeetingServlet.java` 구현
    - `@WebServlet("/meeting")`, GET(목록/상세), POST(저장/수정), DELETE(삭제) 처리
    - action 파라미터로 save/update/delete 분기
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [ ] 12.9 회의록 JSP 뷰 구현
    - `meeting/list.jsp`: 날짜 내림차순 목록
    - `meeting/form.jsp`: 작성/수정 폼 (제목, 날짜, 참석자, 내용, 결정 사항)
    - `meeting/detail.jsp`: 전체 내용 표시, 수정/삭제 버튼
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [ ] 13. 파일 공유 구현
  - [ ] 13.1 `model/FileDTO.java` 생성
    - 필드: fileId, projectId, originalName, savedName, uploaderId, fileSize, uploadedAt
    - getter/setter 구현
    - _Requirements: 8.1_

  - [ ] 13.2 `model/FileDAO.java` 구현
    - `getFilesByProject(int projectId)`: 업로드 일시 내림차순 조회
    - `saveFile(FileDTO file)`: INSERT
    - `deleteFile(int fileId)`: DELETE
    - `getFileById(int fileId)`: 단건 조회 (다운로드용)
    - _Requirements: 8.1, 8.2, 8.3, 8.6_

  - [ ]* 13.3 파일 업로드 메타데이터 속성 기반 테스트 작성
    - **Property 31: 파일 업로드 및 메타데이터 저장**
    - **Validates: Requirements 8.1**

  - [ ]* 13.4 파일 목록 날짜 내림차순 정렬 속성 기반 테스트 작성
    - **Property 32: 파일 목록 날짜 내림차순 정렬**
    - **Validates: Requirements 8.2**

  - [ ]* 13.5 파일 크기 제한 속성 기반 테스트 작성
    - **Property 34: 파일 크기 제한**
    - **Validates: Requirements 8.4**

  - [ ]* 13.6 파일 삭제 속성 기반 테스트 작성
    - **Property 35: 파일 삭제**
    - **Validates: Requirements 8.6**

  - [ ] 13.7 `controller/FileServlet.java` 구현
    - `@WebServlet("/file")`, GET(목록/다운로드), POST(업로드), DELETE(삭제) 처리
    - cos.jar `MultipartRequest` 사용, 최대 크기 50MB 설정
    - 업로드 디렉토리: `WebContent/uploads/{projectId}/`
    - 다운로드: `Content-Disposition: attachment` 헤더 설정
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

  - [ ] 13.8 `files.jsp` 구현
    - 파일 목록 테이블 (파일명, 업로더, 크기, 업로드 일시, 다운로드/삭제 버튼)
    - 파일 업로드 폼 (`enctype="multipart/form-data"`)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.6_

- [ ] 14. 최종 체크포인트 - 전체 통합 검증
  - 모든 테스트 통과 확인, 전체 기능 흐름(로그인 → 프로젝트 생성 → 칸반 → 채팅 → 파일 업로드 → 알림) 확인. 문제가 있으면 사용자에게 질문한다.

- [ ] 15. 교직원 기능 구현
  - [ ] 15.1 `model/InstructorDTO.java` 생성
    - 필드: id, name, email
    - getter/setter 구현
    - _Requirements: 10.1, 10.2_

  - [ ] 15.2 `model/InstructorDAO.java` 구현
    - `getInvitedProjects(String instructorId)`: 초대받은 프로젝트 목록 조회 (프로젝트명, 팀원 수, 진행률 포함)
    - `getProjectDetail(int projectId)`: 특정 프로젝트 상세 읽기 전용 조회
    - `inviteInstructor(int projectId, String instructorId)`: 교직원을 Observer로 project_member에 등록
    - `isObserver(int projectId, String instructorId)`: Observer 여부 확인
    - _Requirements: 10.3, 10.4, 10.5_

  - [ ]* 15.3 교직원 대시보드 초대받은 프로젝트 조회 속성 기반 테스트 작성
    - **Property 41: 교직원 대시보드 초대받은 프로젝트 조회**
    - **Validates: Requirements 10.2, 10.3**

  - [ ]* 15.3b 교직원 초대(Observer 등록) 라운드트립 속성 기반 테스트 작성
    - **Property 41b: 교직원 초대(Observer 등록) 라운드트립**
    - **Validates: Requirements 10.4**

  - [ ]* 15.3c 교직원 채팅 접근 차단 속성 기반 테스트 작성
    - **Property 41c: 교직원 채팅 접근 차단**
    - **Validates: Requirements 10.6**

  - [ ] 15.4 `model/FeedbackDTO.java` 생성
    - 필드: feedbackId, projectId, instructorId, instructorName, content, createdAt
    - getter/setter 구현
    - _Requirements: 10.6_

  - [ ] 15.5 `model/FeedbackDAO.java` 구현
    - `saveFeedback(FeedbackDTO feedback)`: content 공백 검증 후 INSERT
    - `getFeedbacksByProject(int projectId)`: 작성 일시 내림차순 조회 (instructor 이름 JOIN)
    - _Requirements: 10.6, 10.7, 10.9_

  - [ ]* 15.6 피드백 저장/조회 라운드트립 속성 기반 테스트 작성
    - **Property 43: 피드백 저장/조회 라운드트립**
    - **Validates: Requirements 10.8**

  - [ ]* 15.7 피드백 목록 작성 일시 내림차순 정렬 속성 기반 테스트 작성
    - **Property 44: 피드백 목록 작성 일시 내림차순 정렬**
    - **Validates: Requirements 10.9**

  - [ ]* 15.8 빈 피드백 차단 속성 기반 테스트 작성
    - **Property 45: 빈 피드백 차단**
    - **Validates: Requirements 10.11**

  - [ ] 15.9 `controller/InstructorDashboardServlet.java` 구현
    - `@WebServlet("/instructor/dashboard")`, GET 처리
    - 세션 `userType`이 "교직원"이 아니면 403 반환
    - `InstructorDAO.getInvitedProjects(instructorId)`로 초대받은 프로젝트 목록 조회 후 `instructor_dashboard.jsp`로 forward
    - _Requirements: 10.2, 10.3_

  - [ ] 15.10 `controller/ProjectServlet.java` 수정: 팀장의 교직원 초대 기능 추가
    - 초대 대상 `user_type`이 "교직원"이면 `InstructorDAO.inviteInstructor()`로 Observer 등록
    - _Requirements: 10.4_

  - [ ] 15.11 `controller/FeedbackServlet.java` 구현
    - `@WebServlet("/feedback")`, GET(프로젝트별 피드백 목록), POST(피드백 저장) 처리
    - POST 시 세션 `userType`이 "교직원"인지 확인, content 공백 검증
    - _Requirements: 10.8, 10.9, 10.11_

  - [ ] 15.12 교직원 JSP 뷰 구현
    - `instructor_dashboard.jsp`: 초대받은 프로젝트 목록 테이블 (프로젝트명, 팀원 수, 진행률), 각 프로젝트 상세 링크
    - `feedback/form.jsp`: 피드백 작성 폼 (내용 textarea, 제출 버튼)
    - `feedback/list.jsp`: 프로젝트별 피드백 목록 (작성자, 작성 일시, 내용), 작성 일시 내림차순
    - _Requirements: 10.3, 10.5, 10.8, 10.9_

- [ ] 16. 최종 체크포인트 - 교직원 기능 통합 검증
  - 모든 테스트 통과 확인, 교직원 가입 → 로그인 → 교직원 대시보드(초대받은 프로젝트) → 프로젝트 조회 → 피드백 작성, 채팅 접근 차단 흐름 확인. 문제가 있으면 사용자에게 질문한다.

## Notes

- `*` 표시 서브태스크는 선택적 테스트 태스크로, MVP 구현 시 건너뛸 수 있다.
- 속성 기반 테스트는 jqwik 라이브러리 사용 (JUnit 5 기반), 각 테스트 100회 이상 반복
- 테스트 DB는 별도 스키마 `projectos_test` 사용
- 각 태스크는 이전 태스크의 결과물을 전제로 하며, 고아 코드 없이 매 단계 동작 가능 상태 유지
- 모든 Servlet은 최상위 try-catch로 예외 처리, `request.setAttribute("error", ...)` 패턴 사용
