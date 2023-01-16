/*
  Push-connect electrical coupler based around Anderson Power Poles. 

  Designed to be ambidexterous: any coupler can connect to any other coupler, to allow operational flexibility like robot-to-robot connections. 
  The left side is "send" wires, the right side is "receive" wires, so when they're rotated 180 degrees and mated, sends and receives match up. 
*/

include <../../AuroraSCAD/powerpole.scad>;
include <../../AuroraSCAD/screw.scad>;

$fs=0.1; $fa=3;

/* Size of RX coupler in XYZ dimensions */
ecoupler_sz=[130,25,25];
ecoupler_bolt=43; // X distance from center to mounting bolts

/* Electrical insert dimensions */
einsert_centers=[-15,0,+15]; // X coords of center points
einsert_sz=[13,21,22];
einsert_wiggle=0.2; // empty space around inserts
einsert_chamfer=3; // corners chamfered by this much
einsert_index=0.5; // nick in corner chamfer
einsert_lipX=1.0; // retaining lip at top of insert
einsert_lipY=1.0;

// Put children at each insert centerpoint
module einsert_mount_centers() {
    for (x=einsert_centers) translate([x,0,0])
        children();
}

// Basic insert frame, before carving out electrical component spaces
module einsert_frame(shrink=0,dX=0,dY=0,dZ=0) {
    sz=einsert_sz+[dX,dY,dZ]; // actual size of part
    
    translate([0,0,-ecoupler_sz[2]]) // z==0 is interface plane
    linear_extrude(height=sz[2])
    offset(r=-shrink)
    {
        offset(delta=+einsert_chamfer,chamfer=true) 
        offset(r=-einsert_chamfer)
            square([sz[0],sz[1]],center=true);
        
        if (dZ<1) // remove -X,-Y corner's chamfer, for indexing
            translate([-sz[0]/2+einsert_index,-sz[1]/2+einsert_index,0])
                square([sz[0]/2,sz[1]/2]);
    }
}

// Hole in the frame for the einsert
module einsert_cutaway() {
    epsilon=0.01; // prevent OpenSCAD roundoff
    // Main body
    translate([0,0,-epsilon])
        einsert_frame(shrink=-einsert_wiggle,dZ=einsert_wiggle+epsilon);
    
    // Face hole
    einsert_frame(shrink=-einsert_wiggle,
        dX=-2*einsert_lipX,dY=-2*einsert_lipY,dZ=10);
}

/* Mounting bolts of coupler */
ecoupler_mount=M3_cap_screw;
ecoupler_mount_holes=[ecoupler_bolt,10,-10]; // XYZ of holes, relative to center top face

module ecoupler_mount_centers() {
    for (dx=[-1,+1]) 
    for (dy=[-1,+1]) 
        translate([dx*ecoupler_mount_holes[0],dy*ecoupler_mount_holes[1],ecoupler_mount_holes[2]])
            children();
}


/* Fine alignment is via simple mating cones */
align_screw=US_5_16_hex; 
align_OD=8.0; // central spike (may be replaced by steel pin)

align_spike_Y=20; // Y height of alignment spike
align_spike_X=20; // X width of alignment spike
align_spike_centers=[-(ecoupler_bolt-align_spike_X/2),+(ecoupler_bolt+align_spike_X/2)]; // X distance from centerline to spike
align_spike_squish=align_spike_X/align_spike_Y; // X/Y scale factor for alignment features
align_spike_base=12; // lets power poles mate with pure translation (== power pole mating distance plus a little)
align_spike_cone=8; // height of alignment cone above base
align_spike_pin=15; // pin sticks out of cone

// The screw is a cut off hex bolt, held captive above the base.
//  It also retains the power pole pins. 
module align_spike_screw() {
    for (spike_x=align_spike_centers)
    translate([-spike_x,0,-ecoupler_sz[2]+6])
        rotate([180,0,0])
            rotate([0,0,30]) screw_3D(align_screw,thru=100,head_fn=6,extra_head=20);
}

