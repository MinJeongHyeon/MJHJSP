<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<link rel="stylesheet" href="css/bootstrap-datepicker.css">
<script type="text/javascript" src="js/jquery-3.6.0.min.js"></script>


<style type="text/css">
a, a:hover {
	color: #000000;
}
</style>
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
<% /*변수 초기화*/ 
int i=0; 
ArrayList<Bbs> list = null; 
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
String dateOption = null;
if (request.getParameter("dateOption") != null) {
	dateOption = request.getParameter("dateOption");
}
String startDate = "00.01.01";
if (request.getParameter("startDate") != null) {
	startDate = request.getParameter("startDate");
}
String endDate= new SimpleDateFormat("YY.MM.dd").format(new Date());
if (request.getParameter("endDate") != null) {
	endDate = request.getParameter("endDate");
}
String sort = "BBSID DESC";
if (request.getParameter("sort") != null) {
	sort = request.getParameter("sort");
}
int start = (pageNumber-1) / 5 + 1;
int end = start * 5;
%>

<script type="text/javascript">

// 검색 옵션 선택 시 현재 옵션 텍스트 변경
function applyOption(option, optionValue){
	$('#currentSearch').text(option.text);
	$('#searchOption').val(optionValue);
	return false;
}

// 검색 날짜 선택 시 현재 검색 날짜 텍스트 변경 및 기간 변경
function applyDate(option, optionValue){
	$('#currentDate').text(option.text);
	var d = new Date();
	var yy = 0;
	var mm = 0;
	var dd = 0;
	if(optionValue == "1d") dd = 1;
	if(optionValue == "1w") dd = 7;
	if(optionValue == "1m") mm = 1;
	if(optionValue == "6m") mm = 6;
	if(optionValue == "1y") yy = 1;

	// 전체 기간이 아닐 때 시작 날짜 계산
	if(optionValue != "all") {
		$('#startDate').val(
			moment(new Date(
				d.getFullYear()-yy, 
				d.getMonth()-mm, 
				d.getDate()-dd).toLocaleDateString()
			).format('YY.MM.DD')
		);
	}
	// 전체 기간일 때 시작 날짜는 2000년 1월 1일
	else 
		$('#startDate').val(moment(new Date('2000-01-01').toLocaleDateString()).format('YY.MM.DD'));
	
	// 기간을 직접 입력하지 않았다면 종료 날짜는 현재 날짜 
	$('#endDate').val(moment(d.toLocaleDateString()).format('YY.MM.DD'));
	
	$('#dateOption').val(optionValue);
	$('#startDateValue').val($('#startDate').val());
	$('#endDateValue').val($('#endDate').val());
	return false;
}

// n개씩 보기 변경 시 새로 submit
function bunchView(bunch){
	$('#bunch').val(bunch.getAttribute('class'));
	$('#pageNumber').val("1");
	document.getElementById('viewForm').submit();
	return false;
}

// 정렬 버튼
function sort(sortString){
	$('#sort').val(sortString);
	document.getElementById('viewForm').submit();
	return false;
}

// << 버튼
function startPage(){
	$('#pageNumber').val("1");
	document.getElementById('viewForm').submit();
	return false;
}

// < 버튼
function prevPage(){
	$('#pageNumber').val("<%=end-5%>");
	document.getElementById('viewForm').submit();
	return false;
}

// start~end 페이지 버튼
function currentPage(num){
	$('#pageNumber').val(num.text);
	document.getElementById('viewForm').submit();
	return false;
}

// > 버튼
function nextPage(){
	var start = <%=start%>;
	var end = <%=end%>;
	for(;start<=end;start++){}
	$('#pageNumber').val(start);
	document.getElementById('viewForm').submit();
	return false;
}

// >> 버튼
function endPage(size){
	var bunch = <%=bunch%>
	var lSize = size-1
	$('#pageNumber').val(parseInt(lSize/bunch+1));
	document.getElementById('viewForm').submit();
	return false;
}

// 검색할 때 검색어 체크
function check(){
	var word = $('#searchWordInput').val().trim();
	if(word == null || word == ""){
		alert("검색어를 입력하세요");
		return false;
	}
	$('#searchWord').val(word);
	return true;
}

