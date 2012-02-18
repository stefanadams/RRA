<html><head>
<TITLE>dbschemas.asp</TITLE>
</head>
<body bgcolor="#FFFFFF">
<!--#INCLUDE FILE="adovbs.inc" -->
<!--#INCLUDE FILE="lib_fieldtypes.asp" -->
<% 
myDSN = "Provider=SQLOLEDB.1;" & _
        "Network Library=dbmssocn;" & _
        "Data Source=sql.washingtonrotary.com;" & _
        "User ID=washingtonrotary;" & _
        "Password=harris;" & _
        "Initial Catalog=washrot_radioauction;"

set conntemp=server.createobject("adodb.connection")
conntemp.open myDSN

Set rsSchema = conntemp.OpenSchema(adSchemaColumns)
thistable=""
pad="&nbsp;&nbsp;&nbsp;"
DO  UNTIL rsSchema.EOF
   prevtable=thistable
   thistable=rsSchema("Table_Name")
   thiscolumn=rsSchema("COLUMN_NAME")
   IF thistable<>prevtable THEN
      response.write "Table=<b>" & thistable & "</b><br>"
      response.write "TABLE_CATALOG=<b>" & rsSchema("TABLE_CATALOG") & "</b><br>"
      response.write "TABLE_SCHEMA=<b>" & rsSchema("TABLE_SCHEMA") & "</b><p>"
   END IF
   response.write "<br>" & pad & "Field=<b>" & thiscolumn & "</b><br>"
   response.write pad & "Type=<b>" & fieldtypename(rsSchema("DATA_TYPE")) & "</b><br>"


   DIM colschema(27)
   colschema(0)="TABLE_CATALOG"
   colschema(1)="TABLE_SCHEMA"
   colschema(2)="TABLE_NAME"
   colschema(3)="COLUMN_NAME"
   colschema(4)="COLUMN_GUID"
   colschema(5)="COLUMN_PROP_ID"
   colschema(6)="ORDINAL_POSITION"
   colschema(7)="COLUMN_HASDEFAULT"
   colschema(8)="COLUMN_DEFAULT"
   colschema(9)="COLUMN_FLAGS"
   colschema(10)="IS_NULLABLE"
   colschema(11)="DATA_TYPE"
   colschema(12)="TYPE_GUID"
   colschema(13)="CHARACTER_MAXIMUM_LENGTH"
   colschema(14)="CHARACTER_OCTET_LENGTH"
   colschema(15)="NUMERIC_PRECISION"
   colschema(16)="NUMERIC_SCALE"
   colschema(17)="DATETIME_PRECISION"
   colschema(18)="CHARACTER_SET_CATALOG"
   colschema(19)="CHARACTER_SET_SCHEMA"
   colschema(20)="CHARACTER_SET_NAME"
   colschema(21)="COLLATION_CATALOG"
   colschema(22)="COLLATION_SCHEMA"
   colschema(23)="COLLATION_NAME"
   colschema(24)="DOMAIN_NAME"
   colschema(25)="DOMAIN_CATALOG"
   colschema(26)="DOMAIN_SCHEMA"
   colschema(27)="DESCRIPTION"

   ON ERROR RESUME NEXT
   FOR counter=4 to 27
      thisColInfoType=colschema(counter)
      thisColInfo=rsSchema(thisColInfoType)
      If err.number<>0 then
         thiscolinfo="-error-"
         err.clear
      END IF
      IF thisColInfo<>"" THEN
         response.write pad & pad & pad & thiscolinfotype 
         response.write "=<b>" & thiscolinfo & "</b><br>"
      END IF
   NEXT
   response.flush
   rsSchema.MoveNext
LOOP

rsSchema.Close
set rsSchema=nothing

conntemp.close
set conntemp=nothing
%>
</body></html>
