$(document).ready(function() {
  $('#plot').append('<div id="plot1" class="plot"></div>');

  $.getScript("/assets/js/reload.js", function(data, textStatus, jqxhr) {
   console.log(new Date() + " " + textStatus + " " + jqxhr.status); //success
  });

});
