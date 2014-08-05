var Util = {
    createNotification: function (img, title, content){

        if (Notification.permission == "granted") {
            var n = new Notification(title, {icon: img, body: content});
            setTimeout(function(){
                n.close();
            },5000);
        }
        else{
            Notification.requestPermission(function(){
                if(Notification.permission == "granted"){
                    var n = new Notification(title, {icon: img, body: content});
                    setTimeout(function(){
                       n.close();
                    },5000);
                }
            });
        }
    },

    setText: function(name, text){
        localStorage.setItem(name, text);
    },

    getText: function(name){
        var a = localStorage.getItem(name);
        if(a == null)
            return "";
        return a;
    },

    getId: function(id){
        return document.getElementById(id);
    },

    Trigger: function(){
        this.state = true;
        this.get = function(){
            var rstate = this.state;
            this.state = false;
            return rstate;
        }
    },
    //rangeType => true KM / false miles
    getAreaFromPoint: function(pointLat, pointLon, range, rangeType){
        if(!rangeType) range *= 0.621371;

        var latOffset = (1 / 110.54) * range;
        var lonOffset = (1 / (111.320 * Math.cos(pointLat))) * range;
        //returns {minLat, minLon, maxLat, maxLon};
        return {
            minLat: pointLat-latOffset,
            minLon: pointLon-lonOffset,
            maxLat: pointLat+latOffset,
            maxLon: pointLon+lonOffset
        };
    },
}

var MapSystem = {
    me: undefined,
    area: undefined,
    loadMap: function(){
        var mapOptions = {
            zoom: 5,
            panControl: false,
            rotateControl: false,
            maxZoom: 19,
            minZoom: 10,
            streetViewControl: false,
        };

        map = new google.maps.Map(Util.getId('map-canvas'),
mapOptions);
        
        map.setCenter(new google.maps.LatLng(40.3748241, -3.5915732));
    },
    locateMe: function(){
        navigator.geolocation.getCurrentPosition(function(position) {
            var range = 1
            var pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            this.area = Util.getAreaFromPoint(position.coords.latitude, position.coords.longitude, range);

            if(this.me)
                this.me.close();

            this.me = new google.maps.InfoWindow({
                map: map,
                position: pos,
                content: 'Hey, I´m here!'
            });

            map.setCenter(pos);
            map.setOptions({zoom: 16});

            //StationsSystem
            Station.getNear(this.area);
        }, function() {
            Util.createNotification("","", "GeoLocation no obtuvo permiso, o produjo un error.");
        });
    },
}

var Station = {
    list: [],
    markersArray: [],
    selected: undefined,

    getInfo: function(id, from_time, to_time){
        Visual.showLoadingInfo(true);

        $.get('/stations/'+id+'/times', { from: from_time, to: from_time}, 
            function(times){
                Visual.clearTimes();
                Visual.showStationTimes(times);
                Util.getId("timetable").innerHTML = htmlData;
                Visual.showLoadingInfo(false);
            }, "json"
        );
    },

    getNear: function(area){
        //area = {minLat, minLon, maxLat, maxLon}
        var self = this;

        $.get('/stations', area, 
            function(data){
                self.list = data;

                $.each(self.list, function( i, station ) {
                    self.markersArray.push(self.createMarker(station.name, station.lat, station.lon));
                });
            }, "json"
        );
    },
    createMarker: function(title, lat, lon){
        var pos = new google.maps.LatLng(lat, lon);
        var self = this;

        var marker = new google.maps.Marker({
            position: pos,
            map: map,
            title: title
        });

        google.maps.event.addListener(marker, 'click', function(){
            for(var i = 0, len = self.list.length; i < len; i++)
                if(self.list[i].name == marker.title){
                    if(self.list[i] != self.selected)
                        self.showStation(self.selected);

                    self.selected = self.list[i];
                    break;
                }
        });

        return  marker
    },

    showStation: function(station){
        if(typeof(station)==='undefined') station = this.list[0];
        if(!station) return "There´s no any station";

        if ($("#timetable").hasClass("active")){
            $("#timetable").removeClass("active");
            setTimeout(function(){
                $("#stationNameShow").text(station.name);
                $("#timetable").addClass("active");
            }, 500);
        }
        else
        {
            $("#stationNameShow").text(station.name);
            $("#timetable").addClass("active");
        }
    }
}

var Times = {

}