/*
  Rock grinder internals: supports, geartrain, endcaps.
*/
include <../AuroraSCAD/motor.scad>;
include <../AuroraSCAD/gear.scad>;
$fs=0.1; $fa=2; //<- fine output
//$fs=0.2; $fa=5; //<- coarse preview

inch=25.4; // file units are mm

wheelZ=300; // total height, from face to face

// General thickness of plastic walls:
wall=2.0;

// Steel bar that supports the non-motor side
barZ = 160; 
barOD=38.4; // 1.5" steel bar
module bar_2D(shrink=0) {
    round=3;
    d=barOD-2*shrink;
    offset(r=+round) offset(r=-round)
        square([barOD,barOD],center=true);
}
module bar_3D(enlarge=0, hollow=0)
{
    linear_extrude(height=barZ) {
        difference() {
            bar_2D(-enlarge);
            if (hollow) bar_2D(0.065*inch);
        }
    }
}

// 6013 bearings support the outer wheel
bearingOD=100; /// Overall outside diameter (mm)
bearingID=65; /// Overall inside diameter (mm)
bearingZ=18;  /// Overall bearing thickness
bearing_clearance=0.1; // permanent press fit
bearing_assembly=0.3; // slide over repeatedly fit

// Z heights of each bearing in the finished wheel (at -z face of bearing)
bearing1Z=3; // fixed side
bearing2Z=wheelZ/2; // center (optional?)
bearingMZ=wheelZ-bearingZ-3; // motor side
bearingNZ=[bearing1Z,bearing2Z,bearingMZ];


// module M0.8 / 32P gears (available in metal versions)
gearZ=10; // Z height of one layer of gears
gear_spaceZ=2.5; // Z height gap between layers (e.g., washers)

clearance=0.15;

//gear_bearingOD=22+clearance; // 608ZZ skate bearing
//gear_bearingZ=7+clearance;
gear_bearingOD=0.5*inch+clearance; // 5/16" needle bearing
gear_bearingZ=5/16*inch+clearance;

gear_shaftOD=8+2*clearance; // space for 5/16" bolt
gear_bearing_ballR=4.5; // metal BB, inside gears

geartype_motor=[ 0.8, gearZ, 20, 0.32, 0.4 ]; // motor shaft
geartype_idler=[ 1.6, gearZ, 20, 0.32, 0.4 ]; // idler plane
geartype_drive=[ 1.6, gearZ, 20, 0.32, 0.4 ]; // final drive plane

gearplane_motor=[geartype_motor, 13,55, 2];

// 44:1 reduction => 250 rpm (AS-BUILT spring 2022)
//gearplane_idler=[geartype_idler, 22,12, 2];
gearplane_drive=[geartype_drive, 12,22, 2];

gearplane_idler=[geartype_idler, 24,10, 2]; 

// 69:1 reduction => 160 rpm 
//gearplane_idler=[geartype_idler, 24,10, 2]; 
//gearplane_drive=[geartype_drive, 10,24, 2];

//gearplane_idler=[geartype_idler, 16,18, 2]; // 22:1 reduction => 450 rpm, in practice runs a little fast
//gearplane_idler=[geartype_idler, 12,22, 2]; // 12:1 reduction => 800 rpm

// Not 100% sure this is the actual ratio, but it's close
echo("Gear reduction: ", 
    gearplane_Pteeth(gearplane_motor)/gearplane_Steeth(gearplane_motor)
   *gearplane_Steeth(gearplane_idler)/gearplane_Pteeth(gearplane_idler)
   *gearplane_ratio_Rfixed(gearplane_drive)
   );

// The orbit radii all need to match to use the same mounting bolts as axles
echo("Orbit radii: ",
    gearplane_Oradius(gearplane_motor),
    gearplane_Oradius(gearplane_idler),
    gearplane_Oradius(gearplane_drive));

driveZ=bearingMZ-gearZ-gear_spaceZ; // Z altitude where drive plane starts
idlerZ=driveZ-gearZ-gear_spaceZ;
motorZ=idlerZ-gearZ-gear_spaceZ;