// 해당 문서 시작 시 바로 호출
$(document).ready(function () {
	
	// 날짜 검색 시 보여질 달력
	$('#startDate').datepicker({
		autoclose: true,
		format: "yy.mm.dd",	
	    language : "ko",
	    startDate: "2000.01.01",
	    endDate: new Date()
	// 달력에서 날짜 선택 시 호출 
	}).on('changeDate', function(selected){
		var minDate = new Date(selected.date.valueOf());
		$('#endDate').datepicker('setStartDate', minDate); 
		$('#currentDate').text("직접 입력");
		$('#startDateValue').val(moment(minDate).format('YY.MM.DD'));
	});

	$('#endDate').datepicker({
		autoclose: true,
		format: "yy.mm.dd",	
	    language : "ko",	 
	    yearRange: "2001:2021",
	    endDate: new Date()
	}).on('changeDate', function(selected){
		var maxDate = new Date(selected.date.valueOf());
		$('#startDate').datepicker('setEndDate', maxDate); 
		$('#currentDate').text("직접 입력");
		$('#endDateValue').val(moment(maxDate).format('YY.MM.DD'));
	});
});


</script>

<!-- 네비게이션 바 -->
<jsp:include page="top.jsp" flush="false" />

<div class="container" style="margin-bottom: 80px;">
	<div class="row">
	
		<!-- 게시글 검색 폼 -->
		<form class="navbar-form pull-right" 
		role="search" id="viewForm" onsubmit="return check()">
		
			<!-- Parameter -->
			<input type="hidden" name="pageNumber" id="pageNumber" value="<%=pageNumber%>" />
			<input type="hidden" name="bunch" id="bunch" value="<%=bunch%>" />
			<input type="hidden" name="searchOption" id="searchOption" value="bbsTitle" />
			<input type="hidden" name="dateOption" id="dateOption" value="all" />
			<input type="hidden" name="startDate" id="startDateValue" value="<%=startDate%>"/>
			<input type="hidden" name="endDate" id="endDateValue" value="<%=endDate%>" />
			<input type="hidden" name="searchWord" id="searchWord" 
			<%if (searchWord != null) { %>
			value="<%=searchWord%>" <%} %> />
			<input type="hidden" name="sort" id="sort" value="<%=sort%>" />
			
			<table> <!-- 검색 테이블 -->
			
				<tr> <!-- 검색 키워드 출력 -->
					<%if(searchWord != null && !searchWord.equals("")) {%>
					<th style="border:0; line-height:50px; text-align: left; width:200px;">
						검색 단어 : [<%=searchWord%>] 
					</th> <%}%>
					
					<th> <!-- 날짜 옵션 선택 -->
						<div class="btn-group">
							<a class="btn btn-default dropdown-toggle btn-select" href="#"
								data-toggle="dropdown" id="currentDate" style="width: 90px;">전체 기간
							</a>
							<ul class="dropdown-menu" style="width:300px;">
								<li>
									<p style="margin:0px 10px; display:inline;">검색 기간</p>
									<input type="text" id="startDate" style="width:90px; margin:0px 5px;" value="00.01.01" />
									<p style="line-height:20px; display:inline;">~</p>
									<input type="text" id="endDate" style="width:90px; margin:0px 5px;" value="<%=endDate%>"/>
								</li>
								<li class="divider"></li>
								<li><a onClick="javascript:applyDate(this, 'all')">전체 기간</a></li>
								<li><a onClick="javascript:applyDate(this, '1d')">1일</a></li>
								<li><a onClick="javascript:applyDate(this, '1w')">1주</a></li>
								<li><a onClick="javascript:applyDate(this, '1m')">1개월</a></li>
								<li><a onClick="javascript:applyDate(this, '6m')">6개월</a></li>
								<li><a onClick="javascript:applyDate(this, '1y')">1년</a></li>
							</ul>
						</div>
					</th>
					
					<th> <!-- 검색 옵션 선택 -->
						<div class="btn-group">
							<a class="btn btn-default dropdown-toggle btn-select" href="#"
								data-toggle="dropdown" id="currentSearch" style="width: 90px;">제목만
							</a>
							<ul class="dropdown-menu">
								<li><a onClick="javascript:applyOption(this, 'bbsTitle')">제목만</a></li>
								<li><a onClick="javascript:applyOption(this, 'bbsContent')">제목+내용</a></li>
								<li><a onClick="javascript:applyOption(this, 'userID')">작성자</a></li>
							</ul>
						</div>
					</th>
					
					<th> <!-- 검색 창 -->
						<div class="input-group">
							<input type="text" class="form-control" placeholder="Search"
								id="searchWordInput" />
							<div class="input-group-btn">
								<button type="submit" class="btn btn-default" onClick="javascript:$('#pageNumber').val(1)">
									<span class="glyphicon glyphicon-search"></span>
								</button>
							</div>
						</div>
					</th>
					
					<th> <!-- n개씩 보기 -->
						<div class="btn-group">
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
		
		<!-- 게시판 테이블 -->
		<table class="table table-striped"
			style="text-align: center; border: 1px solid #dddddd">
			
			<!-- 게시판 칼럼 -->
			<thead>
				<tr>
					<th style="background-color: #eeeeee; text-align: center; width: 50px;">번호</th>
					<th style="background-color: #eeeeee; text-align: center;">제목
					<% if(sort.equals("BBSTITLE")) {%>
						<a onClick="javascript:sort('BBSTITLE DESC')"><span class="glyphicon glyphicon-chevron-up"></span></a>
					<% } else {%>
						<a onClick="javascript:sort('BBSTITLE')"><span class="glyphicon glyphicon-chevron-down"></span></a>
					<%} %>
					</th>
					<th style="background-color: #eeeeee; text-align: center; width: 80px;">작성자
					<% if(sort.equals("USERID")) {%>
						<a onClick="javascript:sort('USERID DESC')"><span class="glyphicon glyphicon-chevron-up"></span></a>
					<% } else {%>
						<a onClick="javascript:sort('USERID')"><span class="glyphicon glyphicon-chevron-down"></span></a>
					<%} %>
					</th>
					<th style="background-color: #eeeeee; text-align: center; width: 250px;">작성일자
					<% if(sort.equals("BBSDATE")) {%>
						<a onClick="javascript:sort('BBSDATE DESC')"><span class="glyphicon glyphicon-chevron-up"></span></a>
					<% } else {%>
						<a onClick="javascript:sort('BBSDATE')"><span class="glyphicon glyphicon-chevron-down"></span></a>
					<%} %>
					</th>
				</tr>
			</thead>
			
			<!-- 게시판 목록 -->
			<tbody>
				<%
					BbsDAO bbsDAO = new BbsDAO(); // DAO 객체 선언
					if(searchWord == null) // 검색하지 않았을 경우 일반 출력
					list = bbsDAO.getList(pageNumber, bunch);
					else // 검색했을 경우 파라미터에 따라 출력
					list = bbsDAO.getList(searchOption, searchWord, pageNumber, bunch, startDate, endDate, sort);
					for(int n = 0; n < list.size(); n++) {// for문으로 게시글 출력 (n개씩 보기)%>
					<tr>
						<td><%= list.get(n).getBbsID() %></td>
						<td><a href="view.jsp?bbsID=<%= list.get(n).getBbsID() %>"><%= list.get(n).getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %></a></td>
						<td><%= list.get(n).getUserID() %></td>
						<td><%= list.get(n).getBbsDate().substring(2,16)%></td>
					</tr>
					<%}%>
			</tbody>
		</table>
		
		<%if(pageNumber > 5) { // 6 페이지 이상이라면 이전 버튼 활성화%>
		<a onClick="javascript:startPage()" class="btn btn-success btn-arrow-left">&lt;&lt;</a> 
		<a onClick="javascript:prevPage()" class="btn btn-success btn-arrow-left">&lt;</a> <%} 
		
		for (i=1+(start-1)*5; i<=end; i++) { //n ~ n+4 페이지 버튼 출력 
			// 다음 페이지가 존재하면 해당 페이지 버튼 활성화
			if(bbsDAO.nextPage(i, bunch, searchOption, searchWord, startDate, endDate)) {
				if(i==pageNumber) { // 현재 페이지는 다른 css 적용%>
					<a onClick="javascript:currentPage(this)" class="btn btn-info"><%=i%></a>
				<%} else {%>
					<a onClick="javascript:currentPage(this)"class="btn btn-light"><%=i%></a><%}}} 
		
		// 5n 페이지의 다음 페이지가 존재하면 다음 버튼 활성화
		if(bbsDAO.nextPage(end + 1, bunch, searchOption, searchWord, startDate, endDate)) {%>
			<a onClick="javascript:nextPage()" class="btn btn-success btn-arrow-right">&gt;</a> 
			<% if(searchWord != null) {%>
				<a onClick="javascript:endPage('<%=bbsDAO.getTotal(
						searchOption, searchWord, startDate, endDate) 
				%>')"class="btn btn-success btn-arrow-right">&gt;&gt;</a><%} 
			else { %><a onClick="javascript:endPage('<%=bbsDAO.getTotal() %>')"
			class="btn btn-success btn-arrow-right">&gt;&gt;</a><%}} %>
		<a href="write.jsp" class="btn btn-primary pull-right">글쓰기</a>
	</div>
</div>
<script src="https://code.jquery.com/jquery-3.2.1.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js"></script>
<script src="js/bootstrap-datepicker.js"></script>
<script src="js/bootstrap-datepicker.ko.js"></script>
<script src="js/bootstrap.js"></script>
</body>
</html>