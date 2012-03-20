$(document).ready(function(){
	$.getJSON('pl/about', function(data) {
		if ( data.username ) {
			$("#loggedin").append("Logged in as " + data.username);
		}
		document.title = data.name + " " + data.year + (data.night?", Night " + data.night:'') + (data.live?'':' (Offline)');
	});
});
