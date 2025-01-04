use <hexagons.scad>
use <shape_trapezium.scad>
use <rounded_square.scad>

// Units are in mm
$fn= $preview ? 32 : 128;
epsilon = $preview ? 0.001 : 0;

topWindowRadiusing = 8;
topWidth = 37;
midWidth = 38;
midRadiusing = 8;
coverH = 27;
coverExteriorH = 20;
// Width of the actual window.
windowW = 32;
windowH = 25;
windowRadiusing = 6;

module window_profile()
{
    hull()
    {
        translate([-topWidth/2 + topWindowRadiusing, coverH - topWindowRadiusing])
        circle(r=topWindowRadiusing);

        translate([topWidth/2 - topWindowRadiusing, coverH - topWindowRadiusing])
        circle(r=topWindowRadiusing);

        translate([-midWidth/2 + midRadiusing, coverH - coverExteriorH + midRadiusing])
        circle(r=midRadiusing);

        translate([midWidth/2 - midRadiusing, coverH - coverExteriorH + midRadiusing])
        circle(r=midRadiusing);

        translate([0, windowH/2])
        rounded_square(
            size = [windowW, windowH],
            corner_r = windowRadiusing, 
            center = true
        );
    }
}

linear_extrude(3)
window_profile();
