package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {
    
    // 채팅방 생성
    public int createChatRoom(ChatRoomDTO room) {
        String sql = "INSERT INTO chat_rooms (project_id, room_name, room_type, created_at) VALUES (?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, room.getProjectId());
            pstmt.setString(2, room.getRoomName());
            pstmt.setString(3, room.getRoomType());
            pstmt.executeUpdate();
            
            ResultSet rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }
    
    // 채팅방 멤버 추가 (이미 있으면 무시)
    public boolean addRoomMember(int roomId, String memberId) {
        String sql = "INSERT IGNORE INTO chat_room_members (room_id, member_id, joined_at) VALUES (?, ?, NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            pstmt.setString(2, memberId);
            pstmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 채팅방 멤버 제거 (나가기)
    public boolean removeRoomMember(int roomId, String memberId) {
        String sql = "DELETE FROM chat_room_members WHERE room_id = ? AND member_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 채팅방 이름 변경
    public boolean updateRoomName(int roomId, String newName) {
        String sql = "UPDATE chat_rooms SET room_name = ? WHERE room_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newName);
            pstmt.setInt(2, roomId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 사용자가 속한 프로젝트의 채팅방 목록 조회
    public List<ChatRoomDTO> getChatRoomsByProject(int projectId, String memberId) {
        List<ChatRoomDTO> rooms = new ArrayList<>();
        String sql = "SELECT DISTINCT cr.room_id, cr.project_id, cr.room_name, cr.room_type, cr.created_at, " +
                     "(SELECT message FROM chat_messages WHERE room_id = cr.room_id ORDER BY sent_at DESC LIMIT 1) as last_message, " +
                     "(SELECT sent_at FROM chat_messages WHERE room_id = cr.room_id ORDER BY sent_at DESC LIMIT 1) as last_message_time, " +
                     "(SELECT COUNT(*) FROM chat_messages cm WHERE cm.room_id = cr.room_id AND cm.sender_id != ? " +
                     "AND cm.sent_at > COALESCE((SELECT last_read_at FROM chat_room_members WHERE room_id = cr.room_id AND member_id = ?), '1970-01-01')) as unread_count " +
                     "FROM chat_rooms cr " +
                     "INNER JOIN chat_room_members crm ON cr.room_id = crm.room_id " +
                     "WHERE cr.project_id = ? AND crm.member_id = ? " +
                     "ORDER BY last_message_time DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, memberId);
            pstmt.setString(2, memberId);
            pstmt.setInt(3, projectId);
            pstmt.setString(4, memberId);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ChatRoomDTO room = new ChatRoomDTO();
                room.setRoomId(rs.getInt("room_id"));
                room.setProjectId(rs.getInt("project_id"));
                room.setRoomName(rs.getString("room_name"));
                room.setRoomType(rs.getString("room_type"));
                room.setCreatedAt(rs.getTimestamp("created_at"));
                room.setLastMessage(rs.getString("last_message"));
                room.setLastMessageTime(rs.getTimestamp("last_message_time"));
                room.setUnreadCount(rs.getInt("unread_count"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
    
    // 채팅방 정보 조회
    public ChatRoomDTO getChatRoom(int roomId) {
        String sql = "SELECT * FROM chat_rooms WHERE room_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                ChatRoomDTO room = new ChatRoomDTO();
                room.setRoomId(rs.getInt("room_id"));
                room.setProjectId(rs.getInt("project_id"));
                room.setRoomName(rs.getString("room_name"));
                room.setRoomType(rs.getString("room_type"));
                room.setCreatedAt(rs.getTimestamp("created_at"));
                return room;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // 채팅방 멤버 확인
    public boolean isRoomMember(int roomId, String memberId) {
        String sql = "SELECT COUNT(*) FROM chat_room_members WHERE room_id = ? AND member_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            pstmt.setString(2, memberId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 채팅 메시지 저장
    public boolean saveMessage(ChatMessageDTO message) {
        String sql = "INSERT INTO chat_messages (room_id, sender_id, sender_name, message, message_type, sent_at) " +
                     "VALUES (?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, message.getRoomId());
            pstmt.setString(2, message.getSenderId());
            pstmt.setString(3, message.getSenderName());
            pstmt.setString(4, message.getMessage());
            pstmt.setString(5, message.getMessageType());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 시스템 메시지 저장 (sender_id FK 제약 없이 저장)
    public boolean saveSystemMessage(int roomId, String content) {
        // sender_id 컬럼의 FK 제약을 피하기 위해 NULL로 저장
        String sql = "INSERT INTO chat_messages (room_id, sender_id, sender_name, message, message_type, sent_at) " +
                     "VALUES (?, NULL, 'system', ?, 'system', NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            pstmt.setString(2, content);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    // 다른 Servlet 코드들에서 오류가나서 추가한 코드
    /*public boolean saveSystemMessage(Integer roomId, String content) {
        if (roomId == null) return false;
        return saveSystemMessage(roomId.intValue(), content);
    }*/
    
    // 채팅 메시지 조회 (페이징)
    public List<ChatMessageDTO> getRecentMessages(int roomId, int limit) {
        List<ChatMessageDTO> messages = new ArrayList<>();
        String sql = "SELECT * FROM (SELECT * FROM chat_messages WHERE room_id = ? ORDER BY sent_at DESC LIMIT ?) tmp ORDER BY sent_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            pstmt.setInt(2, limit);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ChatMessageDTO message = new ChatMessageDTO();
                message.setMessageId(rs.getInt("message_id"));
                message.setRoomId(rs.getInt("room_id"));
                message.setSenderId(rs.getString("sender_id"));
                message.setSenderName(rs.getString("sender_name"));
                message.setMessage(rs.getString("message"));
                message.setMessageType(rs.getString("message_type"));
                message.setSentAt(rs.getTimestamp("sent_at"));
                messages.add(message);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }
    
 // 채팅 메시지 조회 (페이징)
    public List<ChatMessageDTO> getMessages(int roomId, int limit, int offset) {
        List<ChatMessageDTO> messages = new ArrayList<>();
        String sql = "SELECT * FROM chat_messages WHERE room_id = ? ORDER BY sent_at ASC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ChatMessageDTO message = new ChatMessageDTO();
                message.setMessageId(rs.getInt("message_id"));
                message.setRoomId(rs.getInt("room_id"));
                message.setSenderId(rs.getString("sender_id"));
                message.setSenderName(rs.getString("sender_name"));
                message.setMessage(rs.getString("message"));
                message.setMessageType(rs.getString("message_type"));
                message.setSentAt(rs.getTimestamp("sent_at"));
                messages.add(message);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }
    
    // 마지막 읽은 시간 업데이트
    public boolean updateLastReadTime(int roomId, String memberId) {
        String sql = "UPDATE chat_room_members SET last_read_at = NOW() WHERE room_id = ? AND member_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 개인 채팅방 존재 여부 확인 (두 사용자 간)
    public Integer getPersonalChatRoom(int projectId, String member1, String member2) {
        String sql = "SELECT cr.room_id FROM chat_rooms cr " +
                     "INNER JOIN chat_room_members crm1 ON cr.room_id = crm1.room_id " +
                     "INNER JOIN chat_room_members crm2 ON cr.room_id = crm2.room_id " +
                     "WHERE cr.project_id = ? AND cr.room_type = 'personal' " +
                     "AND crm1.member_id = ? AND crm2.member_id = ? " +
                     "AND (SELECT COUNT(*) FROM chat_room_members WHERE room_id = cr.room_id) = 2";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, projectId);
            pstmt.setString(2, member1);
            pstmt.setString(3, member2);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("room_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // 채팅방 멤버 목록 조회 (ID + 이름)
    public List<java.util.Map<String, String>> getRoomMembersWithName(int roomId) {
        List<java.util.Map<String, String>> members = new ArrayList<>();
        String sql = "SELECT crm.member_id, m.name " +
                     "FROM chat_room_members crm " +
                     "LEFT JOIN member m ON crm.member_id = m.id " +
                     "WHERE crm.room_id = ? " +
                     "ORDER BY crm.joined_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                java.util.Map<String, String> member = new java.util.HashMap<>();
                member.put("memberId", rs.getString("member_id"));
                member.put("name", rs.getString("name") != null ? rs.getString("name") : rs.getString("member_id"));
                members.add(member);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return members;
    }

    /**
     * 채팅방에 초대 가능한 프로젝트 멤버 조회
     * - 프로젝트에 accepted 상태로 참여 중인 학생(교수 제외)
     * - 현재 채팅방에 없는 사람 (나간 사람 포함 — 나가면 chat_room_members에서 삭제되므로 재초대 가능)
     */
    public List<java.util.Map<String, String>> getInvitableMembers(int roomId, int projectId, String requesterId) {
        List<java.util.Map<String, String>> members = new ArrayList<>();
        String sql = "SELECT pm.member_id, m.name " +
                     "FROM project_member pm " +
                     "LEFT JOIN member m ON pm.member_id = m.id " +
                     "WHERE pm.project_id = ? " +
                     "  AND pm.status = 'accepted' " +
                     "  AND m.role != 'professor' " +
                     "  AND pm.member_id != ? " +
                     "  AND pm.member_id NOT IN (" +
                     "      SELECT member_id FROM chat_room_members WHERE room_id = ?" +
                     "  ) " +
                     "ORDER BY m.name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, projectId);
            pstmt.setString(2, requesterId);
            pstmt.setInt(3, roomId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                java.util.Map<String, String> member = new java.util.HashMap<>();
                member.put("memberId", rs.getString("member_id"));
                member.put("name", rs.getString("name") != null ? rs.getString("name") : rs.getString("member_id"));
                members.add(member);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return members;
    }

    // 채팅방 멤버 목록 조회 (ID만, 기존 호환용)
    public List<String> getRoomMembers(int roomId) {
        List<String> members = new ArrayList<>();
        String sql = "SELECT member_id FROM chat_room_members WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                members.add(rs.getString("member_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return members;
    }

    // 프로젝트의 팀 채팅방 ID 목록 조회
    public List<Integer> getTeamChatRoomIds(int projectId) {
        List<Integer> roomIds = new ArrayList<>();
        String sql = "SELECT room_id FROM chat_rooms WHERE project_id = ? AND room_type = 'team'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, projectId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                roomIds.add(rs.getInt("room_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return roomIds;
    }
    
}
