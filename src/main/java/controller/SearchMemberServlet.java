package controller;

import model.MemberDAO;
import model.MemberDTO;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;

@WebServlet("/searchMembers")
public class SearchMemberServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // GET 요청 한글 처리
        request.setCharacterEncoding("UTF-8");
        String keyword = request.getParameter("keyword");
        if(keyword == null) keyword = "";

        // 한글 JSON 출력
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 디버깅용 로그
        System.out.println("검색어 수신: " + keyword);

        try {
            Connection conn = model.DBConnection.getConnection();

            MemberDAO dao = new MemberDAO(conn);
            List<MemberDTO> memberList = dao.searchMembers(keyword);

            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for(int i=0; i<memberList.size(); i++){
                MemberDTO m = memberList.get(i);
                sb.append("{");
                sb.append("\"id\":\"").append(m.getId()).append("\",");
                sb.append("\"name\":\"").append(m.getName()).append("\"");
                sb.append("}");
                if(i != memberList.size()-1) sb.append(",");
            }
            sb.append("]");

            out.print(sb.toString());
        } catch(Exception e){
            e.printStackTrace();
            out.print("[]");
        } finally {
            out.flush();
        }
    }
}