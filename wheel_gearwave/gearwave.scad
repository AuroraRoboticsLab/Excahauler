/*
  Strain wave style stepped planetary geartrain:
     Fits over a 1 inch steel tube, and mounts a fast (approx 10K rpm) brushless
     to a slow (approx 100rpm) wheel hub.
*/
include <../AuroraSCAD/motor.scad>;
include <../AuroraSCAD/gear.scad>;
include <../AuroraSCAD/bearing.scad>;
$fs=0.1; $fa=2; //<- fine output
//$fs=0.2; $fa=5; //<- coarse preview

inch=25.4; // file units are mm

// Overall height of assembly
wheelZ=250;

// General thickness of plastic walls:
wall=2.5;

// Steel bar that supports the non-motor side
barZ = 160; 
barOD=1.0*inch+0.5; // 1.0" steel bar (plus space to slide on)
module bar_2D(shrink=0) {
    round=3;
    d=barOD-2*shrink;
    offset(r=+round) offset(r=-round)
        square([barOD,barOD],center=true);
}
module bar_3D(enlarge=0, hollow=0)
{
    linear_extrude(height=barZ,center=true) {
        difference() {
            bar_2D(-enlarge);
            if (hollow) bar_2D(0.065*inch);
        }
    }
}

thruboltOD=8; // 5/16" bolts
thruboltR=barOD/2+0.25*inch; // 1/2" nuts welded to steel bar

// Planet carrier runs on these bearings
carrier_bearing = bearing_6808;

// 6013 bearings support the outer wheel
bearing_clearance=0.1; // permanent press fit
bearing_assembly=0.3; // slide over repeatedly fit

// Z heights of each bearing in the finished wheel (at -z face of bearing)
bearing1Z=3; // fixed side
bearingMZ=wheelZ-bearingZ-3; // motor side
bearingNZ=[bearing1Z,bearingMZ];


// module M0.8 / 32P gears (available in metal versions)
gearZ=10; // Z height of one layer of gears (including gaps)
gear_spaceZ=1.0; // Z height gap between layers (e.g., washers)

clearance=0.15;

//gear_bearingOD=22+clearance; // 608ZZ skate bearing
//gear_bearingZ=7+clearance;
gear_bearingOD=0.5*inch+clearance; // 5/16" needle bearing
gear_bearingZ=5/16*inch+clearance;

gear_shaftOD=8+2*clearance; // space for 5/16" bolt
gear_bearing_ballR=4.5; // metal BB, inside gears

nplanet=4;
nteeth_planet=12; // teeth on travelling planet gears (determines spin dia)

nteeth_fixed=48; // fixed teeth on output ring gear (determines OD)

nteeth_motor=13; // teeth on motor pinion gear
nteeth_carrier=108; // teeth on planet carrier, driven by motor


geartype_motor=[ 0.8, gearZ, 20, 0.32, 0.4 ]; // motor shaft (purchased pinion)
gearplane_motor=[geartype_motor, nteeth_carrier, nteeth_motor, 1];

output_angle=14.5; // 20; // pressure angle of output gears
geartype_fixed=[ 2.0, gearZ, output_angle, 0.25, 0.35 ]; // fixed gear plane
gearplane_fixed=[geartype_fixed, nteeth_fixed-2*nteeth_planet,nteeth_planet, nplanet];

gearplane_drive=gearplane_stepped(gearplane_fixed,-1);

// Size of motor, with water jacket
jacketedmotorOD=2.0*inch;


// Size of main output bearing
main_bearing_OD=85;
main_bearing_ID=65;
main_bearingZ=10;



// Not 100% sure this is the actual ratio, but it's close
echo("Gear reduction: ", 
    gearplane_Steeth(gearplane_motor)/gearplane_Pteeth(gearplane_motor)
    *nteeth_fixed/nplanet);

