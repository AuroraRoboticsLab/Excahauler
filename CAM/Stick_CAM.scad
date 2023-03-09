
$subpart=1;
$FEM_mode=0;
include <../Excahaul_latest.scad>;


// To fit on a page, use 1/4 scale
scale(0.25) {
    projection() 
        stickModel(0);
    
    translate([400,0,0])
    projection()
    rotate([0,90,0])
            stickModel(0);
}
