// Units are in mm
$fn= $preview ? 32 : 128;

epsilon = $preview ? 0.005 : 0;

function InchToMillis(inch) = inch * 25.4;
function MillisToInch(mm) = mm / 25.4;

innerDiameter = 29;
wallThickness = 1.5;
sleeveLength = 9;
hexLength = 12;
hexSize = 4.5;
hexGap = 1;

hexLayers = ceil((innerDiameter / (hexSize + hexGap)) / 2);
outerDiam = innerDiameter + wallThickness * 2;
totalLength = sleeveLength + hexLength;
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

// Outer wall
difference()
{
    cylinder(d = outerDiam, totalLength);
    chamfered_extrude(totalLength + epsilon, endScale = 1.05, endHeight = 0.8) circle(d = innerDiameter);
}

// Hex grating
difference()
{
    cylinder(d = outerDiam, hexLength);
    for(y = [-hexLayers:hexLayers])
    {
        for(x = [-hexLayers:hexLayers])
        {
            // The double for loops naturally generate a skewed square shape.
            // We can generate a more circular/hex shape by clamping the hex distance to a certain radius.
            // This helps us avoid subtracting unnecessary polygons and looks nicer if hexLayers is not enough to span
            // the entire radius.
            hexDist = (abs(x) + abs(x + y) + abs(y)) / 2;
            if(hexDist <= hexLayers)
            translate([hexSpacing * 1.5 * x, hexSpacing * (sqrt3/2 * x + sqrt3 * y), 0])  // Hex to Euclidean coords
            cylinder(d = hexSize, hexLength + epsilon, $fn=6);
        }
    }
}

