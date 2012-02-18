<?php
	// check this file's MD5 to make sure it wasn't called before
	$prevMD5=@implode('', @file("./setup.md5"));
	$thisMD5=md5(@implode('', @file("./updateDB.php")));
	if($thisMD5==$prevMD5){
		$setupAlreadyRun=true;
	}else{
		// set up tables
		if(!isset($silent)){
			$silent=true;
		}

		// set up tables
		setupTable("stockitems", "create table if not exists `stockitems` ( `ID` INT(11) not null auto_increment , primary key (`ID`), `Name` CHAR(255) , `ItemDescription` CHAR(255) , `suggestedvalue` INT(11) , `Cost` INT(11) )", $silent);


		// save MD5
		if($fp=@fopen("./setup.md5", "w")){
			fwrite($fp, $thisMD5);
			fclose($fp);
		}
	}


	function setupTable($tableName, $createSQL='', $silent=true, $arrAlter=''){
		global $Translation;
		ob_start();

		echo "<div style=\"padding: 5px; border-bottom:solid 1px silver; font-family: verdana, arial; font-size: 10px;\">";
		if($res=@mysql_query("select count(1) from `$tableName`")){
			if($row=@mysql_fetch_array($res)){
				echo str_replace("<TableName>", $tableName, str_replace("<NumRecords>", $row[0],$Translation["table exists"]));
				if(is_array($arrAlter)){
					echo '<br>';
					foreach($arrAlter as $alter){
						if($alter!=''){
							echo "$alter ... ";
							if(!@mysql_query($alter)){
								echo "<font color=red>".$Translation["failed"]."</font><br>";
								echo "<font color=red>".$Translation["mysql said"]." ".mysql_error()."</font><br>";
							}else{
								echo "<font color=green>".$Translation["ok"]."</font><br>";
							}
						}
					}
				}else{
					echo $Translation["table uptodate"];
				}
			}else{
				echo str_replace("<TableName>", $tableName, $Translation["couldnt count"]);
			}
		}else{
			echo str_replace("<TableName>", $tableName, $Translation["creating table"]);
			if(!@mysql_query($createSQL)){
				echo "<font color=red>".$Translation["failed"]."</font><br>";
				echo "<font color=red>".$Translation["mysql said"].mysql_error()."</font>";
			}else{
				echo "<font color=green>".$Translation["ok"]."</font>";
			}
		}

		echo "</div>";

		$out=ob_get_contents();
		ob_end_clean();
		if(!$silent){
			echo $out;
		}
	}
?>