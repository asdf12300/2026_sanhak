# 요구사항 문서

## 소개

대학생 팀 프로젝트 협업 관리 플랫폼 **ProjectOS**는 여러 플랫폼에 분산된 자료와 정보를 하나의 시스템에서 통합 관리하여 팀 프로젝트 진행의 효율성을 높이는 것을 목적으로 한다. 기존에 구현된 로그인(LoginServlet, LoginDAO, LoginDTO, login.jsp) 및 회원가입(JoinServlet, join.jsp) 기능을 기반으로, 대시보드·일정 관리·칸반보드·팀 채팅·회의록·파일 공유 기능을 Java Servlet, JSP, HTML, CSS, JavaScript, MySQL 스택으로 구현한다.

---

## 용어 정의 (Glossary)

- **System**: 대학생 팀 프로젝트 협업 관리 플랫폼 전체
- **Auth_Module**: 사용자 인증 및 세션 관리를 담당하는 모듈 (LoginServlet, JoinServlet 포함)
- **Dashboard**: 프로젝트 진행률 및 팀원별 업무 현황을 시각적으로 표시하는 메인 화면
- **Project**: 팀이 수행하는 하나의 협업 단위로, 팀원·일정·업무·파일·채팅·회의록을 포함
- **Member**: 플랫폼에 가입하여 프로젝트에 참여하는 사용자 (member 테이블 기반)
- **Task**: 칸반보드에서 관리되는 개별 업무 단위로, 담당자·상태·마감일을 가짐
- **Kanban_Board**: Task를 To Do / In Progress / Done 세 컬럼으로 시각화하는 보드
- **Calendar**: 프로젝트 일정을 월별로 표시하고 마감일 알림을 제공하는 기능
- **Chat_Module**: 팀 내 실시간 메시지 및 공지 기능을 제공하는 모듈
- **Meeting_Note**: 회의 내용과 결정 사항을 기록·저장하는 문서
- **File_Manager**: 프로젝트 관련 파일을 업로드·조회·다운로드하는 기능
- **Notification**: 마감일 임박, 새 메시지, 업무 할당 등의 알림 메시지
- **Role**: 프로젝트 내 팀원의 역할 (팀장 / 팀원)
- **Sprint**: 주차별 업무 묶음 단위
- **Instructor**: 플랫폼에 가입하여 초대받은 팀의 프로젝트 진행 상황을 읽기 전용으로 모니터링하고 피드백을 제공하는 교직원 사용자
- **User_Type**: 플랫폼 사용자의 유형 구분 (학생 / 교직원)
- **Feedback**: 교직원이 특정 프로젝트에 작성하는 댓글 형태의 의견 또는 지도 내용
- **Observer**: 프로젝트에 초대된 교직원의 역할로, 읽기 전용 접근 및 피드백 작성 권한을 가지며 채팅은 비공개

---

## 요구사항

### 요구사항 1: 사용자 인증 및 계정 관리

**User Story:** 대학생으로서, 나는 안전하게 로그인하고 계정을 관리하고 싶다. 그래야 내 프로젝트 데이터를 보호할 수 있다.

#### 수용 기준

1. WHEN 사용자가 유효한 아이디와 비밀번호를 입력하고 로그인을 요청하면, THE Auth_Module SHALL 세션을 생성하고 대시보드 페이지로 리다이렉트한다.
2. WHEN 사용자가 잘못된 아이디 또는 비밀번호를 입력하면, THE Auth_Module SHALL 로그인 페이지에 "아이디 또는 비밀번호가 일치하지 않습니다." 오류 메시지를 표시한다.
3. WHEN 회원가입 폼에서 아이디가 5자 미만이거나 12자를 초과하면, THE Auth_Module SHALL 해당 필드에 유효성 오류 메시지를 표시하고 폼 제출을 차단한다.
4. WHEN 회원가입 폼에서 비밀번호가 8자 미만이거나 20자를 초과하면, THE Auth_Module SHALL 해당 필드에 유효성 오류 메시지를 표시하고 폼 제출을 차단한다.
5. WHEN 회원가입 시 이미 존재하는 아이디를 입력하면, THE Auth_Module SHALL "이미 사용 중인 아이디입니다." 오류 메시지를 표시한다.
6. WHEN 사용자가 로그아웃을 요청하면, THE Auth_Module SHALL 세션을 무효화하고 로그인 페이지로 리다이렉트한다.
7. WHILE 사용자가 로그인 세션을 보유하지 않은 상태에서 보호된 페이지에 접근하면, THE Auth_Module SHALL 로그인 페이지로 리다이렉트한다.
8. WHEN 회원가입 폼에서 User_Type을 선택하면, THE Auth_Module SHALL 선택된 User_Type(학생 / 교직원)을 member 테이블에 저장한다.
9. WHEN 로그인한 사용자의 User_Type이 교직원이면, THE Auth_Module SHALL 세션에 User_Type을 "교직원"으로 기록하고 교직원 전용 대시보드로 리다이렉트한다.

