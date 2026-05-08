package model;

import java.sql.Timestamp;

public class ChatMessageDTO {
    private int messageId;
    private int roomId;
    private String senderId;
    private String senderName;
    private String message;
    private Timestamp sentAt;
    private String messageType; // text, file, system
    
    public ChatMessageDTO() {}
    
    public ChatMessageDTO(int roomId, String senderId, String senderName, String message, String messageType) {
        this.roomId = roomId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.message = message;
        this.messageType = messageType;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getSenderId() {
        return senderId;
    }

    public void setSenderId(String senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getSentAt() {
        return sentAt;
    }

    public void setSentAt(Timestamp sentAt) {
        this.sentAt = sentAt;
    }

    public String getMessageType() {
        return messageType;
    }

    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }
}
