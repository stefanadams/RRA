<?php
// This script and data application were generated by AppGini 4.2 on 1/19/2009 at 1:01:05 PM
// Download AppGini for free from http://www.bigprof.com/appgini/download/


	include(dirname(__FILE__)."/defaultLang.php");
	include(dirname(__FILE__)."/language.php");

	$divFormat="<div style=\"text-align: center; font-weight: bold; font-family: verdana,arial; font-size: 15px;\">";
	$backHome="$divFormat<a href=\"./\">".$Translation["goto start page"]."</a></div>";


	if(!extension_loaded('mysql')){
		echo "<div class=Error>ERROR: PHP is not configured to connect to MySQL on this machine. Please see <a href=http://www.php.net/manual/en/ref.mysql.php>this page</a> for help on how to configure MySQL.</div>";
		exit;
	}

	// connect to the database
	if(is_array($HTTP_POST_VARS)){
		$dbServer=$HTTP_POST_VARS['dbServer'];
		$dbUsername=$HTTP_POST_VARS['dbUsername'];
		$dbPassword=$HTTP_POST_VARS['dbPassword'];
		$dbDatabase=$HTTP_POST_VARS['dbDatabase'];
	}else{
		$dbServer=$_POST['dbServer'];
		$dbUsername=$_POST['dbUsername'];
		$dbPassword=$_POST['dbPassword'];
		$dbDatabase=$_POST['dbDatabase'];
	}
	$noDB=0;
	if(!@mysql_connect($dbServer, $dbUsername, $dbPassword)){
		$noDB=1;
	}elseif(!@mysql_select_db($dbDatabase)){
		if(!@mysql_query("create database `$dbDatabase`")){
			$noDB=2;
		}else{
			if(!@mysql_select_db($dbDatabase)){
				$noDB=2;
			}
		}
	}

	// if no connection established, ask for connection data
	if($noDB){
		if($dbServer!=''){
			echo $divFormat."<div style=\"color: red;\">".($noDB==1 ? $Translation["no db connection"] : str_replace("<DBName>", $dbDatabase, $Translation["no db name"]))."</div>"."</div>";
		}

		?>
		<form method="post" action="setup.php">
			<?php echo $divFormat; ?>
				<?php echo $Translation["provide connection data"]; ?>
				<br><br><center>
				<table bgcolor="#FFE4E1" style="border: solid silver 1px;" width="400">
					<tr>
						<td align="right"><?php echo $divFormat; ?><?php echo $Translation["mysql server"]; ?></div></td>
						<td><input type="text" name="dbServer" size="20"></td>
						</tr>
					<tr>
						<td align="right"><?php echo $divFormat; ?><?php echo $Translation["mysql username"]; ?></div></td>
						<td><input type="text" name="dbUsername" size="10"></td>
						</tr>
					<tr>
						<td align="right"><?php echo $divFormat; ?><?php echo $Translation["mysql password"]; ?></div></td>
						<td><input type="password" name="dbPassword" size="10"></td>
						</tr>
					<tr>
						<td align="right"><?php echo $divFormat; ?><?php echo $Translation["mysql db"]; ?></div></td>
						<td><input type="text" name="dbDatabase" size="15"></td>
						</tr>
					<tr>
						<td align="right"></td>
						<td><input type="submit" value="<?php echo $Translation["connect"]; ?>"></td>
						</tr>
					</table>
					</center><br><div style="font-size: 10px;">Powered by <a href="http://www.bigprof.com/appgini/" target=_blank>BigProf AppGini 4.2</a></div>
				</div>
			</form>
		<?php
		exit;
	}else{
		// if connection is successful, save parameters into config.php
		if(!$fp=@fopen("./config.php", "w")){
			echo $divFormat."<div style=\"color: red;\">".$Translation["couldnt save config"]."</div></div><br>";
			echo $backHome;
			exit;
		}else{
			fwrite($fp, "<?php\n");
			fwrite($fp, "\t\$dbServer=\"$dbServer\";\n");
			fwrite($fp, "\t\$dbUsername=\"$dbUsername\";\n");
			fwrite($fp, "\t\$dbPassword=\"$dbPassword\";\n");
			fwrite($fp, "\t\$dbDatabase=\"$dbDatabase\";\n");
			fwrite($fp, "?>");
			fclose($fp);
		}
	}

	$silent=false;
	include(dirname(__FILE__)."/updateDB.php");
	if($setupAlreadyRun){
		echo "$divFormat ".$Translation["setup performed"]." ".date("r", filemtime("./setup.md5")).".<br><br></div>";
		echo "$divFormat<div style=\"font-size: 10px;\">".$Translation["delete md5"]."</div></div><br><br>";
		echo $backHome;
		exit;
	}

	// go to index
	echo $backHome;

?>