motor=motortype_3674;
//motor=motortype_750;
motor_faceZ=motorZ-8; //<- leave space for the set screw
motor_mountZ=motor_faceZ+4; //<- leave meat for mounting bolts
motor_backZ=barZ-20; //<- bolts tap into plastic
//motor_backZ=motor_mountZ-30; // bottom of motor mount, still leaves space for steel frame?

// Support bolts go through plates on the outside
boltN=4;
boltR=gearplane_Oradius(gearplane_motor); // 27.2mm
echo("boltR=",boltR);
bolt_type=US_5_16_hex; // 5/16" bolts (basically 8mm)
bolt_length=6*inch;
module bolt_centers(step=1) {
    da=360/boltN;
    for (angle=[da/2:da*step:360-1]) rotate([0,0,angle])
        translate([boltR,0,0]) children();
}
// Number of face segments (welded plates)
faceN=7;
faceR=58.5;
face_plate=2*inch;
face_plate_thick=1/8*inch;

/* Initial testing: 
    tipR==90 sticks out quite a ways, and hangs up in hand swing tests.
    tipR==82 doesn't stick out much, but still cuts well.
    R==90 with a crossbar: cuts very nicely when swung fast.
*/
tooth_tipR=90;

tooth_stepA=360/faceN*1.5; // angular distance between adjacent teeth
toothN=28; // == 4 teeth per plate


// Make children at the bottom left corner of each face plate.
module face_plates() {
    da=360/faceN;
    for (f=[da/2:da:360-1]) rotate([0,0,f])
        translate([faceR*cos(da/2),-face_plate/2,0])
            children();
}
// 2D outlines of the face plates
module face_plates_2D() {
    face_plates() square([face_plate_thick,face_plate]);
}

// 3D geometry of the steel face plates
module face_plates_3D() {
    face_plates() cube([face_plate_thick,face_plate,wheelZ]);
}

// Translate from wheel origin to the tip of this tooth.
//    The tooth lies along the -X direction
module tooth_number(toothI)
{
    angle=toothI*tooth_stepA;
    height=(toothI+0.5)*wheelZ/toothN;
    rotate([0,0,angle])
        translate([tooth_tipR,0,height])
            rotate([0,0,180])
                children();
}

// Cross section of one tooth
module tooth_2D()
{
    len=tooth_tipR-faceR*cos(30); // -face_plate_thick-0.4;
    thick=8;    
    polygon([
        [0.25*thick,thick],
        [0,0],
        [len,0],
        [1.0*len,0.5*len]
    ]);
}

module teeth_3D() 
{
    for (i=[0:toothN-1])
        tooth_number(i)
            linear_extrude(height=4,center=true)
                tooth_2D();
}

/*
if (0) { // 3D teeth
    #circle(r=tooth_tipR);
    face_plates_3D();
    teeth_3D();
}
else { // 2D tooth shapes
    difference() {
        union() {
            tooth_number(0) tooth_2D();
            tooth_number(1) tooth_2D();
        }
        hull() face_plates_2D();
    }
}
*/

// Basic 3D shape of bearing
module bearing_basic() {
    difference() {
        cylinder(d=bearingOD+bearing_clearance,h=bearingZ);
        cylinder(d=bearingID-bearing_clearance,h=3*bearingZ,center=true);
    }
}

// Supports interior of bearing, with optional bevel on top
module bearing_inside_support(bevel=3,extra_plate=0) 
{
    d=bearingID-bearing_clearance;
    z=bearingZ;
    
    // Block of material below bearing
    cylinder(d=d,h=z+0.01);
    
    // Beveled support above bearing
    if (bevel) translate([0,0,bearingZ]) 
        cylinder(d1=d+2*extra_plate+2*bevel,d2=d+2*extra_plate,h=bevel);
}

// Cut space for the gear axle
module gear_axle_cut(gear)
{
    cylinder(d=gear_shaftOD,h=100,center=true);
}

// Cut a bearing into this gear if there's room.
//   Any support material can be added as a child node.
module gear_bearing_cut(gear) {
    if (0)
    if (gear_ID(gear)>2+gear_bearingOD)
    difference() {
        translate([0,0,-0.01])
            cylinder(d=gear_bearingOD,h=gear_bearingZ);
        children();
    }
}

