/*
 * 게시판 데이터베이스에 접근하는 객체를 구현하는 클래스입니다.
 */

package bbs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;/*
import java.util.Collections;
import java.util.Comparator;*/
import java.text.SimpleDateFormat;
import java.util.Date;
import jdbc.Jdbc;

public class BbsDAO {

	// 현재 날짜를 리턴하는 메소드
	public String getDate() {
		String result = new SimpleDateFormat("YY.MM.dd HH:mm").format(new Date());
		return result;
	}
	
	// 가장 최근 게시글 다음의 BBSID를 리텬
	public int getNext() {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "SELECT BBSID FROM BBS ORDER BY BBSID DESC";
		int result = -1;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				result = rs.getInt(1) + 1;
			} else
				result = 1;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				if (rs != null)
					rs.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result; 
	}
	
	// 삭제되지 않은 게시글의 총합을 리턴
	public int getTotal() {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "select count(*) from bbs where bbsavailable = 1";
		int result = -1;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				result = rs.getInt(1);
			} else
				result = 0;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				if (rs != null)
					rs.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result; 
	}
	
	// 삭제되지 않고 검색 조건에 만족하는 게시글의 총합 리턴
	public int getTotal(String option, String word, String startDate, String endDate) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "select count(*) from bbs where bbsavailable = 1 and " + option + " like ? "
				+ "and to_date(?, 'YY.MM.DD') <= bbsdate and "
				+ "bbsdate < to_date(?, 'YY.MM.DD')+1";
		int result = -1;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, "%" + word + "%");
			pstmt.setString(2, startDate);
			pstmt.setString(3, endDate);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				result = rs.getInt(1);
			} else
				result = 0;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				if (rs != null)
					rs.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result;
	}
	
	// 게시글 작성 후 실행 결과값 리턴
	public int write(String bbsTitle, String userID, String bbsContent) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		String SQL = "INSERT INTO BBS (BBSID, BBSTITLE, USERID, BBSDATE, BBSCONTENT, BBSAVAILABLE) VALUES (?, ?, ?, to_date(?,'YY.MM.DD HH24:MI'), ?, ?)";
		int num = (int) getNext();
		String str = (String) getDate();
		int result = -1;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setInt(1, num);
			pstmt.setString(2, bbsTitle);
			pstmt.setString(3, userID);
			pstmt.setString(4, str);
			pstmt.setString(5, bbsContent);
			pstmt.setInt(6, 1);
			result = pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result;
	}
	
	// 페이지 구성을 위한 ArrayList 리턴
	public ArrayList<Bbs> getList(int pageNumber, int bunch) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "SELECT * FROM (SELECT bbsid, bbstitle, userid, bbsdate, bbscontent, bbsavailable, ROW_NUMBER() OVER(ORDER BY BBSID DESC) rn FROM BBS WHERE BBSAVAILABLE = 1) WHERE ? <= rn and rn <= ?";
		ArrayList<Bbs> list = new ArrayList<Bbs>();
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setInt(1, 1 + (pageNumber - 1) * bunch);
			if (getTotal() < pageNumber * bunch){
				pstmt.setInt(2, getTotal());
			} else {
				pstmt.setInt(2, pageNumber * bunch);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				Bbs bbs = new Bbs();
				bbs.setBbsID(rs.getInt(1));
				bbs.setBbsTitle(rs.getString(2));
				bbs.setUserID(rs.getString(3));
				bbs.setBbsDate(rs.getString(4));
				bbs.setBbsContent(rs.getString(5));
				bbs.setBbsAvailable(rs.getInt(6));
				list.add(bbs);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				if (rs != null)
					rs.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return list;
	}
	
	// 검색 조건에 맞는 페이지 구성을 위한 ArrayList 리턴
	public ArrayList<Bbs> getList(String option, String word, int pageNumber, int bunch, String startDate, String endDate, String sort) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "SELECT * FROM (SELECT bbsid, bbstitle, userid, bbsdate, bbscontent, bbsavailable, "
				+ "ROW_NUMBER() OVER(ORDER BY " + sort + ") rn FROM BBS "
				+ "WHERE BBSAVAILABLE = 1 and " + option + " like ? "
				+ "and to_date(?, 'YY.MM.DD') <= bbsdate and "
				+ "bbsdate < to_date(?, 'YY.MM.DD')+1) "
				+ "WHERE ? <= rn and rn <= ?";
		ArrayList<Bbs> list = new ArrayList<Bbs>();
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, "%" + word + "%");
			pstmt.setString(2, startDate);
			pstmt.setString(3, endDate);
			pstmt.setInt(4, 1 + (pageNumber - 1) * bunch);
			if (getTotal(option, word, startDate, endDate) < pageNumber * bunch)
				pstmt.setInt(5, getTotal(option, word, startDate, endDate));
			else
				pstmt.setInt(5, pageNumber * bunch);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				Bbs bbs = new Bbs();
				bbs.setBbsID(rs.getInt(1));
				bbs.setBbsTitle(rs.getString(2));
				bbs.setUserID(rs.getString(3));
				bbs.setBbsDate(rs.getString(4));
				bbs.setBbsContent(rs.getString(5));
				bbs.setBbsAvailable(rs.getInt(6));
				list.add(bbs);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				if (rs != null)
					rs.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return list;
	}
	
	// pageNumber의 다음 페이지가 존재하는지 리턴
	public boolean nextPage(int pageNumber, int bunch, String option, String word, String startDate, String endDate) {
		if (word == null){
			if ((getTotal() - (pageNumber-1) * bunch) > 0)
				return true;
			else
				return false;
		}
		else {
			if ((getTotal(option, word, startDate, endDate) - (pageNumber-1) * bunch) > 0)
				return true;
			else
				return false;
		}
	}
	
	// BBSID가 일치하는 게시글 리턴
	public Bbs getBbs(int bbsID) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "SELECT * FROM BBS WHERE BBSID = ?";
		Bbs bbs = null;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setInt(1, bbsID); 
			rs = pstmt.executeQuery();
			if(rs.next()) {
				bbs = new Bbs();
				bbs.setBbsID(rs.getInt(1));
				bbs.setBbsTitle(rs.getString(2));
				bbs.setUserID(rs.getString(3));
				bbs.setBbsDate(rs.getString(4));
				bbs.setBbsContent(rs.getString(5));
				bbs.setBbsAvailable(rs.getInt(6));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				if (rs != null)
					rs.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return bbs;
	}
	
	// 게시글 수정 후 실행 결과값 리턴
	public int update(int bbsID, String bbsTitle, String bbsContent) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		String SQL = "UPDATE BBS SET BBSTITLE = ?, BBSCONTENT = ? WHERE BBSID = ?";
		int result = -1;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, bbsTitle);
			pstmt.setString(2, bbsContent);
			pstmt.setInt(3, bbsID);
			result = pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result;
	}
	
	// 게시글 삭제 후 실행 결과값 리턴
	public int delete(int bbsID) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		String SQL = "UPDATE BBS SET BBSAVAILABLE = 0 WHERE BBSID = ?";
		int result = -1;
		try {
			conn = Jdbc.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setInt(1, bbsID);
			result = pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result;
	}
	
}
	/*
	public ArrayList<Bbs> sort(ArrayList<Bbs> list, int num) {
		if (num == 1)
			Collections.sort(list, new compareTitle());
		if (num == 2)
			Collections.sort(list, new compareTitle().reversed());
		if (num == 3)
			Collections.sort(list, new compareID());
		if (num == 4)
			Collections.sort(list, new compareID().reversed());
		if (num == 5)
			Collections.sort(list, new compareDate());
		if (num == 6)
			Collections.sort(list, new compareDate().reversed());
		return list;
	}
 }

class compareTitle implements Comparator<Bbs>{
	@Override
	public int compare(Bbs a,Bbs b){
		return a.getBbsTitle().compareTo(b.getBbsTitle());
	}
}

class compareID implements Comparator<Bbs>{
	@Override
	public int compare(Bbs a,Bbs b){
		return a.getUserID().compareTo(b.getUserID());
	}
}

class compareDate implements Comparator<Bbs>{
	@Override
	public int compare(Bbs a,Bbs b){
		return a.getBbsDate().compareTo(b.getBbsDate());
	}
}*/

