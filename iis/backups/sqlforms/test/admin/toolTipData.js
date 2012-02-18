var FiltersEnabled = 0; // if your not going to use transitions or filters in any of the tips set this to 0
var spacer="&nbsp; &nbsp; &nbsp; ";

// visitorSignup
visitorSignup0=["", spacer+"If this option is selected, visitors will not be able to join this group unless the admin manually moves them to this group from the admin area."];
visitorSignup1=["", spacer+"If this option is selected, visitors can join this group but will not be able to sign in unless the admin approves them from the admin area."];
visitorSignup2=["", spacer+"If this option is selected, visitors can join this group and will be able to sign in instantly with no need for admin approval."];

// stockitems table
stockitems_add=["",spacer+"This option allows all members of the group to add records to the 'stockitems' table. A member who adds a record to the table becomes the 'owner' of that record."];

stockitems_view0=["",spacer+"This option prohibits all members of the group from viewing any record in the 'stockitems' table."];
stockitems_view1=["",spacer+"This option allows each member of the group to view only his own records in the 'stockitems' table."];
stockitems_view2=["",spacer+"This option allows each member of the group to view any record owned by any member of the group in the 'stockitems' table."];
stockitems_view3=["",spacer+"This option allows each member of the group to view all records in the 'stockitems' table."];

stockitems_edit0=["",spacer+"This option prohibits all members of the group from modifying any record in the 'stockitems' table."];
stockitems_edit1=["",spacer+"This option allows each member of the group to edit only his own records in the 'stockitems' table."];
stockitems_edit2=["",spacer+"This option allows each member of the group to edit any record owned by any member of the group in the 'stockitems' table."];
stockitems_edit3=["",spacer+"This option allows each member of the group to edit any records in the 'stockitems' table, regardless of their owner."];

stockitems_delete0=["",spacer+"This option prohibits all members of the group from deleting any record in the 'stockitems' table."];
stockitems_delete1=["",spacer+"This option allows each member of the group to delete only his own records in the 'stockitems' table."];
stockitems_delete2=["",spacer+"This option allows each member of the group to delete any record owned by any member of the group in the 'stockitems' table."];
stockitems_delete3=["",spacer+"This option allows each member of the group to delete any records in the 'stockitems' table."];

/*
	Style syntax:
	-------------
	[TitleColor,TextColor,TitleBgColor,TextBgColor,TitleBgImag,TextBgImag,TitleTextAlign,
	TextTextAlign,TitleFontFace,TextFontFace, TipPosition, StickyStyle, TitleFontSize,
	TextFontSize, Width, Height, BorderSize, PadTextArea, CoordinateX , CoordinateY,
	TransitionNumber, TransitionDuration, TransparencyLevel ,ShadowType, ShadowColor]

*/

toolTipStyle=["white","#00008B","#000099","#E6E6FA","","images/helpBg.gif","","","","\"Trebuchet MS\", sans-serif","","","","3",400,"",1,2,10,10,51,1,0,"",""];

applyCssFilter();
