package controller;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpSession;
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import model.ChatDAO;
import model.ChatMessageDTO;
import model.LoginDTO;

@ServerEndpoint(value = "/chat/{roomId}/{userId}", configurator = HttpSessionConfigurator.class)
public class ChatWebSocket {
    
    private static Map<String, Session> sessions = new ConcurrentHashMap<>();
    //private static Map<String, String> userRooms = new ConcurrentHashMap<>();
    private static Gson gson = new Gson();
    private ChatDAO chatDAO = new ChatDAO();
    
    @OnOpen
    public void onOpen(Session session, @PathParam("roomId") String roomId, @PathParam("userId") String userId) {
        try {
            LoginDTO loginUser = getLoginUser(session);
            int parsedRoomId = Integer.parseInt(roomId);

            if (loginUser == null || !loginUser.getId().equals(userId)
                    || !chatDAO.isRoomMember(parsedRoomId, loginUser.getId())) {
                close(session, "채팅방 접근 권한이 없습니다.");
                return;
            }

            sessions.put(roomId + "_" + loginUser.getId(), session);
            session.getUserProperties().put("loginUserId", loginUser.getId());
            session.getUserProperties().put("loginUserName", loginUser.getName());
            System.out.println("WebSocket 연결: 사용자 " + loginUser.getId() + " -> 채팅방 " + roomId);
        } catch (Exception e) {
            e.printStackTrace();
            close(session, "채팅 연결 검증 중 오류가 발생했습니다.");
            return;
        }
        
        // 입장 알림
        /*JsonObject joinMessage = new JsonObject();
        joinMessage.addProperty("type", "system");
        joinMessage.addProperty("message", userId + "님이 입장했습니다.");
        joinMessage.addProperty("roomId", roomId);
        
        broadcastToRoom(roomId, joinMessage.toString(), null);*/
    }
    
    @OnMessage
    public void onMessage(String message, Session session, @PathParam("roomId") String roomId, @PathParam("userId") String userId) {
        try {
            LoginDTO loginUser = getLoginUser(session);
            int parsedRoomId = Integer.parseInt(roomId);
            if (loginUser == null || !loginUser.getId().equals(userId)
                    || !chatDAO.isRoomMember(parsedRoomId, loginUser.getId())) {
                close(session, "채팅방 접근 권한이 없습니다.");
                return;
            }

            JsonObject jsonMessage = gson.fromJson(message, JsonObject.class);
            String messageType = jsonMessage.get("type").getAsString();
            String content = jsonMessage.get("message").getAsString();
            String senderName = loginUser.getName() != null ? loginUser.getName() : loginUser.getId();

            // DB 저장
            if ("system".equals(messageType)) {
                chatDAO.saveSystemMessage(parsedRoomId, content);
            } else {
                // image 타입도 message 컬럼에 URL 저장, messageType = 'file'
                String dbType = "image".equals(messageType) ? "file" : messageType;
                chatDAO.saveMessage(new ChatMessageDTO(
                    parsedRoomId, loginUser.getId(), senderName, content, dbType
                ));
            }

            // 응답 메시지 구성
            JsonObject response = new JsonObject();
            response.addProperty("type", messageType);
            response.addProperty("senderId", loginUser.getId());
            response.addProperty("senderName", senderName);
            response.addProperty("message", content);
            response.addProperty("timestamp", System.currentTimeMillis());

            broadcastToRoom(roomId, response.toString(), null);

        } catch (Exception e) {
            e.printStackTrace();
            sendError(session, "메시지 처리 중 오류가 발생했습니다.");
        }
    }
    
    @OnClose
    public void onClose(Session session, @PathParam("roomId") String roomId, @PathParam("userId") String userId) {
        String loginUserId = (String) session.getUserProperties().get("loginUserId");
        String removeUserId = loginUserId != null ? loginUserId : userId;
        sessions.remove(roomId + "_" + removeUserId);
        System.out.println("WebSocket 연결 종료: 사용자 " + removeUserId + " <- 채팅방 " + roomId);
        
        // 퇴장 알림
        /*JsonObject leaveMessage = new JsonObject();
        leaveMessage.addProperty("type", "system");
        leaveMessage.addProperty("message", userId + "님이 퇴장했습니다.");
        leaveMessage.addProperty("roomId", roomId);
        
        broadcastToRoom(roomId, leaveMessage.toString(), null);*/
    }
    
    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("WebSocket 오류: " + throwable.getMessage());
        throwable.printStackTrace();
    }
    
    // 특정 채팅방의 모든 사용자에게 메시지 전송
    public static void broadcastToRoom(String roomId, String message, String excludeUserId) {
        sessions.forEach((key, session) -> {
            if (key.startsWith(roomId + "_")) {
                String uid = key.substring(roomId.length() + 1);
                if (excludeUserId == null || !uid.equals(excludeUserId)) {
                    try {
                        if (session.isOpen()) {
                            session.getBasicRemote().sendText(message);
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }
    
    // 에러 메시지 전송
    private void sendError(Session session, String errorMessage) {
        try {
            JsonObject error = new JsonObject();
            error.addProperty("type", "error");
            error.addProperty("message", errorMessage);
            session.getBasicRemote().sendText(error.toString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private LoginDTO getLoginUser(Session session) {
        HttpSession httpSession = (HttpSession) session.getUserProperties().get(HttpSession.class.getName());
        return httpSession != null ? (LoginDTO) httpSession.getAttribute("loginUser") : null;
    }

    private void close(Session session, String reason) {
        try {
            if (session.isOpen()) {
                session.close(new CloseReason(CloseReason.CloseCodes.VIOLATED_POLICY, reason));
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
