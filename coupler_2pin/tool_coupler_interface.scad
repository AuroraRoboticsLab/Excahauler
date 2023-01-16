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

// Draw the pins.  The origin is at the top pin, -y toward the bottom pin.
module toolCouplerPins() {
    for (y=[0,-pinSep])
        translate([0,y,0])
            rotate([0,90,0])
                cylinder(d=pinOD,h=pinSlot,center=true);
}