// Cut lightening holes into a gear
module gear_lighten_holes(gearLow,gearHigh=0)
{
    h=gear_height(gearLow)+0.1;
    
    gapI=(gearHigh?gear_OR(gearHigh):gear_bearingOD/2+1);
    //gapI=gear_bearingOD/2+1.5;
    gapO=gear_IR(gearLow)-1;
    gapR=(gapI+gapO)/2;
    lightenOD=(gapO-gapI);
    
    if (1) // donut scooped out (lower mass for metal gears)
    if (lightenOD>2) {
        rotate_extrude() {
            translate([gapR,h+1])
                circle(d=gapO-gapI);
        }
        // bubble escape hole
        for (angle=[0:120:360-1]) rotate([0,0,angle])
            translate([gapR,0,-1]) cylinder(d=2,h=h+2);
    }
    
    if (0) // ring of spheres
    if (lightenOD>3) {
        count=round(gapR*2*PI/(lightenOD+3));
        for (a=[0:360/count:360-1]) rotate([0,0,a])
            translate([gapR,0,-0.01])
            {
                r=lightenOD/2;
                //cylinder(r=r,h=h,$fn=16); // thru
                //translate([0,0,h]) scale([1,1,-1])
                //    cylinder(r1=r,r2=0.01,h=r); // bevel
                translate([0,0,h]) rotate([90,0,0]) sphere(r=r); // sphere
                if (r>3) cylinder(d=3,h=h); // drain hole
            } 
    }        
}

// Draw a stepped gear between these two gear sizes, with this much space between them.
//   Puts in structural parts to hold gear in place.
module stepped_gear(gearLow,space,gearHigh,bevelLow=1,support=1)
{
    overlap=1;
    difference() {
        union() {
            gear_3D(gearLow,bevel=bevelLow);
            translate([0,0,gear_height(gearLow)-overlap-0.01])
            {
                // taper up to the high gear:
                taperLow=min(gear_OD(gearHigh)+1,gear_ID(gearLow));
                translate([0,0,overlap])
                cylinder(d1=taperLow,d2=gear_ID(gearHigh),
                    h=space);
                
                gear_3D(gearHigh,height=overlap+space+gear_height(gearHigh));
            }
        }
        
        gear_axle_cut(gearLow);
        
        // Consider cutting in lightening holes
        gear_lighten_holes(gearLow,gearHigh);
        
        // Consider cutting in low bearing:
        gear_bearing_cut(gearLow)
        // leave in support material around axle hole
            if (support) cylinder(d=gear_shaftOD+1.5,h=gear_bearingZ-0.3);
        
        // Consider cutting in high bearing:
        if (gear_ID(gearHigh)>3+gear_bearingOD) {
            translate([0,0,gear_height(gearLow)+space+gear_height(gearHigh)-gear_bearingZ+0.01])
                cylinder(d=gear_bearingOD,h=gear_bearingZ);
        }
    }
}

// Printed locations of various gears:
gear_print_motor=[0,0,0];
gear_print_sun=[30,+50,0];
gear_print_drive=[0,-50,0];

module motor_planets(bevelLow) {
    gearplane_planets(gearplane_motor)
        translate([0,0,motorZ])
            stepped_gear(gearplane_Pgear(gearplane_motor),
                gear_spaceZ,
                gearplane_Pgear(gearplane_idler),
                bevelLow);
}
module printable_motor_planets(bevelLow) {
    translate(gear_print_motor+[0,0,-motorZ]) motor_planets(bevelLow);
}

// Add holes for music wire pins, to transmit shear forces up to small gear
module through_pins()
{
    difference() {
        children();
        
        OD=1.0; // 0.030" pilot hole (drill to size)
        if (0) for (a=[0:360/4:360-1]) rotate([0,0,a])
            translate([gear_shaftOD/2+1+OD/2,0,0])
                cylinder(d=OD,h=50);
    }
}

