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
    showLoading: function(value){
        if(value){
            $("#loadStationData").css("display", "block");
            $("#loadStationData").css("background-color", "rgba(0,0,0,0.8)");
        }else{ 
            $("#loadStationData").css("display", "none");
            $("#loadStationData").css("background-color", "rgba(0,0,0,0.0)");
        }
    },
    //rangeType => true KM / false miles
    getAreaFromPoint: function(pointLat, pointLon, range, rangeType){
        if(!rangeType) range *= 0.621371;

        var latOffset = (1 / 110.54) * range;
        var lonOffset = (1 / (111.320 * Math.cos(pointLat))) * range;
        console.log(latOffset);
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
            zoom: 5
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
            console.log(this.area);
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
        Util.showLoading(true);

        $.post('/stations/'+id+'/info', { from_time: from_time, to_time: from_time}, 
        function(data){
            var object = JSON.parse(data);

            var htmlData = "";
            for(var i = 0, len = object.times.length; i < len; i++)
                htmlData += "<div class='anchor timetablevalue bck light'>"+object.times[i]+"</div>"

            Util.getId("timetable").innerHTML = htmlData;
            Util.showLoading(false);
        },
        function(error){
            Util.showLoading(false);
            Util.getId("timetable").innerHTML = "<div class='anchor timetablevalue bck light'>"+"Error Downloading Data"+"</div>";
        });
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
                    self.selected = self.list[i];
                    self.showStation(self.list[i]);
                }
        });

        return  marker
    },

    showStation: function(station){
        if(typeof(station)==='undefined') station = this.list[0];
        if(!station) return "There´s no any station";

        $("#stationNameShow").text(station.name);
        $("#timetable").addClass("active");
    }
}