// Doublecheck that the carrier will fit inside: OD < IDs
echo("Carrier OD: ",gear_OD(gearplane_Sgear(gearplane_motor)));
echo("Fixed ID: ",gear_ID(gearplane_Rgear(gearplane_fixed)));
echo("Drive ID: ",gear_ID(gearplane_Rgear(gearplane_drive)));

carrierOD=1+gear_OD(gearplane_Sgear(gearplane_motor)); // hole for carrier
carrierID=-0.5+gear_ID(gearplane_Sgear(gearplane_motor)); // carrier body size

// Carrier spins on a bushing, but spaced like a 6807 bearing: 35mm x 47mm x 7mm
carrier_bearing_OD=47.5;
carrier_bearing_ID=47;

axleOD=8; // 5/16" or 8mm tube axles
axle_boss=12; // surrounds axle, planets ride on top
axle_support=2; // meat under each axle
axle_bearingOD=10; // babbitt bushing
axle_bearingZ=8; 

closeZ=4*gearZ; // Z height of top of gearbox space
supportZ=3*gearZ; // Z height of top support carrier
driveZ=2*gearZ; // Z height of drive gear teeth
driveR=gear_OR(gearplane_Rgear(gearplane_drive))+wall;

splitZ=driveZ-1; // top of fixed gear
wiperZ=splitZ-5; // dust wiping area
wiperR=gear_OR(gearplane_Rgear(gearplane_fixed))+wall;
fixedZ=gearZ; // Z height of fixed gear teeth
motorZ=0; // Z height of top face where motor spur emerges, bottom support carrier

encoderR=(carrierOD+carrier_bearing_OD)/2/2; // centerline radius of encoders
encoder_ht=4.0;
encoderZ=motorZ-1.5-encoder_ht; // bottom of encoder board channel
encoder_wid=0.35*inch; // size of encoder board
encoder_len=50;
encoder_angle=30; // angle away from motor

// CAM: cut axle shafts this long
echo("Axle length: ",closeZ-fixedZ-2*axle_support);


motor=motortype_3674; // hefty Turnigy motor style
//motor=motortype_750;
motor_faceZ=motorZ-10; // Face of motor 

// Centerline radius of motor
motor_mountR=gearplane_Oradius(gearplane_motor); // must be at least barOD/2 + jacketedmotorOD/2

ring_clearance=0.1; //<- as-printed gap



// Space for motor and mounting bolts
module motor_space()
{
    // M3 motor mounting bolts 
    translate([motor_mountR,0,motor_faceZ]) {
        bolt_floor=5; //< Z plastic under motor bolt heads (for M3x8 socket caps)
        spur_height=20; // height of spur gear on motor shaft (plus a little clearance)
        spur_OD=15;
        
        motor_3D(motor,clearance=0.5);
        //motor_electrical(motor);
        translate([0,0,bolt_floor]) difference() {
            rotate([0,0,30]) motor_bolts(motor,web=0.0,extra_head=25);
            // don't cut middle bolts, they hit the fixed ring gear
            cube([12,100,100],center=true);
        }
        cylinder(d=spur_OD,h=spur_height); // clearance for the spur gear
        translate([10,0,bolt_floor+4]) cube([25,8,8],center=true); // channel for tightening sprocket set screw
    }
}

// Teeth to push dust out of wiper ring
module gearwave_fixed_wiperteeth()
{
    translate([0,0,splitZ]) 
    intersection() {
        scale([1,1,-1])
            cylinder(r=wiperR+0.8,h=splitZ-fixedZ);  
        
        union() {
            for (angle=[0:10:360-1]) rotate([0,0,angle])
                rotate([45,0,0]) cube([2*wiperR+2,8,8],center=true);
        }
    }
}

// Hole for encoder board to read passing magnets on bottom carrier. 
//  Can be assembled on 
module gearwave_fixed_encoderspace()
{
    for (side=[-1,+1]) scale([1,side,1]) 
    rotate([0,0,encoder_angle])
    translate([encoderR,0,encoderZ]) 
    {
        translate([-encoder_wid/2,-encoder_wid/2,0])
            cube([encoder_len,encoder_wid,encoder_ht]);
    }
}

