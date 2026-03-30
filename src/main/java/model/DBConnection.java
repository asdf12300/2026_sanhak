package model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;
import java.io.InputStream;

public class DBConnection {

    public static Connection getConnection() {
        try {
            Properties prop = new Properties();
            InputStream input = DBConnection.class.getClassLoader()
                    .getResourceAsStream("db.properties");

            if (input == null) {
                throw new RuntimeException("db.properties 파일을 찾을 수 없습니다.");
            }

            prop.load(input);

            String driver = prop.getProperty("driver");
            String url = prop.getProperty("url");
            String user = prop.getProperty("user");
            String password = prop.getProperty("password");

            Class.forName(driver);

            // ✅ 매번 새로운 Connection 생성
            return DriverManager.getConnection(url, user, password);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("DB 연결 실패");
        }
    }
}
