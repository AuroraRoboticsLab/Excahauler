/*
 This is a motorized stepped planetary designed to lock the "thumb" of 
 the 2-pin coupler. 
 
 It has 75mm of front-to-back space to make the throw, requiring a small motor
   and compact geartrain.
 It needs about 16-18mm of travel.  On the low side will allow overshoot without trashing everything.
 
 It sits about 50mm on top of the mounting plate (for motor to clear back bracket)
 Its mounting bolts sit on a 141mm diameter circle, 8 bolts.
*/
include <../AuroraSCAD/motor.scad>;
include <../AuroraSCAD/gear.scad>;
$fs=0.1; $fa=2; //<- fine output
//$fs=0.2; $fa=5; //<- coarse preview

inch=25.4; // file units are mm

/*
Z stack order:
    Z==0: motor face
    Z==gearZ: end of input planetary set
    Z==outputZ: start of output planetary set
    Z==bearingZ: centerline of output bearing race
*/
gearZ=10; // height of each set of gears.
outputZ=gearZ+2.5; //< add a little vertical clearance for all inside gears (+washers)
bearingZ=outputZ+gearZ/2; // Z centerline of bearing balls

pivotThickTotal=9; //<- total stack height from output gear to start of pivot ring
centerPivotZ=outputZ+gearZ+pivotThickTotal+5; //<- Z from motor face to pivot ring center
centerPivotPoint=[0,0,centerPivotZ]; // 3D location where we pivot

// module 0.8P gears (available in metal versions)
geartype_motor=[ 0.8, gearZ+0.1, 20, 0.32, 0.4 ];

// All these have the same ring teeth: 45 in, 48 out
//gearplane_in = [geartype_motor, 9, 18, 3]; //<- reduction (96:1) with tiny motor sun
//gearplane_in = [geartype_motor, 11, 17, 3]; //<- reduction (81:1) but off-center
//gearplane_in = [geartype_motor, 13, 16, 3]; //<- reduction (71:1) and standard 13T, though off-center
//gearplane_in = [geartype_motor, 15, 15, 3]; //<- reduction (64:1)

gearplane_in = [geartype_motor, 10, 18, 3]; //<- reduction (92:1) with standard 32P 10T sun



gearplane_out = gearplane_stepped(gearplane_in,+1);
echo("Orbit radii: ",gearplane_Oradius(gearplane_in), gearplane_Oradius(gearplane_out));
echo("Ring teeth: ",gearplane_Rteeth(gearplane_in),gearplane_Rteeth(gearplane_out));
echo("Gear reduction: ",gearplane_ratio_Rfixed(gearplane_in),gearplane_stepped_ratio(gearplane_in,gearplane_out));


bearingBallOD=4.4+0.1; // diameter of steel bearing balls (BB, including clearance)
bearingBallR=bearingBallOD/2;
bearingCenterR=gear_OD(gearplane_Rgear(gearplane_out))/2+2+bearingBallR; // centerline of bearing ball ring
bearingGapR=1.0; // clear space between inner and outer races of ring
bearingClampR=bearingCenterR+bearingBallR+3; // clamp bolt centerlines
module bearing_ball_ring() {
    rotate_extrude() {
        translate([bearingCenterR,bearingZ]) circle(d=bearingBallOD);
    }
}

/*
gearplane_2D(gearplane_in);
translate([0,0,gearZ]) gearplane_2D(gearplane_out);

for (sweep=[0,90,180]) rotate([0,0,sweep]) translate([9,0,0]) cylinder(d=6,h=27);
*/

motor=motortype_2845;
motor_clamp=M3_cap_screw;
motor_clampZ=20; //<- dial in for a flat base

// Holds the motor by squeezing the sides
module motor_clamp(wall=2,clampX=3,clampY=5,Z=motor_clampZ) {
    OD=motor_diameter(motor);
    cut=[OD/2+clampX,0,0]; // center of clamps

    scale([1,1,-1])
    difference() {
        linear_extrude(height=Z,convexity=4)
        difference() {
            r=2;
            offset(r=-r) offset(r=+r)
            union() {
                circle(d=OD+2*wall);
                translate(cut) square([2*clampX,2*clampY],center=true);
            }
            
            translate(cut) square([OD,0.5],center=true);
            
            circle(d=OD);
        }
        
        for (fz=[0.35,0.75]) translate(cut+[0,clampY,Z*fz])
            rotate([-90,0,0])
                screw_3D(motor_clamp,thru=clampY,length=3*clampY,extra_head=10);
    }
}


