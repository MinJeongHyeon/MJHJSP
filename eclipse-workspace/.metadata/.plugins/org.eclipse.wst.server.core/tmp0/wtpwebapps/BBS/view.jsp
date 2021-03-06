<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
	<% 
		// 세션에 있는 userID 변수화
		String userID = null;
		if (session.getAttribute("userID") != null) {
			userID = (String)session.getAttribute("userID");
		}
		int bbsID = 0;
		// 받아온 bbsID 변수화
		if (request.getParameter("bbsID") != null) {
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		// bbsID가 0일 경우 돌려보냄
		if (bbsID == 0) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다.')");
			script.println("location.href = 'bbs.jsp'");
			script.println("</script>");	
		}
		// 받아온 bbsID를 bbs 객체
		Bbs bbs = new BbsDAO().getBbs(bbsID);
	%>
	<jsp:include page="top.jsp" flush="false" />
	<div class="container">
		<div class="row">
			<table class="table table-striped"
				style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<th colspan="3"
							style="background-color: #eeeeee; text-align: center;">게시글 읽기</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<!-- replaceAll 하지 않으면 여러 문제가 발생함 -->
						<td style="width: 20%;">글 제목</td>
						<td colspan="2"><%= bbs.getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %>
					</tr>
					<tr>
						<td style="width: 20%;">작성자</td>
						<td colspan="2"><%= bbs.getUserID() %>
					</tr>
					<tr>
						<td style="width: 20%;">작성일자</td>
						<td colspan="2"><%= bbs.getBbsDate().substring(0,16) %>
					</tr>
					<tr>
					<!-- replaceAll 하지 않으면 여러 문제가 발생함 -->
						<td style="width: 20%;">내용</td>
						<td colspan="2">
							<div class="bbs-content" style="min-height: 200px; text-align: left;">
								<%= bbs.getBbsContent().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %>
							</div>
					</tr>
				</tbody>
			</table>
			<a href="bbs.jsp" class="btn btn-primary">목록</a>
			<%
				if(userID != null && userID.equals(bbs.getUserID())) {
			%>
					<a href="update.jsp?bbsID=<%=bbsID%>" class="btn btn-primary">수정</a>
					<a onclick="return confirm('정말로 삭제하시겠습니까?')" href="deleteAction.jsp?bbsID=<%=bbsID%>" class="btn btn-primary">삭제</a>
			<% 
				}
			%>
		</div>
	</div>
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
</body>
</html>