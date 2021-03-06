/*
 * 데이터베이스 연결 클래스입니다.
 * 다른 클래스에서 데이터베이스 연결을 하려고 할 때
 * import jdbc.Jdbc;를 한 후에
 * Jdbc.getConnection을 하는 것으로 쉽게 연결할 수 있습니다.
 */

package jdbc;

import java.sql.Connection;
import java.sql.DriverManager;

public class Jdbc {

	public static Connection conn;

	public static Connection getConnection() {
		try {
			String dbURL = "jdbc:oracle:thin:@localhost:1521:xe";
			String dbID = "c##MJH";
			String dbPassword = "zmffhfmzkffba12";
			Class.forName("oracle.jdbc.driver.OracleDriver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return conn;
	}
}