// Output pivot is a 1/4" hex bolt
pivotCapZ=4.3;
pivotCapOD=7/16*inch+0.2;
pivotOD=6.3+0.1;
pivotR=8; // <- total travel = 2* this number
web=0.35; //<- better bridges by making big flat surface
pivot=[0,pivotR,gearZ+pivotCapZ];
pivotRoof=pivotThickTotal-pivotCapZ; // plastic on top of the pivot cap

// Hole for the pivot bolt (a 1/4" bolt, cut off and machined)
module output_ring_head(enlarge=0,extra_head=0)
{
    translate(pivot){
        scale([1,1,-1])
            cylinder(d=pivotCapOD/cos(30)+2*enlarge,h=pivotCapZ+extra_head,$fn=6);
        translate([0,0,web-0.01]) cylinder(d=pivotOD,h=20);
    }
}

// Holds the actual steel pivot bolt.
module output_ring() {
    ring = gearplane_Rgear(gearplane_out);
    wall=2;
    ringR=bearingCenterR-bearingGapR/2; // 2*wall+gear_OD(ring);
    roof=2;
    
    magnet=[0,ringR-0.5,gearZ+pivotThickTotal/2];
    
    difference() {
        union() {
            hull() {
                cylinder(r=ringR,h=gearZ+roof);
                translate(pivot) cylinder(d=pivotCapOD+2*wall,h=pivotRoof);
                translate(magnet) rotate([90,0,0]) cylinder(d=pivotThickTotal-0.1,h=10);
            }
        }
        translate([0,0,-outputZ]) bearing_ball_ring();
        
        output_ring_head();

        // Ring gear in the base
        difference() {
            ring_gear_cut(ring);
            
            // Support material under hex head
            difference() {
                output_ring_head(enlarge=1,extra_head=2*gearZ);
                output_ring_head(enlarge=0,extra_head=2*gearZ);                
            }
        }
        
        // Hole for magnet to be epoxied in
        translate(magnet) rotate([90,0,0]) cylinder(d=5,h=8,center=true);
        
        // cutaway
        //cube([100,100,100]);
    }
}


module bearing_clamp_ring_bolt_locations()
{
    nbolt=6;
    da=360/nbolt;
    for (angle=[0:da:360-1]) rotate([0,0,angle])
        translate([bearingClampR,0,bearingZ+bearingBallR+0.5])
            children();
}
module bearing_clamp_ring_bolts() 
{
    bearing_clamp_ring_bolt_locations()
        screw_3D(M3_cap_screw,thru=gearZ/2,length=2*gearZ);
}

// Cross section of output ring clamp
module bearing_clamp_ring_2D(aroundbolts=3)
{
    difference() {
        hull() {
            // Base circle
            circle(r=bearingCenterR+bearingBallR+3);
            // Bosses around each bolt
            bearing_clamp_ring_bolt_locations()
                circle(r=aroundbolts);
        }
        circle(r=bearingCenterR+bearingGapR/2);
    }
}

// Holds down the bearing balls to the output ring
//   Screws down into the motor/gearbox mount
module bearing_clamp_ring()
{
    difference() {
        translate([0,0,bearingZ])
        linear_extrude(height=gearZ/2,convexity=4)
            bearing_clamp_ring_2D(4);

        bearing_clamp_ring_bolts();
        bearing_ball_ring();
    }
}

module beveled_cylinder(r,h,bevel)
{
    hull() {
        cylinder(r=r-bevel,h=h);
        translate([0,0,bevel])
            cylinder(r=r,h=h-2*bevel);
    }
}

// Adapt from motor up to gearbox, and base of bearing
module motor_gearbox(cutaway=0) {
    ring = gearplane_Rgear(gearplane_in);
    
    wall=2;
    ringOD=2*wall+gear_OD(ring);
    bevel=5;
    
    difference() {
        union() {
            motor_clamp();
            
            hull() {
                cylinder(d=ringOD+2,h=gearZ);
                
                // Connect up to mounting ring bolts
                translate([0,0,gearZ])
                    linear_extrude(height=bearingZ-gearZ,convexity=4)
                        bearing_clamp_ring_2D(3);
                
                // Connect down to motor diameter
                translate([0,0,-bevel])
                    cylinder(d=motor_diameter(motor),h=1);
            }
            
            plate_bolt_full_truss();
        }
        
        bearing_ball_ring();
        bearing_clamp_ring_bolts();
        
        plate_bolt_locations() cylinder(d=0.200*inch,h=10,center=true); // #10 bolt
        
        // carve holes for gears and output ring
        translate([0,0,gearZ-0.01])
            beveled_cylinder(r=bearingCenterR+bearingGapR/2,h=100,bevel=1.5);
        
        motor_3D(motor,clearance=0.2);
        ring_gear_cut(ring);
        
        if (cutaway) cube([100,100,100]);
    }
}

