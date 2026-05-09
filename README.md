# ProjectOS

이 폴더는 **서버 배포용 프로젝트(`sanhak`)** 입니다.

## 기술 스택

- Java Servlet/JSP
- Apache Tomcat 9
- MySQL/RDS
- AWS S3 파일 저장소
- WebSocket 실시간 채팅
- Naver 로그인 연동
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
  deploy.ps1                    서버 배포 스크립트
  배포하기.bat                   더블클릭 배포 실행 파일
```

## 서버용/로컬용 분리 규칙

구조가 같은 파일:

```text
Servlet, DAO, DTO, JSP, JS, CSS, web.xml 구조
```

환경별로 달라도 되는 파일:

```text
DB 설정
S3/로컬 파일 저장 설정
API 키
메일 계정
네이버 Redirect URL
Tomcat context.xml
config.properties
secret.properties
```

주의할 점:

```text
환경 설정 파일은 서로 복사하지 않습니다. (따로 구축해서 하는 거 아니면 그대로 두셔도 됩니다.)
sanhak은 서버 배포용 설정을 유지합니다.
```

## web.xml 정책

현재 프로젝트는 `@WebServlet` annotation 방식으로 서블릿 URL을 관리합니다.

`web.xml`에는 servlet mapping을 넣지 않고, 다음 공통 설정만 유지합니다.

중요:

```text
web.xml에 servlet-mapping을 추가하면서 Java 파일의 @WebServlet을 그대로 두면 중복 매핑 오류가 발생할 수 있어서 새 Servlet을 만드실 땐 Java 파일에 @WebServlet 경로로 명시해주세요 !
```

## 환경 파일

.gitignore에 설정이 되어있고 따로 배포 및 테스트를 진행하실 땐 각 환경에 맞는 파일 및 키 값을 수정해주시면 돼요

필요한 설정 예:

```properties
naver.client.id=your-naver-client-id
naver.client.secret=your-naver-client-secret
kakao.js.key=your-kakao-js-key
mail.username=your-naver-id@naver.com
mail.password=your-mail-app-password
```

```properties
src/main/resources/db.properties
src/main/resources/secret.properties
src/main/WebContent/WEB-INF/config.properties
src/main/WebContent/META-INF/context.xml
```

도서 추천 기능은 `WEB-INF/config.properties`에 Groq API 받아서 오시면 됩니다. 

```properties
groq.api.key=your-groq-api-key
```

## 데이터베이스

서버용 전체 SQL은 아래 파일을 기준으로 하고 실행시키시면 됩니다. (서버에 이미 되어있어서 추가로 배포 작업 진행하시면 아래 db 실행해주세요)

```text
src/main/WebContent/resource/sql/ProjectOS_DB.sql
```

## 배포 방법

1. Eclipse에서 WAR 파일을 Export합니다.

```text
Project 우클릭
Export
WAR file
Destination: 배포 할 위치 설정
Target runtime: Apache Tomcat v9.0 or 자신이 사용하는 서버 버전 선택 
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

처음 배포진행하시면  `deploy.example.ps1`을 `deploy.local.ps1`로 복사한 뒤 자기 환경에 맞게 수정하셔야됩니다. 

```powershell
$KeyPath = "key 위치 복사 붙이기"
$Server = "ubuntu@your-server-ip"
```
서버 key.pem은 따로 관리해서 필요하시면 보내드리겠습니다. 

배포 스크립트 실행하면 아래와 같이 실행됩니다.

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

## 주의사항

- 서버 배포는 `sanhak`에서만 진행합니다. 
- 코드 구조는 두 프로젝트가 최대한 같게 유지해야해요 제가 최대한 수정은 해놓았어요 구조 다른 건 S3 부분 정도예요
- 환경 설정 파일은 서로 덮어쓰지 않습니다.
- 서버 오류는 브라우저 화면보다 Tomcat 로그를 기준으로 보시고 디버깅하시면 됩니다. 
