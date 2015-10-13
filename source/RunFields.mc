using Toybox.Time as Time;
using Toybox.System as Sys;

class RunFields {
    // last 10 seconds - 'current speed' samples
    hidden var lastSecs = new [10];
    hidden var curPos;
    hidden var lastElapsedTime;

    var hrZonesDef = new [5];
    var hrZones = new [6];

    // public fields - usable after the user calls compute
    var dist;
    var hr;
    var hrZoneN;
    var hrN;
    var timer;
    var timerSecs;
    var cadence;
    var cadenceN;
    var pace10s;
    var paceAvg;
    var time;

    function initialize() {
        for (var i = 0; i < lastSecs.size(); ++i) {
            lastSecs[i] = 0.0;
        }
        hrZonesDef[0] = 116;
        hrZonesDef[1] = 149;
        hrZonesDef[2] = 165;
        hrZonesDef[3] = 177;
        hrZonesDef[4] = 186;

        for (var i = 0; i < hrZones.size(); ++i) {
            hrZones[i] = 0.0;
        }

        curPos = 0;
    }

    function reset() {
      initialize();
    }

    function getAverage(a) {
        var count = 0;
        var sum = 0.0;
        for (var i = 0; i < a.size(); ++i) {
            if (a[i] > 0.0) {
                count++;
                sum += a[i];
            }
        }
        if (count > 0) {
            return sum / count;
        } else {
            return null;
        }
    }

    function toPace(speed) {
        if (speed == null || speed == 0) {
            return null;
        }

        var settings = Sys.getDeviceSettings();
        var unit = 1609; // miles
        if (settings.paceUnits == Sys.UNIT_METRIC) {
            unit = 1000; // km
        }
        return unit / speed;
    }

    function toDist(d) {
        if (d == null) {
            return "0.00";
        }

        var dist;
        if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC) {
            dist = d / 1000.0;
        } else {
            dist = d / 1609.0;
        }
        return dist.format("%.2f", dist);
    }

    function toStr(o) {
        if (o != null) {
            return "" + o;
        } else {
            return "---";
        }
    }

    function fmtSecs(secs) {
        if (secs == null) {
            return "--:--";
        }

        var s = secs.toLong();
        var hours = s / 3600;
        s -= hours * 3600;
        var minutes = s / 60;
        s -= minutes * 60;
        var fmt;
        if (hours > 0) {
            fmt = "" + hours + ":" + minutes.format("%02d");
        } else {
            fmt = "" + minutes + ":" + s.format("%02d");
        }

        return fmt;
    }

    function fmtTime(clock) {
        var h = clock.hour;
        if (!Sys.getDeviceSettings().is24Hour) {
            if (h > 12) {
                h -= 12;
            } else if (h == 0) {
                h += 12;
            }
        }
        return "" + h + ":" + clock.min.format("%02d");
    }

    function zoneFor(n) {
        for (var i = 0; i < hrZonesDef.size(); i++) {
            if (n <= hrZonesDef[i]) {
                return i;
            }
        }
        return hrZonesDef.size();
    }

    function compute(info) {
        var elapsed = info.elapsedTime;
        var inActivity = elapsed != null && elapsed > 0;

        if (info.currentSpeed != null && info.currentSpeed > 0) {
            var idx = curPos % lastSecs.size();
            curPos++;
            lastSecs[idx] = info.currentSpeed;
        }

        var avg10s = getAverage(lastSecs);

        // update hrZones
        hrN = info.currentHeartRate;
        if (inActivity && hrN != null) {
            var timeSinceLastUpdate;
            if (lastElapsedTime == null) {
                timeSinceLastUpdate = elapsed;
            } else {
                timeSinceLastUpdate = elapsed - lastElapsedTime;
            }
            lastElapsedTime = elapsed;

            hrZoneN = zoneFor(hrN);
            hrZones[hrZoneN] += (timeSinceLastUpdate / 1000.0);
        }

        var elapsedSecs = null;
        if (elapsed != null) {
            elapsed /= 1000;

            if (elapsed >= 3600) {
                elapsedSecs = (elapsed.toLong() % 60).format("%02d");
            }
        }

        dist = toDist(info.elapsedDistance);
        hr = toStr(info.currentHeartRate);
        timer = fmtSecs(elapsed);
        timerSecs = elapsedSecs;
        cadence = toStr(info.currentCadence);
        cadenceN = info.currentCadence;
        pace10s =  fmtSecs(toPace(avg10s));
        paceAvg = fmtSecs(toPace(info.averageSpeed));
        time = fmtTime(Sys.getClockTime());
    }
}
