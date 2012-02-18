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
		setupTable("contacts", "create table if not exists `contacts` ( `id` INT unsigned not null auto_increment , primary key (`id`), `contact_chamberid` SMALLINT , `contact_name` VARCHAR(40) not null , `contact_type` VARCHAR(40) , `contact_primary` VARCHAR(40) , `contact_secondary` VARCHAR(40) , `contact_address` VARCHAR(40) , `contact_city` VARCHAR(40) default 'Washington' , `contact_state` VARCHAR(40) default 'MO' , `contact_zip` VARCHAR(10) default '63090' , `contact_phone` VARCHAR(25) , `contact_email` VARCHAR(40) , `contact_dns` VARCHAR(40) , `contact_lastyear` VARCHAR(40) , `contact_advertisements` TINYTEXT , `contact_comments` TINYTEXT , `rotarian_id` INT unsigned )", $silent, array(" ALTER TABLE `contacts` CHANGE `contact_memberid` `contact_memberid` VARCHAR(40) not null ","ALTER TABLE `contacts` CHANGE `contact_memberid` `contact_chamberid` VARCHAR(40) not null ","ALTER TABLE `contacts` DROP `contact_ischamber`"," ALTER TABLE `contacts` CHANGE `contact_chamberid` `contact_chamberid` VARCHAR(40) ","ALTER TABLE `contacts` DROP INDEX `contact_chamberid`","ALTER TABLE `contacts` ADD UNIQUE (`contact_chamberid`)","ALTER TABLE `contacts` DROP INDEX `contact_chamberid`"," ALTER TABLE `contacts` CHANGE `contact_chamberid` `contact_chamberid` SMALLINT "," ALTER TABLE `contacts` CHANGE `contact_phone` `contact_phone` VARCHAR(25) "));
		setupTable("rotarians", "create table if not exists `rotarians` ( `id` INT unsigned not null auto_increment , primary key (`id`), `rotarian_name` VARCHAR(40) not null )", $silent);
		setupTable("donations", "create table if not exists `donations` ( `id` INT unsigned not null auto_increment , primary key (`id`), `donation_year` YEAR not null , `donation_item` VARCHAR(40) , `donation_description` VARCHAR(40) , `donation_msrp` SMALLINT(15) , `donation_more_url` VARCHAR(40) , `donation_more_text` TINYTEXT , `contact_id` INT unsigned , `stockitem_id` INT unsigned )", $silent, array(" ALTER TABLE `donations` CHANGE `donation_year` `donation_year` YEAR not null "));
		setupTable("stockitems", "create table if not exists `stockitems` ( `id` INT unsigned not null auto_increment , primary key (`id`), `stockitem_name` VARCHAR(40) not null , `stockitem_description` VARCHAR(40) , `stockitem_msrp` SMALLINT(15) not null , `stockitem_cost` SMALLINT(15) not null )", $silent);


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