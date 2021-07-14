<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<style type="text/css">
a, a:hover {
	color: #000000;
}
</style>
<title>JSP 게시판 웹 사이트</title>
<script src="js/jquery-3.6.0.min.js"></script>
</head>
<body>
<%int i=0; ArrayList<Bbs> list = null;%>
	<% 
		String userID = null;
		if (session.getAttribute("userID") != null) {
			userID = (String)session.getAttribute("userID");
		}
		int pageNumber = 1;
		if (request.getParameter("pageNumber") != null) {
			pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
		}
		int bunch = 10;
		if (request.getParameter("bunch") != null) {
			bunch = Integer.parseInt(request.getParameter("bunch"));
		}
		String searchOption = null;
		if (request.getParameter("searchOption") != null) {
			searchOption = request.getParameter("searchOption");
		}
		String searchWord = null;
		if (request.getParameter("searchWord") != null) {
			searchWord = request.getParameter("searchWord");
		}
		int start = (pageNumber-1) / 5 + 1;
		int end = start * 5;
		%>
		<script type="text/javascript">
function applyOption(option, optionValue){
	$('#currentSearch').text(option.text);
	$('#searchOption').val(optionValue);
	return false;
}

function bunchView(bunch){
	$('#bunch').val(bunch.getAttribute('class'));
	$('#pageNumber').val("1");
	document.getElementById('viewForm').submit();
	return false;
}

function startPage(){
	$('#pageNumber').val("1");
	document.getElementById('viewForm').submit();
	return false;
}

function prevPage(){
	$('#pageNumber').val("<%=end-5%>");
	document.getElementById('viewForm').submit();
	return false;
}

function currentPage(num){
	$('#pageNumber').val(num.text);
	document.getElementById('viewForm').submit();
	return false;
}
function nextPage(){
	var start = <%=start%>;
	var end = <%=end%>;
	for(;start<=end;start++){}
	$('#pageNumber').val(start);
	document.getElementById('viewForm').submit();
	return false;
}
function endPage(size){
	var bunch = <%=bunch%>
	var lSize = size-1
	$('#pageNumber').val(parseInt(lSize/bunch+1));
	document.getElementById('viewForm').submit();
	return false;
}
</script>
		<jsp:include page="top.jsp" flush="false" />
	<div class="container" style="margin-bottom: 80px;">
		<div class="row">
			<form class="navbar-form pull-right" role="search" id="viewForm">
				<table>
					<tr>
						<%if(searchWord != null && !searchWord.equals("")) {
						%>
						<th style="border:0; line-height:50px;">
							[<%=searchWord%>] 검색 결과
						</th>
						<th style="width:200px;">
						</th>
						<%
						}	
						%>
						
						<th>
							<input type="hidden" name="pageNumber" id="pageNumber" value="<%=pageNumber%>" />
							<input type="hidden" name="bunch" id="bunch" value="<%=bunch%>" />
							<input type="hidden" name="searchOption" id="searchOption" value="bbsTitle" />
							<div class="btn-group pull-right"
								style="padding: 10px 0px 10px 10px;">
								<a class="btn btn-default dropdown-toggle btn-select" href="#"
									data-toggle="dropdown" id="currentSearch" style="width: 90px;">제목만
								</a>
								<ul class="dropdown-menu">
									<li><a class='searchOption'
										onClick="javascript:applyOption(this, 'bbsTitle')">제목만</a></li>
									<li><a class='searchOption'
										onClick="javascript:applyOption(this, 'bbsContent')">제목+내용</a></li>
									<li><a class='searchOption'
										onClick="javascript:applyOption(this, 'userID')">작성자</a></li>
								</ul>
							</div>
						</th>
						
						<th>
							<div class="input-group">
								<input type="text" class="form-control" placeholder="Search"
									name="searchWord" id="searchWord" />
								<div class="input-group-btn">
									<button type="submit" class="btn btn-default" onClick="javascript:$('#pageNumber').val(1)">
										<span class="glyphicon glyphicon-search"></span>
									</button>
								</div>
							</div>
						</th>

						<th>
							<div class="btn-group pull-right"
								style="padding: 10px 0px 10px 10px;">
								<a class="btn btn-default dropdown-toggle btn-select" href="#"
									data-toggle="dropdown"><%=bunch%>개씩 <span class="caret"></span></a>
								<ul class="dropdown-menu">
									<li><a class="10" onClick="javascript:bunchView(this)">10개씩</a></li>
									<li><a class="15" onClick="javascript:bunchView(this)">15개씩</a></li>
									<li><a class="20" onClick="javascript:bunchView(this)">20개씩</a></li>
								</ul>
							</div>
						</th>
						
					</tr>
				</table>
			</form>
			<table class="table table-striped"
				style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<th
							style="background-color: #eeeeee; text-align: center; width: 50px;">번호</th>
						<th style="background-color: #eeeeee; text-align: center;">제목</th>
						<th
							style="background-color: #eeeeee; text-align: center; width: 80px;">작성자</th>
						<th
							style="background-color: #eeeeee; text-align: center; width: 250px;">작성일</th>
					</tr>
				</thead>
				<tbody>
					<%
						BbsDAO bbsDAO = new BbsDAO();
						if(searchOption == null)
						{list = bbsDAO.getList(pageNumber, bunch);}
						else
						{
							list = bbsDAO.getList(searchOption, searchWord, pageNumber, bunch);
						}
						for(int n = 0; n < list.size(); n++) {
					%>
					<tr>
						<td><%= list.get(n).getBbsID() %></td>
						<td><a href="view.jsp?bbsID=<%= list.get(n).getBbsID() %>"><%= list.get(n).getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %></a></td>
						<td><%= list.get(n).getUserID() %></td>
						<td><%= list.get(n).getBbsDate() %></td>
					</tr>
					<%} %>
				</tbody>
			</table>
			<%	
				if(pageNumber > 5) {
			%>
			<a onClick="javascript:startPage()"
				class="btn btn-success btn-arrow-left">&lt;&lt;</a> 
			<a onClick="javascript:prevPage()"
				class="btn btn-success btn-arrow-left">&lt;</a>
			<%} 
				for (i=1+(start-1)*5; i<=end; i++) {
					if(bbsDAO.nextPage(i, bunch, searchOption, searchWord)) {
						if(i==pageNumber) {
			%>
			<a onClick="javascript:currentPage(this)"
				class="btn btn-info"><%=i%></a>
			<% } else {%>
			<a onClick="javascript:currentPage(this)"
				class="btn btn-light"><%=i%></a>
			<%
						}
					}
				} if(bbsDAO.nextPage(pageNumber + 1, bunch, searchOption, searchWord)) {
			%>
			<a onClick="javascript:nextPage()"
				class="btn btn-success btn-arrow-right">&gt;</a> 
			<a onClick="javascript:endPage('<%=bbsDAO.getTotal() %>')"
				class="btn btn-success btn-arrow-right">&gt;&gt;</a>
			<%} %>
			<a href="write.jsp" class="btn btn-primary pull-right">글쓰기</a>
		</div>
	</div>
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
</body>
</html>