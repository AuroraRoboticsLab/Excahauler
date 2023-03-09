
$subpart=1;
include <../Excahaul_latest.scad>;


// To fit on a page, use 1/4 scale
rotate([0,0,-90])
{
    projection() 
        stickModel(0);
    pivotHoles(stickPivotHoles,0);
    
    translate([400,0,0])
    projection()
    rotate([0,90,0])
    difference() {
            stickModel(0);
        
    }
}