// 3D printing support under the fixed base
module gearwave_fixed_support() 
{
    // Support under the motor ring (high slope area)
    translate([0,0,motor_faceZ])
    if (support) {
        difference() {
            cylinder(d=carrierOD+support,h=motorZ-motor_faceZ);
            translate([0,0,-1])
              cylinder(d=carrierOD,h=motorZ-motor_faceZ+2);                
        }
        for (cross=[-45,+45,+90]) rotate([0,0,cross]) translate([0,0,(motorZ-motor_faceZ)/2])
            cube([carrierOD,support*0.5,motorZ-motor_faceZ],center=true);
    }
}

// Bottom, fixed part of gearwave
module gearwave_fixed(support=0) {
    difference() {
        union() {
            hull() {
                // Extra around motor (mostly for easier printing)
                
                // Surround motor and bar
                translate([0,0,motor_faceZ]) {
                    // Extra meat to keep printed slopes reasonable
                    cylinder(d=carrierOD+2*wall-(motorZ-motor_faceZ),h=motorZ-motor_faceZ-1);
                    
                    translate([motor_mountR,0,0]) cylinder(d=motor_diameter(motor),h=fixedZ-motor_faceZ-2);
                    linear_extrude(height=fixedZ-motor_faceZ) offset(r=2*wall) bar_2D();
                    //cylinder(d=0.7*gear_OD(gearplane_Rgear(gearplane_fixed)),h=1);
                }
                
                // Surround bottom carrier
                translate([0,0,motorZ-wall]) {
                    cylinder(d=carrierOD+2*wall,h=wiperZ-1-(motorZ-wall));   
                }
                
                // Surround fixed ring gear
                translate([0,0,fixedZ-wall]) {
                    cylinder(r=wiperR,h=wiperZ-1-(fixedZ-wall));     
                }
            }
            // Wiper ring
            translate([0,0,fixedZ]) {
                cylinder(r=wiperR,h=splitZ-fixedZ);  
            }
            gearwave_fixed_wiperteeth();
            //gearwave_fixed_support();
        }
        // Space for the motor
        motor_space();
        
        // Space for the encoder
        gearwave_fixed_encoderspace();
        
        // Space for the thru bar
        bar_3D();
        
        // Space for a steel cross bar (also reduces 3D printed volume)
        translate([0,0,motorZ-wall-barOD/2])
            rotate([90,0,0]) bar_3D();
        
        // Central hole clearance:
        difference() {
            union() {
                // Cut the fixed ring gear
                bevel=2;
                translate([0,0,fixedZ-bevel+0.1]) {
                    gear=gearplane_Rgear(gearplane_fixed);
                    gear_3D(gear,clearance=ring_clearance,bevel=bevel,height=splitZ-fixedZ+1+2*bevel);
                }
                
                // Channel for the carrier
                translate([0,0,motorZ]) {
                    cylinder(d=carrierOD+2*wall,h=0.2+fixedZ-motorZ);   
                }
            }
            // Put back the carrier bearing
            translate([0,0,motorZ-2])
                cylinder(d=carrier_bearing_ID,h=fixedZ-motorZ);
        }
        
        // Space for a grease Zerk fitting, to refill bearing/bushing with grease
        translate([-carrier_bearing_OD/2+1,0,motor_faceZ-0.1])
        {
            cylinder(d1=10.3,d2=8.6,h=8); // 1/8" NPT zerk
            cylinder(d=4,h=12); // grease channel
        }
    }
    
}

mountR=55; // center to mounting bolt distance
mountN=8; // number of tire mounting bolts
mountID=0.140*inch; // #10-24 mounting screw minor diameter (or pop rivets?)
mountOD=0.190*inch; // major diameter
// Put children at the center of each drive-to-tire mounting bolt 
module gearwave_drive_mountcenters() {
    for (angle=[360/mountN/2:360/mountN:360-1]) rotate([0,0,angle]) translate([mountR,0,0])
        children();
}


