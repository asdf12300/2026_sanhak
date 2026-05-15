package controller;
import java.io.InputStream;
import java.util.Properties;
import java.io.IOException;
import java.util.Random;
import java.sql.Connection;
import model.DBConnection;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.LoginDTO;
import model.MemberDAO;

import java.util.Properties;

@WebServlet("/delete/sendCode")
public class DeleteSendCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain; charset=UTF-8");

        HttpSession session = request.getSession();
        LoginDTO loginUser = (LoginDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.getWriter().write("로그인이 필요합니다.");
            return;
        }

        String userId = loginUser.getId();
        String mode = request.getParameter("mode");

        try {
            Connection conn = DBConnection.getConnection();

            MemberDAO dao = new MemberDAO(conn);

            String email = dao.getEmailById(userId);

            if (email == null || email.trim().isEmpty()) {
                response.getWriter().write("등록된 이메일이 없습니다.");
                return;
            }

            String code = String.format("%06d",
                    new Random().nextInt(1000000));

            session.setAttribute("deleteEmailCode", code);
            session.setAttribute("deleteEmailCodeTime",
                    System.currentTimeMillis());

            sendMail(email, code, mode);

            conn.close();

            response.getWriter().write("등록된 이메일로 인증번호를 발송했습니다.");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("인증번호 발송 실패");
        }
    }

    private void sendMail(String toEmail, String code, String mode) throws Exception {

        Properties secretProp = new Properties();

        InputStream is = getServletContext()
                .getResourceAsStream("/WEB-INF/classes/secret.properties");

        secretProp.load(is);

        String user = secretProp.getProperty("mail.username");
        String password = secretProp.getProperty("mail.password");

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.naver.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.trust", "smtp.naver.com");
        Session mailSession = Session.getInstance(props,
            new javax.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(user, password);
                }
            }
        );
        
        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(user));
        message.setRecipients(
            Message.RecipientType.TO,
            InternetAddress.parse(toEmail)
        );
        System.out.println("보내는 이메일: " + user);
        System.out.println("받는 이메일: " + toEmail);
        if (user == null || user.trim().isEmpty()) {
            throw new RuntimeException("secret.properties의 mail.user 값이 없습니다.");
        }

        if (password == null || password.trim().isEmpty()) {
            throw new RuntimeException("secret.properties의 mail.password 값이 없습니다.");
        }

        if (toEmail == null || toEmail.trim().isEmpty()) {
            throw new RuntimeException("DB에 저장된 사용자 이메일이 없습니다.");
        }
        String subject;
        String content;

        if ("settings".equals(mode)) {

            subject = "[ProjectOS] 설정 변경 인증번호";

            content =
                "설정 변경 인증번호는 [" + code + "] 입니다.\n\n"
                + "본인이 요청하지 않았다면 무시해주세요.";

        } else {

            subject = "[ProjectOS] 계정 탈퇴 인증번호";

            content =
                "계정 탈퇴 인증번호는 [" + code + "] 입니다.\n\n"
                + "본인이 요청하지 않았다면 무시해주세요.";
        }

        message.setSubject(subject);
        message.setText(content);

        Transport.send(message);
    }
}