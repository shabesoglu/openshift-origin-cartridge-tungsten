function load_data() {
$.getScript("load.js", function(data, textStatus, jqxhr) {
   //console.log(data); //data returned
   console.log(new Date() + " " + textStatus + " " + jqxhr.status); //success
   //console.log(jqxhr.status); //200
   //console.log('Load was performed.');
});

}

function write_date() {
  var d = (new Date()).toString();
  console.log(d);
  $("#epoch").val(d);
//  document.getElementById("epoch").innerHTML = new Date();
  return 0;
}

function refresh() {
  load_data();
  write_date();
  setTimeout(refresh, 3000);
}


refresh();