module align_spike_roundsquare(round_d,shrink=0)
{
    offset(r=+round_d) offset(r=-round_d)
        square([align_spike_X-2*shrink,align_spike_Y-2*shrink],center=true);
}

// One spike used for alignment during mating
module align_spike(shrink=0,extraZ=0) 
{
    d=align_OD-shrink;
    round_d=d/2;
    z=align_spike_base+align_spike_cone+extraZ-0.7*shrink; // top of cone
    
    for (spike_x=align_spike_centers)
    translate([spike_x,0,0])
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
                offset(r=taper*(b-1))
                    align_spike_roundsquare(round_d,shrink);
            if (0) // cone style
                scale([align_spike_squish,1,1])
                {
                    o=align_spike_Y-2*shrink;
                    cylinder(d=o,h=align_spike_base);
                }
        }
        // tiny flare around the base (guides the mate in)
        flare=1.0-shrink;
        hull() {
            linear_extrude(height=0.001)  // wide base
            difference() {
                offset(r=flare)
                    align_spike_roundsquare(round_d,shrink);
                // don't flare next to mate side
                side=-1; // ((shrink>0)?+1:-1); // *((spike_x>0)?+1:-1);
                translate([side*(align_spike_X/2-shrink+100),0,0])
                    square([200,200],center=true);
            }
            linear_extrude(height=flare)  // top
                offset(r=0)
                    align_spike_roundsquare(round_d,shrink);
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

// Main body of coupler
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
        
        align_spike_screw();
        
        ecoupler_mount_centers()
            screw_3D(ecoupler_mount,thru=25,extra_head=50);
        
        einsert_mount_centers()
            einsert_cutaway();
        
        // Cutaway
        if (cutaway) translate([0,100,0]) cube([200,200,200],center=true);
    }
}


/* Electrical connections are via Anderson Power Pole blocks,
designed with a left-right-symmetric pinout:
    24V
    gnd
*/
pp=powerpole_45A; //<- small Anderson Power Pole size
pp_OD=powerpole_OD(pp);
pp_origin=[0.0*pp_OD,-0.5*pp_OD,-powerpole_length(pp)+powerpole_mate(pp)/2];
pp_rot=[0,0,90]; // rotation from coupler to Anderson
pp_wiggle=0.15; // wiggle room to allow powerpoles to be inserted/removed for assembly

// Make powerpoles at each of their centers, on both sides
module pp_orient() {
    translate(pp_origin) rotate(pp_rot) 
        powerpole_array(pp,2,1) 
            children();
}

// Spaces for powerpoles: slot to insert them, pins to retain them.
module pp_spaces() {
    translate([0,0,pp_origin[2]])
    {
        // Space for the actual boxes
        linear_extrude(height=powerpole_length(pp)) 
            pp_orient() offset(r=pp_wiggle) {
                powerpole_box2D(pp);
                powerpole_key2D(pp);
            }
        // Space for wires
        linear_extrude(height=10,center=true) 
            offset(r=+2) offset(r=-2) // round the edges
            hull()
            pp_orient() offset(r=pp_wiggle) {
                powerpole_wire2D(pp);
            }
        // Space around mating shround
        translate([0,0,powerpole_length(pp)-powerpole_mate(pp)])
        linear_extrude(height=20) 
            pp_orient() offset(r=0.2+pp_wiggle) {
                powerpole_box2D(pp);
            }
    }
    
    // Sideways thru holes for steel retaining pins
    translate(pp_origin) rotate(pp_rot) 
            powerpole_pins3D(pp,4,100);
}

// Insert that holdes two Anderson power poles
module einsert_powerpole() {
    difference() {
        einsert_frame();
        
        // Space for power poles and pins
        pp_spaces();
    }
}

// USB-A connection distance
usb_a_mate=10; // mm of travel for USB-A
usb_a_z=usb_a_mate/2.0; // topmost Z height of connector