module idler_sun(bevelLow,support) {
    translate([0,0,idlerZ])
    through_pins() 
        stepped_gear(gearplane_Sgear(gearplane_idler),
            gear_spaceZ,
            gearplane_Sgear(gearplane_drive),
            bevelLow,support);
}
module printable_idler_sun(bevelLow,support=1) {
    translate(gear_print_sun+[0,0,-idlerZ]) idler_sun(bevelLow,support);
}

module drive_planets(bevelLow) {
    gearplane_planets(gearplane_drive)
        translate([0,0,driveZ])
        difference() {
            gear=gearplane_Pgear(gearplane_drive);
            gear_3D(gear,bevel=bevelLow,clearance=clearance);
            gear_axle_cut(gear);
            gear_bearing_cut(gear);
            gear_lighten_holes(gear);
        }
}
module printable_drive_planets(bevelLow) {
    //rotate([180,0,0])
    translate(gear_print_drive+[0,0,-driveZ]) 
        drive_planets(bevelLow);
}

module printable_gears(bevelLow=1,support=1) {
    printable_motor_planets(bevelLow);
    printable_idler_sun(bevelLow,support);
    printable_drive_planets(bevelLow);
}

// gear container is for filling with castable silicone.
//    gearHigh may be missing, like for single idler gears.
module printable_gear_container(shrink,shell,gearLow,gearHigh)
{
    gd=gear_OD(gearLow);
    gap=3; // distance from gear to outside of container
    od=gd+2*gap;
    h=gearZ+gap;
    top=gearHigh?2*gearZ+gear_spaceZ+gap:h;
    difference() {
        union() {
            dLow=od-2*shrink;
            hLow=h-shrink;
            dHigh=gear_OD(gearHigh)+2*gap-2*shrink;
            cylinder(d=dLow,h=hLow);
            if (gearHigh) {
                cylinder(d=dHigh,
                    h=top-shrink);
                bevel=2;
                translate([0,0,hLow-0.01]) cylinder(d1=dHigh+2*bevel,d2=dHigh,h=bevel);
            }
        }
        if (shrink>0 && shrink<2) { // cut little features to index casting
            tower=2.5;
            cylinder(d=tower,h=100);
            bevel=1;
            for (flip=[-1,1]) translate([0,0,flip<0?top-shrink:0]) scale([1,1,flip])
                cylinder(d1=tower+2*bevel,d2=tower,h=bevel);
        }
        // core out the central tower
        if (!shell)
        translate([0,0,gap]) cylinder(d=6,h=100);
        if (shell && shrink) { 
            // leave a stand to support the gear
            translate([0,0,top])
            intersection() {
                union() {
                    for (angle=[0,90]) rotate([0,0,angle])
                        cube([12,1,20],center=true);
                }
                scale([1,1,-1]) union() {
                    cylinder(d=12,h=gap); // base
                    cylinder(d=gear_shaftOD-0.3,h=20);
                }
            }
        }
    }
}

module printable_gear_containers(shrink=0,shell=0)
{
    translate(gear_print_motor)
    gearplane_planets(gearplane_motor)
    printable_gear_container(shrink,shell,
        gearplane_Pgear(gearplane_motor),
        gearplane_Pgear(gearplane_idler));
    
    translate(gear_print_sun)
    printable_gear_container(shrink,shell,
        gearplane_Sgear(gearplane_idler),
        gearplane_Sgear(gearplane_drive));

    translate(gear_print_drive)
    gearplane_planets(gearplane_drive)
    printable_gear_container(shrink,shell,
        gearplane_Pgear(gearplane_drive));
    
}

// For making silicone or alginate castings
module castable_gears(cups=0,gears=0,shells=0) {
    shrinkage=1.0; // no shrinkage allowance
    //shrinkage=1.015; // 1.5% for zinc
    scale([shrinkage,shrinkage,shrinkage])
    {
        intersection() {
            union()
            {
                if (cups) // pour directly into these
                    difference() {
                        printable_gear_containers(3);
                        translate([0,0,-0.01])
                            printable_gears(bevelLow=1);
                    }
                
                if (gears) // gears themselves (casting pattern)
                    printable_gears(bevelLow=1);
                
                if (shells) // thin-wall shells for casting gears
                   difference() {
                      printable_gear_containers(0,1);
                      translate([0,0,-0.01])
                       printable_gear_containers(1,1);
                   }
            }
            translate([1000,0,0]) cube([2000,2000,2000],center=true); // one side only
        }
        // Pour spout
        if (0)
        translate([-10,0,0]) {
            d=gear_shaftOD-0.3;
            h=30;
            cylinder(d1=2.5*d,d2=d,h=1.5*d); // taper
            cylinder(d=d,h=h); // inside hole
            cylinder(d=d+4,h=h-10); // outside hole
        }
    }
}

