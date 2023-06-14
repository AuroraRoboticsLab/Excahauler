/*
 Holds Peg Perego motor gearbox gears in a 3-jaw lathe chuck.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-04-28 (Public Domain)
*/
$fs=0.05; $fa=2;

use <../AuroraSCAD/gear.scad>;


pressureAngle=10; // 14.5;
add=0.4;
ded=0.4;

// Geartypes for each gear layer
geartype0 = [ 0.8, 9.0, pressureAngle, add, ded ]; // motor
geartype1 = [ 1.25, 10.5+1.2, pressureAngle, add, ded ]; // fastest gear output
geartype2 = [ 1.77, 12+1.7, pressureAngle, add, 0.3 ]; // intermediate gear
geartype3 = [ 2.25, 16, pressureAngle, add, ded ]; // output gear

// The holders count as ring gears as far as tooth geometry
gear1 = gear_create(geartype1,15,0);
gear2 = gear_create(geartype2,12,0);
gear3 = gear_create(geartype3,13,0);

wall=2.0;

/* Create a holder for this gear, so it can be clamped in a lathe without damaging the teeth. */
module gear_holder(gear) 
{
    r=gear_OR(gear)+wall;
    linear_extrude(height=gear_height(gear),convexity=8)
    difference() {
        intersection_for (side=[0:60:360-1]) rotate([0,0,side])
            translate([r-100,0,0]) square([200,200],center=true);
        
        offset(r=0.3) // printed clearance
            gear_2D(gear);
        
        // Slot so holder can wrap around gear, and clamp down to it
        square([r+1,0.5]);
    }
}

// Create a gear, plus "wings" to mark drill locations for encoder magnets
module gear_wings(gear) {
    encoderCenter=[0,19]; // 19mm radius
    gear_holder(gear);
    for (side=[-1,+1]) scale([1,side,1]) 
    linear_extrude(convexity=2,height=1.2)
    difference() {
        hull() {
            translate([0,gear_OR(gear)+wall/2])
                square([12,1],center=true);
            translate(encoderCenter) circle(d=10);
        }
        translate(encoderCenter) circle(d=3.2);
    }
}

gear_wings(gear1);
translate([40,0]) gear_holder(gear2);
//translate([0,40]) gear_holder(gear3);

