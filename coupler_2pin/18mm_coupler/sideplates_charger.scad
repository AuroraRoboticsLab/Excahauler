/*
 Sideplates hold pins onto a tool, like the mining head.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-02-03 (Public Domain)
*/
inch=25.4; // file units are mm

include <../../AuroraSCAD/bevel.scad>;
include <../tool_coupler_interface.scad>;
include <../electric/electric_coupler.scad>;

wall=3.0; // coupler's general wall thickness
rib=1.5; // thickness of reinforcing ribs
thick=18; // thickness in the along-pin direction
floor=1.5; // thickness under the pins
pinspots=[[0,0,0]];
pin_wiggle=0.15; // print this much space around pins
pin_outside=pinOD+2*pin_wiggle;
pin_inside=0.615*inch-2*pin_wiggle; // inside of pins (1/2" EMT)
pin_inside_thick=2*thick; // filler stops pins from denting
pinODwall=pin_outside+2*wall;

bolt=0.195*inch; // 3/16" bolt OD
bolthead=0.5*inch; // flat spot for bolts
boltback_ht=32;
boltspots=[[knuckleSpace,0,thick/2],[knuckleSpace,64,thick/2]]; // base of each bolt
boltlen=[knuckleSpace+pinOD/2+wall+0.5, 15];

ecoupler=ecoupler_top_corner+[0,pinSep,0];
ecoupler_size2D=[25,25];

// 3D bolts (inside==1) or supports (inside==0)
module sideplate_bolts_3D(inside=0) 
{
    OD=inside?bolt:bolt+3*wall;
    for (i=[0,1]) translate(boltspots[i]) rotate([0,-90,0])
    {
        if (inside) { // thru hole
            translate([0,0,-1])
            cylinder(d=OD,h=boltlen[i]+2);
        } else { // beveled support cylinder
            bevel=wall*0.7;
            hull() {
                cylinder(d=OD,h=boltlen[i]-bevel);
                cylinder(d=OD-2*bevel,h=boltlen[i]);
            }
        }
    }
}

// Back side of bolt supports
module sideplate_boltback_2D(side=-1) {
    dy=(side<1)?-1:+1;
    h=(side<0)?boltback_ht:1;
    translate([0,dy*boltback_ht/2]) 
        scale([-1,1])
            square([wall,h]);
}

// Electronic coupler box
module ecoupler_box_2D(scale=1) {
    translate(ecoupler) 
        scale([1,-scale]) square(ecoupler_size2D);
}

// Overall outline of sideplates
//   0: bottom section;  1: top section
module sideplate_solid_2D(side) {
    hull() {
        translate(pinspots[side]) circle(d=pinODwall);
        translate(boltspots[1-side]) sideplate_boltback_2D();
        if (side==0) ecoupler_box_2D();
        if (side==1) translate(boltspots[1]) sideplate_boltback_2D();
    }
}

// Solid blocks around pins and bolts
module sideplate_ribsolid_2D(side) {
    for (i=[0,1])
    {
        hull() {
            translate(pinspots[i]) circle(d=pinODwall);
            translate(boltspots[i]) sideplate_boltback_2D(side);
        }
    }
}
module sideplate_eribsolid_2D(side)
{
    if (side==1) ecoupler_box_2D();
    else if (0)
        hull() {
            ecoupler_box_2D(0.1);
            translate(pinspots[0]) circle(d=pinODwall);
        }
}

// Convert a solid child into rib outlines
module sideplate_ribify_2D(edge) {
    difference() {
        children();
        offset(r=-edge) children();
    }
}

// Round off inside corners of this shape, for strength
module sideplate_round(extra=0) {
    round=1.5+extra;
    offset(r=-round) offset(r=+round) children();
}

// Ribs to support major parts
module sideplate_ribs_2D() {
    sideplate_round()
    {
        // Surround each pin fully:
        sideplate_ribify_2D(wall) for (p=pinspots) translate(p) circle(d=pinODwall);
        
        for (side=[0,1])
        {
            sideplate_ribify_2D(wall) sideplate_solid_2D(side);
            sideplate_ribify_2D(rib) sideplate_ribsolid_2D(side);
            sideplate_ribify_2D(rib) sideplate_eribsolid_2D(side);
        }
    }
}

module sideplate_floor_2D() {
    sideplate_round() {
        for (side=[0,1]) sideplate_solid_2D(side);
    }
}

// Basic overall 3D shape
module sideplate3D() {
    intersection() {
        union() {
            // Reinforcing ribs
            linear_extrude(height=floor) 
                sideplate_floor_2D();

            // Walls and reinforcing ribs
            linear_extrude(height=thick,convexity=8)
                sideplate_ribs_2D();
            
            // Bevel walls/ribs on top and bottom sides
            stepmax=1.9;
            for (top=[0,1]) for (wallstep=[0.5:0.5:stepmax]) 
                translate([0,0,top?thick:0]) scale([1,1,top?-1:1])
                linear_extrude(height=floor+wallstep,convexity=8)
                sideplate_round() intersection() {
                    for (side=[0,1]) sideplate_solid_2D(side); 
                    offset(r=+stepmax-wallstep)
                        sideplate_ribs_2D();
                }

            // Top plate
            translate([0,0,thick-floor])
                linear_extrude(height=floor) {
                    ecoupler_box_2D();
                    difference() {
                        sideplate_solid_2D(1);
                        sideplate_solid_2D(0);
                    }
                }
        }
        
        // Bevel the leading edge, to guide coupler inside
        union() {
            bevel=2;
            for (side=[0,1])
            hull() {
                linear_extrude(height=thick-bevel) 
                    sideplate_solid_2D(side); 
                linear_extrude(height=thick+0.01) 
                    offset(r=-bevel)
                        sideplate_solid_2D(side);
                // don't bevel the back or bottom edge
                translate([1000,-1000]) cube([1,1,thick]);
            }
        }
    }
}

// Reinforcing inside pin holes, to keep the thin-wall steel tubes from crushing
module pin_inside3D() {
    difference() {
        cylinder(d=pin_inside,h=pin_inside_thick);
        translate([0,0,pin_inside_thick+0.1]) scale([1,1,-1]) {
            cylinder(d1=pin_inside-wall,d2=5,h=10);
        }
    }
}

module sideplate3Dbolted() {
    difference() {
        union() {
            difference() {
                union() {
                    sideplate3D();
                    sideplate_bolts_3D(0);
                }
                // clear space around pins
                for (i=[0,1])
                translate(pinspots[i]+[0,0,floor]) cylinder(d=pin_outside,h=thick);
            }
            
            // fill pin insides
            for (i=[0,1])
                translate(pinspots[i]) pin_inside3D();
        }
        // bolt holes
        sideplate_bolts_3D(1);
    }
}

module sideplate3Dprintable() {
    rotate([0,0,90]) {
        sideplate3Dbolted();

        translate([55,0,0]) scale([-1,1,1]) sideplate3Dbolted();
    }
}

sideplate3Dprintable();
