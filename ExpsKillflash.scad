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
housingH = 27;
coverExteriorH = 22;
// Width of the actual window.
windowW = 32;
windowH = 25;
windowRadiusing = 6;
hoodLength = 35;

hexRadius = 2.5;
hexGap = 0.5;
hexLevels = 6;
hexLength = 10;

useRibs = true;
topRibRadius = 1;
sideRibRadius = 1.5;
coverH = housingH + wallThickness;

module window_profile()
{
    hull()
    {
        translate([-topWidth/2 + topWindowRadiusing, housingH - topWindowRadiusing])
        circle(r=topWindowRadiusing);

        translate([topWidth/2 - topWindowRadiusing, housingH - topWindowRadiusing])
        circle(r=topWindowRadiusing);

        translate([-midWidth/2 + midRadiusing, housingH - coverExteriorH + midRadiusing])
        circle(r=midRadiusing);

        translate([midWidth/2 - midRadiusing, housingH - coverExteriorH + midRadiusing])
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
        outerH = coverH;
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
        translate([0, (coverH)/2])
        hexagons(hexRadius, hexGap, hexLevels);
    }
}

intersection()
{
    translate([0, 0, hexLength])
    linear_extrude(hoodLength)
    hollow_out(wallThickness)
    killflash_profile(false);

    intersectX = midWidth + wallThickness*2;
    intersectY = coverExteriorH - midRadiusing;
    translate([0, coverH - intersectY/2, hexLength])
    linear_extrude(hoodLength)
    square([intersectX, intersectY], center=true);
}

// Retention ribs
if(useRibs)
{
    // Top rib
    hull()
    {
        translate([0, coverH, hexLength + hoodLength - topRibRadius])
        sphere(topRibRadius);

        translate([0, coverH, hexLength + topRibRadius + 5])
        sphere(topRibRadius);
    }

    // Side ribs
    hull()
    {
        yPos = coverH - coverExteriorH + midRadiusing + sideRibRadius;
        translate([midWidth/2 + wallThickness, yPos, hexLength + hoodLength - sideRibRadius])
        sphere(sideRibRadius);

        translate([midWidth/2 + wallThickness, yPos, hexLength + sideRibRadius + 5])
        sphere(sideRibRadius);
    }

    hull()
    {
        yPos = coverH - coverExteriorH + midRadiusing + sideRibRadius;
        translate([-midWidth/2 - wallThickness, yPos, hexLength + hoodLength - sideRibRadius])
        sphere(sideRibRadius);

        translate([-midWidth/2 - wallThickness, yPos, hexLength + sideRibRadius + 5])
        sphere(sideRibRadius);
    }
}
