/* Ring to hold magnets on wheel driver. 
*/

$fs=0.1;
$fa=2;

magnet_OD=9.5;
magnet_Z=1.6;
magnet_N=12;
ring_R=35;
ring_Z=12; // height of top of circle of magnets

use <drive_v15.scad>;


difference() {
    cylinder(d1=70,d2=magnet_OD+2*ring_R+4,h=ring_Z);
    
    for (angle=[0:360/magnet_N:360-0.1]) 
    rotate([0,0,angle]) {
        translate([ring_R,0,ring_Z-magnet_Z])
            cylinder(d=magnet_OD,h=magnet_Z+0.01);
    }
    
    translate([0,0,-0.01])
        encoder_ring(3);
    
    // flatten bottom
    cube([200,200,3.5],center=true);
    
    //cube([100,100,100]); // cutaway
}