topPlate=1.0; // thickness of top closeout plate

// Output gear on top
module gearwave_drive() 
{
    topZ=closeZ+topPlate;
    mountZ=8; // mounting bolt hole boss thickness
    mountH=20; // hole depth
    
    gear=gearplane_Rgear(gearplane_drive);
    difference() {
        hull() {
            translate([0,0,wiperZ])
                cylinder(r=driveR+0.5,h=(supportZ+wall)-wiperZ);
            translate([0,0,supportZ])
                cylinder(d=carrierOD+2*wall,h=topZ-supportZ);
            
            // Meat around tire mounting bolts
            gearwave_drive_mountcenters() translate([0,0,topZ-mountZ])
               cylinder(d=mountOD+wall,h=mountZ); 
        }
        
        // Holes for tire mounting bolts
        gearwave_drive_mountcenters() translate([0,0,topZ-mountH])
           cylinder(d=mountID,h=mountH); 
        
        // Carrier clearance
        translate([0,0,supportZ])
            cylinder(d=gear_ID(gear),h=closeZ-supportZ);
        
        //Wiper clearance
        translate([0,0,wiperZ-1])
            cylinder(r=wiperR+1,h=driveZ-(wiperZ-1));
        
        // Central hole, for fixed axle and bearing
        translate([0,0,closeZ-1]) cylinder(d=0.5*inch,h=5);
            
        // Ring gear cut
        bevel=2;
        translate([0,0,driveZ-bevel]) {
            gear_3D(gear,clearance=ring_clearance,bevel=bevel,height=splitZ-fixedZ+1+2*bevel);
        }
    }
}

// The bottom carrier gears the motor pinion to the planet axles
module gearwave_motorcarrier() 
{
    gear=gearplane_Sgear(gearplane_motor);
    translate([0,0,motorZ])
    difference() {
        union() {
            gear_3D(gear,height=fixedZ-motorZ-1);
            // boss supports each planet gear
            gearplane_planets(gearplane_fixed) cylinder(d=axle_boss,h=fixedZ-motorZ);
        }
        
        // Hole for planet shafts
        translate([0,0,axle_support])
            gearplane_planets(gearplane_fixed) cylinder(d=axleOD,h=splitZ-motorZ);

        // Hole for encoder magnets
        magnetN=4;
        da=360/magnetN;
        for (angle=[da/2:da:360-1]) rotate([0,0,angle]) translate([encoderR,0,motorZ-0.1])
            cylinder(d=4.8,h=6);
        
        // Space for bearing / bushing
        translate([0,0,-1])
        cylinder(d=carrier_bearing_OD,h=fixedZ-motorZ+1);
    }
}

// The support carrier just holds the top of the planet axles
module gearwave_supportcarrier()
{
    gear=gearplane_Sgear(gearplane_motor);
    translate([0,0,supportZ])
    difference() {
        union() {
            translate([0,0,1])
                cylinder(d=carrierID,h=closeZ-supportZ-1);
            // boss supports each planet gear
            gearplane_planets(gearplane_fixed) cylinder(d=axle_boss,h=closeZ-supportZ);
        }
        
        // Hole for planet shafts
        translate([0,0,-0.1])
            gearplane_planets(gearplane_fixed) cylinder(d=axleOD,h=closeZ-supportZ-axle_support);

        // Space for bearing / bushing
        translate([0,0,-1])
        cylinder(d=carrier_bearing_OD,h=fixedZ-motorZ+2);
    }
}

// Planet gears
module gearwave_planets(with_bearings=1) {
    translate([0,0,fixedZ])
    difference() {
        stepped_planets(gearplane_fixed,gearplane_drive,
            axle_hole=axleOD,bevel=1);
        
        // Axle bearings fixed in the planets
        if (with_bearings)
        gearplane_planets(gearplane_fixed) 
            for (top=[0,1]) translate([0,0,top?supportZ-fixedZ:0]) scale([1,1,top?-1:+1]) 
            translate([0,0,-0.1])
            {
                cylinder(d=axle_bearingOD,h=axle_bearingZ);
            }
    }
}

