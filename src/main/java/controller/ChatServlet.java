package controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;

import model.*;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ChatDAO chatDAO = new ChatDAO();
    private ProjectMemberDAO projectMemberDAO = new ProjectMemberDAO();
    private Gson gson = new Gson();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        LoginDTO user = (LoginDTO) session.getAttribute("loginUser");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if ("getRooms".equals(action)) {
            getRooms(request, response, user);
        } else if ("getMessages".equals(action)) {
            getMessages(request, response, user);
        } else if ("getRoomInfo".equals(action)) {
            getRoomInfo(request, response, user);
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

        try {
            if ("createRoom".equals(action)) {
                createRoom(request, response, user);
            } else if ("createPersonalChat".equals(action)) {
                createPersonalChat(request, response, user);
            } else if ("markAsRead".equals(action)) {
                markAsRead(request, response, user);
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
        int limit = request.getParameter("limit") != null ? Integer.parseInt(request.getParameter("limit")) : 50;
        int offset = request.getParameter("offset") != null ? Integer.parseInt(request.getParameter("offset")) : 0;

        // 채팅방 멤버 확인
        if (!chatDAO.isRoomMember(roomId, user.getId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<ChatMessageDTO> messages;
        if ("recent".equals(request.getParameter("type"))) {
            messages = chatDAO.getRecentMessages(roomId, limit); // ← 추가
        } else {
            messages = chatDAO.getMessages(roomId, limit, offset);
        }

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(gson.toJson(messages));
    }

    // 채팅방 정보 조회
    private void getRoomInfo(HttpServletRequest request, HttpServletResponse response, LoginDTO user)
            throws IOException {
        int roomId = Integer.parseInt(request.getParameter("roomId"));

        // 채팅방 멤버 확인
        if (!chatDAO.isRoomMember(roomId, user.getId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        ChatRoomDTO room = chatDAO.getChatRoom(roomId);
        List<String> members = chatDAO.getRoomMembers(roomId);
        
        final ChatRoomDTO finalRoom = room;
        final List<String> finalMembers = members;
        
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(gson.toJson(new Object() {
            public ChatRoomDTO room = finalRoom;
            public List<String> members = finalMembers;
        }));
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
                    for (ProjectMemberDTO member : members) {
                        if ("accepted".equals(member.getStatus())) {
                            chatDAO.addRoomMember(roomId, member.getMemberId());
                        }
                    }
                    // 팀장이 project_member에 없을 경우를 대비해 생성자도 추가
                    chatDAO.addRoomMember(roomId, user.getId());
                } else {
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

    // 프로젝트 멤버 확인
    private boolean isProjectMember(int projectId, String memberId) {
        return projectMemberDAO.isActiveMember(projectId, memberId);
    }
}
