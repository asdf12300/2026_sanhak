# ProjectOS

ProjectOS는 산학 프로젝트 팀을 위한 협업 웹 애플리케이션입니다. 프로젝트 관리, 일정, 업무, 회의록, 피드백, 파일 공유, 실시간 채팅, 이메일 인증, 소셜 로그인을 한 곳에서 다룹니다.

이 폴더는 **서버 배포용 프로젝트(`sanhak`)**입니다. 로컬 테스트용 프로젝트는 상위 폴더의 `sanhak_test`를 사용합니다.

## 기술 스택

- Java Servlet/JSP
- Apache Tomcat 9
- MySQL/RDS
- AWS S3 파일 저장소
- WebSocket 실시간 채팅
- Naver/Kakao 로그인 연동
- Naver SMTP 이메일 인증
- Groq API 기반 도서 추천

## 폴더 구조

```text
sanhak/
  src/main/java/controller/     Servlet, WebSocket Controller
  src/main/java/model/          DAO, DTO, DB 연결 모델
  src/main/java/util/           공통 유틸리티
  src/main/resources/           db/secret properties 예시 및 리소스
  src/main/WebContent/          JSP, 정적 리소스, WEB-INF
  src/main/WebContent/WEB-INF/  web.xml, lib, config.properties
  src/main/WebContent/resource/ CSS, JS, SQL 등 화면 리소스
  deploy.ps1                   서버 배포 스크립트
  배포하기.bat                  더블클릭 배포 실행 파일
```

## 서버용/로컬용 분리 규칙

상위 폴더에는 두 프로젝트가 있습니다.

```text
2026_sanhak/
  sanhak/       서버 배포용
  sanhak_test/  로컬 테스트용
```

공통으로 맞춰야 하는 파일:

```text
Servlet, DAO, DTO, JSP, JS, CSS, web.xml 구조
```

환경별로 달라도 되는 파일:

```text
DB 설정
S3/로컬 파일 저장 설정
API 키
메일 계정
네이버/카카오 Redirect URL
Tomcat context.xml
config.properties
secret.properties
```

주의할 점:

```text
환경 설정 파일은 서로 복사하지 않습니다.
sanhak은 서버 배포용 설정을 유지합니다.
sanhak_test는 로컬 테스트용 설정을 유지합니다.
```

## web.xml 정책

현재 프로젝트는 `@WebServlet` annotation 방식으로 서블릿 URL을 관리합니다.

`web.xml`에는 servlet mapping을 넣지 않고, 다음 공통 설정만 유지합니다.

```text
DB JNDI resource-ref
welcome-file-list
error-page
```

중요:

```text
web.xml에 servlet-mapping을 추가하면서 Java 파일의 @WebServlet을 그대로 두면 중복 매핑 오류가 발생할 수 있습니다.
새 Servlet을 추가할 때는 Java 파일에 @WebServlet 경로를 명확히 작성합니다.
파일 업로드는 FileShareServlet의 @MultipartConfig로 관리합니다.
```

## 환경 파일

실제 환경 파일은 Git에 올리지 않습니다.

```text
src/main/resources/db.properties
src/main/resources/secret.properties
src/main/WebContent/WEB-INF/config.properties
src/main/WebContent/META-INF/context.xml
```

예시 파일만 공유합니다.

```text
*.properties.example
*.xml.example
```

필요한 설정 예:

```properties
naver.client.id=your-naver-client-id
naver.client.secret=your-naver-client-secret
kakao.js.key=your-kakao-js-key
mail.username=your-naver-id@naver.com
mail.password=your-mail-app-password
```

도서 추천 기능은 `WEB-INF/config.properties`에 Groq API 키가 필요합니다.

```properties
groq.api.key=your-groq-api-key
```

## 데이터베이스

서버용 전체 SQL은 아래 파일을 기준으로 합니다.

```text
src/main/WebContent/resource/sql/ProjectOS_DB.sql
```

서버와 로컬 DB는 가능한 한 같은 테이블 구조를 유지하는 것을 권장합니다. 예를 들어 `file_share`는 로컬에서 S3를 사용하지 않더라도 서버와 같은 컬럼 구조를 유지하는 편이 안전합니다.

## 배포 방법

1. Eclipse에서 WAR 파일을 Export합니다.

```text
Project 우클릭
Export
WAR file
Destination: C:\Users\1_032\OneDrive\바탕 화면\2026_sanhak\ProjectOS.war
Target runtime: Apache Tomcat v9.0
Overwrite existing file 체크
Finish
```

2. 아래 파일을 더블클릭합니다.

```text
배포하기.bat
```

또는 PowerShell에서 직접 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1
```

처음 배포하는 팀원은 `deploy.example.ps1`을 `deploy.local.ps1`로 복사한 뒤 자기 환경에 맞게 수정해야 합니다.

```powershell
$KeyPath = "C:\path\to\projectos-key.pem"
$Server = "ubuntu@your-server-ip"
```

`deploy.local.ps1`은 개인별 설정 파일이므로 Git에 올리지 않습니다.

배포 스크립트는 다음 작업을 수행합니다.

```text
ProjectOS.war 확인
서버로 ROOT.war 업로드
Tomcat 중지
기존 ROOT 제거
새 ROOT.war 배치
Tomcat 시작
/login.jsp 응답 확인
최근 Tomcat 로그 출력
```

## 서버 확인

브라우저:

```text
https://projectos-team.duckdns.org/
```

서버 내부 확인:

```bash
curl -I http://127.0.0.1:8080/login.jsp
```

## 로그 확인

오류가 발생하면 서버에서 Tomcat 로그를 먼저 확인합니다.

```bash
sudo tail -n 100 /opt/tomcat/logs/catalina.out
sudo tail -n 100 /opt/tomcat/logs/localhost.YYYY-MM-DD.log
```

자주 보는 오류:

```text
404: WAR 배포 실패, ROOT.war 이름 문제, URL 경로 문제
500: Java 예외, DB 오류, properties 누락, 라이브러리 누락
413: Nginx 업로드 용량 제한
Duplicate servlet mapping: web.xml과 @WebServlet 중복
UnsupportedClassVersionError: Java 버전 불일치
ClassNotFoundException/NoClassDefFoundError: jar 누락 또는 깨진 빌드
```

## Git 관리 규칙

`.gitignore`는 실제 환경 파일과 빌드 산출물을 제외합니다.

Git에 올리지 않는 것:

```text
실제 DB/API/메일 비밀 설정
context.xml
WAR 파일
build 결과물
Eclipse 개인 설정
```

Git에 올릴 수 있는 것:

```text
소스 코드
JSP/JS/CSS
SQL
example 설정 파일
WEB-INF/lib 라이브러리 jar
README
배포 스크립트
```

## 유지보수 원칙

- 서버 배포는 `sanhak`에서만 진행합니다.
- 로컬 테스트는 `sanhak_test`에서 진행합니다.
- 코드 구조는 두 프로젝트가 최대한 같게 유지합니다.
- 환경 설정 파일은 서로 덮어쓰지 않습니다.
- 서버 오류는 브라우저 화면보다 Tomcat 로그를 기준으로 판단합니다.
