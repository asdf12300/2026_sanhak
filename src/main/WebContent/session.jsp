<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
  model.LoginDTO loginUser = (model.LoginDTO) session.getAttribute("loginUser");
  String userName = (loginUser != null) ? loginUser.getName() : "게스트";
  String userId   = (loginUser != null) ? loginUser.getId()   : "";
  String initials = (userName.length() >= 2) ? userName.substring(0,2) : userName;
%>