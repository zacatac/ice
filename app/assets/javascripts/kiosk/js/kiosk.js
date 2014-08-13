$(document).ready(function () {
    $("#kiosk-login").hide();
    
     $('#dp5').datetimepicker({
	 viewMode: "years",
         pickTime: false,
	 useCurrent: false,
	 defaultDate: new Date(1990,1,1)
     });    
    
    
    window.setTimeout(function() { 
	$(".flash").animo({animation: 'fadeOutRight', duration: 0.5, keep: true}, function() {
	    $(".animated").hide('slow', function() { $('.animated').remove()});
	});
    },5000);
     $('#calendar-click').click();
     $('#calendar-click').click();
     $('#birth-text').val("");
     $("select[name='sex']").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse'});     
     $("select[name='waiver']").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse', size: 2});     
     $(".dropdown-menu li a").click(function(button){	 
	 $(this).closest(".btn-group").find(".btn").text($(this).text());
	 $(this).closest(".btn-group").find(".btn").val($(this).text());	 
     });
    var optionsBootstrap = {
        classNamePrefix: 'bvalidator_bootstraprc_',
        position: {x:'right', y:'center'},
        offset:     {x:15, y:0},
        template: '<div class="{errMsgClass}"><div class="bvalidator_bootstraprc_arrow"></div><div class="bvalidator_bootstraprc_cont1">{message}</div></div>',    
        templateCloseIcon: '<div style="display:table"><div style="display:table-cell">{message}</div><div style="display:table-cell"><div class="{closeIconClass}">&#215;</div></div></div>'
    };

    $("#signin-form").bValidator(optionsBootstrap);
    $("#register-form").bValidator(optionsBootstrap);
    $("#swipe").focus();
    $("#waiver-button").hide();
    $("#waiver").change(handleWaiverSelect);
    $("#file-button").hide();
     $("#file").hide();
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
    
    // $('#swipe-form').submit(function () {
    // 	console.log($('#swipe').val().slice(0,5));
    // 	if ($('#swipe').val().slice(0,5) !== '%LTCC'){
    // 	    alertify.error("Card Read Error. Please swipe again.");
    // 	    return false;
    // 	}
    // 	window.swipe = $('#swipe').val();
    // 	window.cardid = $('#swipe').val().split("?")[0].slice(5);
    // 	$('#swipe-form').ajaxSubmit({url: "{{ url_for('kiosk.main') }}", type: 'post'})
    // 	//ALDSKFJASLKDJALSKDJ
    // 	return false;
    // });    
    
    function addCardidField(jform) {
	var cardidField = $("<input>")
	    .attr("type","hidden")
	    .attr("name", "cardid").val(window.cardid);
	jform.append($(cardidField));	
    }
    $('#signin-form').submit(function () {
	addCardidField($('#signin-form'))
	return true;
    });

    $('#register-form').submit(function () {
	addCardidField($('#register-form'))
	return true;
    });
 
    $('#waiver-form').submit(function () {
	addCardidField($('#waiver-form'))
	return true;
    });

    $('#photo-form').submit(function () {
	addCardidField($('#photo-form'))
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
    if ($("#waiver").find(":selected").text() === "Yes"){		
	$("#waiver-button").show();
    } else {
	$("#waiver-button").hide();
    }
   
}