---

### 요구사항 2: 프로젝트 생성 및 팀원 관리

**User Story:** 팀장으로서, 나는 프로젝트를 생성하고 팀원을 초대하여 협업 환경을 구성하고 싶다. 그래야 팀 전체가 하나의 플랫폼에서 협업할 수 있다.

#### 수용 기준

1. WHEN 로그인한 사용자가 프로젝트 생성 폼을 제출하면, THE System SHALL 프로젝트 이름·설명·마감일을 저장하고 생성자를 팀장(Role: 팀장)으로 등록한다.
2. WHEN 팀장이 유효한 아이디로 팀원 초대를 요청하면, THE System SHALL 해당 Member를 프로젝트에 팀원(Role: 팀원)으로 추가한다.
3. IF 팀장이 존재하지 않는 아이디로 팀원 초대를 요청하면, THEN THE System SHALL "존재하지 않는 사용자입니다." 오류 메시지를 표시한다.
4. WHEN 팀장이 팀원을 프로젝트에서 제외하면, THE System SHALL 해당 Member의 프로젝트 접근 권한을 즉시 제거한다.
5. THE System SHALL 하나의 프로젝트에 최소 1명, 최대 20명의 Member를 허용한다.
6. WHILE 사용자가 프로젝트에 소속되어 있는 동안, THE Dashboard SHALL 해당 프로젝트의 진행 현황을 표시한다.

---

### 요구사항 3: 대시보드

**User Story:** 팀원으로서, 나는 프로젝트 진행률과 팀원별 업무 현황을 한눈에 확인하고 싶다. 그래야 프로젝트 상태를 빠르게 파악할 수 있다.

#### 수용 기준

1. WHEN 로그인한 사용자가 대시보드에 접근하면, THE Dashboard SHALL 전체 Task 수, 완료 Task 수, 진행 중 Task 수, 지연 Task 수를 표시한다.
2. THE Dashboard SHALL 전체 Task 대비 완료 Task의 비율을 백분율(%)로 계산하여 진행률 차트로 표시한다.
3. THE Dashboard SHALL 각 팀원별 담당 Task 완료율을 진행 바(progress bar) 형태로 표시한다.
4. THE Dashboard SHALL 오늘 날짜 기준으로 마감일이 지난 Task를 "지연" 상태로 분류하여 표시한다.
5. WHEN 새로운 Task가 생성되거나 상태가 변경되면, THE Dashboard SHALL 통계 수치를 갱신하여 표시한다.

---

### 요구사항 4: 일정 관리 (캘린더)

**User Story:** 팀원으로서, 나는 캘린더에서 프로젝트 일정을 등록하고 마감일 알림을 받고 싶다. 그래야 일정을 놓치지 않고 관리할 수 있다.

#### 수용 기준

1. THE Calendar SHALL 월별 달력 형태로 프로젝트 일정을 표시한다.
2. WHEN 사용자가 일정 등록 폼에 제목·날짜·담당자를 입력하고 저장하면, THE Calendar SHALL 해당 일정을 달력에 표시한다.
3. WHEN 사용자가 달력의 이전/다음 버튼을 클릭하면, THE Calendar SHALL 해당 월의 일정을 표시한다.
4. WHEN Task의 마감일까지 3일 이하가 남으면, THE Notification SHALL 해당 Task 담당자에게 마감 임박 알림을 표시한다.
5. WHEN Task의 마감일이 오늘 날짜를 초과하면, THE Notification SHALL 해당 Task를 지연 상태로 표시하고 담당자에게 알림을 표시한다.
6. IF 일정 등록 시 날짜 필드가 비어 있으면, THEN THE Calendar SHALL "날짜를 입력해 주세요." 오류 메시지를 표시하고 저장을 차단한다.

---

### 요구사항 5: 칸반보드 (역할 분담 및 업무 관리)

**User Story:** 팀원으로서, 나는 칸반보드에서 업무를 생성하고 진행 상태를 관리하고 싶다. 그래야 팀 전체의 업무 분담과 진행 상황을 시각적으로 파악할 수 있다.

#### 수용 기준

