using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System as Sys;

class myRunFieldsView extends Ui.DataField {
    hidden var fields;
    hidden var what;
    var colorsForHr = new [6];

    function initialize() {
        what = 0;
        fields = new RunFields();
        colorsForHr[0] = Graphics.COLOR_LT_GRAY;
        colorsForHr[1] = Graphics.COLOR_BLUE;
        colorsForHr[2] = Graphics.COLOR_GREEN;
        colorsForHr[3] = Graphics.COLOR_YELLOW;
        colorsForHr[4] = Graphics.COLOR_ORANGE;
        colorsForHr[5] = Graphics.COLOR_RED;
    }

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onHide() {
    }

    function drawLayout(dc) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
        // horizontal lines
        dc.drawLine(0, 71, 218, 71);
        dc.drawLine(0, 132, 218, 132);
        dc.drawLine(0, 198, 218, 198);
        // vertical lines
        if (what < 5 || fields.hrN == null) {
            dc.drawLine(109, 0, 109, 71);
        }
        dc.drawLine(65, 71, 65, 132);
        dc.drawLine(153, 71, 153, 132);
        dc.drawLine(109, 132, 109, 198);
    }

    function doHrZones(dc) {
        var hrZ = fields.hrZones;
        var pctZS;
        var base;
        var next;

        if (fields.hrZoneN < fields.hrZonesDef.size()) {
            next = fields.hrZonesDef[fields.hrZoneN];
        } else {
            next = 192;
        }

        if (fields.hrZoneN > 0) {
            base = fields.hrZonesDef[fields.hrZoneN - 1];
        } else {
            base = 0;
        }

        var diff = next - base;
        var curDiff = fields.hrN - base;

        var pctZ = fields.hrZoneN + (curDiff.toDouble() / diff);
        pctZS = "Z" + pctZ.format("%.1f");

        textC(dc, 109, 10, Graphics.FONT_XTINY, pctZS);

        var total = 0.0;
        for (var i = 0; i < hrZ.size(); i++) {
            total += hrZ[i];
        }

        var curX = 35;

        // to avoid setting the color
        for (var i = 0; i < hrZ.size(); i++) {
            textC(dc, curX, 65, Graphics.FONT_XTINY, "Z" + i);
            curX += 25;
        }

        curX = 29;
        for (var i = 0; i < hrZ.size(); i++) {
            var pct = hrZ[i] / total;
            var h = (pct * 40 + 0.5).toLong();
            var y = 64 - h;
            if (h > 0) {
                dc.setColor(colorsForHr[i], Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(curX, y, 20, h);
            }
            curX += 25;
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();

        drawLayout(dc);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (what < 5 || fields.hrN == null) {
            textL(dc, 36, 45, Graphics.FONT_NUMBER_MEDIUM,  fields.time);
            textL(dc, 55, 18, Graphics.FONT_XTINY, "TOD");
            textL(dc, 112, 45, Graphics.FONT_NUMBER_MEDIUM,  fields.timer);
            if (fields.timerSecs != null) {
                var length = dc.getTextWidthInPixels(fields.timer, Graphics.FONT_NUMBER_MEDIUM);
                textL(dc, 112 + length + 1, 55, Graphics.FONT_NUMBER_MILD, fields.timerSecs);
            }

            textL(dc, 120, 18, Graphics.FONT_XTINY,  "TIMER");

        } else {
            doHrZones(dc);
        }
        what++;
        if (what > 10) {
            what = 0;
        }



        doCadenceBackground(dc, fields.cadenceN);
        textC(dc, 30, 107, Graphics.FONT_NUMBER_MEDIUM, fields.cadence);
        textC(dc, 30, 79, Graphics.FONT_XTINY,  "CAD");

        textC(dc, 110, 107, Graphics.FONT_NUMBER_MEDIUM, fields.pace10s);
        textL(dc, 78, 79, Graphics.FONT_XTINY,  "PACE 10s");

        doHrBackground(dc, fields.hrZoneN);
        textC(dc, 180, 107, Graphics.FONT_NUMBER_MEDIUM, fields.hr);
        textC(dc, 180, 79, Graphics.FONT_XTINY,  "HR");


        textC(dc, 66, 154, Graphics.FONT_NUMBER_MEDIUM, fields.dist);
        textL(dc, 54, 186, Graphics.FONT_XTINY, "DIST");

        textC(dc, 150, 154, Graphics.FONT_NUMBER_MEDIUM, fields.paceAvg);
        textL(dc, 124, 186, Graphics.FONT_XTINY, "A PACE");

        drawBattery(dc);

        return true;
    }


    function doHrBackground(dc, hrz) {
        if (hrz == null) {
            return;
        }

        var color = colorsForHr[hrz];
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(154, 72, 65, 16);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    }

    function doCadenceBackground(dc, cadence) {
        if (cadence == null) {
            return;
        }

        var color;
        if (cadence > 183) {
            color = Graphics.COLOR_PURPLE;
        } else if (cadence >= 174) {
            color = Graphics.COLOR_BLUE;
        } else if (cadence >= 164) {
            color = Graphics.COLOR_GREEN;
        } else if (cadence >= 153) {
            color = Graphics.COLOR_ORANGE;
        } else {
            color = Graphics.COLOR_RED;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(00, 72, 65, 16);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    }

    function drawBattery(dc) {
        var pct = Sys.getSystemStats().battery;
        dc.drawRectangle(110, 202, 28, 11);
        dc.fillRectangle(138, 205, 2, 5);

        var pctS = pct.format("%.0f") + "%";
        textL(dc, 75, 206, Graphics.FONT_TINY, pctS);
        var color = Graphics.COLOR_GREEN;
        if (pct < 25) {
            color = Graphics.COLOR_RED;
        } else if (pct < 40) {
            color = Graphics.COLOR_YELLOW;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        var width = (pct * 26.0 / 100 + 0.5).toLong();
        if (width > 0) {
            dc.fillRectangle(111, 203, width, 9);
        }
    }

    function compute(info) {
        fields.compute(info);
        return 1;
    }

    function textL(dc, x, y, font, s) {
        if (s != null) {
            dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function textC(dc, x, y, font, s) {
        if (s != null) {
            dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function textR(dc, x, y, font, s) {
        if (s != null) {
            dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}

class myRunFieldsApp extends App.AppBase {

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new myRunFieldsView() ];
    }
}