// USB-A male plug: short black mini-B type cable for Arduino Nano
module einsert_USB_A_male(wiggle=0.15,halves=1)
{
    w2=2*[wiggle,wiggle,wiggle]; // wiggle room on all sides
    difference() {
        einsert_frame();
        
        translate([0,0,usb_a_z])
        rotate([0,90,0]) rotate([0,0,90]) 
        {
            // X: across flat of cable
            // Y: along cable
            // Z: across narrow side of cable
            
            // space for mating USB female
            translate([0,-usb_a_z,0])
                cube([18,10.8,usb_a_mate+1],center=true);
            
            // metal USB box proper
            cube([12.1,2*14,4.6]+w2,center=true);
            
            // Cable back mold
            linear_extrude(height=7.9+wiggle,center=true)
            offset(r=wiggle)
            hull() {
                translate([0,-12.3]) square([15.8,0.1],center=true);
                translate([0,-26.4]) square([15.4,0.1],center=true);
                translate([0,-32.0]) square([9.6,0.1],center=true);
                
            }
        
            if (halves) // cut into two half pieces
                cube([0.2+wiggle,100,100],center=true);
        }
    }
}

function vec2_from_vec3(v) = [v[0],v[1]];

// round 2D shape's outside edges with this radius
module r2(r=2) {
    offset(r=+r) offset(r=-r) children();
}

// USB-A female plug: 3ft black USB extender
module einsert_USB_A_female(wiggle=0.15,halves=1)
{
    w2=2*[wiggle,wiggle,wiggle]; // wiggle room on all sides
    bx=[10.3,17.6,23.5];
    bx2=vec2_from_vec3(bx+w2);
    
    difference() {
        einsert_frame();
        
        translate([0,0,usb_a_z])
        rotate([0,180,0]) // Z+ faces down
        {
            // X: across narrow side of cable
            // Y: across flat side of cable
            // Z: along cable
            
            // space for mating USB female
            linear_extrude(height=13.4) r2() square(bx2,center=true);
            // divot (retains plug)
            linear_extrude(height=20) offset(r=-0.6) r2() square(bx2,center=true);
            hull() {
                translate([0,0,14])
                    linear_extrude(height=9) r2() square(bx2,center=true);
                translate([0,0,31])
                    cube([10.2,11.6,0.1]+w2,center=true);
            }
            
            translate([0,0,15])
            cylinder(d1=10,d2=12.4+wiggle,h=32-15);
        
            if (halves) // cut into two half pieces
                cube([100,0.2+wiggle,100],center=true);
        }
    }
}


// External required mounting holes
module ecoupler_mountholes(shrink=0,thru=10) {
    ecoupler_mount_centers()
        cylinder(d=2.3,h=50,center=true);
    
    // Slot for wires to get out (wide so USB can pass through)
    translate([0,0,-ecoupler_sz[2]])
    linear_extrude(height=2*thru,center=true)
    offset(r=-shrink)
    hull() {
        for (x=einsert_centers) translate([x,0,0]) circle(d=einsert_sz[1]-4*einsert_lipY);
    }
}


module ecoupler_demo(cutaway=0) {
    ecoupler_frame(cutaway);
    
    // einsert
    color([0.3,1.0,0.3])
        einsert_mount_centers()
            einsert_powerpole();
    
    // Populated connectors
    #color([1,0.1,0.2])
        pp_orient() powerpole_3D(pp,wiggle=0,matinghole=1);
    
    // Mounting bolts
    #ecoupler_mount_centers()
        screw_3D(ecoupler_mount);
}

//ecoupler_demo(1);

//ecoupler_frame();
//translate([0,ecoupler_sz[1],0]) einsert_powerpole();

if (0) { // USB inserts
    translate([einsert_centers[0],ecoupler_sz[1],0])
        einsert_USB_A_male();
    translate([einsert_centers[2],ecoupler_sz[1],0])
        einsert_USB_A_female();
}





