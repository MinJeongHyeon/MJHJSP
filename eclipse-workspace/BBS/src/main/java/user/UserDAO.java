/*
 * 유저 데이터베이스에 접근하는 객체를 구현하는 클래스입니다.
 */

package user;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jdbc.Jdbc;

public class UserDAO {

	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	public UserDAO() {
		try {
			conn = Jdbc.getConnection();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public int login(String userID, String userPassword) {
		// 유저 아이디가 ?인 레코드의 비밀번호를 가져오는 쿼리입니다.
		String SQL = "SELECT USERPASSWORD FROM USERS WHERE USERID = ?";
		SHA256 sha256 = new SHA256();
		try {
			// pstmt 객체를 생성합니다.
			pstmt = conn.prepareStatement(SQL);
			// 파라미터로 받은 유저 아이디를 쿼리에 삽입합니다.
			pstmt.setString(1, userID);
			// 쿼리를 실행합니다.
			rs = pstmt.executeQuery();
			if (rs.next()) {
				// 파라미터로 받은 비밀번호와 쿼리로 가져온 비밀번호가 일치하는지 확인합니다.
				if(rs.getString(1).equals(sha256.encrypt(userPassword)))
					return 1; // 로그인 성공
				else
					return 0; // 비밀번호 오류
			}
			return -1; // 아이디 오류
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -2; // 데이터베이스 오류
	}
	
	public int join(User user) {
		String SQL = "INSERT INTO USERS (USERID, USERPASSWORD, USERNAME, USERGENDER, USEREMAIL) VALUES (?, ?, ?, ?, ?)";
		try {
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, user.getUserID());
			SHA256 sha256 = new SHA256();
			String pw = sha256.encrypt(user.getUserPassword());
			pstmt.setString(2, pw);
			pstmt.setString(3, user.getUserName());
			pstmt.setString(4, user.getUserGender());
			pstmt.setString(5, user.getUserEmail());
			return pstmt.executeUpdate();
		} catch(Exception e) {
			e.printStackTrace();
		}
		return -1; // 데이터베이스 오류
	}
}
