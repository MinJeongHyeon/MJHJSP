<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="java.io.PrintWriter"%>
<% request.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
	<%
		String userID = null;
		PrintWriter script = response.getWriter();
		if(session.getAttribute("userID") != null) {
			userID = (String)session.getAttribute("userID");
		}
		if(userID == null) {
			script.println("<script>");
			script.println("alert('로그인이 필요합니다.')");
			script.println("location.href = 'login.jsp'");
			script.println("</script>");	
		} 
		
		int bbsID = 0;
		if (request.getParameter("bbsID") != null) {
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		if (bbsID == 0) {
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다.')");
			script.println("location.href = 'bbs.jsp'");
			script.println("</script>");	
		}
		Bbs bbs = new BbsDAO().getBbs(bbsID);
		if (!userID.equals(bbs.getUserID())) {
			script.println("<script>");
			script.println("alert('권한이 없습니다.')");
			script.println("location.href = 'bbs.jsp'");
			script.println("</script>");	
		
		} else {
			BbsDAO bbsDAO= new BbsDAO();
			int result = bbsDAO.delete(bbsID);
			if (result == -1) { // 오류
				script.println("<script>");
				script.println("alert('삭제 중 오류가 발생하였습니다.')");
				script.println("history.back()");
				script.println("</script>");	
			} else { // 삭제 완료
				script.println("<script>");
				script.println("location.href = 'bbs.jsp'");
				script.println("</script>");	
			}
		}

	%>

</body>
</html>