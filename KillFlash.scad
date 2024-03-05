// Units are in mm
$fn= $preview ? 32 : 128;

epsilon = 0.005;

function InchToMillis(inch) = inch * 25.4;
function MillisToInch(mm) = mm / 25.4;

innerDiameter = 28;
wallThickness = 2;
sleeveLength = 5;
hexLength = 10;
hexSize = 3;
hexSpacing = 0.5;

outerDiam = innerDiameter + wallThickness * 2;
totalLength = sleeveLength + hexLength;
hexCtC = hexSpacing + hexSize;

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
    // cylinder(d = outerDiam, totalLength);
    // cylinder(d = innerDiameter, sleeveLength);

    cylinder(d = outerDiam, hexLength);
    cylinder(d = hexSize, hexLength + epsilon, $fn=6);
    for(j = [1:5])
    {
        rotIncr = 360 / (6*j);
        echo(str("layer = ", j, ", rotIncr = ", rotIncr));
        for(i = [0 : 6*j-1])
        {
            translate([hexCtC * cos(30 + rotIncr*i) * j, hexCtC * sin(30 + rotIncr*i) * j, 0])
            cylinder(d = hexSize, hexLength + epsilon, $fn=6);
        }
    }
}

