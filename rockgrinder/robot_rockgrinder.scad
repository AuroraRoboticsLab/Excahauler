/*
  Rock grinder tool in context, attached to robot.
*/
include <../Excahaul_latest.scad>;
$subpart=1;
include <../AuroraSCAD/motor.scad>;


// Ammunition can: some sort of flares, similar to a 50cal can but taller.
module ammocan() 
{
    x=285;
    y=300;
    z=150;
    translate([-x/2,0,0]) cube([x,y,z]);
}

// Top-to-bottom length of rock grinding wheel
rockgrinderWheelZ=297+6;
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
    cylinder($fn=faceN,r=rockgrinderFaceR,h=rockgrinderWheelZ,center=true);
}

// Translate from wheel origin to the tip of this tooth.
//    The tooth lies along the -X direction
module tooth_number(toothI)
{
    angle=toothI*tooth_stepA;
    height=(toothI+0.5)*rockgrinderWheelZ/toothN;
    rotate([0,0,angle])
        translate([tooth_tipR,0,height-rockgrinderWheelZ/2])
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
Ybase=-200; // bottom of ammo boxes
Ytop=+50; // top of support for ammo boxes
Zwheel=400; // distance to wheel (sets length of cutting arc)
Zcross=Zwheel-130; // crossbar support over wheel

Ybot=Ybase+120; // supports scoop bottom edge
Zbot=Zwheel; 
Ztip=Zwheel;

// The bottom curve of the bucket is around the coupler pivot
//   with bucket facing up, for easier motion planning (pure curl)
//rockgrinderPivotOrigin=[0,-75,-75]; // matches facing down
rockgrinderPivotOrigin=[0,75,-75]; // matches facing up

function length2D(dx,dy) = sqrt(dx*dx+dy*dy);

// Onboard storage bottom beyond wheel centerline
minWheelR=65; //<- == rockgrinder faceR, plus some clearance
rockgrinderScoopR=length2D(
    Ybase-rockgrinderPivotOrigin[1],
    Zwheel-rockgrinderPivotOrigin[2]
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
                translate([Zwheel,Ybase]) circle(d=rockgrinderWheelOD-2*shrink,$fa=5); // clearance around wheel
            }
            
            if (shrink==0)
                rockgrinderBucketHoles2D();
        }
        
        // Trim off top surface
        translate([Zcross-shrink,Ybase-0.5*inch-shrink]) 
            rotate([0,0,-20]) // keep bucket size reasonable
                //translate([0,400])  // cutting tip only
                    square([1000,1000]);
        
        // Trim off bottom surface
        translate([0,Ybase-0.5*inch-shrink+1000])
            square([2000,2000],center=true);

        // Trim everything but support area
        hull() {
            circle(d=400);
            translate([Zwheel,Ybase]) circle(d=100);
        }
    }
}

rockgrinderBucketPlateOverlap=1*inch;

// Holes to mount rock grinder plates to bucket
module rockgrinderBucketHoles2D() 
{
    translate([Zwheel,Ybase]) 
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
                translate([Zwheel,Ybase]) {
                    // Fill in hole around wheel
                    circle(d=100,$fa=5); 
                }
            }
            translate([Zwheel,Ybase]) {
                // Trim back to just central hole around wheel
                circle(d=rockgrinderWheelOD+2*rockgrinderBucketPlateOverlap,$fa=5);
                // Include top portion to match bucket lip
                scale([-1,1]) translate([0,-0.5*inch])
                    square([200,100]);
            }
        }
        rockgrinderBucketHoles2D();
        translate([Zwheel,Ybase]) 
        {
            if (bolts) bolt_centers() circle(d=screw_diameter(bolt_type));
            if (box)    square([1.5*inch,1.5*inch],center=true);
        }
    }
}

// change XY scoop sideview to ZY tool coords
module rockgrinderXYtoZY() 
{
    rotate([0,-90,0]) 
        children();
}

// Rock grinder onboard storage bucket (sheet metal)
module rockgrinderStorage(shrink=0)
{
    rockgrinderXYtoZY() // change XY here to ZY tool coords
    linear_extrude(height=rockgrinderWheelZ-2*shrink,center=true,convexity=4)
        rockgrinderBucket2D(shrink);
}


// Placeholder for a rock grinding wheel
module rockgrinder3D(showFrame=1,showParts=1)
{
    OD=190; 
    couplerPickupFull();

    if (0) // big scoop sticking out
    difference() {
        rockgrinderStorage(0);
        rockgrinderStorage(0.065*inch);
    }
    

    if (showParts) {
        translate([0,Ybase-frameSteel/2,30]) ammocan();
        //translate([0,Ybase,170]) ammocan();
        
        translate([0,Ybase,Zwheel]) rotate([0,90,0]) {
            cylinder($fn=7,r=faceR,h=rockgrinderWheelZ,center=true);
            //#cylinder($fa=5,d=rockgrinderWheelOD,h=rockgrinderWheelZ,center=true);
            face_plates_3D();
            teeth_3D();
            
            
            translate([0,0,rockgrinderWheelZ/2]) bolt_centers() screw_3D(bolt_type);
        }
        rockgrinderXYtoZY()
        for (side=[0,1]) scale([1,1,1-2*side])
        translate([0,0,rockgrinderWheelZ/2])
        linear_extrude(height=1)
            rockgrinderBucketPlate2D(side,1-side);
    }
    
    
    
    if (showFrame) {
        // Steel square tube frame
        shrink=0;
        Zclose=frameSteel/2; //<- sits in front of pickup
        rockGrinderFrame=[
            //[-Xframe,Ybot,Zbot], // bottom edge of scoop
            [-Xframe,Ybase,Zwheel], // axle of wheel
            [-Xframe,Ybase,Zclose], // coupler side bottom corner
            [-Xframe,Ytop,Zclose], // coupler side top corner
            //[-Xframe,Ytop,Ztip] // support the cutting edge of scoop
        ];
        steelExtrude(rockGrinderFrame,1) steelCube(shrink,frameSteel);
        rockGrinderCross=[
            [-Xframe,Ybase,Zcross],
            [+Xframe,Ybase,Zcross]
        ];
        steelExtrude(rockGrinderCross,0) steelCube(shrink,frameSteel);
        
        for (Y=[-75,+50]) {
            rockGrinderPickup=[
                [-Xframe,Y,Zclose],
                [+Xframe,Y,Zclose]
            ];
            steelExtrude(rockGrinderPickup,0) steelCube(shrink,frameSteel);
        }
    }
}

//configDigRockgrinder=[0.9,0.5,1.0-$t,0.0]; // curl in (sprays robot with chips)
configDigRockgrinder=[0.65,0.2,0.6+$t,1.0]; // reach low

//rockgrinder3D(1,1);
//robot(configDigRockgrinder,0) rockgrinder3D(1,1);
//rockgrinderStorage();
//rockgrinderBucket2D();

if (0) { // 2D plate templates (laser print, plasma cut)
    rockgrinderBucketPlate2D(1,0);
    scale([1,-1,1]) rockgrinderBucketPlate2D(0,1);
}


