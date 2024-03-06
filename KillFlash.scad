// Units are in mm
$fn= $preview ? 32 : 128;

epsilon = $preview ? 0.005 : 0;

function InchToMillis(inch) = inch * 25.4;
function MillisToInch(mm) = mm / 25.4;

innerDiameter = 28.6;
wallThickness = 2;
sleeveLength = 10;
hexLength = 10;
hexSize = 3;
hexGap = 1;

outerDiam = innerDiameter + wallThickness * 2;
totalLength = sleeveLength + hexLength;
hexCtC = hexGap + hexSize;
horiz = 0.75 * hexSize;
sqrt3 = sqrt(3);
vert = sqrt3 / 2 * hexSize;
hexSpacing = hexSize * 0.5 + hexGap * 0.5;

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
    cylinder(d = outerDiam, totalLength);
    cylinder(d = innerDiameter, totalLength + epsilon);
}

difference()
{
    cylinder(d = outerDiam, hexLength);
    cylinder(d = hexSize, hexLength + epsilon, $fn=6);
    for(j = [-6:6])
    {
        for(i = [-6:6])
        {
            translate([hexSpacing * 1.5 * i, hexSpacing * (sqrt3 / 2 * i + sqrt3 * j), 0])
            cylinder(d = hexSize, hexLength + epsilon, $fn=6);
        }
    }
}

