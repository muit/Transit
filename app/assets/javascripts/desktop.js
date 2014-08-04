// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree ./desktop
//= require same

$( document ).ready(function() {
    if(window.google)
        MapSystem.loadMap();
    else
        Util.createNotification("", "Error", "Google Maps doesn´t work! Make sure you have internet.");

    $("body").bind('click', function(event) {

        switch($(event.target).attr('id')){

        case "closeaside":
            $("#timetable").removeClass("active");
            break;
        case "closemenuaside":
            $("#controlmenu").removeClass("active");
            break;
        case "asidebutton":
            if(Station.selected) $("#timetable").addClass("active");
            break;
        case "menuasidebutton":
            $("#controlmenu").addClass("active");
            break;
        case "locateMe":
            if(window.google) 
                MapSystem.locateMe();
            else
                Util.createNotification("", "Error", "Google Maps doesn´t work! Make sure you have internet.");
            break;
        }
    });
    $("body").bind('mouseover', function(event) {

        switch($(event.target).attr('id')){
        case "asidebutton":
            $("#asidebutton").addClass("active");
            break;
        case "menuasidebutton":
            $("#menuasidebutton").addClass("active");
            break;
        }
    });

    $("body").bind('mouseout', function(event) {

        switch($(event.target).attr('id')){
        case "asidebutton":
            $("#asidebutton").removeClass("active");
            break;
        case "menuasidebutton":
            $("#menuasidebutton").removeClass("active");
            break;
        }
    });
});