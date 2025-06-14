// Retaining cap for a polycarbonate lens for the SMS HFXC

// Units are in mm
$fn= $preview ? 32 : 128;
epsilon = $preview ? 0.005 : 0;
clearance = 0.1;

lightOD = 25.0 + clearance;
lightL = 8.5;
laserOD = 23.9 + clearance;
laserL = 10.25;
lightLaserW = 50.4;
lensThickness = 0;

wallThickness = 1.5;
lipRadius = 3;

capHeight = max(lightL, laserL) + lensThickness + wallThickness;
lightX = lightOD/2;
laserX = lightLaserW - laserOD/2;

module chamfered_extrude(height, startScale = 1, startHeight = 0, endScale = 1, endHeight = 0)
{
    assert(height >= startHeight + endHeight, "start + end heights cannot be greater than total height");
    midScale = 1;
    midHeight = height - startHeight - endHeight;
    if(startHeight > 0) linear_extrude(height = startHeight, scale = midScale/startScale) scale(startScale) children();
    if(midHeight > 0) translate([0,0,startHeight]) linear_extrude(height = midHeight, scale = midScale) children();
    if(endHeight > 0) translate([0,0,startHeight + midHeight]) linear_extrude(height = endHeight, scale = endScale) children();
}

difference()
{
    union()
    {
        translate([lightX, 0]) 
        chamfered_extrude(capHeight, startHeight=capHeight-lightL, startScale = 0.975) circle(d=lightOD + wallThickness*2);

        translate([laserX, 0]) 
        chamfered_extrude(capHeight, startHeight=capHeight-laserL, startScale = 0.975) circle(d=laserOD + wallThickness*2);
    }

    lightDiffL = max(lightL, laserL) - lightL;
    innerChamferMarginL = 0.5;
    
    translate([lightX, 0]) 
    chamfered_extrude(capHeight, startHeight=wallThickness + lightDiffL - innerChamferMarginL, startScale = 1.1) circle(d=lightOD - lipRadius*2);
    translate([lightX, 0, capHeight-lightL-lensThickness]) 
    linear_extrude(capHeight) circle(d=lightOD);

    translate([laserX, 0]) 
    chamfered_extrude(capHeight, startHeight=wallThickness - innerChamferMarginL, startScale = 1.05) circle(d=laserOD - lipRadius*2);
    translate([laserX, 0, capHeight-laserL-lensThickness]) 
    linear_extrude(capHeight) circle(d=laserOD);
}
