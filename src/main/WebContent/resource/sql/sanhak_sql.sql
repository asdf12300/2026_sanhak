create table member(
name varchar(20) NOT NULL,
id varchar(20) NOT NULL,
pw varchar(20) NOT NULL,
email varchar(30) NOT NULL,
tel varchar(15) NOT NULL
)

INSERT INTO member VALUES ('홍길동', 'hong123', '1234', 'hong@email.com', '010-1234-5678');

select * from member;