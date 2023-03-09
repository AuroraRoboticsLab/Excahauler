/*
 Frame and outside parts of rock grinder tool. 
 
 This file is intended to be included from the robot itself.
 
*/
include <../AuroraSCAD/motor.scad>;
include <../coupler_2pin/tool_coupler_interface.scad>;

// Ammunition can: some sort of flares, similar to a 50cal can but taller.
module ammocan() 
{
    x=285;
    y=150;
    z=290;
    color([0.5,0.5,0.5])
    translate([-x/2,0,0]) cube([x,y,z]);
}

// Top-to-bottom length of rock grinding wheel
rockgrinderWheelY=knuckleSpace+297+6;
rockgrinderFaceR=58.5;
rockgrinderWheelOD=190; // full clearance including tines
faceR=58.5; // face plates around wheel
boltR=27.2; // actual mounting bolts holding wheel onto frame (top side)
boltN=4;
bolt_type=US_5_16_hex; // 5/16" bolts (basically 8mm)

// Bolts hold the end plate onto the grinder
module bolt_centers(step=1) {
    da=360/boltN;
    for (angle=[da/2:da*step:360-1]) rotate([0,0,angle])
        translate([boltR,0,0]) children();
}



/* Initial testing: 
    tipR==90 sticks out quite a ways, and hangs up in hand swing tests.
    tipR==82 doesn't stick out much, but still cuts well.
    R==90 with a crossbar: cuts very nicely when swung fast.
*/
tooth_tipR=90;

faceN=7;
tooth_stepA=360/faceN*1.5; // angular distance between adjacent teeth
toothN=28; // == 4 teeth per plate

// 3D geometry of the steel face plates
module face_plates_3D() {
    cylinder($fn=faceN,r=rockgrinderFaceR,h=rockgrinderWheelY,center=true);
}

// Translate from wheel origin to the tip of this tooth.
//    The tooth lies along the -X direction
module tooth_number(toothI)
{
    angle=toothI*tooth_stepA;
    height=(toothI+0.5)*rockgrinderWheelY/toothN;
    rotate([0,0,angle])
        translate([tooth_tipR,0,height-rockgrinderWheelY/2])
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



Xframe=-330/2; // +- this width between frame centerlines
Zbase=-295; // bottom of ammo boxes
Ztop=-45; // top of support for ammo boxes
Ywheel=knuckleSpace+400; // distance to wheel (sets length of cutting arc)
Ycross=Ywheel-130; // crossbar support over wheel

Zbot=Zbase+120; // supports scoop bottom edge
Ybot=Ywheel; 
Ytip=Ywheel;

// The bottom curve of the bucket is around the coupler pivot
//   with bucket facing up, for easier motion planning (pure curl)
//rockgrinderPivotOrigin=[0,-75,-75]; // matches facing down
rockgrinderPivotOrigin=[0,75,-75]; // matches facing up

function length2D(dx,dy) = sqrt(dx*dx+dy*dy);

// Onboard storage bottom beyond wheel centerline
minWheelR=65; //<- == rockgrinder faceR, plus some clearance
rockgrinderScoopR=length2D(
    Zbase-rockgrinderPivotOrigin[1],
    Ywheel-rockgrinderPivotOrigin[2]
    ) + minWheelR;


// 2D cross section of the actual storage bucket
module rockgrinderBucket2D(shrink=0,clear_grinder=1)
{
    intersection() {
        round=20; // bottom edge rounding, so material doesn't jam
        difference() {
            offset(r=+round) offset(r=-round)
            difference() {
                // Pivot around the origin
                translate([rockgrinderPivotOrigin[2],rockgrinderPivotOrigin[1]])
                    circle($fn=20,r=rockgrinderScoopR-shrink,$fa=5); 
                
                if (clear_grinder)
                translate([Ywheel,Zbase]) circle(d=rockgrinderWheelOD-2*shrink,$fa=5); // clearance around wheel
            }
            
            if (shrink==0)
                rockgrinderBucketHoles2D();
        }
        
        // Trim off top surface
        translate([Ycross-shrink,Zbase-0.5*inch-shrink]) 
            rotate([0,0,-20]) // keep bucket size reasonable
                //translate([0,400])  // cutting tip only
                    square([1000,1000]);
        
        // Trim off bottom surface
        translate([0,Zbase-0.5*inch-shrink+1000])
            square([2000,2000],center=true);

        // Trim everything but support area
        hull() {
            circle(d=400);
            translate([Ywheel,Zbase]) circle(d=100);
        }
    }
}

rockgrinderBucketPlateOverlap=1*inch;

// Holes to mount rock grinder plates to bucket
module rockgrinderBucketHoles2D() 
{
    translate([Ywheel,Zbase]) 
    for (angle=[0:45:360]) rotate([0,0,angle])
        translate([(rockgrinderWheelOD+rockgrinderBucketPlateOverlap)/2,0,0])
            circle(d=5);
}

// Steel seal plate that bolts on both sides of bucket
module rockgrinderBucketPlate2D(bolts=1, box=0) 
{
    round=12;
    difference() {
        offset(r=-round) offset(r=+round)
        intersection() {
            union() {
                rockgrinderBucket2D(clear_grinder=0);
                translate([Ywheel,Zbase]) {
                    // Fill in hole around wheel
                    circle(d=100,$fa=5); 
                }
            }
            translate([Ywheel,Zbase]) {
                // Trim back to just central hole around wheel
                circle(d=rockgrinderWheelOD+2*rockgrinderBucketPlateOverlap,$fa=5);
                // Include top portion to match bucket lip
                scale([-1,1]) translate([0,-0.5*inch])
                    square([200,100]);
            }
        }
        rockgrinderBucketHoles2D();
        translate([Ywheel,Zbase]) 
        {
            if (bolts) bolt_centers() circle(d=screw_diameter(bolt_type));
            if (box)    square([1.5*inch,1.5*inch],center=true);
        }
    }
}

// change XZ scoop sideview to YZ tool coords
module rockgrinderXZtoYZ() 
{
    rotate([90,0,0])
    rotate([0,90,0]) 
        children();
}

// Placeholder for a rock grinding wheel
module rockgrinder3D(showFrame=1,showParts=1)
{
    OD=190; 