/*
translate([0,0,driveZ]) gearplane_2D(gearplane_drive);
translate([0,0,idlerZ]) gearplane_2D(gearplane_idler);
translate([0,0,motorZ]) gearplane_2D(gearplane_motor);
*/

module bolts_motorside(extra_R=0,extra_tip=0)
{
    bolt_centers() translate([0,0,wheelZ]) 
        screw_3D(bolt_type,clearance=0.2+extra_R,length=bolt_length+extra_tip,thru=bolt_length-inch);
}   

// Need enough wiggle room to slide over the welded face plates
bearing_mount_wiggle=0.3;

// Holds the outside of the bearings to the inside of the face plates
module bearing_mount(floor=1.0,extra_wiggle=0.3) {
    difference() {
        r=faceR-bearing_mount_wiggle-extra_wiggle;
        clip=1.5; // rounded corners (stay off welds, leave gap for dust to escape)
        round=4;
        linear_extrude(height=floor+bearingZ-0.01)
            offset(r=+round) offset(r=-round)
            intersection() {
                circle(r=r,$fn=faceN); // poly sides
                circle(r=r-clip); 
            }
        
        // Pocket for bearing
        translate([0,0,floor])
            cylinder(d=bearingOD+0.2,h=bearingZ+0.01);
        
        // Thru hole
        cylinder(d=bearingID+10,h=3*bearingZ,center=true);
            
        // M3 holes for pulling / seal mounting / etc
        for (angle=[0:360/faceN:360-1]) rotate([0,0,angle])
            translate([(faceR+bearingOD/2)/2-1,0,floor+3])
                cylinder(d=2.5,h=100);
    }
}

// Drive ring gear and top bearing mount
module bearing_mount_ring_gear() {
    floor = gearZ+gear_spaceZ;
    difference() {
        bearing_mount(floor,extra_wiggle=0.0); //<- tighter fit for drive ring
        
        // carve out gear
        translate([0,0,-0.01])
        gear_3D(gearplane_Rgear(gearplane_drive),
            height=floor+0.02,bevel=0,
            clearance=-0.2);
    }
}

// Welding jig to assemble face plates together
module face_plate_jig() {
    difference() {
        union() {
            floor=1.5;
            wall=1.5;
            upright=8;
            clearance=0.2;
            
            cylinder(r=faceR,$fn=faceN,h=floor);
            
            linear_extrude(height=floor) hull() offset(r=wall+clearance) face_plates_2D();
            
            linear_extrude(height=upright,convexity=2) difference() {
                offset(r=wall+clearance) face_plates_2D();
                offset(r=clearance) face_plates_2D();
            }
        }
        
        // Carve hole in middle
        cylinder(d=bearingOD+2,h=20,center=true);
    }
}

// Clearance for motor electrical connections and back bolts
module motor_electrical(motor)
{
    Zinsert=[0,-25]; // slot to allow motor to be slid inside
    translate([0,0,-motor_length(motor)]) {
        elecX=21;
        elecZ=11;
        elecY=35;
        hull() for(z=Zinsert)
            translate([0,elecY/2,z+elecZ/2]) cube([elecX,elecY,elecZ],center=true);
        
        screwNub=8;
        for (angle=[0:120:360-1]) rotate([0,0,angle]) 
            hull() for(z=Zinsert)
            translate([0,-motor_diameter(motor)/2,screwNub/2+z])
                sphere($fn=12,d=screwNub);
    }
}

