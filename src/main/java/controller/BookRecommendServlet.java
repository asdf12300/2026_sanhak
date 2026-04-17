package controller;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet("/bookRecommend")
public class BookRecommendServlet extends HttpServlet {

    private String API_KEY;

    @Override
    public void init() throws ServletException {
        try {
            Properties props = new Properties();
            props.load(getServletContext().getResourceAsStream("/WEB-INF/config.properties"));
            API_KEY = props.getProperty("groq.api.key");
        } catch (IOException e) {
            throw new ServletException("API 키 로드 실패", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");
        String query = request.getParameter("query");

        String prompt;
        if (query != null && !query.trim().isEmpty()) {
            prompt = String.format(
                "%s 관련 도서 12권 추천해줘. " +
                "반드시 아래 JSON 배열 형식으로만 답해줘:\n" +
                "[{\"title\":\"제목\",\"titleEn\":\"English Title\",\"author\":\"저자\",\"desc\":\"한줄소개\"}]",
                query
            );
            request.setAttribute("category", query);
        } else if (category != null && !category.trim().isEmpty()) {
            prompt = String.format(
                "\"%s\" 카테고리 관련 도서 12권 추천해줘. " +
                "반드시 아래 JSON 배열 형식으로만 답해줘:\n" +
                "[{\"title\":\"제목\",\"titleEn\":\"English Title\",\"author\":\"저자\",\"desc\":\"한줄소개\"}]",
                category
            );
            request.setAttribute("category", category);
        } else {
            request.getRequestDispatcher("/bookRecommend.jsp").forward(request, response);
            return;
        }

        Gson gson = new Gson();

        JsonObject message = new JsonObject();
        message.addProperty("role", "user");
        message.addProperty("content", prompt);

        JsonArray messages = new JsonArray();
        messages.add(message);

        JsonObject requestJson = new JsonObject();
        requestJson.addProperty("model", "llama-3.3-70b-versatile");
        requestJson.add("messages", messages);
        requestJson.addProperty("max_tokens", 3000);

        String requestBody = gson.toJson(requestJson);

        try {
            HttpClient client = HttpClient.newBuilder().build();

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.groq.com/openai/v1/chat/completions"))
                    .header("Authorization", "Bearer " + API_KEY)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody, StandardCharsets.UTF_8))
                    .build();

            long start = System.currentTimeMillis();
            HttpResponse<byte[]> apiResponse = client.send(req, HttpResponse.BodyHandlers.ofByteArray());
            String body = new String(apiResponse.body(), StandardCharsets.UTF_8);
            System.out.println("Groq 응답 시간: " + (System.currentTimeMillis() - start) + "ms");
            System.out.println("Groq status code: " + apiResponse.statusCode());
            System.out.println("Groq 응답 body: " + body);

            JsonObject json = JsonParser.parseString(body).getAsJsonObject();
            String content = json.getAsJsonArray("choices")
                    .get(0).getAsJsonObject()
                    .getAsJsonObject("message")
                    .get("content").getAsString();

            content = content.replaceAll("```json", "").replaceAll("```", "").trim();
            System.out.println("파싱된 content: " + content);

            JsonArray books = JsonParser.parseString(content).getAsJsonArray();
            System.out.println("books 파싱 결과 수: " + books.size());

            ExecutorService executor = Executors.newFixedThreadPool(12);
            List<CompletableFuture<JsonObject>> futures = new ArrayList<>();

            for (int i = 0; i < books.size(); i++) {
                JsonObject book = books.get(i).getAsJsonObject();
                CompletableFuture<JsonObject> future = CompletableFuture.supplyAsync(() -> {
                    String title = book.get("title").getAsString();
                    String titleEn = book.has("titleEn") ? book.get("titleEn").getAsString() : "";
                    String author = book.get("author").getAsString();
                    String imageUrl = getBookImageUrl(client, title, titleEn, author);
                    if (!imageUrl.isEmpty()) {
                        book.addProperty("image", imageUrl);
                    }
                    return book;
                }, executor);
                futures.add(future);
            }

            long imageStart = System.currentTimeMillis();
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
            System.out.println("이미지 조회 시간: " + (System.currentTimeMillis() - imageStart) + "ms");

            JsonArray filteredBooks = new JsonArray();
            List<JsonObject> noImageBooks = new ArrayList<>();

            for (CompletableFuture<JsonObject> future : futures) {
                try {
                    JsonObject book = future.getNow(null);
                    if (book == null) continue;
                    if (book.has("image")) {
                        if (filteredBooks.size() < 6) filteredBooks.add(book);
                    } else {
                        noImageBooks.add(book);
                    }
                } catch (Exception e) {
                    System.out.println("병렬 처리 오류: " + e.getMessage());
                }
            }

            for (JsonObject book : noImageBooks) {
                if (filteredBooks.size() >= 6) break;
                filteredBooks.add(book);
            }

            System.out.println("최종 표시 책 수: " + filteredBooks.size());
            executor.shutdown();

            request.setAttribute("books", filteredBooks.toString());
            request.getRequestDispatcher("/bookRecommend.jsp").forward(request, response);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ServletException("API 호출 중 인터럽트 발생", e);
        }
    }

    private String getBookImageUrl(HttpClient client, String title, String titleEn, String author) {
        String result = searchBookImage(client, title + " " + author);
        if (!result.isEmpty()) return result;

        if (!titleEn.isEmpty()) {
            result = searchBookImage(client, titleEn + " " + author);
            if (!result.isEmpty()) return result;
        }

        result = searchBookImage(client, titleEn.isEmpty() ? title : titleEn);
        return result;
    }

    private String searchBookImage(HttpClient client, String query) {
        try {
            String encoded = URLEncoder.encode(query, StandardCharsets.UTF_8);
            String url = "https://www.googleapis.com/books/v1/volumes?q=" + encoded + "&maxResults=1";

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<byte[]> res = client.send(req, HttpResponse.BodyHandlers.ofByteArray());
            String body = new String(res.body(), StandardCharsets.UTF_8);
            JsonObject json = JsonParser.parseString(body).getAsJsonObject();

            JsonArray items = json.getAsJsonArray("items");
            if (items != null && items.size() > 0) {
                JsonObject volumeInfo = items.get(0).getAsJsonObject()
                        .getAsJsonObject("volumeInfo");
                JsonObject imageLinks = volumeInfo.getAsJsonObject("imageLinks");
                if (imageLinks != null && imageLinks.has("thumbnail")) {
                    String url2 = imageLinks.get("thumbnail").getAsString().replace("http://", "https://");
                    System.out.println("이미지 URL: " + url2);
                    return url2;
                }
            }
        } catch (Exception e) {
            System.out.println("이미지 조회 실패: " + e.getMessage());
        }
        return "";
    }
}