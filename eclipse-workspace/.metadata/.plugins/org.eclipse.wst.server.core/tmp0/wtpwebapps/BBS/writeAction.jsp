<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="java.io.PrintWriter"%>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="bbs" class="bbs.Bbs" scope="page" />
<jsp:setProperty name="bbs" property="bbsTitle" />
<jsp:setProperty name="bbs" property="bbsContent" />
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
		// 로그인 안 되어 있을 시 로그인 유도
		if(userID == null) {
			script.println("<script>");
			script.println("alert('로그인이 필요합니다.')");
			script.println("location.href = 'login.jsp'");
			script.println("</script>");	
		} else { // 빈 항목 있을 경우 입력 유도
			if (bbs.getBbsTitle() == null || bbs.getBbsContent() == null
				|| request.getParameter("bbsTitle").equals("") || request.getParameter("bbsContent").equals("")) {
				script.println("<script>");
				script.println("alert('모든 항목을 입력해주세요.')");
				script.println("history.back()");
				script.println("</script>");	
			} else {
				BbsDAO bbsDAO= new BbsDAO();
				// 게시글 작성 시도 후 결과 리턴
				int result = bbsDAO.write(bbs.getBbsTitle(), userID, bbs.getBbsContent());
				if (result == -1) { // 오류
					script.println("<script>");
					script.println("alert('작성 중 오류가 발생하였습니다.')");
					script.println("history.back()");
					script.println("</script>");	
				} else { // 작성 완료
				script.println("<script>");
				script.println("alert('작성되었습니다.')");
				script.println("location.href = 'view.jsp?bbsID=" + (bbsDAO.getNext()-1) + "'");
				script.println("</script>");	
				}
			}
		}

	%>

</body>
</html>