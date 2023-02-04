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
thick=20; // thickness in the along-pin direction
floor=1.5; // thickness under the pins
pinspots=[[0,0,0],[0,pinSep,0]];
pinODwall=pinOD+2*wall;

bolt=0.195*inch; // 3/16" bolt OD
bolthead=0.5*inch; // flat spot for bolts
boltback_ht=32;
boltspots=[[knuckleSpace,0,thick/2],[knuckleSpace,125,thick/2]]; // base of each bolt
boltlen=[knuckleSpace+pinOD/2+wall, 29];

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
            bevel=wall/2;
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

module sideplate3D() {
    intersection() {
        union() {
            linear_extrude(height=floor) 
                sideplate_floor_2D();
            linear_extrude(height=thick,convexity=8)
                sideplate_ribs_2D();
        }
        
        // Trim the leading edge, to guide coupler inside
        union() {
            bevel=rib;
            for (side=[0,1])
            hull() {
                linear_extrude(height=thick-rib) 
                    sideplate_solid_2D(side); 
                linear_extrude(height=thick+0.01) 
                    offset(r=-rib)
                        sideplate_solid_2D(side);
                // don't bevel the back or bottom edge
                translate([1000,-1000]) cube([1,1,thick]);
            }
        }
    }
}

pin_inside=0.615*inch; // inside of pins (1/2" EMT)
pin_inside_thick=2*thick; // filler stops pins from denting
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
            sideplate3D();
            for (i=[0,1])
                translate(pinspots[i]) pin_inside3D();
            
            difference () {
                sideplate_bolts_3D(0);
                for (i=[0,1])
                translate(pinspots[i]+[0,0,floor]) cylinder(d=pinOD,h=thick);
            }
        }
        sideplate_bolts_3D(1);
    }
}

sideplate3Dbolted();

translate([55,0,0]) scale([-1,1,1]) sideplate3Dbolted();