// Draw 2D outline of gears and critical components
module gearwave_illustrate() 
{
    translate([0,0,-50]) bar_3D();
    #motor_space();
    
    color([0.3,0.4,0.8]) translate([0,0,motorZ])
    {
        gearplane_2D(gearplane_motor);
       // scale([1,1,-1]) translate([motorR,0,0]) cylinder(d=jacketedmotorOD,h=75);
    }

    translate([0,0,fixedZ])
        gearplane_2D(gearplane_fixed);

    color([1.0,0.7,0.2]) translate([0,0,driveZ])
        gearplane_2D(gearplane_drive);

    // Planet axles
    gearplane_planets(gearplane_fixed)
    translate([0*gearplane_Oradius(gearplane_fixed),0,0]) {
        translate([0,0,motorZ])
            cylinder(d=8,h=closeZ-motorZ); // 8mm shaft runs thru
        translate([0,0,fixedZ])
            cylinder(d=0.5*inch,h=supportZ-fixedZ); // needle bearings (or bushings?)
    }

}

module gearwave_main_bearing() {    
    translate([0,0,closeZ]) difference() {
        cylinder(d=main_bearing_OD,h=main_bearingZ);
        cylinder(d=main_bearing_ID,h=3*main_bearingZ,center=true);
    }
}

// Entire assembly, with cutaway view
module gearwave_cutaway() {
    difference() {
        union() {
            gearwave_fixed();
            gearwave_motorcarrier();
            gearwave_planets();
            gearwave_drive();
            gearwave_supportcarrier();
        }
        //translate([0,0,driveZ+gearZ/2+100])  cube([200,200,200],center=true);
        translate([0,0,motor_faceZ]) cube([200,200,200]);
    }
}

module gearwave_printable(boxes=1,carrier=1,gear=1) {
    shift=115; // space each part this far
    if (boxes) {
        if (boxes==1) translate([0,0,-motor_faceZ]) gearwave_fixed(support=1);
        if (boxes==2) translate([0,0,closeZ+wall]) rotate([180,0,0]) gearwave_drive(); 
    }
    if (carrier) {
        translate([shift,0,-motorZ]) gearwave_motorcarrier();
        translate([shift,shift,closeZ]) rotate([180,0,0]) gearwave_supportcarrier();
    }
    if (gear) {
        //translate([-shift,shift/2,supportZ]) rotate([180,0,0]) gearwave_planets(0); // plain shaft
        translate([-shift,shift/2,supportZ]) rotate([180,0,0]) gearwave_planets(1); // bearings
    }
}

/********** Mount to plastic Barbie Jeep tire ***********/

jeeptire_bearingOD=22+0.2;
jeeptire_bearingID=0.375*inch+2;
jeeptire_bearingZ=8+0.2;

// 2D cross section of jeep tire mount drive tab: 
//   the nub molded into the tire that pushes it around.
module jeeptire_mount_tab2D(trim=0) 
{
    d=15; // width of tab slots
    circlecenter=[36.5+d/2,0,0]; // rounded inside of tabs
    
    hull() {
        translate(circlecenter) circle(d=d);
        translate([61-d/2-trim,0,0]) square([d,d],center=true);
    }
}

// Rotate to each jeeptire_mount tab
module jeeptire_mount_tabs() {
    da=90; // change in angle between mounts, degrees
    for (cross=[0:da:360-1]) rotate([0,0,cross]) children();
}

// 2D cross section of jeep tire mount
//   Tabs: push on nubs molded into tire
//   Ribs: connect parts together
//   Ears: screw onto mounting bolts
module jeeptire_mount2D(inside=0,tabs=1,ribs=0,ears=0) 
{
    rib=1.5;
    drivewall=2.5;
    d=15; // width of tab slots
    pushR=45; // distance to secure arms
    
