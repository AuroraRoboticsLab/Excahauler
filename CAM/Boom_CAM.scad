
$subpart=1;
//$FEM_active=1;
if (warnings_desired) ;
include <../Excahaul_latest.scad>;


rotate([0,0,-90])
{
    //projection() 
        boomModel(0,0,0);
    frameModel(0);
    
    // backview
    translate([0,-600,0])
    //projection() 
    rotate([90,0,0])
        boomModel(0,0,0);
    
    // sideview
    symmetryX()
    translate([20,0,0])
    //projection()
    rotate([0,90,0])
        boomModel(0,0,0);
}