// Sits above gears and caps the top end
module end_mount_top() {
    bevel=5; // flare bottom of uprights
    difference() {
        union() {
            translate([0,0,bearingMZ]) 
                bearing_inside_support(extra_plate=10); //<- dust shield
            
            intersection() {
                cylinder(d=bearingID-bearing_assembly,h=1000); //<- everything needs to fit through bearing
                
                union() {
                    // Tubes to set gearplane Z height
                    rotate([0,0,90]) bolt_centers(2) 
                    {
                        d=screw_diameter(bolt_type)+2*wall;
                        translate([0,0,motorZ])
                            cylinder(d=d,h=bearingMZ-motorZ);
                        translate([0,0,bearingMZ]) scale([1,1,-1])
                            cylinder(d1=d+bevel,d2=d,h=bevel);
                    }
                }
            }
        }
        bolts_motorside(0,25);
        
        // Threaded holes, for pulling the end plate
        threadR=bearingID/2-10;
        for (x=[-1,+1]) translate([x*threadR,0,bearingMZ+5]) 
            cylinder(d=1/4*inch,h=25);
        
        /*
        // Lightening holes (just to save plastic)
        round=3;
        translate([0,0,bearingMZ-0.1]) linear_extrude(height=bearingZ)
        offset(r=+round) offset(r=-round)
        difference() {
            circle(d=bearingID-2*wall);
            bolt_centers() circle(d=8+2*bevel);
            circle(d=15);
            for (a=[45:90:360-1]) rotate([0,0,a]) square([bearingID,wall],center=true);
        }
        */
        
        // Center idler axle bolt
        cylinder(d=gear_shaftOD,h=1000);
        translate([0,0,bearingMZ+bearingZ-6]) cylinder($fn=6,d=1/2*inch/cos(30)+0.2,h=20);
    }
}

// Sits below shaft and caps the bottom end
module end_mount_bottom() {
    difference() {
        bearing_inside_support();
        bar_3D(enlarge=0.2); 
    }
}

module end_mount_flip(bearing_base=0) {
    translate([0,0,bearingZ+3])
    rotate([180,0,0])
    translate([0,0,-bearing_base])
        children();
}

waterjacket_wall=1; //<- SLA print, can be watertight while small.
waterjacket_motorOD=motor_diameter(motor)+0.2; // needs to slide over motor easily
waterjacket_ringOD=42.3; // #26 buna-N O-ring
waterjacketOD=waterjacket_ringOD+2*waterjacket_wall; //<- add meat behind O-rings
waterjacket_hoseOD=1/4*inch; //<- interference fit on 1/4" OD tubing?
waterjacket_hoseZ=25; //<- good overlap with hose to minimize leaks
waterjacket_startZ=bearing2Z+bearingZ+4;
waterjacket_endZ=motor_faceZ-12;
waterjacket_round=2.5;

module round_cylinder(round,d,h)
{
    minkowski() {
        sphere(r=round,$fn=16);
        translate([0,0,round]) cylinder(d=d-2*round,h=h-2*round);
    }
}

// Basic solid outline of waterjacket
module waterjacket_clear(shrink=0) {
    translate([0,0,waterjacket_startZ])
        round_cylinder(round=waterjacket_round, d=waterjacketOD-2*shrink, 
            h=waterjacket_endZ-waterjacket_startZ-shrink);    
}



// 2D rotate_extrude cross section of waterjacket
module waterjacket_2D()
{
    // outside walls
    offset(r=+waterjacket_round) offset(r=-waterjacket_round) 
    translate([0,waterjacket_startZ])
        square([waterjacketOD/2,waterjacket_endZ-waterjacket_startZ]);
    
}

module waterjacket_inside_2D() {
    wall=waterjacket_wall;
    motorOD=motor_diameter(motor);

    jacketIR=motorOD/2+0.5; // insert motor clearance
    jacketOR=waterjacketOD/2; 

    lo=waterjacket_startZ; // start Z
    hi=waterjacket_endZ;

    ringOR=waterjacket_ringOD/2;
    ringD=3.5; // diameter of O-ring rubber, plus clearance to insert
    ringR=ringD/2;
    ringZ=[lo+wall+ringR, hi-wall-ringR];
    ringCR=ringOR-ringR; // centerline of O-rings
    
