package controller;

import java.io.IOException;
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

@WebServlet("/sendCode")
public class SendCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            response.getWriter().write("{\"result\":\"fail\",\"msg\":\"이메일을 입력해주세요.\"}");
            return;
        }

        // 6자리 랜덤 코드 생성
        String code = String.format("%06d", new Random().nextInt(1000000));

        // 세션에 코드 + 이메일 저장
        request.getSession().setAttribute("verifyCode", code);
        request.getSession().setAttribute("verifyEmail", email);
        request.getSession().setAttribute("codeVerified", false);

        try {
            sendEmail(email, code);
            response.getWriter().write("{\"result\":\"ok\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"result\":\"fail\",\"msg\":\"이메일 발송에 실패했습니다.\"}");
        }
    }

    private void sendEmail(String toEmail, String code) throws Exception {
        java.io.InputStream is = getServletContext().getResourceAsStream("/WEB-INF/classes/secret.properties");
        java.util.Properties secret = new java.util.Properties();
        secret.load(is);

        String username = secret.getProperty("mail.username");
        String password = secret.getProperty("mail.password");

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.naver.com");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                return new javax.mail.PasswordAuthentication(username, password);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(username, "ProjectOS"));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        message.setSubject("[ProjectOS] 이메일 인증 코드");
        message.setContent(
            "<h2>ProjectOS 이메일 인증</h2>" +
            "<p>아래 인증 코드를 입력해주세요.</p>" +
            "<div style='font-size:2rem;font-weight:700;letter-spacing:8px;color:#2563eb;margin:20px 0;'>" + code + "</div>" +
            "<p style='color:#94a3b8;font-size:12px;'>코드는 10분간 유효합니다.</p>",
            "text/html;charset=UTF-8"
        );

        Transport.send(message);
        System.out.println("인증 코드 발송: " + toEmail + " / 코드: " + code);
    }
}