    if (showParts) 
    color([0.5,0.5,0.5]) {
        toolPickup();

        translate([0,knuckleSpace+30,Zbase-frameSteel/2]) ammocan();
        
        translate([0,Ywheel,Zbase]) rotate([0,-90,0]) {
            cylinder($fn=7,r=faceR,h=rockgrinderWheelY,center=true);
            face_plates_3D();
            teeth_3D();
            
            
            translate([0,0,rockgrinderWheelY/2]) bolt_centers() screw_3D(bolt_type);
        }
        rockgrinderXZtoYZ()
        for (side=[0,1]) scale([1,1,1-2*side])
        translate([0,0,rockgrinderWheelY/2])
        linear_extrude(height=1)
            rockgrinderBucketPlate2D(side,1-side);        
    }
    
    if (showFrame) {
        // Steel square tube frame
        shrink=0;
        Yclose=knuckleSpace+frameSteel/2; //<- sits in front of pickup
        rockGrinderFrame=[
            //[-Xframe,Ybot,Zbot], // bottom edge of scoop
            [-Xframe,Ywheel,Zbase], // axle of wheel
            [-Xframe,Yclose,Zbase], // coupler side bottom corner
            [-Xframe,Yclose,Ztop], // coupler side top corner
            //[-Xframe,Ytip,Ztop] // support the cutting edge of scoop
        ];
        steelExtrude(rockGrinderFrame,1) steelCube(shrink,frameSteel);
        rockGrinderCross=[
            [-Xframe,Ycross,Zbase],
            [+Xframe,Ycross,Zbase]
        ];
        steelExtrude(rockGrinderCross,0) steelCube(shrink,frameSteel);
        
        for (Z=[Ztop-125,Ztop]) {
            rockGrinderPickup=[
                [-Xframe,Yclose,Z],
                [+Xframe,Yclose,Z]
            ];
            steelExtrude(rockGrinderPickup,0) steelCube(shrink,frameSteel);
        }
    }
}

//configDigRockgrinder=[0.9,0.5,1.0-$t,1.0]; // curl in (sprays robot with chips)
configDigRockgrinder=[0.65,0.2,0.6+$t,0.0]; // reach low

