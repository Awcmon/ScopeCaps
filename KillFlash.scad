// Units are in mm
$fn= $preview ? 32 : 128;

epsilon = $preview ? 0.005 : 0;

function InchToMillis(inch) = inch * 25.4;
function MillisToInch(mm) = mm / 25.4;

// Inner diameter of the kill flash, or diameter of the bell
innerDiameter = 32.75; // 0.05
// The length of the bell the killflash slides over. The lip starts immediately past this distance, if there is one.
sleeveLength = 12; // 0.05
// How thick the sleeve is.
wallThickness = 1.5; // 0.05
// How long the hexes are.
hexLength = 10; // 0.05
// The diameter of the hex holes.
hexSize = 4.5; // 0.05
// How thick the material between the hexes are.
hexGap = 1; // 0.05
// Sometimes needs to be increased to get full hex coverage.
numAdditionalHexLayers = 1; // 1
// Use a lip instead of a chamfer. Used for stuff with a slight bell around the objective like the Viper PST II 1-6x.
useLip = true;
// Generally, the diameter of the tube
lipInnerDiameter = 30; // 0.05

lipRadius = (innerDiameter - lipInnerDiameter) / 2;
hexLayers = ceil((innerDiameter / (hexSize + hexGap)) / 2) + numAdditionalHexLayers;
outerDiam = innerDiameter + wallThickness * 2;
totalLength = sleeveLength + hexLength + (useLip ? lipRadius*2 : 0);
horiz = 0.75 * hexSize;
sqrt3 = sqrt(3);
vert = sqrt3 / 2 * hexSize;
hexSpacing = hexSize * 0.5 + hexGap * 0.5;

echo(totalLength=totalLength);

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
    if(useLip)
    {
        cylinder(totalLength + epsilon, d = innerDiameter);
    }
    else
    {
        chamfered_extrude(totalLength + epsilon, endScale = 1.05, endHeight = 0.8) circle(d = innerDiameter);
    }

}

if(useLip)
{
    translate([0,0,totalLength-lipRadius])
    rotate_extrude(convexity = 10)
    translate([innerDiameter/2, 0, 0])
    circle(r = 1.375);
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
