package controller;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import model.ChatDAO;
import model.ChatMessageDTO;

@ServerEndpoint("/chat/{roomId}/{userId}")
public class ChatWebSocket {
    
    private static Map<String, Session> sessions = new ConcurrentHashMap<>();
    //private static Map<String, String> userRooms = new ConcurrentHashMap<>();
    private static Gson gson = new Gson();
    private ChatDAO chatDAO = new ChatDAO();
    
    @OnOpen
    public void onOpen(Session session, @PathParam("roomId") String roomId, @PathParam("userId") String userId) {
    	sessions.put(roomId + "_" + userId, session);
		System.out.println("WebSocket 연결: 사용자 " + userId + " -> 채팅방 " + roomId);
        
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
            JsonObject jsonMessage = gson.fromJson(message, JsonObject.class);
            String messageType = jsonMessage.get("type").getAsString();
            String content = jsonMessage.get("message").getAsString();
            String senderName = jsonMessage.has("senderName") ? jsonMessage.get("senderName").getAsString() : userId;
            
         // DB 저장
            //String senderId = userId;
            if ("system".equals(messageType)) {
                chatDAO.saveSystemMessage(Integer.parseInt(roomId), content);
            } else {
            	chatDAO.saveMessage(new ChatMessageDTO(
                        Integer.parseInt(roomId), userId, senderName, content, messageType
                    ));
            }
            
            
            // 응답 메시지 구성
            JsonObject response = new JsonObject();
            response.addProperty("type", messageType);
            response.addProperty("senderId", userId);
            response.addProperty("senderName", senderName);
            response.addProperty("message", content);
            response.addProperty("timestamp", System.currentTimeMillis());
            
            // 같은 채팅방의 모든 사용자에게 브로드캐스트
            broadcastToRoom(roomId, response.toString(), null);
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(session, "메시지 처리 중 오류가 발생했습니다.");
        }
    }
    
    @OnClose
    public void onClose(Session session, @PathParam("roomId") String roomId, @PathParam("userId") String userId) {
    	sessions.remove(roomId + "_" + userId);
        System.out.println("WebSocket 연결 종료: 사용자 " + userId + " <- 채팅방 " + roomId);
        
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
}
