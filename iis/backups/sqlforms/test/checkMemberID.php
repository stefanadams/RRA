<?php ob_start(); ?>
<center>

<?php

	include(dirname(__FILE__)."/defaultLang.php");
	include(dirname(__FILE__)."/language.php");
	include(dirname(__FILE__)."/lib.php");

	$memberID=mysql_escape_string($_GET['memberID']);
	if($memberID!=''){
		$res=sql("select memberID from membership_users where memberID='$memberID'");
		if($row=mysql_fetch_row($res)){
			echo "<b>".str_replace("<MemberID>", $memberID, $Translation['user already exists'])."</b>";
		}else{
			echo "<b>".str_replace("<MemberID>", $memberID, $Translation['user available'])."</b>";
		}
	}else{
		echo $Translation['empty user'];
	}
?>

<br><br><input type="button" value="Close" onClick="window.close();">
</center>
