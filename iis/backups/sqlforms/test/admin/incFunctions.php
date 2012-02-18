<?php
	########################################################################
	/*
	~~~~~~ LIST OF FUNCTIONS ~~~~~~
		getTableList() -- returns an associative array of all tables in this application in the format tableName=>tableCaption
		makeSafe($string)
		checkPermissionVal($pvn)
		sql($statment)
		sqlValue($statment)
		getLoggedAdmin()
		checkUser($username, $password)
		logOutUser()
		getPKFieldName($tn)
		getCSVData($tn, $pkValue)
		errorMsg($msg)
		redirect($URL, $absolute=FALSE)
		htmlRadioGroup($name, $arrValue, $arrCaption, $selectedValue, $selClass="", $class="", $separator="<br>")
		htmlSelect($name, $arrValue, $arrCaption, $selectedValue, $class="", $selectedClass="")
		htmlSQLSelect($name, $sql, $selectedValue, $class="", $selectedClass="")
		isEmail($email) -- returns $email if valid or false otherwise.
		notifyMemberApproval($memberID) -- send an email to member acknowledging his approval by admin, returns false if no mail is sent
		setupMembership() -- check if membership tables exist or not. If not, create them.
		thisOr($this, $or) -- return $this if it has a value, or $or if not.
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	*/
	########################################################################

	#########################################################
	if(!function_exists('getTableList')){
		function getTableList(){
			$arrTables=array(
				"stockitems"=>"stockitems",
				);
	
			return $arrTables;
		}
	}
	########################################################################
	function makeSafe($string){
		$string=(get_magic_quotes_gpc() ? stripslashes($string) : $string);
		if(function_exists('mysql_real_escape_string')){
			// send a trivial query to initiate mysql connection
			sql("select (1+1) from membership_groups limit 1");
			return mysql_real_escape_string($string);
		}else{
			return mysql_escape_string($string);
		}
	}
	########################################################################
	function checkPermissionVal($pvn){
		// fn to make sure the value in the given POST variable is 0, 1, 2 or 3
		// if the value is invalid, it default to 0
		$pvn=intval($_POST[$pvn]);
		if($pvn!=1 && $pvn!=2 && $pvn!=3){
			return 0;
		}else{
			return $pvn;
		}
	}
	########################################################################
	if(!function_exists('sql')){
		function sql($statment){
			static $connected=FALSE; // would be set to TRUE on successful connection

			if(!$connected){
				// get db connection data from config file
				@require(dirname(__FILE__)."/../config.php");

				/****** Connect to MySQL ******/
				if(!mysql_connect($dbServer, $dbUsername, $dbPassword)){
					echo "<div class=\"error\">Couldn't connect to MySQL at '$dbServer'.</div>";
					exit;
				}
				/****** Select DB ********/
				if(!mysql_select_db($dbDatabase)){
					echo "<div class=\"error\">Couldn't connect to the database '$dbDatabase'.</div>";
					exit;
				}

				$connected=TRUE;
			}

			if(!$result = @mysql_query($statment)){
				echo "An error occured while attempting to execute:<br><pre>".htmlspecialchars($statment)."</pre><br>MySQL said:<br><pre>".mysql_error()."</pre>";
				exit;
			}

			return $result;
		}
	}
	########################################################################
	function sqlValue($statment){
		// executes a statment that retreives a single data value and returns the value retrieved
		if(!$res=sql($statment)){
			return FALSE;
		}
		if(!$row=mysql_fetch_row($res)){
			return FALSE;
		}
		return $row[0];
	}
	########################################################################
	function getLoggedAdmin(){
		// checks session variables to see whether a user is logged or not
		// if not, it returns FALSE
		// if logged, it returns the user id

		global $adminConfig;

		if($_SESSION['adminUsername']!=''){
			return $_SESSION['adminUsername'];
		}elseif($_SESSION['memberID']==$adminConfig['adminUsername']){
			$_SESSION['adminUsername']=$_SESSION['memberID'];
			return $_SESSION['adminUsername'];
		}else{
			return FALSE;
		}
	}
	########################################################################
	function checkUser($username, $password){
		// checks given username and password for validity
		// if valid, registers the username in a session and returns true
		// else, return FALSE and destroys session

		require(dirname(__FILE__)."/incConfig.php");
		if($username!=$adminConfig['adminUsername'] || md5($password)!=$adminConfig['adminPassword']){
			return FALSE;
		}

		$_SESSION['adminUsername']=$username;
		return TRUE;
	}
	########################################################################
	function logOutUser(){
		// destroys current session
		$_SESSION = array();
		if(isset($_COOKIE[session_name()])){
			setcookie(session_name(), '', time()-42000, '/');
		}
		session_destroy();
	}
	########################################################################
	function getPKFieldName($tn){
		// get pk field name of given table

		if(!$res=sql("show fields from `$tn`")){
			return FALSE;
		}

		while($row=mysql_fetch_assoc($res)){
			if($row['Key']=='PRI'){
				return $row['Field'];
			}
		}

		return FALSE;
	}
	########################################################################
	function getCSVData($tn, $pkValue){
		// get pk field name for given table
		if(!$pkField=getPKFieldName($tn)){
			return "";
		}

		// get a concat string to produce a csv list of field values for given table record
		if(!$res=sql("show fields from `$tn`")){
			return "";
		}
		while($row=mysql_fetch_assoc($res)){
			$csvFieldList.=$row['Field'].",";
		}
		$csvFieldList=substr($csvFieldList, 0, -1);

		return sqlValue("select CONCAT_WS(', ', $csvFieldList) from `$tn` where $pkField='$pkValue'");
	}
	########################################################################
	function errorMsg($msg){
		echo "<div class=\"status\" style=\"font-weight: bold; color: red;\">$msg</div>";
	}
	########################################################################
	function redirect($URL, $absolute=FALSE){
		$host   = $_SERVER['HTTP_HOST'];
		$uri    = rtrim(dirname($_SERVER['PHP_SELF']), '/\\');
		$http   = (strtolower($_SERVER['HTTPS']) == 'on' ? 'https:' : 'http:');
		$fullURL=($absolute ? "" : "$http//$host$uri/")."$URL";
		if(!headers_sent()){
			header("Location: $fullURL");
		}else{
			echo "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"0;url=$fullURL\">";
			echo "<br><br><a href=\"$fullURL\">Click here</a> if you aren't automatically redirected.";
		}
		exit;
	}
	########################################################################
	function htmlRadioGroup($name, $arrValue, $arrCaption, $selectedValue, $selClass="", $class="", $separator="<br>"){
		if(is_array($arrValue)){
			for($i=0; $i<count($arrValue); $i++){
				$out.="<span onMouseOver=\"stm(".$name.$arrValue[$i].", toolTipStyle);\"  onMouseOut=\"htm();\" class=\"".($arrValue[$i]==$selectedValue ? $selClass :$class)."\"><input type=\"radio\" name=\"$name\" value=\"".$arrValue[$i]."\"".($arrValue[$i]==$selectedValue ? " checked" : "")."> ".$arrCaption[$i]."</span>".$separator;
			}
		}
		return $out;
	}
	########################################################################
	function htmlSelect($name, $arrValue, $arrCaption, $selectedValue, $class="", $selectedClass=""){
		if($selectedClass==""){
			$selectedClass=$class;
		}
		if(is_array($arrValue)){
			$out="<select name=\"$name\" id=\"$name\">";
			for($i=0; $i<count($arrValue); $i++){
				$out.="<option value=\"".$arrValue[$i]."\"".($arrValue[$i]==$selectedValue ? " selected class=\"$class\"" : " class=\"$selectedClass\"").">".$arrCaption[$i]."</option>";
			}
			$out.="</select>";
		}
		return $out;
	}
	########################################################################
	function htmlSQLSelect($name, $sql, $selectedValue, $class="", $selectedClass=""){
		$arrVal[]='';
		$arrCap[]='';
		if($res=sql($sql)){
			while($row=mysql_fetch_row($res)){
				$arrVal[]=$row[0];
				$arrCap[]=$row[1];
			}
			return htmlSelect($name, $arrVal, $arrCap, $selectedValue, $class, $selectedClass);
		}else{
			return "";
		}
	}
	########################################################################
	function isEmail($email){
		if(ereg('^[-!#$%&\'*+\\./0-9=?A-Z^_`a-z{|}~]+'. '@'.
			'[-!#$%&\'*+\\/0-9=?A-Z^_`a-z{|}~]+\.'. 
			'[-!#$%&\'*+\\./0-9=?A-Z^_`a-z{|}~]+$', $email)){
			return $email;
		}else{
			return FALSE;
		}
	}
	########################################################################
	function notifyMemberApproval($memberID){
		require(dirname(__FILE__)."/incConfig.php");

		$email=sqlValue("select email from membership_users where memberID='$memberID'");
		if(!isEmail($email)){
			return FALSE;
		}
		if(!@mail($email, $adminConfig['approvalSubject'], $adminConfig['approvalMessage'], "From: ".$adminConfig['senderName']." <".$adminConfig['senderEmail'].">")){
			return FALSE;
		}

		return TRUE;
	}
	########################################################################
	function setupMembership(){
		require(dirname(__FILE__)."/incConfig.php");

		// check if membership tables exist or not
		sql("CREATE TABLE IF NOT EXISTS membership_groups (groupID int unsigned NOT NULL auto_increment, name varchar(20), description text, allowSignup tinyint, needsApproval tinyint, PRIMARY KEY (groupID))");
		sql("CREATE TABLE IF NOT EXISTS membership_users (memberID varchar(20) NOT NULL, passMD5 varchar(40), email varchar(100), signupDate date, groupID int unsigned, isBanned tinyint, isApproved tinyint, custom1 text, custom2 text, custom3 text, custom4 text, comments text, PRIMARY KEY (memberID))");
		sql("CREATE TABLE IF NOT EXISTS membership_grouppermissions (permissionID int unsigned NOT NULL auto_increment,  groupID int, tableName varchar(100), allowInsert tinyint, allowView tinyint NOT NULL DEFAULT '0', allowEdit tinyint NOT NULL DEFAULT '0', allowDelete tinyint NOT NULL DEFAULT '0', PRIMARY KEY (permissionID))");
		sql("CREATE TABLE IF NOT EXISTS membership_userrecords (recID bigint unsigned NOT NULL auto_increment, tableName varchar(100), pkValue varchar(255), memberID varchar(20), dateAdded bigint unsigned, dateUpdated bigint unsigned, groupID int, PRIMARY KEY (recID))");

		// create membership indices if not existing
		@mysql_query("ALTER TABLE membership_userrecords ADD INDEX pkValue (pkValue)");
		@mysql_query("ALTER TABLE membership_userrecords ADD INDEX tableName (tableName)");


		// check if anonymous group and user exist. If not, create them
		$anonGroupID=sqlValue("select groupID from membership_groups where name='".$adminConfig['anonymousGroup']."'");
		if(!$anonGroupID){
			sql("insert into membership_groups set name='".$adminConfig['anonymousGroup']."', allowSignup=0, needsApproval=0, description='Anonymous group created automatically on ".date("Y-m-d")."'");
			$anonGroupID=mysql_insert_id();

			// set anonymous group permissions
			sql("insert into membership_grouppermissions set groupID='$anonGroupID', tableName='stockitems', allowInsert=0, allowView=0, allowEdit=0, allowDelete=0");
		}
		$anonMemberID=sqlValue("select memberID from membership_users where memberID='".$adminConfig['anonymousMember']."' and groupID='$anonGroupID'");
		if(!$anonMemberID){
			sql("insert into membership_users set memberID='".$adminConfig['anonymousMember']."', signUpDate='".date("Y-m-d")."', groupID='$anonGroupID', isBanned=0, isApproved=1, comments='Anonymous member created automatically on ".date("Y-m-d")."'");
		}

		// check if admin group and user exist. If not, create them
		$adminGroupID=sqlValue("select groupID from membership_groups where name='Admins'");
		if(!$adminGroupID){
			sql("insert into membership_groups set name='Admins', allowSignup=0, needsApproval=1, description='Admin group created automatically on ".date("Y-m-d")."'");
			$adminGroupID=mysql_insert_id();
		}

		if(sqlValue("select count(1) from membership_grouppermissions where groupID='$adminGroupID'")<1){
			sql("delete from membership_grouppermissions where groupID='$adminGroupID'");
			// set admin group permissions
			sql("insert into membership_grouppermissions set groupID='$adminGroupID', tableName='stockitems', allowInsert=1, allowView=3, allowEdit=3, allowDelete=3");
		}
		$adminMemberID=sqlValue("select memberID from membership_users where memberID='".$adminConfig['adminUsername']."' and groupID='$adminGroupID'");
		if(!$adminMemberID){
			sql("insert into membership_users set memberID='".$adminConfig['adminUsername']."', passMD5='".$adminConfig['adminPassword']."', email='".$adminConfig['senderEmail']."', signUpDate='".date("Y-m-d")."', groupID='$adminGroupID', isBanned=0, isApproved=1, comments='Admin member created automatically on ".date("Y-m-d")."'");
		}

	}
	########################################################################
	function thisOr($this, $or='&nbsp;'){
		return ($this!='' ? $this : $or);
	}
	########################################################################
?>