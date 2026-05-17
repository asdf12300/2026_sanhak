package controller;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.util.Properties;
import java.util.Random;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.DBConnection;
import model.LoginDTO;
import model.MemberDAO;

@WebServlet("/delete/sendCode")
public class DeleteSendCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int CODE_EXPIRE_MINUTES = 3;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        HttpSession session = request.getSession(false);
        LoginDTO loginUser = session != null ? (LoginDTO) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            response.getWriter().write("로그인이 필요합니다.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            MemberDAO dao = new MemberDAO(conn);
            String email = dao.getEmailById(loginUser.getId());

            if (email == null || email.trim().isEmpty()) {
                response.getWriter().write("등록된 이메일이 없습니다.");
                return;
            }

            String code = String.format("%06d", new Random().nextInt(1000000));
            session.setAttribute("deleteEmailCode", code);
            session.setAttribute("deleteEmailCodeTime", System.currentTimeMillis());

            String mode = request.getParameter("mode");
            sendMail(email, code, mode);
            response.getWriter().write("등록된 이메일로 인증번호를 발송했습니다. "
                    + CODE_EXPIRE_MINUTES + "분 안에 입력해주세요.");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("인증번호 발송 실패");
        }
    }

    private void sendMail(String toEmail, String code, String mode) throws Exception {
        Properties secret = new Properties();
        try (InputStream is = getServletContext().getResourceAsStream("/WEB-INF/classes/secret.properties")) {
            if (is == null) {
                throw new IllegalStateException("secret.properties file was not found in WEB-INF/classes.");
            }
            secret.load(is);
        }

        String username = secret.getProperty("mail.username");
        String password = secret.getProperty("mail.password");
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            throw new IllegalStateException("mail.username or mail.password is missing in secret.properties.");
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.naver.com");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                return new javax.mail.PasswordAuthentication(username, password);
            }
        });

        MimeMessage message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(username, "ProjectOS"));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        boolean settingsMode = "settings".equals(mode);
        message.setSubject(settingsMode ? "[ProjectOS] 설정 변경 인증번호" : "[ProjectOS] 계정 탈퇴 인증번호");
        message.setContent(
            "<h2>ProjectOS " + (settingsMode ? "설정 변경" : "계정 탈퇴") + " 인증</h2>"
                + "<p>" + (settingsMode ? "설정 변경을 계속하려면" : "계정 탈퇴를 계속하려면") + " 아래 인증번호를 입력해주세요.</p>"
                + "<div style='font-size:2rem;font-weight:700;letter-spacing:8px;color:"
                + (settingsMode ? "#2563eb" : "#dc2626") + ";margin:20px 0;'>"
                + code
                + "</div>"
                + "<p style='color:#94a3b8;font-size:12px;'>본인이 요청하지 않았다면 이 메일을 무시해주세요.</p>",
            "text/html;charset=UTF-8"
        );

        Transport.send(message);
    }
}
