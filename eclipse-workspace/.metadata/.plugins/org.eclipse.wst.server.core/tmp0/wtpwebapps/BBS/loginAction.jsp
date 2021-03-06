<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO" %>
<%@ page import="java.io.PrintWriter" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="user" class="user.User" scope="page" />
<jsp:setProperty name="user" property="userID" />
<jsp:setProperty name="user" property="userPassword" />
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
	<%
		// html문 삽입 객체
		PrintWriter script = response.getWriter();
		// 세션에 있는 userID 변수화
		String userID = null;
		if(session.getAttribute("userID") != null) {
			userID = (String)session.getAttribute("userID");
		}
		// 로그인 상태에서 한 번 더 로그인하려고 할 시 이미 로그인 되있음을 알림
		if(userID != null) {
			script.println("<script>");
			script.println("alert('이미 로그인이 되어있습니다.')");
			script.println("location.href = 'main.jsp'");
			script.println("</script>");	
		}
		UserDAO userDAO = new UserDAO();
		// 로그인 시도, 결과 리턴
		int result = userDAO.login(user.getUserID(), user.getUserPassword());
		// 로그인 성공
		if (result == 1) {
			session.setAttribute("userID", user.getUserID());
			script.println("<script>");
			script.println("location.href = 'main.jsp'");
			script.println("</script>");	
		}
		// 비밀번호 오류
		else if (result == 0) {
			script.println("<script>");
			script.println("alert('비밀번호 오류')");
			script.println("history.back()");
			script.println("</script>");	
		}
		// 아이디 오류
		else if (result == -1) {
			script.println("<script>");
			script.println("alert('아이디 오류')");
			script.println("history.back()");
			script.println("</script>");	
		}
		// 데이터베이스 오류
		else if (result == -2) {
			script.println("<script>");
			script.println("alert('데이터베이스 오류')");
			script.println("history.back()");
			script.println("</script>");	
		}

	%>

</body>
</html>