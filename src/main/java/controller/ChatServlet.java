package controller;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.google.gson.Gson;

import model.*;

@WebServlet("/ChatServlet")
@MultipartConfig(
    maxFileSize    = 10 * 1024 * 1024,
    maxRequestSize = 12 * 1024 * 1024
)
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ChatDAO chatDAO = new ChatDAO();
    private ProjectMemberDAO projectMemberDAO = new ProjectMemberDAO();
    private Gson gson = new Gson();

    private static final String UPLOAD_DIR = "uploads/chat";
    private String getUploadPath() {
        return getServletContext().getRealPath("/") + UPLOAD_DIR;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        LoginDTO user = (LoginDTO) session.getAttribute("loginUser");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 교수는 채팅 접근 불가
        if ("professor".equals(user.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        if ("getRooms".equals(action)) {
            getRooms(request, response, user);
        }else if ("getMessages".equals(action)) {
            getMessages(request, response, user);
        } else if ("getRoomInfo".equals(action)) {
            getRoomInfo(request, response, user);
        } else if ("getInvitableMembers".equals(action)) {
            getInvitableMembers(request, response, user);
        } else {
            request.getRequestDispatcher("chat.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        LoginDTO user = (LoginDTO) session.getAttribute("loginUser");

        System.out.println("[ChatServlet] doPost action=" + action + ", user=" + (user != null ? user.getId() : "null"));

        if (user == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"로그인이 필요합니다\"}");
            return;
        }

        // 교수는 채팅 접근 불가
        if ("professor".equals(user.getRole())) {
            response.getWriter().write("{\"success\": false, \"message\": \"교수는 채팅을 사용할 수 없습니다\"}");
            return;
        }

        try {
            if ("createRoom".equals(action)) {
                createRoom(request, response, user);
            } else if ("createPersonalChat".equals(action)) {
                createPersonalChat(request, response, user);
            } else if ("markAsRead".equals(action)) {
                markAsRead(request, response, user);
            } else if ("leaveRoom".equals(action)) {
                leaveRoom(request, response, user);
            } else if ("renameRoom".equals(action)) {
                renameRoom(request, response, user);
            } else if ("uploadImage".equals(action)) {
                uploadImage(request, response, user);
            } else if ("addMember".equals(action)) {
                addMember(request, response, user);
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"알 수 없는 action: " + action + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"최상위 오류: " + e.getMessage() + "\"}");
        }
    }

    // 채팅방 목록 조회
    private void getRooms(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");

        try {
            int projectId = Integer.parseInt(request.getParameter("projectId"));

            System.out.println("[ChatServlet] getRooms projectId=" + projectId + ", user=" + user.getId());

            List<ChatRoomDTO> rooms = chatDAO.getChatRoomsByProject(projectId, user.getId());

            System.out.println("[ChatServlet] getRooms result count=" + rooms.size());

            response.getWriter().write(gson.toJson(rooms));

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    // 채팅 메시지 조회
    private void getMessages(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        int limit = request.getParameter("limit") != null ? Integer.parseInt(request.getParameter("limit")) : 30;
        int offset = request.getParameter("offset") != null ? Integer.parseInt(request.getParameter("offset")) : 0;

        // 채팅방 멤버 확인
        if (!chatDAO.isRoomMember(roomId, user.getId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<ChatMessageDTO> messages = chatDAO.getMessages(roomId, limit, offset);
        
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(gson.toJson(messages));
    }

    // 채팅방 정보 조회
    private void getRoomInfo(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));

            if (!chatDAO.isRoomMember(roomId, user.getId())) {
                response.getWriter().write("{\"success\": false, \"message\": \"권한 없음\"}");
                return;
            }

            ChatRoomDTO room = chatDAO.getChatRoom(roomId);
            List<java.util.Map<String, String>> members = chatDAO.getRoomMembersWithName(roomId);

            // Gson 익명 클래스 직렬화 문제 우회 → Map으로 직접 구성
            java.util.Map<String, Object> result = new java.util.HashMap<>();
            result.put("room", room);
            result.put("members", members);

            response.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
  // 팀 채팅방 생성
    private void createRoom(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");

        try {
            int projectId = Integer.parseInt(request.getParameter("projectId"));
            String roomName = request.getParameter("roomName");
            String roomType = request.getParameter("roomType");

            if (roomName == null || roomName.trim().isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"채팅방 이름이 없습니다\"}");
                return;
            }

            ChatRoomDTO room = new ChatRoomDTO(projectId, roomName.trim(), roomType);
            int roomId = chatDAO.createChatRoom(room);

            if (roomId > 0) {
                if ("team".equals(roomType)) {
                    List<ProjectMemberDTO> members = projectMemberDAO.getMembersByProject(projectId);

                    // 1단계: 멤버 추가 (교수 제외)
                    boolean creatorAdded = false;
                    for (ProjectMemberDTO member : members) {
                        if ("accepted".equals(member.getStatus()) && !"professor".equals(member.getRole())) {
                            chatDAO.addRoomMember(roomId, member.getMemberId());
                            if (member.getMemberId().equals(user.getId())) {
                                creatorAdded = true;
                            }
                        }
                    }
                    if (!creatorAdded) {
                        chatDAO.addRoomMember(roomId, user.getId());
                    }

                    // 2단계: 시스템 메시지 저장 (교수 제외, 생성자 → "참가", 나머지 → "초대")
                    for (ProjectMemberDTO member : members) {
                        if ("accepted".equals(member.getStatus()) && !"professor".equals(member.getRole())) {
                            String name = (member.getName() != null && !member.getName().isEmpty())
                                          ? member.getName() : member.getMemberId();
                            if (member.getMemberId().equals(user.getId())) {
                                chatDAO.saveSystemMessage(roomId, name + " 님이 채팅방에 참가하였습니다.");
                            } else {
                                chatDAO.saveSystemMessage(roomId, name + " 님이 초대되었습니다.");
                            }
                        }
                    }
                    if (!creatorAdded) {
                        chatDAO.saveSystemMessage(roomId, user.getName() + " 님이 채팅방에 참가하였습니다.");
                    }

                } else {
                    // 개인 채팅방
                    chatDAO.addRoomMember(roomId, user.getId());
                }
                response.getWriter().write("{\"success\": true, \"roomId\": " + roomId + "}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"DB 저장 실패\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"서버 오류: " + e.getMessage() + "\"}");
        }
    }

    // 개인 채팅방 생성 또는 조회
    private void createPersonalChat(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");

        try {
            int projectId = Integer.parseInt(request.getParameter("projectId"));
            String targetMemberId = request.getParameter("targetMemberId");

            if (targetMemberId == null || targetMemberId.trim().isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"대상 멤버가 없습니다\"}");
                return;
            }

            // 기존 개인 채팅방 확인
            Integer existingRoomId = chatDAO.getPersonalChatRoom(projectId, user.getId(), targetMemberId);

            int roomId;
            if (existingRoomId != null) {
                roomId = existingRoomId;
            } else {
                String roomName = user.getName() + " & " + targetMemberId;
                ChatRoomDTO room = new ChatRoomDTO(projectId, roomName, "personal");
                roomId = chatDAO.createChatRoom(room);

                if (roomId > 0) {
                    chatDAO.addRoomMember(roomId, user.getId());
                    chatDAO.addRoomMember(roomId, targetMemberId);
                }
            }

            if (roomId > 0) {
                response.getWriter().write("{\"success\": true, \"roomId\": " + roomId + "}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"채팅방 생성 실패\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"서버 오류: " + e.getMessage() + "\"}");
        }
    }

    // 읽음 처리
    private void markAsRead(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            boolean success = chatDAO.updateLastReadTime(roomId, user.getId());
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false}");
        }
    }

    // 채팅방 나가기
    private void leaveRoom(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            // 멤버인지 확인
            if (!chatDAO.isRoomMember(roomId, user.getId())) {
                response.getWriter().write("{\"success\": false, \"message\": \"채팅방 멤버가 아닙니다\"}");
                return;
            }
            // chat_room_members에서 제거
            boolean removed = chatDAO.removeRoomMember(roomId, user.getId());
            if (removed) {
                // 시스템 메시지 DB 저장
                chatDAO.saveSystemMessage(roomId, user.getName() + " 님이 나갔습니다.");

                // 현재 채팅방 접속자에게 실시간 전송
                /*com.google.gson.JsonObject broadcast = new com.google.gson.JsonObject();
                broadcast.addProperty("type",    "system");
                broadcast.addProperty("message", user.getName() + " 님이 나갔습니다.");
                ChatWebSocket.broadcastToRoom(String.valueOf(roomId), broadcast.toString(), null);*/

                response.getWriter().write("{\"success\": true}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"나가기 처리 실패\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"서버 오류: " + e.getMessage() + "\"}");
        }
    }

    // 채팅방 이름 변경
    private void renameRoom(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String newName = request.getParameter("newName");
            if (newName == null || newName.trim().isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"이름을 입력해주세요\"}");
                return;
            }
            // 멤버인지 확인
            if (!chatDAO.isRoomMember(roomId, user.getId())) {
                response.getWriter().write("{\"success\": false, \"message\": \"채팅방 멤버가 아닙니다\"}");
                return;
            }
            boolean updated = chatDAO.updateRoomName(roomId, newName.trim());

            if (updated) {
                // 이름 변경 시스템 메시지 저장
                chatDAO.saveSystemMessage(roomId,
                    user.getName() + " 님이 채팅방 이름을 '" + newName.trim() + "'(으)로 변경했습니다.");

                // 현재 접속자에게 실시간 전송 (이름 변경 알림)
                /*com.google.gson.JsonObject broadcast = new com.google.gson.JsonObject();
                broadcast.addProperty("type",    "system");
                broadcast.addProperty("message", user.getName() + " 님이 채팅방 이름을 '" + newName.trim() + "'(으)로 변경했습니다.");
                broadcast.addProperty("renameRoom", true);
                broadcast.addProperty("newName", newName.trim());
                ChatWebSocket.broadcastToRoom(String.valueOf(roomId), broadcast.toString(), null);*/
                response.getWriter().write("{\"success\": true}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"이름 변경 실패\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"서버 오류: " + e.getMessage() + "\"}");
        }
    }

    // 프로젝트 멤버 확인
    private boolean isProjectMember(int projectId, String memberId) {
        return projectMemberDAO.isActiveMember(projectId, memberId);
    }

    // 채팅방에 초대 가능한 프로젝트 멤버 조회
    private void getInvitableMembers(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        try {
            int roomId    = Integer.parseInt(request.getParameter("roomId"));
            int projectId = Integer.parseInt(request.getParameter("projectId"));

            if (!chatDAO.isRoomMember(roomId, user.getId())) {
                response.getWriter().write("[]");
                return;
            }

            List<java.util.Map<String, String>> members = chatDAO.getInvitableMembers(roomId, projectId, user.getId());
            response.getWriter().write(gson.toJson(members));
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    // 채팅방에 멤버 추가 (초대)
    private void addMember(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        try {
            int    roomId         = Integer.parseInt(request.getParameter("roomId"));
            String targetMemberId = request.getParameter("targetMemberId");
            String targetName     = request.getParameter("targetName");

            if (targetMemberId == null || targetMemberId.trim().isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"대상 멤버가 없습니다\"}");
                return;
            }
            if (!chatDAO.isRoomMember(roomId, user.getId())) {
                response.getWriter().write("{\"success\": false, \"message\": \"권한 없음\"}");
                return;
            }

            boolean added = chatDAO.addRoomMember(roomId, targetMemberId);
            if (added) {
                String displayName = (targetName != null && !targetName.trim().isEmpty())
                                     ? targetName : targetMemberId;
                chatDAO.saveSystemMessage(roomId,
                    user.getName() + " 님이 " + displayName + " 님을 초대했습니다.");
                response.getWriter().write("{\"success\": true}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"멤버 추가 실패\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"서버 오류: " + e.getMessage() + "\"}");
        }
    }

    // 채팅 이미지 업로드
    private void uploadImage(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException, ServletException {
        response.setContentType("application/json; charset=UTF-8");
        try {
            Part filePart = request.getPart("image");
            if (filePart == null || filePart.getSize() == 0) {
                response.getWriter().write("{\"success\": false, \"message\": \"파일이 없습니다\"}");
                return;
            }

            // 이미지 확장자 검증
            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf('.')).toLowerCase() : "";
            if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png")
                    && !ext.equals(".gif") && !ext.equals(".webp")) {
                response.getWriter().write("{\"success\": false, \"message\": \"이미지 파일만 업로드 가능합니다\"}");
                return;
            }

            String savedName = UUID.randomUUID().toString() + ext;
            java.io.File uploadDir = new java.io.File(getUploadPath());
            if (!uploadDir.exists()) uploadDir.mkdirs();

            java.io.File dest = new java.io.File(uploadDir, savedName);
            filePart.write(dest.getAbsolutePath());

            // 접근 가능한 URL 반환
            String imageUrl = request.getContextPath() + "/uploads/chat/" + savedName;
            response.getWriter().write("{\"success\": true, \"imageUrl\": \"" + imageUrl + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"업로드 실패: " + e.getMessage() + "\"}");
        }
    }
}
