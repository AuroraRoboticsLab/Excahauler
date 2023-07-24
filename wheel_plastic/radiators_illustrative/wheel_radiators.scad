/*

Models of heat radiators on wheels.


*/

$fs=0.1; $fa=2;
inch=25.4; // file units are mm
thruHole=3/8*inch;
hexFlats=9/16*inch; // 3/8" hex bolt, across the flats
hexHole=(hexFlats+0.15)/cos(30);

OD=150;
Z=32;
wall=1.5;

module axle() {
    cylinder(d=thruHole,h=100,center=true);
    translate([0,0,3]) cylinder(d=hexHole,$fn=6,h=100);
}

dy=60; // starting difference between radiator panels
module radiator_scoops() {
    for (rad=[-dy,0,+dy]) translate([0,-dy/4+rad,1])
        rotate([45,0,0])
        translate([-100,0,0])
            cube([200,100,100]);
}

module scallops() {
    axle();
    radiator_scoops();
    difference() {
        translate([0,dy/2,30])
            scale([1,1,-1]) radiator_scoops();
        
        for (x=[-OD/4,0,+OD/4]) translate([x,0,0])
            cube([wall,200,200],center=true);
        
        cylinder(d=1.5*hexHole,$fn=6,h=100,center=true);
    }
}

module raw_disk() 
{
    difference() {
        cylinder(d=OD,h=Z);
        axle(); // thru hole for mounting bolt
        intersection() {
            translate([0,0,-1]) cylinder(d=OD-2*wall,h=Z+2);
            scallops();
        }
        
        //cube([100,100,100]); // cutaway
    }
}

intersection() {
    //translate([0,10,0]) cube([200,100,200],center=true);
    raw_disk();
}

