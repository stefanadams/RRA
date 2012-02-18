	</td>
    <td>&nbsp;</td>
  </tr>
</table>
<br><br>

<br>

</BODY>
</HTML>

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