/* Plate: mounting plate to hold to robot */
plateY=-50; // Y level of mounting plate
plateR=70.5; //<- radius of mounting screws around centerline
plateZ=centerPivotZ; //<- Z distance up to pivot point around plate

plate_corner=[0,plateY,bearingZ];
plate_screw=US10_24_pan_screw;
plate_screw_centers=[
    [0,plateY+5,bearingZ],
    [0,plateY+15,bearingZ],
];

module plate_bolt_locations(holes=[-1,+1]) {
    nbolt=8;
    da=360/nbolt;
    translate([0,plateY,plateZ]) rotate([90,0,0])
        for (angle=holes) //<- back 3 bolts
            rotate([0,0,da*angle]) translate([0,-plateR,0])
                children();
}

// The truss is made from several 3D locations
plate_truss_all_spots=[-1,0,+1,2,3];
// Convert spot to 3D location
module plate_truss_spots(i) 
{
    if (i==0) { // centerline
        translate(plate_corner+[0,-8,-3])
            children();
    }
    else if (i<2) {
        plate_bolt_locations(i) translate([0,-8,10]) children();
    }
    else if (i==2) { // base of motor
        translate([0,-motor_diameter(motor)/4,-motor_clampZ])
        rotate([90+35,0,0])
            scale([1,1,1]) children();
    }
    else if (i==3) { // top of motor
        translate([0,-motor_diameter(motor)/4,bearingZ-3])
        rotate([90+60,0,0])
            scale([1,1,1]) children();
    }
}
module plate_truss_set(set) 
{
    hull() {
        for (i=set) plate_truss_spots(i) sphere(d=3,$fn=8);
    }
}

module plate_truss_sets() 
{
    plate_truss_set([-1,2,3]); // left wing
    plate_truss_set([+1,2,3]); // right wing
    plate_truss_set([0,2,3]); // center box
}

// Flat plate on base
module plate_bolt_hull(bolt=screw_head_diameter(plate_screw),shift=0,shrink=0,withmotor=1) {
    bossZ=3;
    boss=bolt+2*bossZ; // bevel out sides
    h=1.5; // thickness of base plate
    hull() {
        translate(plate_corner+[0,0,-boss/2]) rotate([90,0,0])
            scale([1,1,-1]) cylinder(d=boss,h=h,$fn=6);
        plate_bolt_locations() translate([0,shift,0]) 
            scale([1,1,-1]) cylinder(d=boss,h=h,$fn=6);
    }
    // Bosses around each bolt
    plate_bolt_locations() scale([1,1,-1]) cylinder(d1=boss,d2=bolt,h=bossZ);
}

module plate_bolt_full_truss()
{
    difference() {
        intersection() {
            union() {
                //plate_bolt_truss();
                plate_truss_sets();
                plate_bolt_hull(withmotor=0); // base plate
                
                // extra plastic around corner
                hull()
                for (p=plate_screw_centers) translate(p) rotate([180,0,0]) cylinder(d=screw_head_diameter(plate_screw)+2,h=20);
            }
            
            // Trim outer edges and bottom so they're flat
            trimBox=plateR+4;
            translate(centerPivotPoint) rotate([-90,0,0]) 
                translate([-trimBox,-trimBox,plateY]) //cylinder(r=plateR+4,h=1000);
                    cube([2*trimBox,2*trimBox,1000]);
        }
        for (p=plate_screw_centers) translate(p) screw_3D(plate_screw,length=20.1);
    }
}


/* Printable: oriented for 3D printing ****/

shaft_extra=0.05; // extra space around motor shaft (function of print tolerances)

module printable_planets() {   
    stepped_planets(gearplane_in,gearplane_out,axle_hole=gear_ID(gearplane_Pgear(gearplane_out))-4);
}

module printable_sun(enlarge=0) {
    difference() {
        gear_3D(gearplane_Sgear(gearplane_in),enlarge=enlarge);
        motor_3D_shaft(motor,shaft_clearance=shaft_extra-enlarge); 
    }
}
module printable_idler_sun() {
    difference() {
        gear_3D(gearplane_Sgear(gearplane_out));
        motor_3D_shaft(motor,spin=shaft_extra+0.2); 
    }
}

// Castable: fill metal into 3D printed mold
castable_wall=0.75; // wall thickness around molds
castable_col=10; // diameter of central pour 
castable_ht=40; // height of pour (more height == more pressure)

module castable_symmetry()
{
    ncopies=2;
    for (angle=[0:360/ncopies:360-1]) rotate([0,0,angle])
        children();
}

// transform from central column to gear
module cast_gear_xform(s) {
    translate([s,0,s*0.5]) rotate([0,30,0]) rotate([0,0,90]) children();
}