1. THE Kanban_Board SHALL Task를 To Do, In Progress, Done 세 개의 컬럼으로 구분하여 표시한다.
2. WHEN 사용자가 Task 생성 폼에 제목·담당자·마감일·주차(Sprint)를 입력하고 저장하면, THE Kanban_Board SHALL 해당 Task를 To Do 컬럼에 추가한다.
3. WHEN 사용자가 Task를 다른 컬럼으로 이동하면, THE Kanban_Board SHALL Task의 상태를 해당 컬럼 상태(To Do / In Progress / Done)로 업데이트한다.
4. THE Kanban_Board SHALL 각 컬럼에 포함된 Task 수를 컬럼 헤더에 표시한다.
5. WHEN 사용자가 Task를 삭제하면, THE Kanban_Board SHALL 해당 Task를 목록에서 제거하고 Dashboard 통계를 갱신한다.
6. THE Kanban_Board SHALL 주차(Sprint)별로 Task를 필터링하여 표시하는 기능을 제공한다.
7. WHEN Task가 Done 컬럼으로 이동하면, THE Dashboard SHALL 완료 Task 수와 진행률을 즉시 갱신한다.

---

### 요구사항 6: 실시간 팀 채팅 및 공지

**User Story:** 팀원으로서, 나는 팀 채팅과 공지 기능을 통해 팀원들과 원활하게 소통하고 싶다. 그래야 별도의 메신저 없이 플랫폼 내에서 의사소통할 수 있다.

#### 수용 기준

1. WHEN 로그인한 사용자가 채팅 메시지를 전송하면, THE Chat_Module SHALL 메시지를 데이터베이스에 저장하고 채팅 화면에 표시한다.
2. THE Chat_Module SHALL 채팅 메시지를 전송자 이름, 전송 시각, 메시지 내용과 함께 표시한다.
3. WHEN 팀장이 공지 메시지를 등록하면, THE Chat_Module SHALL 해당 메시지를 공지로 구분하여 채팅 목록 상단에 고정 표시한다.
4. THE Chat_Module SHALL 채팅 메시지 목록을 최신 메시지가 하단에 오도록 시간 순서로 표시한다.
5. IF 메시지 내용이 비어 있으면, THEN THE Chat_Module SHALL 전송 버튼을 비활성화하고 빈 메시지 전송을 차단한다.
6. THE Chat_Module SHALL 프로젝트별로 독립된 채팅 채널을 제공한다.

---

### 요구사항 7: 회의록 관리

**User Story:** 팀원으로서, 나는 회의 내용과 결정 사항을 기록하고 조회하고 싶다. 그래야 회의 결과를 팀 전체가 공유하고 추후에 참고할 수 있다.

#### 수용 기준

1. WHEN 사용자가 회의록 작성 폼에 회의 제목·날짜·참석자·내용·결정 사항을 입력하고 저장하면, THE System SHALL 해당 Meeting_Note를 데이터베이스에 저장한다.
2. THE System SHALL 저장된 Meeting_Note 목록을 회의 날짜 기준 내림차순으로 표시한다.
3. WHEN 사용자가 특정 Meeting_Note를 선택하면, THE System SHALL 해당 회의록의 전체 내용을 표시한다.
4. WHEN 작성자가 Meeting_Note를 수정하면, THE System SHALL 변경된 내용을 저장하고 수정 일시를 기록한다.
5. WHEN 작성자가 Meeting_Note를 삭제하면, THE System SHALL 해당 회의록을 목록에서 제거한다.
6. IF 회의록 저장 시 제목 또는 날짜 필드가 비어 있으면, THEN THE System SHALL "필수 항목을 입력해 주세요." 오류 메시지를 표시하고 저장을 차단한다.

---

### 요구사항 8: 파일 공유 및 통합 관리

**User Story:** 팀원으로서, 나는 프로젝트 관련 파일을 업로드하고 팀원들과 공유하고 싶다. 그래야 자료를 한 곳에서 통합 관리할 수 있다.

#### 수용 기준

1. WHEN 사용자가 파일을 선택하고 업로드를 요청하면, THE File_Manager SHALL 파일을 서버에 저장하고 파일명·업로더·업로드 일시·파일 크기를 데이터베이스에 기록한다.
2. THE File_Manager SHALL 업로드된 파일 목록을 업로드 일시 기준 내림차순으로 표시한다.
3. WHEN 사용자가 파일 다운로드를 요청하면, THE File_Manager SHALL 해당 파일을 사용자의 브라우저로 전송한다.
4. IF 업로드 파일 크기가 50MB를 초과하면, THEN THE File_Manager SHALL "파일 크기는 50MB 이하여야 합니다." 오류 메시지를 표시하고 업로드를 차단한다.
5. THE File_Manager SHALL 프로젝트별로 독립된 파일 저장 공간을 제공한다.
6. WHEN 업로더가 파일을 삭제하면, THE File_Manager SHALL 서버 저장 파일과 데이터베이스 기록을 함께 제거한다.

