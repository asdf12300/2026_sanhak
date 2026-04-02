package model;

import java.sql.Connection;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class DBConnection {

    private static DataSource ds;

    static {
        try {
            Context ctx = new InitialContext();
            ds = (DataSource) ctx.lookup("java:comp/env/jdbc/sanhak");
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("DataSource 초기화 실패: " + e.getMessage());
        }
    }

    public static Connection getConnection() {
        try {
            return ds.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("DB 커넥션 획득 실패: " + e.getMessage());
        }
    }
}
