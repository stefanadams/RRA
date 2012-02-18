<?php
	error_reporting(E_ALL ^ E_NOTICE);
	set_magic_quotes_runtime(0);
	ob_start();

	// check if setup was performed or not yet
	$setupStyle="border: solid 1px red; background-color: #FFFFE0; color: red; font-size: 16px; font-family: arial; font-weight: bold; padding: 10px; width:400px; text-align: left;";
	if(!is_file(dirname(__FILE__)."/config.php")){
		?>
		<center>
		<div style="<?php echo $setupStyle ?>">
			<?php echo $Translation['db setup needed']; ?>
			</div>
			</center>
		<?php
		exit;
	}
	if(!is_file(dirname(__FILE__)."/admin/incConfig.php")){
		?>
		<center>
		<div style="<?php echo $setupStyle ?>">
			<?php echo $Translation['admin setup needed']; ?>
			</div>
			</center>
		<?php
		exit;
	}
	// -----------------------------------------

	include(dirname(__FILE__)."/admin/incFunctions.php");
	include(dirname(__FILE__)."/admin/incConfig.php");

	// check sessions config
	$noPathCheck=True;
	$arrPath=explode(';', ini_get('session.save_path'));
	$save_path=$arrPath[count($arrPath)-1];
	if(!$noPathCheck && !is_dir($save_path)){
		?>
		<center>
		<div style="<?php echo $setupStyle ?>">
			Your site is not configured to support sessions correctly. Please edit your php.ini file and change the value of <i>session.save_path</i> to a valid path.
			</div>
			</center>
		<?php
		exit;
	}
	if(session_id()){ session_write_close(); }
	ini_set('session.save_handler', 'files');
	ini_set('session.serialize_handler', 'php');
	ini_set('session.use_cookies', '1');
	@ini_set('session.use_only_cookies', '1');
	ini_set('session.cache_limiter', 'nocache');
	@session_name('washingtonrotary_master');
	session_start();
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	header('Content-Type: text/html; charset=us-ascii');

	// check if membership system exists
	setupMembership();

	// silently apply db changes, if any
	if(!$_SESSION['calledUpdateDB']){
		@include_once(dirname(__FILE__).'/updateDB.php');
		$_SESSION['calledUpdateDB']=true;
	}

	// do we have a login request?
	if($_POST['signIn']!=''){
		if(logInMember()){
			redirect("index.php");
		}
	}

	#########################################################
	/*
	~~~~~~ LIST OF FUNCTIONS ~~~~~~
		getTableList() -- returns an associative array (tableName=>tableCaption) of tables accessible by current user
		getLoggedMemberID() -- returns memberID of logged member. If no login, returns anonymous memberID
		getLoggedGroupID() -- returns groupID of logged member, or anonymous groupID
		logOutMember() -- destroys session and logs member out.
		logInMember() -- checks POST login. If not valid, redirects to index.php, else returns TRUE
		getTablePermissions($tn) -- returns an array of permissions allowed for logged member to given table (allowAccess, allowInsert, allowView, allowEdit, allowDelete) -- allowAccess is set to true if any access level is allowed
		htmlUserBar() -- returns html code for displaying user login status to be used on top of pages.
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	*/
	#########################################################
	function getTableList(){
		$arrTables=array(
			"contacts"=>"Contacts",
			"rotarians"=>"Rotarians",
			"donations"=>"Donations",
			"stockitems"=>"Stockitems",
			);
		if(is_array($arrTables)){
			foreach($arrTables as $tn=>$tc){
				$arrPerm=getTablePermissions($tn);
				if($arrPerm[0]){
					$arrAccessTables[$tn]=$tc;
				}
			}
		}

		return $arrAccessTables;
	}
	#########################################################
	function getTablePermissions($tn){
		$groupID=getLoggedGroupID();
		$res=sql("select allowInsert, allowView, allowEdit, allowDelete from membership_grouppermissions where groupID='$groupID' and tableName='$tn'");
		if($row=mysql_fetch_row($res)){
			if($row[0] || $row[1] || $row[2] || $row[3]){
				$arrRet[0]=TRUE;
			}else{
				$arrRet[0]=FALSE;
			}
			$arrRet[1]=$row[0];
			$arrRet[2]=$row[1];
			$arrRet[3]=$row[2];
			$arrRet[4]=$row[3];

			return $arrRet;
		}

		return array(FALSE, 0, 0, 0, 0);
	}
	#########################################################
	function getLoggedGroupID(){
		if($_SESSION['memberGroupID']!=''){
			return $_SESSION['memberGroupID'];
		}else{
			setAnonymousAccess();
			return getLoggedGroupID();
		}
	}
	#########################################################
	function getLoggedMemberID(){
		if($_SESSION['memberID']!=''){
			return $_SESSION['memberID'];
		}else{
			setAnonymousAccess();
			return getLoggedMemberID();
		}
	}
	#########################################################
	function setAnonymousAccess(){
		global $adminConfig;

		$anonGroupID=sqlValue("select groupID from membership_groups where name='".$adminConfig['anonymousGroup']."'");
		$_SESSION['memberGroupID']=($anonGroupID ? $anonGroupID : 0);

		$anonMemberID=sqlValue("select memberID from membership_users where memberID='".$adminConfig['anonymousMember']."' and groupID='$anonGroupID'");
		$_SESSION['memberID']=($anonMemberID ? $anonMemberID : 0);
	}
	#########################################################
	function logInMember(){
		if($_POST['username']!='' && $_POST['password']!=''){
			$username=makeSafe($_POST['username']);
			$password=md5($_POST['password']);

			if(sqlValue("select count(1) from membership_users where memberID='$username' and passMD5='$password' and isApproved=1 and isBanned=0")==1){
				$_SESSION['memberID']=$username;
				$_SESSION['memberGroupID']=sqlValue("select groupID from membership_users where memberID='$username'");
				return TRUE;
			}
		}

		redirect("index.php?loginFailed=1");
		return FALSE;
	}
	#########################################################
	function logOutMember(){
		logOutUser();
		redirect("index.php?signIn=1");
	}
	#########################################################
	function htmlUserBar(){
		global $adminConfig, $Translation;

		if($_POST['Print_x'] || $_GET['Print_x']){
			return "";
		}

		ob_start();

		?>
		<div class="TableFooter" style="text-align: right;">
			<?php
				if(!$_GET['signIn'] && !$_GET['loginFailed']){
					if(getLoggedMemberID()==$adminConfig['anonymousMember']){
						?><?php echo $Translation['not signed in']; ?>. <a href="index.php?signOut=1"><?php echo $Translation['sign in']; ?></a><?php
					}else{
						?><?php echo $Translation['signed as']; ?> '<?php echo getLoggedMemberID(); ?>'. <a href="index.php?signOut=1"><?php echo $Translation['sign out']; ?></a><?php
					}
				}
			?>
			 &nbsp; &nbsp; &nbsp; 
			</div><br><br>
		<?php

		$html=ob_get_contents();
		ob_end_clean();

		return $html;
	}
	#########################################################
?>