    coolantOD=waterjacket_ringOD;
    coolantZlo=lo+wall+ringD+wall;
    coolantZhi=hi-wall-ringD-wall;
    coolantRound=ringR;
    
    // space for motor
    square([jacketIR,1000]);
    
    // space for coolant
    offset(r=+ringR) offset(r=-ringR) 
    translate([0,coolantZlo])
        square([coolantOD/2,coolantZhi-coolantZlo]);
    
    // space for O rings
    for (z=ringZ) hull() for (insert=[-10,0]) 
        translate([ringCR+insert,z]) circle(d=ringD);
}

waterjacket_pipe_OD=1/4*inch+0.2;
waterjacket_pipeX=0.75+waterjacket_pipe_OD/2;
waterjacket_pipeY=-waterjacket_ringOD/2-0.5-waterjacket_pipe_OD/2;
module waterjacket_pipes(enlarge=0,longer=0)
{
    for (side=[-1,+1]) scale([side,1,1])
        translate([waterjacket_pipeX,waterjacket_pipeY,waterjacket_startZ-longer])
        {
            d=waterjacket_pipe_OD+2*enlarge;
            h=25+longer;
            
            // Tubing slides into this portion
            cylinder(d=d,h=h); 
            
            // Merges with the jacket here
            translate([0,0,h+longer]) hull() {
                sphere(d=d);
                translate([3,3+waterjacket_pipe_OD,15])
                    sphere(d=d+enlarge);
            }
            
        }
}

// SLA print, holds 1/4" hoses and #26 O-rings to cool the motor.
//   Probably filled with oil, not water, to reduce impact of freezing/leaks.
module motor_waterjacket() {
    difference() {
        union() {
            rotate_extrude(convexity=4)
                waterjacket_2D();
            
            waterjacket_pipes(waterjacket_wall);
        }
        
        // Inside of jacket
        difference() {
            rotate_extrude(convexity=4)
                waterjacket_inside_2D();
            
            // Plate dividing the input from output flows
            OringZ=4.5;
            translate([0,-waterjacketOD/2,(waterjacket_startZ+waterjacket_endZ)/2])
                cube([waterjacket_wall,8,waterjacket_endZ-waterjacket_startZ-2*OringZ],center=true);
        }
        
        // Inside of pipes
        waterjacket_pipes(0);
    }
}
//#waterjacket();

// Holds motor mount onto steel bar, using #10-32 or 5mm
module motor_mount_bolts(enlarge=0.0,dzs=[0]) {
    translate([0,0,bearing2Z-5])
        hull() for (dz=dzs) translate([0,0,dz])
        rotate([0,90,0])
            cylinder(d=5+2*enlarge,h=barOD+4*wall-0.001*enlarge,center=true);
}