// Castable solid object: sprue, gear, vents, etc.
//   This can be used as a pattern by itself, or make a shell by diffing.
//   "col" is the central pouring column
module castable_solid(enlarge=0) 
{
    e2=2*enlarge;
    translate([0,0,-enlarge]) cylinder(d=castable_col+e2,h=castable_ht);
    
    // Pour funnel
    translate([0,0,castable_ht-enlarge]) scale([1,1,-1])
        cylinder(d1=2*castable_col+e2,d2=castable_col+e2,h=castable_col);
    
    gear=gearplane_Sgear(gearplane_in);
    s=castable_col/2+0.9*gear_OR(gear); // radius to center of as-cast gear
    castable_symmetry() {
        cast_gear_xform(s) printable_sun(enlarge=enlarge);
        
        // Fill spout:
        difference() {
            hull() {
                cylinder(d=castable_col/2+e2,h=2+e2);
                cast_gear_xform(s) difference() {
                    d=gear_ID(gear);
                    cylinder(d=d+e2,h=0.1);
                    // Trim off top half of inlet
                    //translate([0,100+2+enlarge,0]) cube([200,200,200],center=true);
                }
            }
            // Leave motor shaft entrance connected to base
            if (enlarge==0)
            cast_gear_xform(s) scale([1,1,3]) sphere(d=motor_shaft_diameter(motor)+e2,$fn=16);
        }
        
        // Vents on upward-facing gear teeth
        ht=geartype_height(gear_geartype(gear));
        vent=[s*1.6,0,s*0.8+ht];
        vent_OD=3;
        sprue=1.2;
        translate([0,0,-enlarge]) translate(vent) cylinder(d=vent_OD+e2,h=castable_ht-vent[2]);
        for (angle=[0:360/gear_nteeth(gear):360-1])
            if (angle<200 || angle==280) // ==0 || (angle>70 && angle<300))
            hull() {
                cast_gear_xform(s) rotate([0,0,angle]) translate([gear_IR(gear),0,ht])
                    sphere(d=sprue+e2);
                translate(vent) cylinder(d=vent_OD+e2,h=1);
            }
        
        // Plate to stabilize vents
        if (enlarge>0) translate([0,0,-enlarge]) {
            cylinder(d=2*castable_col+e2,h=enlarge);
            hull() {
                cylinder(d=enlarge,h=castable_ht);
                translate([vent[0],0,0]) cylinder(d=enlarge,h=castable_ht);
            }
        }
        // Solid central motor shaft (otherwise fills with uncured goo)
        if (enlarge>0) cast_gear_xform(s) intersection() {
            motor_3D_shaft(motor);
            cylinder($fn=6,h=ht,d=5);
        }
    }
}

// Make a mold for pouring in a low temperature alloy, like pewter or zinc
module castable_shell()
{
    shrinkage=1.015; // scale factor to compensate for post-casting shrinkage
    scale([shrinkage,shrinkage,shrinkage])
    difference() {
        castable_solid(enlarge=castable_wall);
        castable_solid(enlarge=0);

        // cutaway
        //translate([0,100,0]) cube([200,200,200],center=true);
    }
}


module printable_gears(planets=1,sun=1,idler=1) {
    if (planets) 
        printable_planets();
    
    s=gearplane_Rradius(gearplane_in)+2*gearplane_Sradius(gearplane_in);
    
    if (sun)
    for (spare=[0,1]) // make spare motor suns (they break)
        translate([spare*gearplane_Sradius(gearplane_in)*2.5,s,0]) printable_sun();
    
    if (idler)
        translate([0,s+2.5*gearplane_Sradius(gearplane_out),0]) 
            printable_idler_sun();
}

// Output parts
module printable_output() {
    output_ring();
    translate([0,0,bearingZ+gearZ/2]) rotate([180,0,0]) bearing_clamp_ring();
}

module printable_motor_gearbox() {
    difference() {
        translate([0,0,motor_clampZ])
            motor_gearbox();
        
        translate([0,0,-1000]) cube([2000,2000,2000],center=true);
    }
}

// Demo of all working parts
module motor_assembled() {
    #motor_3D(motor);
    motor_gearbox(cutaway=1);
    translate([0,0,outputZ]) output_ring();
    bearing_clamp_ring();
    #bearing_ball_ring();
}

if (0) difference() {
    motor_assembled();
    for (angle=[0,-45]) rotate([0,0,angle])
    color([1,0.4,0.3]) cube([100,100,100]); // big cutaway
}



printable_motor_gearbox();
//printable_output();
//printable_gears();

//castable_part();
//castable_shell();

//motor_assembled();
