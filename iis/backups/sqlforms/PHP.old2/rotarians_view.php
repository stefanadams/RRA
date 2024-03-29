<?php
// This script and data application were generated by AppGini 4.2 on 1/19/2009 at 1:01:05 PM
// Download AppGini for free from http://www.bigprof.com/appgini/download/

	include(dirname(__FILE__)."/defaultLang.php");
	include(dirname(__FILE__)."/language.php");
	include(dirname(__FILE__)."/lib.php");
	include(dirname(__FILE__)."/rotarians_dml.php");

	// SQL query used in the filters page and the CSV file
	$filtersCSVQuery="select rotarians.id as 'ID', rotarians.rotarian_name as 'Name' from rotarians ";
	// SQL query used in the table view
	$tableViewQuery="select rotarians.id as 'ID', rotarians.rotarian_name as 'Name' from rotarians ";

	// mm: can the current member access this page?
	$perm=getTablePermissions('rotarians');
	if(!$perm[0]){
		echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">";
		echo "<div class=\"error\">".$Translation['tableAccessDenied']."</div>";
		exit;
	}

	$x = new DataList;
	$x->TableName = "rotarians";
	$x->DataHeight = 150;
	$x->AllowSelection = 1;
	$x->HideTableView = ($perm[2]==0 ? 1 : 0);
	$x->AllowDelete = $perm[4];
	$x->AllowInsert = $perm[1];
	$x->AllowUpdate = $perm[3];
	$x->SeparateDV = 0;
	$x->AllowDeleteOfParents = 0;
	$x->AllowFilters = 1;
	$x->AllowSavingFilters = 1;
	$x->AllowSorting = 1;
	$x->AllowNavigation = 1;
	$x->AllowPrinting = 0;
	$x->AllowCSV = 0;
	$x->RecordsPerPage = 10;
	$x->QuickSearch = 3;
	$x->QuickSearchText = $Translation["quick search"];
	$x->ScriptFileName = "rotarians_view.php";
	$x->RedirectAfterInsert = "rotarians_view.php?SelectedID=#ID#";
	$x->TableTitle = "Rotarians";
	$x->PrimaryKey = "rotarians.id";
	$x->DefaultSortField = "2";
	$x->DefaultSortDirection = "asc";

	$x->ColWidth   = array(150, 150);
	$x->ColCaption = array("ID", "Name");
	$x->ColNumber  = array(1, 2);

	$x->Template = 'rotarians_templateTV.html';
	$x->SelectedTemplate = 'rotarians_templateTVS.html';
	$x->ShowTableHeader = 1;
	$x->ShowRecordSlots = 0;
	$x->HighlightColor = '#FFF0C2';
	if($HTTP_POST_VARS["Filter_x"] != ""  || $HTTP_POST_VARS['CSV_x'] != ""){
		// Query used in filters page and CSV output
		// mm: build the query based on current member's permissions
		if($perm[2]==1){ // view owner only
			$x->Query = $filtersCSVQuery.", membership_userrecords  where rotarians.id=membership_userrecords.pkValue and membership_userrecords.tableName='rotarians' and membership_userrecords.memberID='".getLoggedMemberID()."'";
		}elseif($perm[2]==2){ // view group only
			$x->Query = $filtersCSVQuery.", membership_userrecords  where rotarians.id=membership_userrecords.pkValue and membership_userrecords.tableName='rotarians' and membership_userrecords.groupID='".getLoggedGroupID()."'";
		}elseif($perm[2]==3){ // view all
			$x->Query = $filtersCSVQuery."";
		}elseif($perm[2]==0){ // view none
			$x->Query = "select 'Not enough permissions' from rotarians";
		}
	}else{
		// Query used in table view
		// mm: build the query based on current member's permissions
		if($perm[2]==1){ // view owner only
			$x->Query = $tableViewQuery.", membership_userrecords  where rotarians.id=membership_userrecords.pkValue and membership_userrecords.tableName='rotarians' and membership_userrecords.memberID='".getLoggedMemberID()."'";
		}elseif($perm[2]==2){ // view group only
			$x->Query = $tableViewQuery.", membership_userrecords  where rotarians.id=membership_userrecords.pkValue and membership_userrecords.tableName='rotarians' and membership_userrecords.groupID='".getLoggedGroupID()."'";
		}elseif($perm[2]==3){ // view all
			$x->Query = $tableViewQuery."";
		}elseif($perm[2]==0){ // view none
			$x->Query = "select 'Not enough permissions' from rotarians";
		}
	}

	// handle date sorting correctly
	// end of date sorting handler


	$x->Render();

	include(dirname(__FILE__)."/header.php");
	echo $x->HTML;
	include(dirname(__FILE__)."/footer.php");
?>