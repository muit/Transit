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

        //return [minLat, minLon, maxLat, maxLon];
        return [pointLat-latOffset, pointLon-lonOffset, pointLat+latOffset, pointLon+lonOffset];
    },
}


