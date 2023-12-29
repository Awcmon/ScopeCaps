// Old scope cap design that has radial tabs rather than the singular tab.

// Units are in mm
$fn= $preview ? 32 : 64;
epsilon = $preview ? 0.005 : 0;

tolerance = 0.025;

function InchToMillis(inch) = inch * 25.4;

scopeOuterDiameter = 44; // cap inner diameter
capThickness = 2.5;
capDepth = 3;
cordDiam = 3;
textDepth = 0.2;

tabWidth = 5.5;
tabDepth = 1.5;

numTabs = 2;
tabArc = 45;
tabArcOffset = 0;
tabArcStep = 360 / numTabs;

// numTabs = 4;
// tabArc = 15;
// tabArcOffset = 45;
// tabArcStep = 360 / numTabs;

tabRounding = 1;
tabNumArcPoints = 15;

capRadius = (scopeOuterDiameter / 2) + capThickness;
capHeight = capDepth + capThickness;
cordRadius = cordDiam / 2;
cordHoleOffset = capRadius + (cordRadius);

module wedge(r, startDeg, endDeg, arcNumPoints)
{
    degStep = (endDeg - startDeg) / arcNumPoints;
    arcPoints = [for(i = [0 : arcNumPoints]) [r * cos(startDeg + i*degStep), r * sin(startDeg + i*degStep)]];
    polygon(points=concat([[0,0]], arcPoints));
}

module roundedWedge(r, startDeg, endDeg, arcNumPoints, arcPointRadius)
{
    degStep = (endDeg - startDeg) / arcNumPoints;
    r2 = r - arcPointRadius;
    hull()
    {
        circle(arcPointRadius);
        for(i = [0 : arcNumPoints]) translate([r2 * cos(startDeg + i*degStep), r2 * sin(startDeg + i*degStep), 0]) circle(arcPointRadius);
    }
}

module capPoly()
{
    hull()
    {
        circle(capRadius);
        translate([-cordHoleOffset,0,0]) circle(r=cordRadius + capThickness);
        translate([cordHoleOffset,0,0]) circle(r=cordRadius + capThickness);
    }
}

module rounded_rect(w, l, h, r)
{
	hull()
	{
		translate([r,r,0]) circle(r);
		translate([r,l-r,0]) circle(r);
		translate([w-r,l-r,0]) circle(r);
		translate([w-r,r,0]) circle(r);
	}
}

module chamfered_extrude(startScale, startHeight, midScale, midHeight, endScale, endHeight)
{
    linear_extrude(height = startHeight, scale = midScale/startScale) scale(startScale) children();
    translate([0,0,startHeight]) linear_extrude(height = midHeight, scale = midScale) children();
    translate([0,0,startHeight + midHeight]) linear_extrude(height = endHeight, scale = endScale) children();
}

color(alpha = 0.5) render() 
difference()
{
    union()
    {
        chamfered_extrude(0.975, 1, 1, capHeight - 2, 1, 1) capPoly();
        // translate([0, -capRadius/2, 0]) chamfered_extrude(0.1, 3, 1, capHeight - 4, 0.1, 1) circle(r=17.5, $fn=6);
        // translate([0,0,capHeight]) linear_extrude(textDepth) text("One Billion", size = 5, halign="center");
        // translate([0,0,capHeight]) linear_extrude(textDepth) text("Concepts", size = 5, halign="center", valign="top");

        translate([0,0,capHeight]) linear_extrude(textDepth) offset(delta=0.001) 
        import("SciTangAwcmon3.svg", center = true, dpi = 1024);

        translate([0,-10,capHeight]) linear_extrude(textDepth) 
        text(str(scopeOuterDiameter, "mm"), size = 2, halign="center", valign="bottom");

        // create tabs
        translate([0,0,capHeight - tabDepth]) linear_extrude(tabDepth) for(i = [0 : numTabs]) 
        roundedWedge(capRadius + tabWidth, tabArcStep * i + tabArcOffset - tabArc, tabArcStep * i + tabArcOffset + tabArc, tabNumArcPoints, tabRounding);
    }
    // cylinder(capDepth, d=scopeOuterDiameter);
    chamfered_extrude(1.05, 1, 1, capDepth - 1, 1, 0) circle(d=scopeOuterDiameter);

    // translate([-cordHoleOffset, 0, 0]) cylinder(capHeight, d=cordDiam);
    // translate([cordHoleOffset, 0, 0]) cylinder(capHeight, d=cordDiam);

    translate([-cordHoleOffset, 0, 0]) chamfered_extrude(1.2, 1.5, 1, capHeight - 3, 2, 1.5) circle(d=cordDiam);
    translate([cordHoleOffset, 0, 0]) chamfered_extrude(1.2, 1.5, 1, capHeight - 3, 2, 1.5) circle(d=cordDiam);

    // translate([0,0,capHeight-textDepth]) linear_extrude(textDepth) text("One Billion", size = 5, halign="center");
    // translate([0,0,capHeight-textDepth]) linear_extrude(textDepth) text("Concepts", size = 5, halign="center", valign="top");
}