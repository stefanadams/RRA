<!--#INCLUDE FILE='vars.asp' -->
<!--#INCLUDE FILE='connect.asp' -->
<html>
	<head>
		<title>M (<% Response.Write DBYEAR %>): <% Response.Write radiotitle %></title>
		<style type="text/css">
			A:link		{color:red; text-decoration:underline}
			A:visited	 {color:red; text-decoration:underline}
			A:hover	   {color:red; text-decoration:underline}
			A.mainlinks:link		{color:red; text-decoration:underline}
			A.mainlinks:visited	 {color:red; text-decoration:underline}
			A.mainlinks:hover	   {color:red; text-decoration:underline}
			body {topmargin="0" leftmargin="0"  bgcolor="#FFFFFF"
			table .bidding {text-align:center;width:100%;padding:4;spacing:0;border:0}
			tbody .item {text-valign:top;border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080}
			.suggestedvalue {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080;text-align:right}
			thead td.noitems {align:center;font-face:verdana;color:#000;font-size:14px}
			thead td.item {border-bottom: 1 solid #808080}
			thead td.value {text-align:center;border-bottom: 1 solid #808080}
			thead td.current {text-align:center;border-bottom: 1 solid #808080}
			thead td.high {text-align:center;border-bottom: 1 solid #808080}
			thead td.donor {text-align:center;border-bottom: 1 solid #808080}
			thead td.message {text-align:center;border-bottom: 1 solid #808080}
			tbody td.item {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080;text-align:right}
			tbody td.value {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080;text-align:right}
			tbody td.current {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080;text-align:right}
			tbody td.current span {font-weight:bold;color:red}
			tbody td.high {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080;text-align:center}
			tbody td.donor {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080}
			tbody td.message {text-valign:top;border-right: 1 solid #808080; border-bottom: 1 solid #808080}
			table#menu {width:500;text-align:center;padding:5;spacing:0;background-color:#F2F2E0}
			table#menu td {text-align:center;font-face:verdana:color:#000;font-size:14px}
		</style>
		<META HTTP-EQUIV="refresh" content="30;URL=<%=Request.ServerVariables("SCRIPT_NAME")%>">
		<link href="style.css" rel="STYLESHEET">
		<script language=javascript>
			function showpage(id) {
				var options;
				var leftpos;
				var toppos;
				var page;
				page = "/sponsorinfo.asp?id="+id;
				leftpos = (screen.width-400)/2;
				toppos = (screen.height-400)/2;
				options = "'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,copyhistory=no,width=400,height=400 left=" + leftpos + " top=" + toppos + "')"
				var spw = window.open(page, "sponsorinfo", options);
			}
		</script>
	</head>

	<body>
		<% if Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" then Response.Write Session("status") & "<br />" end if %>
		<%
			SQLStatement = "SELECT id, name, status, sellername, suggestedprice, bid, timer, timeradmin, advertisement, active, moreinfo FROM items WHERE (status = 'Bidding' Or status = 'Halt') Order By id"
			objRS.Open SQLStatement, objConn
		%>
		<table class="bidding">
		<% If objRS.EOF Then %>
			<thead>
				<th class="noitems">No Items Currently Up For Bid</th></tr>
			</thead>
		<% else %>
			<thead>
				<tr>
					<th class="item">Item Up For Bid</td>
					<th class="value">Value</td>
					<th class="current">Current Bid</td>
					<th class="high">High Bidder</td>
					<th class="donor">Donor</td>
					<th class="message">Message</td>
				</tr>
			</head>
			<%	while not objRS.eof
					adtext = objRS("advertisement")
					moreinfo = objRS("moreinfo")
					strbid = ""
					trcolor = "#F2F2E0"
					if objRS("timer") <> "" and (objRS("timeradmin") = "time" or objRS("timeradmin") = "end") Then
						newtime = timer
						elapsed = newtime - objRS("timer")
						strTimer = "<img align='left' src='images/timer.gif'>&nbsp;"
						trcolor = "#FFD685"
					Else
						strTimer =  "&nbsp;"
						'trcolor = "#F2F2E0"
					end if
					if objRS("bid") => objRS("SuggestedPrice") Then
						strbid = "<img src='images/overbid_star.gif' width='14' height='14'>&nbsp;"
						if timeleft = "" or timeleft > 60 Then trcolor = "#FFD685"
					End If
					if objRS("timeradmin") = "Halt" Then
						strTimer =  "<nobr>Auction Closed</nobr><br>"
						trcolor = "#87cefa"
					end if %>
					<tr bgcolor='<% response.write trcolor %>'>
						<td class="item">
							<% if moreinfo <> "" Then %>
								<a href='<% response.write moreinfo %>'><b>More Info</b></a> | 
							<% End If %>
							<% Response.Write objRS("id") & ": " & objRS("name") %>
						</td>
						<td class="value"><% response.write formatcurrency(objRS("suggestedprice"),2) %></td>
						<td class="current">
							<% if strTimer <> "" then Response.Write strTimer %>
							<% if strbid <> "" Then Response.Write strbid %>
							<span<% response.write formatcurrency(objRS("bid"),2) %></span>
						</td>
						<td class="high">
							<% if objRS("bid") > 0 Then call biddername(objRS("id")) Else Response.Write "&nbsp;-&nbsp;" End If %>
						</td>
						<td class="donor"><% response.write objRS("sellername") %></td>
						<td class="message">
							<% if adtext <> "" Then %>
								<a href="#" onClick="showpage('<% response.write objRS("id") %>');"><% response.write left(adtext,50) %>...</a>
							<% Else %>
								&nbsp;
							<% End If %>
						</td>
					</tr>
					<% objRS.MoveNext %>
			<% wend %>
			<tr>
				<td colspan='6'>
					Key: <img src='images/overbid_star.gif' valign='middle' width='14' height='14'>&nbsp;= Bell Ringer | <img valign='middle' src='images/timer.gif'>&nbsp;= Timer
				</td>
			</tr>
		<% end if %>
		<% objRS.Close %>
		</table>
		<% If Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" Then %>
			<br><br>
			<table id="menu">
				<tr>
					<td><a class='mainlinks' href='welcome.asp'>Welcome</a></td>
				</tr>
			</table>
			<br>
		<% else %>
			<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
			<a href="/admin.asp"><img width=8 border=0 src="http://radioauction.washingtonrotary.com/auction/content/icons/arrow-right2.gif"></a>  
		<% end If %>
	</body>
</html>

<%
On Error Resume Next
if isObject(objRS) Then
	objRS.close
	set objRS = nothing
End If

if isObject(objConn) Then
	ojbConn.close
	set objConn = nothing
End If
%>
