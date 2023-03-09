/*
 Interface-defining parameters between robot coupler and tool,
 for large 18mm diameter 2-pin tool coupler.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2021--2022 (Public Domain)
*/

// Tool double pin parameters:
//   18mm diameter pins, 175mm apart, 150mm slot, 30mm slot depth
pinOD=18.1; // pin diameter (plus a little slop)
pinSlot=150; // left-right pin length (minimum tool space)
pinSep=175; // up-down distance between pins

knuckleSpace=25; // center of pins to back of tool plate

// 3D coordinates, relative to center of top pin, for ecoupler's top front corner
ecoupler_top_corner=[0,-pinSep-15,0];

spin_to_top_pin=85; // Z coordinate distance from spin center to top pin center

// Draw the pins.  The origin is at the center of the top pin, -Z toward the bottom pin, +Y to tool forward
module toolCouplerPins() {
    for (z=[0,-pinSep])
        translate([0,0,z])
            rotate([0,90,0])
                cylinder(d=pinOD,h=pinSlot,center=true);
}

// Draw an approximate tool pickup, including pins and sideplates. 
module toolPickup(sides=15) {
    color([0.9,0.9,0.9]) toolCouplerPins();
    color([0.2,0.2,0.2]) for (side=[-1,+1]) scale([side,1,1])
        translate([pinSlot/2,0,0])
        hull() {
            for (z=[0,-pinSep]) translate([0,0,z])
                rotate([0,90,0]) cylinder(d=pinOD+3,h=sides);
            translate([0,knuckleSpace-1,-pinSep]) cube([sides,1,0.9*pinSep]);
        }
}


