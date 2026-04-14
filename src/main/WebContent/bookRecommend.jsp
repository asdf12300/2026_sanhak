<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.google.gson.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>도서 추천</title>
    <link rel="stylesheet" href="resource/css/bookRecommend.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="resource/css/index.css">
</head>
<body>
<jsp:include page="sidebar.jsp"/>
<!-- 로딩 오버레이 -->
<div id="loading-overlay" style="display:none;">
    <div class="loading-box">
        <div class="spinner"></div>
        <p>추천 도서를 찾고 있습니다...</p>
    </div>
</div>

<div class="container">

    <div class="category-section">
        <div class="category-buttons">
            <a href="bookRecommend?category=소설" onclick="showLoading()">소설</a>
            <a href="bookRecommend?category=자기계발" onclick="showLoading()">자기계발</a>
            <a href="bookRecommend?category=과학" onclick="showLoading()">과학</a>
            <a href="bookRecommend?category=역사" onclick="showLoading()">역사</a>
            <a href="bookRecommend?category=프로그래밍" onclick="showLoading()">프로그래밍</a>
        </div>
    </div>

    <div class="search-section">
        <form action="bookRecommend" method="get" onsubmit="showLoading()">
            <input type="text" name="query" placeholder="예) 감동적인 소설 추천해줘"
                   value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>">
            <button type="submit">검색</button>
        </form>
    </div>

    <%
    String booksJson = (String) request.getAttribute("books");
    String category = (String) request.getAttribute("category");

    if (booksJson != null) {
        JsonArray books = JsonParser.parseString(booksJson).getAsJsonArray();
    %>

    <div class="result-title">
        "<%= category %>" 추천 도서
    </div>

    <div class="book-grid">
        <%
        for (JsonElement el : books) {
            JsonObject book = el.getAsJsonObject();
            String title = book.get("title").getAsString();
            String author = book.get("author").getAsString();
            String desc = book.get("desc").getAsString();
            String imageUrl = book.has("image") ? book.get("image").getAsString() : "";
        %>
        <div class="book-card">
            <% if (!imageUrl.isEmpty()) { %>
                <img class="book-cover" src="<%= imageUrl %>" alt="<%= title %> 표지">
            <% } else { %>
                <div class="book-cover-placeholder">이미지 없음</div>
            <% } %>
            <div class="book-info">
                <div class="book-title"><%= title %></div>
                <div class="book-author"><%= author %></div>
                <div class="book-desc"><%= desc %></div>
            </div>
        </div>
        <%
        }
        %>
    </div>

    <% } else { %>

    <div class="empty-state">
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" stroke="#378ADD" stroke-width="1.5" stroke-linecap="round"/>
            <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" stroke="#378ADD" stroke-width="1.5"/>
        </svg>
        <p>카테고리를 선택하거나 검색어를 입력해주세요</p>
    </div>

    <% } %>

</div>

<script>
function showLoading() {
    document.getElementById('loading-overlay').style.display = 'flex';
}
</script>

</body>
</html>