    if (!inside)
        circle(d=jeeptire_bearingOD+2*rib);
    jeeptire_mount_tabs()
    {
        // Actual drive tabs
        if (tabs) 
        offset(r=inside?0:drivewall)
        jeeptire_mount_tab2D(trim=inside?0:drivewall+0.1);
        
        if (ribs) {
            // Support lattice to bearing
            for (dy=[-1,+1]) for (sy=[-1,+1])
            if (sy>=dy)
            hull() {
                translate([0,dy*jeeptire_bearingOD/2]) circle(d=rib);
                translate([pushR,sy*d/2]) circle(d=rib);
            }
            // Outer diagonals
            hull() {
                translate([pushR,d/2]) circle(d=rib);
                rotate([0,0,90])
                translate([pushR,-d/2]) circle(d=rib);
            }
        }
        
        // Screw ears
        if (ears) 
        hull() {
            for (side=[-1,+1]) scale([1,side,1])
                rotate([0,0,360/mountN/2]) translate([mountR,0,0])
                    circle(d=12);
            // connect back to tabs
            jeeptire_mount_tab2D();
        }
    }
    
}

// Hold a Barbie Jeep tire onto the gearwave gearbox
module jeeptire_mount() {
    h=14; // total height of part
    floor=1.0; // plastic under tabs and everything
    ears=h; // plastic under mounting ears
    round=2.5;
    difference() {
        union() {
            // Main blocks around bearing and tabs
            linear_extrude(height=h,convexity=12) 
                offset(r=-round) offset(r=+round)
                    jeeptire_mount2D(0,1,1,1);
            
            linear_extrude(height=floor,convexity=6) 
            offset(r=-round) offset(r=+round)
            {
                hull() jeeptire_mount2D(0,0,1); // ribs only
                jeeptire_mount2D(0,1,0,1); // tabs stick out from there
            }
        }
        
        // Remove area around mounting bolts
        gearwave_drive_mountcenters() {
            cylinder(d=mountOD,h=25,center=true);
            translate([0,0,3]) // flared area around each bolt
                cylinder(d1=12,d2=28,h=h);
        }
        
        // Remove inside of tabs
        max_taper=2.0;
        for (taper=[0:0.25:max_taper])
        translate([0,0,floor+h]) scale([1,1,-1])
            linear_extrude(height=h-max_taper+taper,convexity=8) 
                offset(r=-taper) 
                    jeeptire_mount_tabs()
                        jeeptire_mount_tab2D(trim=-1-max_taper);
        
        // Space for bearing (with support)
        difference() {
            // Main bearing hole
            cylinder(d=jeeptire_bearingOD,h=jeeptire_bearingZ);
            // Add support material back in
            cylinder(d=jeeptire_bearingID+1,h=jeeptire_bearingZ);
        }
        // axle thru hole
        translate([0,0,-1])
            cylinder(d=jeeptire_bearingID,h=h+2);
        
        // Trim back the outer rim (avoid stress concentration on tire)
        trimOD=125;
        difference() {
            cylinder(d=trimOD,h=h+1);
            cylinder(d1=trimOD,d2=trimOD-h,h=h);
        }
        
    }
}

// Compare jeep tire mount to previous mount
module jeeptire_mount_compare() {
    translate([0,0,closeZ+3])
    {
        color([1,0,0])
        jeeptire_mount();

        // 2D cross section
        if (0) color([1,0.5,0.3])
        projection(cut=true)
        translate([0,0,-5]) rotate([0,0,45])
        import("tiremount_v14.stl");
        
        // 3D section
        translate([0,0,14]) rotate([0,0,45]) rotate([180,0,0])
        import("tiremount_v14.stl");
    }
}


//gearwave_illustrate();
gearwave_cutaway();
//bearing3D(carrier_bearing);


//gearwave_printable(1,0,0);
//gearwave_drive();

//jeeptire_mount_compare();
//jeeptire_mount();


