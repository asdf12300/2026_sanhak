<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
에러코드: <%= response.getStatus() %><br>
에러메시지: <%= exception != null ? exception.getMessage() : "없음" %>