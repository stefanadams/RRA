$(document).ready(function(){
    $.getJSON('pl/env', function(data) {
        if ( data.username ) {
            $("#loggedin").append("Logged in as " + data.username);
        }
    });
});
