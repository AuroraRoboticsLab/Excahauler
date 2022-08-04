/*
  Push-connect electrical coupler based around Anderson Power Poles. 

  Designed to be ambidexterous: any coupler can connect to any other coupler, to allow operational flexibility like robot-to-robot connections. 
  The left side is "send" wires, the right side is "receive" wires, so when they're rotated 180 degrees and mated, sends and receives match up. 
*/

include <../AuroraSCAD/powerpole.scad>;
include <../AuroraSCAD/screw.scad>;

$fs=0.1; $fa=3;

/* Size of RX coupler in XYZ dimensions */
ecoupler_sz=[73,28,23];
ecoupler_wall=2;

/* Mounting bolts of coupler */
ecoupler_mount=M3_cap_screw;
ecoupler_mount_holes=[16,10,-16];

module ecoupler_mount_centers() {
    for (dx=[-1,+1]) 
    for (dy=[-1,+1]) 
        translate([dx*ecoupler_mount_holes[0],dy*ecoupler_mount_holes[1],ecoupler_mount_holes[2]])
            children();
}


/* Fine alignment is via simple mating cones */
align_screw=US_5_16_hex; 
align_OD=8.0; // central spike (may be replaced by steel pin)

align_spike_space=25; // X distance from centerline to spike
align_spike_Y=24; // Y height of alignment spike
align_spike_X=20; // X width of alignment spike
align_spike_squish=align_spike_X/align_spike_Y; // X/Y scale factor for alignment features
align_spike_base=10; // lets power poles mate with pure translation (needs to be power pole mating distance plus a little)
align_spike_cone=8; // height of alignment cone above base
align_spike_pin=15; // pin sticks out of cone

// The screw is a cut off hex bolt, held captive above the base.
//  It also retains the power pole pins. 
module align_spike_screw() {
    translate([align_spike_space,0,-ecoupler_sz[2]+6])
        rotate([180,0,0])
            rotate([0,0,30]) screw_3D(align_screw,thru=50,head_fn=6,extra_head=10);
}

// One spike used for alignment during mating
module align_spike(shrink=0,extraZ=0) 
{
    d=align_OD-shrink;
    z=align_spike_base+align_spike_cone+extraZ-0.7*shrink; // top of cone
    
    translate([-align_spike_space,0,0])
    scale([1,1,-1])
    {
        bevel=3; // bevel the tip of the spike (now machined from steel)
        hull() { // models steel pin
            for (b=[0,+1])
                cylinder(d=d-2*b*bevel,h=z+align_spike_pin-(1-b)*bevel);
        }
        hull() { // flares out for alignment
            cylinder(d=d,h=z);
            
            // Base of alignment feature
            taper=0.3; //<- angle the final entrance
            for (b=[0,+1])
            linear_extrude(height=align_spike_base-b) 
                offset(r=+d/2+taper*(b-1)) offset(r=-d/2)
                    square([align_spike_X-2*shrink,align_spike_Y-2*shrink],center=true);
            if (0) // cone style
                scale([align_spike_squish,1,1])
                {
                    o=align_spike_Y-2*shrink;
                    cylinder(d=o,h=align_spike_base);
                }
        }
    }
}
align_spike_shrink=0.15; //<- half the spacing between mated spikes

module spike_mated_cross_section()
{
    difference() {
        align_spike(-align_spike_shrink,1);
        align_spike(align_spike_shrink);
        translate([0,100,0]) cube([200,200,200],center=true);
    }
}

/* Electrical connections are via Anderson Power Pole blocks,
designed with a symmetric pinout:
    5V  24V  5V
    gnd gnd  gnd
    TX  STOP RX
*/
pp=powerpole_45A; //<- small Anderson Power Pole size
pp_OD=powerpole_OD(pp);
pp_origin=[1.0*pp_OD,-1.0*pp_OD,-powerpole_length(pp)+powerpole_mate(pp)/2];
pp_rot=[0,0,90]; // rotation from coupler to Anderson
pp_wiggle=0.10; // wiggle room to allow powerpoles to be inserted/removed for assembly

// Make powerpoles at each of their centers, on both sides
module pp_orient() {
    translate(pp_origin) rotate(pp_rot) 
        powerpole_array(pp,3,3) 
            children();
}

// Spaces for powerpoles: slot to insert them, pins to retain them.
module pp_spaces() {
    translate([0,0,pp_origin[2]])
    {
        linear_extrude(height=powerpole_length(pp)) 
            pp_orient() offset(r=pp_wiggle) {
                powerpole_box2D(pp);
                powerpole_key2D(pp);
            }
        linear_extrude(height=10,center=true) 
            hull()
            pp_orient() offset(r=pp_wiggle) {
                powerpole_wire2D(pp);
            }
    }
    translate([28.0,0,0]) //<- time the shaft to end before the align spike cavity
    translate(pp_origin) rotate(pp_rot) 
            powerpole_pins3D(pp,4,100);
}

module ecoupler_frame(cutaway=0) {
    difference() {
        union() {
            translate([-ecoupler_sz[0]/2,-ecoupler_sz[1]/2,-ecoupler_sz[2]])
                cube(ecoupler_sz);
            // male half of spike
            rotate([0,180,0]) align_spike(align_spike_shrink);
        }
        
        // female half of spike
        translate([0,0,0.01])
        align_spike(-align_spike_shrink);
        
        pp_spaces();
        
        align_spike_screw();
        
        ecoupler_mount_centers()
            screw_3D(ecoupler_mount,thru=25,extra_head=50);
        
        // Cutaway
        if (cutaway) translate([0,100,0]) cube([200,200,200],center=true);
    }
}


module ecoupler_demo(cutaway=0) {
    ecoupler_frame(cutaway);
    
    // Populated connectors
    #color([1,0.1,0.2])
        pp_orient() powerpole_3D(pp,wiggle=0,matinghole=1);
    
    // Mounting bolts
    #ecoupler_mount_centers()
        screw_3D(ecoupler_mount);
}

//ecoupler_demo(0);
ecoupler_frame();








