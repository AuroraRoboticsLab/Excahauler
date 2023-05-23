/*
 A ventilated card that fits in a nanoslot rack,
 to hold a Raspberry Pi 4 controller or a set of USB hardware.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-04-26 (Public Domain)
*/
include <../driver_case_interface.scad>;
include <../../../AuroraSCAD/bevel.scad>;

boxsize=[driver_case_horizontal-1.0,driver_case_vertical-2.0,driver_case_thick-1.0];
bevel=1.5;
wall=1.5;


pisize=[93,64,24];
pistart=[16,78,wall];
piangle=[0,0,-30];


module pi_walls3D(enlarge=0,hole=0) {
    w=enlarge;
    difference() {
        translate(pistart) rotate(piangle)
            translate([-w-hole,-w,-w])
                bevelcube(pisize+2*[w,w,w]+[hole,hole,hole],bevel=bevel,bz=hole?1:0);
    }
}

module pi_base3D() {
    difference() {
        // outside
        bevelcube(boxsize+[0,0,10],bevel=bevel);

        // trim the top (without a bevel)
        translate([0,0,boxsize[2]+500]) cube([1000,1000,1000],center=true);
        
        // inside, with open top
        translate([wall,wall,wall])
        bevelcube(boxsize+[-2*wall,-2*wall,+2*wall],bevel=2*bevel);
        
        // gap for wires halfway out
        for (del=[[0,0,0],[0,50,-boxsize[2]/2+2*wall]])
        translate(boxsize/2+[0,0,boxsize[2]/2]+del)
            bevelcube(boxsize+[-50,20,0],center=true,bevel=2*bevel);
    }
}

module pi_slot3D(pi=1) {
    difference() {
        union() {
            pi_base3D();
            if (pi) pi_walls3D(wall);
        }
        
        if (pi) pi_walls3D(0.0,hole=3);
        
        // vent / wiretie holes
        dx=boxsize[0]/8;
        dy=boxsize[1]/5;
        linear_extrude(height=2*wall+0.2,center=true,convexity=10)
        for (gridx=[2*dx:dx:boxsize[0]-2*dx+1])
        for (gridy=[dy:dy:boxsize[1]-dy+1])
            translate([gridx,gridy,0])
                bevelsquare([dx-2*wall,dy-2*wall,2*wall+0.2],
                    bevel=bevel,center=true);
    }
    
    // Extend pi walls down to floor
    if (pi) 
    intersection() {
        piwall=2.0;
        translate([0,0,-wall-0.1])
        difference() {
            pi_walls3D(wall);
            pi_walls3D(0.0,hole=3);
        }
        translate([0,0,piwall/2])
            cube([500,500,piwall],center=true);
    }
}

//pi_slot3D(1); // with pi
pi_slot3D(0); // without pi


//translate([55,85]) rotate([0,0,-90]) whole_frame();



// Drop raw DXF on top of everything
// color([1,0,0]) translate([0,0,3]) import(dxf_name);

