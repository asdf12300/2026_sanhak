<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.ProjectMemberDTO" %>

<%
request.setCharacterEncoding("UTF-8");
List<ProjectMemberDTO> invitationList =
        (List<ProjectMemberDTO>) request.getAttribute("invitationList");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>초대 목록</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Malgun Gothic", Arial, sans-serif;
            background: #f2f5fa;
            color: #222;
        }
        .page-wrap {
            width: 1020px;
            margin: 70px auto;
        }
        .card {
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.08);
            padding: 30px 30px 28px;
        }
        .title {
            font-size: 24px;
            font-weight: 700;
            color: #2f6fed;
            margin: 0 0 22px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }
        thead tr {
            background: #eef3ff;
        }
        th {
            color: #2f6fed;
            font-size: 15px;
            font-weight: 700;
            padding: 14px 10px;
            text-align: center;
        }
        td {
            padding: 14px 10px;
            text-align: center;
            border-bottom: 1px solid #eceff5;
            font-size: 15px;
        }
        .empty-row td {
            color: #7b8794;
            padding: 24px 10px;
        }
        .action-box {
            display: flex;
            justify-content: center;
            gap: 8px;
        }
        .inline-form {
            margin: 0;
        }
        .btn {
            border: none;
            border-radius: 8px;
            padding: 8px 14px;
            font-size: 14px;
            font-weight: 700;
            color: #fff;
            cursor: pointer;
        }
        .btn-accept { background: #2eb85c; }
        .btn-reject { background: #e74c3c; }
        .btn-delete { background: #444; }
        .btn:hover { opacity: 0.92; }
        .status-invited { color: #555; font-weight: 600; }
        .status-accepted { color: #2eb85c; font-weight: 700; }
        .status-rejected { color: #e74c3c; font-weight: 700; }
    </style>
</head>
<body>
    <div class="page-wrap">
        <div class="card">
            <h2 class="title">내가 받은 프로젝트 초대</h2>

            <table>
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>프로젝트 번호</th>
                        <th>회원ID</th>
                        <th>역할</th>
                        <th>상태</th>
                        <th>초대일</th>
                        <th>처리</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (invitationList == null || invitationList.isEmpty()) {
                %>
                    <tr class="empty-row">
                        <td colspan="7">받은 초대가 없습니다.</td>
                    </tr>
                <%
                    } else {
                        for (ProjectMemberDTO dto : invitationList) {
                            String status = dto.getStatus() == null ? "" : dto.getStatus().trim();
                            String statusClass = "status-invited";
                            if ("accepted".equalsIgnoreCase(status)) {
                                statusClass = "status-accepted";
                            } else if ("rejected".equalsIgnoreCase(status)) {
                                statusClass = "status-rejected";
                            }
                %>
                    <tr>
                        <td><%= dto.getPmNo() %></td>
                        <td><%= dto.getProjectId() %></td>
                        <td><%= dto.getMemberId() %></td>
                        <td><%= dto.getRole() == null ? "팀원" : dto.getRole() %></td>
                        <td class="<%= statusClass %>"><%= status %></td>
                        <td><%= dto.getInvitedAt() == null ? "" : dto.getInvitedAt() %></td>
                        <td>
                            <div class="action-box">

                                <% if ("invited".equalsIgnoreCase(status)) { %>
                                <form class="inline-form" method="post"
                                      action="<%= request.getContextPath() %>/inviteMembers">
                                    <input type="hidden" name="action" value="accept">
                                    <input type="hidden" name="pmNo" value="<%= dto.getPmNo() %>">
                                    <button type="submit" class="btn btn-accept">수락</button>
                                </form>

                                <form class="inline-form" method="post"
                                      action="<%= request.getContextPath() %>/inviteMembers">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="pmNo" value="<%= dto.getPmNo() %>">
                                    <button type="submit" class="btn btn-reject">거절</button>
                                </form>
                                <% } %>

                                <% if ("rejected".equalsIgnoreCase(status)) { %>
                                <form class="inline-form" method="post"
                                      action="<%= request.getContextPath() %>/inviteMembers"
                                      onsubmit="return confirm('이 초대 기록을 삭제하시겠습니까?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="pmNo" value="<%= dto.getPmNo() %>">
                                    <button type="submit" class="btn btn-delete">삭제</button>
                                </form>
                                <% } %>

                            </div>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>