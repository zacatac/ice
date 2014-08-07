$(document).ready(function () {

     $('#dp5').datetimepicker({
	 viewMode: "years",
         pickTime: false
     });    
     
     $('#calendar-click').click();
     $('#calendar-click').click();
     $('#birth-text').val("");
     $("select[name='sex']").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse'});     
     $("select[name='waiver']").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse'});     
     $(".dropdown-menu li a").click(function(){
	 
	 $(".btn:first-child").text($(this).text());
	 $(".btn:first-child").val($(this).text());
	 
     });
     
    $("#swipe").focus();
     $("#waiver-button").hide();
     $("#waiver").change(handleWaiverSelect);
     $("#file-button").hide();
     $("#file").hide();
     $("#kiosk-login").hide();
     $("#canvas").hide();
     $('#retake-photo').hide();
     $('#save-photo').hide();
     $("#kiosk-login-button").click(function(){
	 $("#kiosk-login").show();
	 $("#kiosk-register-button").show();
	 $("#kiosk-register").hide();
     });
     
     function focusRegisterForm(){
 	 $("#kiosk-login").hide();
	 $("#kiosk-register-button").show();
	 $("#kiosk-register").show();
     }
     $("#kiosk-register-button").click(focusRegisterForm);
     $("#kiosk-no-email-button").click(focusRegisterForm);
    
    $('#swipe-form').submit(function () {
	console.log($('#swipe').val().slice(0,5));
	if ($('#swipe').val().slice(0,5) !== '%LTCC'){
	    alertify.error("Card Read Error. Please swipe again.");
	    return false;
	}
	window.swipe = $('#swipe').val();
	window.cardid = $('#swipe').val().split("?")[0].slice(5);
	$('#swipe-form').ajaxSubmit({url: "{{ url_for('kiosk.main') }}", type: 'post'})
	//ALDSKFJASLKDJALSKDJ
	return false;
    });    

    $('#signin-form').submit(function () {
	var cardidField = $("<input>")
	    .attr("type","hidden")
	    .attr("name", "cardid").val(window.cardid);
	$('#signin-form').append($(cardidField));
	return true;
    });

    $('#register-form').submit(function () {
 	var cardidField = $("<input>")
	    .attr("type","hidden")
	    .attr("name", "cardid").val(window.cardid);
	console.log(window.cardid);
	$('#register-form').append($(cardidField));
	return true;
    });
 
    $('#waiver-form').submit(function () {
 	var cardidField = $("<input>")
	    .attr("type","hidden")
	    .attr("name", "cardid").val(window.cardid);
	$('#waiver-form').append($(cardidField));
	return true;
    });

    $('#photo-form').submit(function () {
 	var cardidField = $("<input>")
	    .attr("type","hidden")
	    .attr("name", "cardid").val(window.cardid);
	$('#photo-form').append($(cardidField));
	return true;
    });
     
     // Put event listeners into place
     window.addEventListener("DOMContentLoaded", function() {
       // Grab elements, create settings, etc.
       var canvas = document.getElementById("canvas"),
       context = canvas.getContext("2d"),
       video = document.getElementById("video"),
       videoObj = { "video": true },
       errBack = function(error) {
	 console.log("Video capture error: ", error.code); 
       };

       // Put video listeners into place
       if(navigator.getUserMedia) { // Standard
	 navigator.getUserMedia(videoObj, function(stream) {
	   video.src = stream;
	   video.play();
	 }, errBack);
       } else if(navigator.webkitGetUserMedia) { // WebKit-prefixed
	 navigator.webkitGetUserMedia(videoObj, function(stream){
	   video.src = window.webkitURL.createObjectURL(stream);
	   video.play();
	 }, errBack);
       } else if(navigator.mozGetUserMedia) { // WebKit-prefixed
	 navigator.mozGetUserMedia(videoObj, function(stream){
	   video.src = window.URL.createObjectURL(stream);
	   video.play();
	 }, errBack);
       }

       // Trigger photo take
       document.getElementById("snap").addEventListener("click", function() {
	 context.drawImage(video, 0, 0, 640, 480);
	 // $('#retkae-photo').show();
	 $('#save-photo').show();
	 $('#retake-photo').show();
	 $('#snap').hide();	   
	 $('#canvas').show();
	 $('#video').hide();
	 var dataURL = canvas.toDataURL("image/jpeg");
	 // console.log(dataURL);
	 $("#file").val(dataURL);	   
	 // $("#file-button").click();
       });
     }, false);

     $('#retake-photo').click(function () {
	$('#video').show();
	$('#canvas').hide();
	$('#snap').show();
	$('#save-photo').hide();
	$('#retake-photo').hide();
     });
     
     $('#save-photo').click(function () {
	 $("#file-button").click();
     });


 });

function handleWaiverSelect(){
    console.log($("#waiver").find(":selected").text());
    if ($("#waiver").find(":selected").text() === "Yes"){		
	$("#waiver-button").show();
    } else {
	$("#waiver-button").hide();
    }
   
}