---

### 요구사항 9: 알림 기능

**User Story:** 팀원으로서, 나는 업무 할당·마감 임박·새 메시지 등의 알림을 받고 싶다. 그래야 중요한 이벤트를 놓치지 않을 수 있다.

#### 수용 기준

1. WHEN 새로운 Task가 특정 Member에게 할당되면, THE Notification SHALL 해당 Member의 알림 목록에 "새 업무가 할당되었습니다." 메시지를 추가한다.
2. WHEN Task 마감일까지 3일 이하가 남으면, THE Notification SHALL 담당 Member의 알림 목록에 마감 임박 메시지를 추가한다.
3. WHEN 새로운 채팅 메시지가 도착하면, THE Notification SHALL 해당 프로젝트 팀원의 알림 아이콘에 미확인 메시지 수를 표시한다.
4. WHEN 사용자가 알림을 확인하면, THE Notification SHALL 해당 알림을 읽음 상태로 변경한다.
5. THE Notification SHALL 읽지 않은 알림 수를 내비게이션 바의 알림 아이콘에 숫자 배지로 표시한다.

---

### 요구사항 10: 교직원 역할 및 프로젝트 모니터링

**User Story:** 교직원으로서, 나는 플랫폼에 가입하여 초대받은 팀의 프로젝트 진행 상황을 실시간으로 확인하고 피드백을 제공하고 싶다. 그래야 팀별 역할 분담을 한눈에 파악하고 보다 신속하고 효율적인 지도가 가능하다.

#### 수용 기준

1. WHEN 회원가입 시 User_Type을 "교직원"으로 선택하면, THE Auth_Module SHALL 해당 계정을 Instructor로 등록하고 교직원 전용 기능에 접근 가능하도록 권한을 부여한다.
2. WHEN Instructor가 로그인하면, THE System SHALL 해당 Instructor가 초대받은 프로젝트 목록을 조회할 수 있는 교직원 대시보드로 이동한다.
3. WHILE Instructor가 로그인 세션을 보유한 동안, THE System SHALL 해당 Instructor가 초대받은 프로젝트 목록(프로젝트명, 팀원 수, 진행률)만 읽기 전용으로 표시하며 초대받지 않은 프로젝트는 표시하지 않는다.
4. WHEN 팀장이 Instructor 아이디로 프로젝트 초대 요청을 제출하면, THE System SHALL 해당 Instructor를 해당 프로젝트의 Observer로 등록한다.
5. WHEN Instructor가 초대받은 프로젝트를 선택하면, THE Dashboard SHALL 해당 팀의 진행률, 칸반보드, 팀원별 업무 현황을 읽기 전용으로 표시한다.
6. IF Instructor가 채팅 페이지에 접근을 요청하면, THEN THE System SHALL 해당 요청을 차단하고 채팅 내용을 표시하지 않는다.
7. WHILE Instructor가 프로젝트 상세 페이지를 조회하는 동안, THE Kanban_Board SHALL Task 목록과 각 팀원의 담당 업무를 읽기 전용으로 표시하며 Instructor의 Task 생성·수정·삭제 요청을 차단한다.
8. WHEN Instructor가 특정 프로젝트에 피드백 내용을 입력하고 제출하면, THE System SHALL 해당 Feedback을 작성자(Instructor 아이디), 작성 일시와 함께 데이터베이스에 저장한다.
9. WHEN Member가 자신이 소속된 프로젝트의 피드백 목록을 조회하면, THE System SHALL 해당 프로젝트에 Instructor가 작성한 Feedback 목록을 작성 일시 내림차순으로 표시한다.
10. IF Instructor가 프로젝트의 Task, 파일, 채팅 메시지에 대해 수정 또는 삭제를 요청하면, THEN THE System SHALL 해당 요청을 거부하고 "교직원은 팀 데이터를 수정하거나 삭제할 수 없습니다." 오류 메시지를 표시한다.
11. IF Feedback 제출 시 내용 필드가 비어 있으면, THEN THE System SHALL "피드백 내용을 입력해 주세요." 오류 메시지를 표시하고 저장을 차단한다.
12. WHILE Instructor가 로그인 세션을 보유한 동안, THE System SHALL Instructor가 Observer로 등록되지 않은 프로젝트의 Task, 파일, 채팅 메시지 데이터에 대한 접근 및 수정·삭제 권한을 부여하지 않는다.
