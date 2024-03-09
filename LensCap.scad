// Retaining cap for a polycarbonate lens

// Units are in mm
$fn= $preview ? 32 : 128;
epsilon = $preview ? 0.005 : 0;

function InchToMillis(inch) = inch * 25.4;
function MillisToInch(mm) = mm / 25.4;

innerDiameter = 31.4;
wallThickness = 1.5;
length = 25;
lipWidth = 2;
lipThickness = 2;

outerDiam = innerDiameter + wallThickness * 2;

difference()
{
    cylinder(length, d = outerDiam);
    cylinder(length, d = innerDiameter - lipWidth);
    translate([0, 0, lipThickness])
    cylinder(length, d = innerDiameter);
}