/* Holds motor, waterjacket, and gear bolts torque into it (tapped)
    Assembly order:
        - Tap 3D printed motor_mount
        - Weld 5/16 coupling nuts (de-zinc'd) onto steel bar
        - Grind back coupling nuts so they clear bearing ID
        - Slide in water jacket (with O-rings) in +Y direction
        - Slide in motor (with 13 tooth pinion) in +Z direction
        - Slide middle bearing (with mount) over motor mount
        - Slide motor mount assembly over the steel bar
        - Hook up motor wires and cooling tubes
        - Assemble the 
*/
module motor_mount() {
    maxOD=bearingID;
    round=8;
    difference() {
        union() {
            translate([0,0,bearing2Z])
            linear_extrude(height=motorZ-bearing2Z,convexity=6)
                offset(r=-round) offset(r=+round) {
                    circle(d=motor_diameter(motor)+3*wall);
                    bolt_centers() circle(d=screw_diameter(bolt_type)+2*wall);
                }
            
            // Support for bearing 2Z
            translate([0,0,bearing2Z]) 
                bearing_inside_support();
            
            // X-bracing to hold motor to bar
            intersection() {
                thick=4;
                dx=boltR*0.707;
                cylinder(d=maxOD,h=wheelZ); // rounded outside profile
                
                rotate([90,0,90]) // tilt up along Z
                linear_extrude(height=bearingID,center=true,convexity=4)
                offset(r=-thick) offset(r=+thick)
                for (side=[-1,+1]) hull() {
                    translate([+dx*side,motor_faceZ]) circle(d=thick);
                    translate([-dx*side,bearing2Z+bearingZ]) circle(d=thick);
                }
            }
            
            
            // Bolt this mount to the steel bar
            motor_mount_bolts(4*wall,dzs=[0,10]);
        }
        motor_mount_bolts();
        
        // Trim back so bearing fits on the end
        difference() {
            cylinder(d=bearingOD,h=bearing2Z+bearingZ);
            cylinder(d=bearingID-bearing_assembly,h=wheelZ);
        }
        
        // Lighten / vent holes
        translate([0,0,(motor_faceZ+motor_backZ)/2])
            for (r=[0,90]) rotate([0,0,r])
                scale([1,1,2]) rotate([90,0,0])
                    cylinder(d=30,h=42,center=true);
        
        // Space to slide in water jacket
        hull() for (y=[0,-50]) translate([0,y,0])
            waterjacket_clear(-0.5);
        waterjacket_pipes(0.5,50);
            
        // M3 motor mounting bolts 
        translate([0,0,motor_faceZ]) {
            bolt_floor=4; //< Z plastic under motor bolt heads
            motor_3D(motor,clearance=0.5);
            motor_electrical(motor);
            translate([0,0,bolt_floor]) rotate([0,0,30]) motor_bolts(motor,web=0.35);
            cylinder(d=16,h=20); // clearance for the sprocket
            translate([0,0,bolt_floor+4]) cube([150,8,8],center=true); // channel for tightening sprocket set screw
        }
        
        // Thru bolts (final assembly)
        bolts_motorside(0,25);
        
        bolt_centers(1) translate([0,0,motor_backZ-0.01])
            rotate([0,0,30])
                cylinder($fn=6,d=1/2*inch/cos(30) + 1,h=20);
        
        // Space to insert end of support bar
        difference() {
            bar_3D(enlarge=0.2); 
            
            // Add back plastic around bolts (so they tap in)
            translate([0,0,motor_backZ])
            linear_extrude(height=motorZ-motor_backZ)
                bolt_centers() circle(d=screw_diameter(bolt_type)+2*wall);
        }
    }
}
module printable_motor_mount()
{
    rotate([180,0,0]) translate([0,0,-motorZ]) motor_mount();
}

module illustrate_parts(explode=0)
{
    #bar_3D();
    #translate([0,0,motor_faceZ]) motor_3D(motor);

    //#for (z=bearingNZ) translate([0,0,z]) bearing_basic();
    translate([0,0,explode*1.0]) #bolts_motorside();
    //#face_plates_3D();
    
    translate([0,0,explode*1.0]) end_mount_top();
    end_mount_flip() end_mount_bottom();
    motor_mount();
    motor_waterjacket();
    rotate([0,0,45]) {
        translate([0,0,explode*0.2]) motor_planets();
        translate([0,0,explode*0.4]) idler_sun();
        translate([0,0,explode*0.6]) drive_planets();
    }
    translate([0,0,bearing1Z]) bearing_mount(extra_wiggle=0);
    translate([0,0,bearing2Z]) bearing_mount();
    translate([0,0,explode*0.9]) translate([0,0,bearingMZ-gearZ-gear_spaceZ]) bearing_mount_ring_gear();
}
if (0) difference() {
    illustrate_parts(); // explode=50);
    if (0) rotate([0,0,45])
        cube([1000,1000,1000]); // cutaway
}

//printable_motor_mount();
//motor_waterjacket();
//translate([1.1*bearingOD,0,0]) end_mount_flip(bearingMZ) end_mount_top();

//intersection() { printable_gears(); translate([1000,0,0]) cube([2000,2000,2000],center=true); }
//printable_idler_sun(1,1);
//printable_motor_planets();
//printable_drive_planets();
//castable_gears(cups=1);
castable_gears(shells=1);

//bearing_mount(extra_wiggle=0); // endcap
//bearing_mount(); // middle
//end_mount_flip() end_mount_bottom();
//bearing_mount_ring_gear(); // top ring gear


//face_plate_jig();
