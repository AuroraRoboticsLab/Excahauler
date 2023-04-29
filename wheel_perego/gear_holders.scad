/*
 Holds Peg Perego motor gearbox gears in a 3-jaw lathe chuck.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-04-28 (Public Domain)
*/
$fs=0.05; $fa=2;

use <../AuroraSCAD/gear.scad>;


// Geartypes for each gear layer
geartype0 = [ 0.8, 9.0, 20, 0.32, 0.4 ]; // motor
geartype1 = [ 1.25, 10.5, 20, 0.32, 0.4 ]; // fastest gear output
geartype2 = [ 1.75, 12, 20, 0.32, 0.4 ]; // intermediate gear
geartype3 = [ 2.25, 16, 20, 0.32, 0.4 ]; // output gear

// The holders count as ring gears as far as tooth geometry
gear1 = gear_create(geartype1,15,1);
gear2 = gear_create(geartype2,12,1);
gear3 = gear_create(geartype3,13,1);

wall=2.5;

/* Create a holder for this gear, so it can be clamped in a lathe without damaging the teeth. */
module gear_holder(gear) 
{
    r=gear_OR(gear)+wall;
    linear_extrude(height=gear_height(gear),convexity=8)
    difference() {
        intersection_for (side=[0:60:360-1]) rotate([0,0,side])
            translate([r-100,0,0]) square([200,200],center=true);
        
        gear_2D(gear);
    }
}

gear_holder(gear1);
translate([40,0]) gear_holder(gear2);
translate([0,40]) gear_holder(gear3);

