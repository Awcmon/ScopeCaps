use <hexagons.scad>
use <shape_trapezium.scad>
use <rounded_square.scad>
use <hollow_out.scad>

// Units are in mm
$fn= $preview ? 32 : 128;
epsilon = $preview ? 0.001 : 0;

wallThickness = 1.5;
topWindowRadiusing = 8;
topWidth = 37;
midWidth = 37;
midRadiusing = 6;
coverH = 27;
coverExteriorH = 22;
// Width of the actual window.
windowW = 32;
windowH = 25;
windowRadiusing = 6;
hoodLength = 35;

hexRadius = 2.5;
hexGap = 0.5;
hexLevels = 6;

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

module killflash_profile(includeWindow = true)
{
    hull()
    {
        outerH = coverH + wallThickness;
        outerTopW = topWidth + wallThickness*2;
        outerMidW = midWidth + wallThickness*2;
        outerTopRadiusing = topWindowRadiusing + wallThickness;
        translate([-outerTopW/2 + outerTopRadiusing, outerH - outerTopRadiusing])
        circle(r=outerTopRadiusing);

        translate([outerTopW/2 - outerTopRadiusing, outerH - outerTopRadiusing])
        circle(r=outerTopRadiusing);

        outerMidRadiusing = windowRadiusing;
        translate([-outerMidW/2 + outerMidRadiusing, outerH - coverExteriorH + outerMidRadiusing])
        circle(r=outerMidRadiusing);

        translate([outerMidW/2 - outerMidRadiusing, outerH - coverExteriorH + outerMidRadiusing])
        circle(r=outerMidRadiusing);

        if(includeWindow)
        {
            translate([0, windowH/2])
            rounded_square(
                size = [windowW, windowH],
                corner_r = windowRadiusing, 
                center = true
            );
        }
    }
}

linear_extrude(10)
union()
{
    hollow_out(wallThickness)
    killflash_profile();

    difference()
    {
        killflash_profile();
        translate([0, (coverH + wallThickness)/2])
        hexagons(hexRadius, hexGap, hexLevels);
    }
}

intersection()
{
    translate([0, 0, 10])
    linear_extrude(hoodLength)
    hollow_out(wallThickness)
    killflash_profile(false);

    intersectX = midWidth + wallThickness*2;
    intersectY = coverExteriorH - midRadiusing;
    translate([0, coverH + wallThickness - intersectY/2, 10])
    linear_extrude(hoodLength)
    square([intersectX, intersectY], center=true);
}

