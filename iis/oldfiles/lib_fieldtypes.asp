<%
FUNCTION fieldtypename(parm1)
   SELECT CASE Parm1
   CASE 0
      fieldtypename="adEmpty"
   CASE 16
      fieldtypename="adTinyInt"
   CASE 2
      fieldtypename="adSmallInt"
   CASE 3
      fieldtypename="adInteger"
   CASE 20
      fieldtypename="adBigInt"
   CASE 17
      fieldtypename="adUnsignedTinyInt"
   CASE 18
      fieldtypename="adUnsignedSmallInt"
   CASE 19
      fieldtypename="adUnsignedInt"
   CASE 21
      fieldtypename="adUnsignedBigInt"
   CASE 4
      fieldtypename="adSingle"
   CASE 5
      fieldtypename="adDouble"
   CASE 6
      fieldtypename="adCurrency"
   CASE 14
      fieldtypename="adDecimal"
   CASE 131
      fieldtypename="adNumeric"
   CASE 11
      fieldtypename="adBoolean"
   CASE 10
      fieldtypename="adError"
   CASE 132
      fieldtypename="adUserDefined"
   CASE 12
      fieldtypename="adVariant"
   CASE 9
      fieldtypename="adIDispatch"
   CASE 13
      fieldtypename="adIUnknown"
   CASE 72
      fieldtypename="adGUID"
   CASE 7
      fieldtypename="adDate"
   CASE 133
      fieldtypename="adDBDate"
   CASE 134
      fieldtypename="adDBTime"
   CASE 135
      fieldtypename="adDBTimeStamp"
   CASE 8
      fieldtypename="adBSTR"
   CASE 129
      fieldtypename="adChar"
   CASE 200
      fieldtypename="adVarChar"
   CASE 201
      fieldtypename="adLongVarChar"
   CASE 130
      fieldtypename="adWChar"
   CASE 202
      fieldtypename="adVarWChar"
   CASE 203
      fieldtypename="adLongVarWChar"
   CASE 128
      fieldtypename="adBinary"
   CASE 204
      fieldtypename="adVarBinary"
   CASE 205
      fieldtypename="adLongVarBinary"
   CASE ELSE
      fieldtypename="Undefined by ADO"
   END SELECT
END FUNCTION
%>
