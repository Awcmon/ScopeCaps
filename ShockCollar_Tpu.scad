// Units are in mm

// M2 Screw dims:
//  Head: 3.65mm
//  Hex: 4.50mm
//  Shaft: 1.92mm 

$fn= $preview ? 32 : 128;

epsilon = 0.005;
tolerance = 0.025;

function InchToMillis(inch) = inch * 25.4;

tubeDiameter = 44.5; // collar inner diameter
collarThickness = 2;
collarLength = 8;
cordDiam = 3.5;

collarRadius = (tubeDiameter / 2) + collarThickness;
cordRadius = cordDiam / 2;
cordHoleInnerMargin = 1.5;
cordHoleOffset = (tubeDiameter / 2) + (cordRadius) + cordHoleInnerMargin;

function magnitude2(a, b) = sqrt(a*a + b*b);

module collar()
{
    difference()
    {
        hull()
        {
            circle(collarRadius);
            translate([-cordHoleOffset,0,0]) circle(r=cordRadius + collarThickness);
            translate([cordHoleOffset,0,0]) circle(r=cordRadius + collarThickness);
        }
    }
}

module chamfered_extrude(height, startScale = 1, startHeight = 0, endScale = 1, endHeight = 0)
{
    assert(height >= startHeight + endHeight, "start + end heights cannot be greater than total height");
    midScale = 1;
    midHeight = height - startHeight - endHeight;
    if(startHeight > 0) linear_extrude(height = startHeight, scale = midScale/startScale) scale(startScale) children();
    if(midHeight > 0) translate([0,0,startHeight]) linear_extrude(height = midHeight, scale = midScale) children();
    if(endHeight > 0) translate([0,0,startHeight + midHeight]) linear_extrude(height = endHeight, scale = endScale) children();
}

color(alpha = 0.5) render()
difference()
{
    chamfered_extrude(collarLength, 0.975, 1, 0.975, 1) collar();
    
    // Chamfered cutout for the scope tube
    linear_extrude(collarLength) circle(d=tubeDiameter);

    // Chamfered holes for the cords
    translate([-cordHoleOffset, 0, 0]) chamfered_extrude(collarLength, 1.2, 1, 1.2, 1) circle(d=cordDiam);
    translate([cordHoleOffset, 0, 0]) chamfered_extrude(collarLength, 1.2, 1, 1.2, 1) circle(d=cordDiam);
}
