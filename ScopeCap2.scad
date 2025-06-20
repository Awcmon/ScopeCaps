// Units are in mm
$fn= $preview ? 32 : 128;
epsilon = $preview ? 0.005 : 0;

function InchToMillis(inch) = inch * 25.4;

scopeOuterDiameter = 42.5; // cap inner diameter
capThickness = 2;
wallThickness = 2;
capDepth = 3;
capChamferDepth = 2;
cordDiam = 3.75; // [0:0.25:10]

logoPath = "SciTangAwcmon3_Bold.svg";
logoSrcW = 40;
logoSrcH = 17;
logoDestH = 12;
logoScale = logoDestH / logoSrcH;
logoDestW = logoSrcW * logoScale;
textDepth = 0.3;
textPlacement = 2; // 0 = None, 1 = Inside and Protruding, 2 = Outside and Inset

capRadius = (scopeOuterDiameter / 2) + wallThickness;
capHeight = capDepth + capThickness;
cordRadius = cordDiam / 2;
cordHoleInnerMargin = 1.5;
cordHoleOffset = (scopeOuterDiameter / 2) + (cordRadius) + cordHoleInnerMargin;

tabWidth = capRadius * 0.65;
tabLengthBottom = 3; // length to extend past bottom of scope cap
tabLengthTop = -1; // length to extend past bottom of scope cap
tabThickness = 2; // essentially the thickness of the tab
tabBaseWidth = capRadius; // determines the angle of the tab
tabRounding = 3;

slopeType = 0; // 0 = None, 1 = Tabs only, 2 = All
slopeThickness = 2; // thickness across which to slope

function magnitude2(a, b) = sqrt(a*a + b*b);

module capPoly()
{
    hull()
    {
        circle(capRadius);
        translate([-cordHoleOffset,0,0]) circle(r=cordRadius + wallThickness);
        translate([cordHoleOffset,0,0]) circle(r=cordRadius + wallThickness);
    }
}

module tabs()
{
    hull()
    {
        if(tabLengthBottom >= 0)
        {
            translate([-tabWidth + tabRounding, -capRadius - tabLengthBottom + tabRounding, 0]) circle(tabRounding);
            translate([tabWidth - tabRounding, -capRadius - tabLengthBottom + tabRounding, 0]) circle(tabRounding);
        }
        translate([-tabBaseWidth, 0, 0]) circle(tabRounding);
        translate([tabBaseWidth, 0, 0]) circle(tabRounding);
        if(tabLengthTop >= 0)
        {
            translate([-tabWidth + tabRounding, capRadius + tabLengthTop - tabRounding, 0]) circle(tabRounding);
            translate([tabWidth - tabRounding, capRadius + tabLengthTop - tabRounding, 0]) circle(tabRounding);
        }
    }
}

module logo_and_text()
{
    translate([0, 0, 0]) offset(delta=0.001) 
    scale(logoScale) import("SciTangAwcmon3_Bold.svg", center = true);

    translate([0, -15, 0])
    text(str(scopeOuterDiameter, "mm"), size = 5, halign="center", valign="bottom", font="Agency FB:style=Bold");
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

module cylindrical_outer_chamfer(h, startRadius, radius)
{
    difference()
    {
        children();
        difference()
        {
            chamferCylInnerScale = startRadius / radius;

            cylinder(h - epsilon, r=radius);

            translate([0,0,-epsilon])
            chamfered_extrude(h + epsilon, startScale = chamferCylInnerScale, startHeight = h + epsilon)
            circle(radius);
        }
    }
}

color(alpha = 0.5) render()
union()
{
    difference()
    {
        cordTabRadius = cordHoleOffset + cordRadius + wallThickness;
        flipTabBottomRadius = magnitude2(tabWidth, -capRadius - tabLengthBottom);
        flipTabTopRadius = magnitude2(tabWidth, capRadius + tabLengthTop);
        cylOuterChamferRadius = max(cordTabRadius, flipTabBottomRadius, flipTabTopRadius);

        assert(slopeType >= 0 && slopeType <= 2, "Valid SlopeType must be selected.");
        if(slopeType == 0)
        union()
        {
            chamfered_extrude(capHeight, endScale = 0.985, endHeight = 1) capPoly();
            linear_extrude(tabThickness) tabs();
        }
        else if(slopeType == 1)
        union()
        {
            chamfered_extrude(capHeight, endScale = 0.985, endHeight = 1) capPoly();
            cylindrical_outer_chamfer(slopeThickness, capRadius, cylOuterChamferRadius)
            linear_extrude(tabThickness) tabs();
        }
        else if(slopeType == 2)
        cylindrical_outer_chamfer(slopeThickness, capRadius, cylOuterChamferRadius)
        {
            chamfered_extrude(capHeight, endScale = 0.985, endHeight = 1) capPoly();
            linear_extrude(tabThickness) tabs();
        }

        // Chamfered cutout for the scope tube
        translate([0, 0, capThickness]) 
        chamfered_extrude(capDepth, endScale = 1.05, endHeight = capChamferDepth) circle(d=scopeOuterDiameter);

        // Chamfered holes for the cords
        translate([-cordHoleOffset, 0, 0]) chamfered_extrude(capHeight, 1.5, 1.5, 1, 1.5) circle(d=cordDiam);
        translate([cordHoleOffset, 0, 0]) chamfered_extrude(capHeight, 1.5, 1.5, 1, 1.5) circle(d=cordDiam);

        // Add logo and text to the outside of the cap
        if(textPlacement == 2) linear_extrude(textDepth) rotate([0,180,0]) logo_and_text();
    }

    // Add logo and text to the inside of the cap
    if(textPlacement == 1) translate([0, 0, capThickness]) linear_extrude(textDepth) logo_and_text();
}
