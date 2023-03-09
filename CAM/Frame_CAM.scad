
$subpart=1;
$FEM_mode=0;
include <../Excahaul_latest.scad>;


rotate([0,0,-90])
{
    projection() 
        frameModel(0);
    
    // backview
    translate([0,-600,0])
    projection() 
    rotate([90,0,0])
        frameModel(0);
    
    // sideview
    translate([500,0,0])
    projection()
    rotate([0,90,0])
            frameModel(0);
}
