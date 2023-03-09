/*
 Excavator-hauler
 Dr. Orion Lawlor, lawlor@alaska.edu (Public Domain)
 
 Coordinate system here is right-handed, in mm:
    +X is right side 
    +Y is travel direction (Unity demands this)
    +Z is up (against gravity)
 
 boom linear: 500mm/20" travel (625-1125 overall)
 stick linear: 300mm/12" travel
 coupler linear: 300mm/12" travel (425-725 overall)
*/

// $fs=0.5; $fa=5; // fine mode
$fs=3.0; $fa=30; // coarse mode


//$subpart=0; // 0: this is the whole robot; 1: included from elsewhere.

// FEM mode: simpler geometry, smaller mesh segments
$FEM_mode=0; // 0: graphics only; 1: finite element sim

inch=25.4; // file units = mm
steel1=1*inch; // 1x1 steel box tubing
steel34=3/4*inch; // 3/4" steel box tubing

frameWall=0.062*inch;

frameSteel=steel1;
boomSteel=steel1;
stickSteel=steel1;
couplerSteel=steel1;

steelColor=[0.9,0.9,0.9];
wheelColor=[0.35,0.1,0.2];

// wiper with dust channels, sits between moving parts
//  Material: PTFE filled with MoS2
wiper=3;


include <Excahaul_wheel.scad>;

// Frame parameters
axleX=400; // distance from centerline to outside of frame
digAxle=450; // Y coordinate of front axle, on the digging side
eboxAxle=-450; // Y coordinate of back axle, by electronics box

rockerBogie=1; // 1: 6 wheels. 0: 4 wheels.
middleAxle=0; // Y coordinate of middle axle (6 wheels).  Might push back a bit
rockerAxle=(middleAxle+eboxAxle)/2; // could be non-centered?

axleZ=-75; // vertical height of wheel mount point

crossY=-310; // Y coordinate of center of frame crossbar

eBoxY=300; // thickness of electronics main box
eBoxFrontY=-370; // radiator and electronics box starts here
eBoxBackY=eBoxFrontY-eBoxY;
robotBackY=crossY-frameSteel/2-wheelDia; // only bumper beyond here


// Warm electrical box: back portion
eBoxAsBuilt=1; ///< 1: real tupperware box.  0: flight-style radiator on top.

eBoxTop=400; // Z coordinate of top of electronics & camera box
eBox=[2*axleX-25,eBoxY,465];
eBoxCenter=[0,eBoxFrontY-eBox[1]/2,eBox[2]/2]; // coords of center of electronics box
eTilt=[0,0,0]; // tilted backward, away from boom and stick
eColor=[0.7,0.7,0.8];

// Lump of batteries in the middle (for better center of mass than the far-back main electronics box)
batteryBoxFrontY=-50;
batteryBox=[400,batteryBoxFrontY-eBoxCenter[1],150];
batteryBoxCenter=[0,batteryBoxFrontY-batteryBox[1]/2,batteryBox[2]/2];

eBoxMLI=20; // thickness of MLI around eBox (internal to eBox above)
louverMLI=15; // thickness of MLI around thermal louver



// Lights and cameras box
cameraPivot=[0,eBoxFrontY+25/2,300];

cameraOutsideX=axleX+wheelThick;
cameraSpinDia=230;
radiatorBox=[2*cameraOutsideX,eBoxY,50];
radiatorBoxCenter=[
    0,
    eBoxCenter[1], // -10, // robotBackY+radiatorBox[1]/2,
    eBoxTop-radiatorBox[2]/2];

radiatorMLIthick=louverMLI; // MLI over radiator panel
radiatorThickY=radiatorBox[1];
radiatorPivotZ=eBoxTop;
radiatorPivot=[0,eBoxBackY,radiatorPivotZ];
radiatorPerimeterZ=200; // dust and heat wall around radiator panel front and sides

MLIColor=[0.8,0.8,1.0];
radiatorColor=[0.2,0.2,0.2];


// X coordinate of outside of boom's steel frame
boomX=axleX-frameSteel-wiper;
// X coordinate of outside of stick's steel frame
stickX=265;

couplerWid=75; // width of coupler (along pins)
couplerHt=125; // height of coupler (between pins)
couplerSize=200; // steel frame and rotating arm


// X coordinate of outside of coupler assembly's steel frame
couplerX=125;

// Radius of main tube of linear actuator
//  (Careful, gearbox end is wider!)
actuatorR=20;

actuatorColor=[0.3,0.2,0.3];

// Centerline of linear actuators that move everything:
boomActuatorX=axleX-wiper-actuatorR;
stickActuatorX=264; // stickX-wiper-actuatorR; 
    //couplerX+wiper+stickSteel+wiper+actuatorR;
tiltActuatorX=couplerX; // -wiper-actuatorR;

// This is where the boom actuator attaches to the frame
boomFrameActuator=[boomActuatorX-actuatorR-wiper-boomSteel/2,-310,60];

// This is where the stick actuator pushes on the boom
boomStickActuator=[stickActuatorX+actuatorR+wiper+boomSteel/2,-75,58];

// These are points in the boom's 3d model, relative to
//   both the frame and the boom's rest configuration.

// Pivot point of boom shoulder:
boomShoulder=[boomX-0.5*boomSteel,570,0];
// Boom actuator attachment point:
boomLat=[boomActuatorX-actuatorR-wiper-boomSteel/2,315,140];
// Truss under actuator attachment
boomUnderLat=[boomLat[0],boomLat[1],0];
// Pivot point to stick:
boomElbow=[stickX+wiper+boomSteel/2,-245,82];
// This bit straightens out before the actual elbow joint
boomPreElbow=[boomStickActuator[0],boomStickActuator[1],boomElbow[2]+15];


// In stick coords, origin is at boom-stick pivot,
//   +Y points along the stick
stickXlo=stickX-stickSteel/2;
stickXhi=couplerX+wiper+stickSteel/2;
stickElbow=[stickXlo,0,0];
stickCrossbar=[stickXlo,130,50];
stickTiltActuator=[stickXlo,stickCrossbar[1]+60,stickCrossbar[2]-70];
stickBoomActuator=[stickXhi,560,50];
stickCouplerPivot=[stickXhi,730,0];



// Location of stick-to-coupler pivot point in coupler coords:
couplerHeight=75; // from pivot to front of coupler face
couplerThick=couplerSteel; // Z thickness of mating tool pickup
couplerBearingHeight=37+couplerThick; // from top of frame to back of pickup
couplerPivot=[couplerX-couplerSteel/2,-75,-couplerHeight];

// Pivot point where actuator attaches to coupler
tiltActuator=[tiltActuatorX-actuatorR-wiper-couplerSteel/2,85,-couplerHeight];

couplerDriveDia=couplerSize-2*couplerThick;
couplerBevel=couplerSteel; // size of coupler bevels


/* "link" data structure describes a moving part:
*/
function linkParent(link) = link[0]; /* either undef, or a parent link */
function linkName(link) = link[1]; /* string name of link */
function linkConfig(link) = link[2]; /* 0-based index in config (drive command) array */
function linkStart(link) = link[3]; /* vec3 parent-relative translation start */
function linkRotateStart(link) = link[4]; /* vec3 initial rotation at config==0.0 */
function linkRotateRange(link) = link[5]; /* vec3 rotation through config==1.0 */
function linkEnd(link) = link[6]; /* vec3 final translation */

boomLink=[undef,"Boom",0, 
    boomShoulder, // translate start (relative to parent frame) 
    [0,0,0],[-125,0,0], // rotate start and range 
    -boomShoulder // translate end 
];

/*
// "tilt" is the difference between the two boom segment heights, 
//  here horribly faked by rotating around Y just after the boom.
//  Details not modeled because this probably isn't worth it.
tiltPoint=[stickX,boomElbow[1],boomElbow[2]];
tiltLink=[boomLink,"Tilt",4,
    tiltPoint,
    [0,0,0],[0,10,0], // rotate start and range
    -tiltPoint,
];
*/

stickLink=[boomLink,"Stick",1,
    [0,boomElbow[1],boomElbow[2]], // translate start (relative to parent frame) 
    [15,0,0],[125,0,0], // rotate start and range 
    [0,0,0] // translate end 
];

couplerLink=[stickLink,"Coupler",2,
    [0,stickCouplerPivot[1],stickCouplerPivot[2]], // translate start (relative to parent frame) 
    [-180,0,0],[140,0,0], // rotate start and range 
    [0,-couplerPivot[1],-couplerPivot[2]] // translate end 
];

wristLink=[couplerLink,"Wrist",3,
    [0,0,0],
    [0,0,0],[0,0,180], // rotate start and range
    [0,0,0],
];

/*
  Apply this link's incremental transform,
  relative to its parent.
*/
module linkXformParent(config,link) {
    rot=linkRotateStart(link)+linkRotateRange(link)*config[linkConfig(link)];
    
    translate(linkStart(link))
        rotate(rot)
            translate(linkEnd(link))
                children();
}

/*
  Apply this link's world transform.
  (The recursive product of all parent links.)
*/
module linkXformWorld(config,link) {
    if (link==undef) children();
    else {        
        linkXformWorld(config,linkParent(link))
            linkXformParent(config,link)
                children();
    }
}


// Tilt up child 2D section and extrude along Y,
//   moving from S to E
module line_extrudeY(S,E,convexity=2)
{
    D=E-S;
    
    // Split up long segments in FEM mode:
    if ($FEM_mode && sqrt(D*D)>100.0) {
        M=(S+E)/2; // split at midpoint
        line_extrudeY(S,M) children();
        line_extrudeY(M,E) children();
    }
    else { // extrude in one segment    
        // section(XY)  extrusion  translation
        m=[
            [1,0,D.x,S.x],
            [0,0,D.y,S.y],
            [0,1,D.z,S.z]
        ];
        multmatrix(m) {
            linear_extrude(height=1.0,convexity=convexity)
                children();
            
        }
    }
}

// Extrude 2D shape along a list of points.
//   2D shape is tilted up so it moves along +Y
module list_extrudeY(list,convexity=2) {
    for (i=[1:len(list)-1]) {
        line_extrudeY(list[i-1],list[i],convexity)
            children();
    }
}


// Filled PTFE wiper between moving parts
//  Oriented Z up
module wiper() {
    color([0.9,0.9,0.9])
        cylinder(d=30,h=wiper);
}
// Oriented X out, relative to center of steel frame
module wiperSteel(steel) {
    translate([steel/2,0,0]) rotate([0,90,0]) wiper();
}

hubmotorOD=230;
hubmotorZ=100;

// Holds wheel to hubmotor
module wheelSpokes()
{
    intersection() {
        translate([0,0,1])
        cylinder(d=wheelDia-1,h=wheelThick-2,$fn=32); 
        union() {
            for (angle=[0:60:360-1]) rotate([0,0,angle])
            for (lean=[0,1])
            intersection() {
                union() {
                    
                    translate([hubmotorOD/2-10,0,lean?hubmotorZ-10:wheelBevel])
                    rotate([0,lean?30:90,0])
                    for (tilt=[-45,0,+45]) rotate([tilt,0,0])
                        cube([2,2,100]);
                }  
            }
        }   
    }
}

// Total placeholder for hub-mounted motor and geartrain (strain wave?)
module hubMotor() {
    color([0.3,0.3,0.3]) translate([0,0,-5])
        cylinder(d=hubmotorOD,h=hubmotorZ);
}

// Wheel: twist indicates spiraled grousers
module wheel(twist=0,includeMotor=1,includeSpokes=1) {
    $fa=7.5;
    if (includeMotor) translate([0,0,-wiper]) wiper();
    color (wheelColor)
    {
        wheelRim();
        wheelGrousers(twist);
    }
    if (includeSpokes) color(steelColor) wheelSpokes();
    
    // hubmotor
    if (includeMotor) hubMotor();
}

// Position each wheel at each axle
module wheelAxles() {
    for (side=[-1,+1]) scale([side,1,1]) 
    {
        x=axleX+wiper+rockerBogie*(frameSteel+wiper);
        translate([x,digAxle,axleZ])
            rotate([0,90,0]) wheel(+1);
        
        if (rockerBogie) { // middle axle
            translate([x,middleAxle,axleZ])
                rotate([0,90,0]) wheel(0);
        }
        translate([x,eboxAxle,axleZ]) 
            rotate([0,90,0]) wheel(-1);
    }
}

module radiatorTilt() 
{
    skew=0.2;// pushed down along the z axis as y changes.
    M = [ 
      [ 1  , 0  , 0  , 0   ],
      [ 0  , 1  , 0  , 0   ],  
      [ 0  , skew  , 1  , 0   ],
      [ 0  , 0  , 0  , 1   ] ] ;
    translate(radiatorPivot)
    multmatrix(M)
    translate(-radiatorPivot)
        children();
}

// Radiator panels on top of robot.
//   "Thick" is distance down from top of eBox
//   "Parapet" is distance back from front (cold side)
module radiatorTop(extraZ=0.0,parapet=radiatorMLIthick+1,thick=radiatorMLIthick) 
{ 
    x=cameraOutsideX-2*parapet; // thickness of radiator
    translate([-x,eBoxFrontY-2*parapet,eBoxTop-thick])
        scale([1,-1,1])
            cube([2*x,radiatorThickY,thick+extraZ]);
    
    translate([-x,eBoxFrontY-2*parapet,eBoxTop-thick])
        scale([1,-1,1])
            cube([2*x,25,thick+radiatorPerimeterZ*0.8]);
}

// Rotate_extrude the XY plane around the X axis
module rotate_around_X(angle,convexity)
{
    rotate([0,90,0])
    rotate_extrude(angle=angle,convexity=convexity)
        rotate([0,0,90]) // Y = X
            children();
}


// Entire radiator louver assembly
module radiatorLouver(open=0.5)
{
    radiatorTilt()
    translate(radiatorPivot)
    translate([0,-radiatorThickY*open*0.9,0])
    translate(-radiatorPivot)
    translate([0,0,3]) //<- dust clearance
    color(eColor)
    {
        radiatorTop(0.0,radiatorMLIthick);
    }
}

// Beveled electrical box cube
module bevelcube(size,center=true,bz=1,bevel=25)
{
    hull() {
        cube(size-[2*bevel,2*bevel,0],center);
        cube(size-[2*bevel,0,bz*2*bevel],center);
        cube(size-[0,2*bevel,bz*2*bevel],center);
    }
}

// Electrical box as a solid shape
//  shrink==0 is outside of MLI
module eBoxSolid(shrink=0) 
{
    $fa=45;
    s2=2*[shrink,shrink,shrink];
    difference() {
        color(eColor)
        union()
        {
            // Back electronics box
            translate(eBoxCenter) 
                bevelcube(eBox-s2,center=true);
            
            // Forward battery box
            translate(batteryBoxCenter) 
            hull() {
                bevelcube(batteryBox-s2,center=true);
                // Ridge in middle of battery box (to shed dust)
                translate([0,0,25])
                    bevelcube([100,batteryBox[1],batteryBox[2]]-s2,center=true);
            }
            
            // Raw box for radiator
            translate(radiatorBoxCenter+[0,0,radiatorPerimeterZ/2])
                bevelcube(radiatorBox+[0,0,radiatorPerimeterZ]-s2,center=true,bz=0);
                
        }
        
        // Slot for opening top/back radiator panel
        translate([0,-0.1,0.1])
        radiatorTilt()
        union() {
            translate([0,0,0.1-shrink]) // MLI walls
            color(eColor) {
                radiatorTop(300,radiatorMLIthick-1-shrink); 
            }
            color(radiatorColor) { // radiator floor
                radiatorTop(0.0); 
            }
        }
    }
}


module lightsCameras()
{
    symmetryX() {
        translate(radiatorBoxCenter)
        for (rotTrans=[
            [ [0,0,0], [0,70,0] ],
            [ [0,0,-90], [0,40,0] ],
            [ [0,0,180], [0,70,0] ],
            ])
        rotate(rotTrans[0]) translate(rotTrans[1])
        {
            // Crude model of Intel RealSense:
            color([0.5,0.5,0.5])
                cube([100,25,25],center=true); 
            
            // Lights
            color([1,1,0.8])
                translate([0,50,150])
                    cube([25,25,25],center=true);
        }
    }
}

// Diameter of mounting plate that spins the camera arm
SpinDia=250;

// End of camera arm
module cameraEnd()
{
    // Camera and eyebrow
    linear_extrude(height=70,center=true,scale=1.5) {
        hull() {
            r=50;
            translate([0,50,0]) circle(r=r);
            translate([0,-50,0]) circle(r=r);
        }
    }
    // Light
    color([1,1,1,1])
        translate([0,-90,30])
            cube([30,30,30],center=true);
}

// Build out arm from camera pivot point, at this angle
module cameraArm(cameraAngle=0.0) 
{
    sz=25;
    straight=1000; // arm is flat for this far before bending
    bend=45; // degrees of bend in camera arm
    postbend=500; // arm length after bend
    
    color(steelColor) 
    translate(cameraPivot)
    rotate([0,cameraAngle,0])
    {
        translate([-sz/2,-sz/2,0])
        {
            rotate([-10,0,0])
            translate([0,0,-(cameraSpinDia/2-4)])
                cube([sz,sz,cameraSpinDia/2]);

            cube([sz,sz,straight]);
        }
        
        translate([0,0,straight])
        rotate([-bend,0,0])
        {
            translate([0,0,-0.25*sz])
            {
                translate([-sz/2,-sz/2,0])
                cube([sz,sz,postbend]); 
                translate([0,0,postbend])
                {
                    rotate([-90,0,0]) // Z is in camera look dir
                    {
                        cameraEnd();
                        children();
                    }
                }
            }
        }
    }
    
}

// Disk of MLI that rotates with the camera arm
module cameraArmDisk() 
{
    translate([0,0,0])
        scale([1,-1,1]) rotate([-90,0,0])
            cylinder($fa=5,d=cameraSpinDia,h=eBoxMLI);
}

// Depth camera field of view (Intel RealSense 455)
module drawFOV(hfov=86,vfov=57,distance=4000.0)
{
    hull() {
        cube([1,1,1],center=true);
        translate([0,0,distance])
            cube([
                2*tan(vfov/2)*distance,
                2*tan(hfov/2)*distance,
                1],center=true);
        /*
        for (dy=[-1,+1]) for (dx=[-1,+1])
            rotate([0,vfov/2*dy,0])
            rotate([hfov/2*dx,0,0])
                cube([0.01,0.01,distance]);
        */
    }
}
module aboveGround() {
    difference() {
        children();
        translate([0,0,-10000-wheelDia/2]) cube([20000,20000,20000],center=true);
    }
}

// Electrical box
module eBox() 
{
    if (eBoxAsBuilt==1) { // ground test version with tupperware box
        sz=[480,360,320];
        color(eColor) 
        translate([0,eboxAxle,sz[2]/2]) bevelcube(sz,center=true);
    }
    if (eBoxAsBuilt==0) { // full flight version with radiators and MLI parapet
        // Camera rotation mechanism
        color(eColor) 
        translate(cameraPivot) 
            cameraArmDisk();
            
        difference() {
            eBoxSolid(0);
            
            eBoxSolid(eBoxMLI); // interior space (not MLI)
            
            //eBoxViewSlot(0.0); // space for cameras to see out
            
            symmetryX()
            for (clearancePoint=[boomFrameActuator]) 
                    translate(clearancePoint) {
                        sphere(r=actuatorR*2);
                    }
            
            //translate([1000,0,0]) cube([2000,2000,2000],center=true); // cutaway
        }
        
        /*
        // Dirt-deflecting "eyebrow" over camera facing mining area
        symmetryX() translate(eBoxViewSlotStart)
            translate([0,radiatorBox[1]/2-25,49]) cube([wheelThick,75,2]);
        
        lightsCameras();
        
        eBoxGlass();
        */
    }
}


/*
Excavator arm parts:

The boom connects to the frame at the shoulder.
The stick connects to the boom at the elbow.
*/

module steelCube(shrink,dia)
{
    v=dia-2*shrink;
    cube([v,v,v],center=true);
}
module steelSquare(shrink,dia,chamfer=true)
{
    bevel=2.0;
    s=dia-2*shrink;
    offset(delta=+bevel, chamfer=chamfer) offset(r=-bevel)
    square([s,s],center=true);
}

module steelExtrude(path,symmetry=1) 
{
    color(steelColor)
    for (sym=[-1:2:symmetry]) scale([sym,1,1])
    for (i=[0:len(path)-2])
        hull() {
            translate(path[i]) children();
            translate(path[i+1]) children();
        }
}

// Cut holes for pivot pins, all the way through assembly.
module pivotHoles(holeList,shrink,dia=8) {
    // Cut pivot pin holes
    if (!$FEM_mode) //<- causes lots of weird features
    for (pins=holeList)
        translate([pins[0],pins[1],pins[2]]) rotate([0,90,0])
            cylinder(d=dia+2*shrink,h=2000,center=true);
}


// Reverse this point's X coordinate (mirror symmetry)
function flipX(pt) = [-pt[0],pt[1],pt[2]];

// Draw two copies of this, symmetric along X axis
module symmetryX() { children(); scale([-1,1,1]) children(); }


// Draw a linear actuator starting from this point,
//   and going to this child's linearActuatorEnd.
module linearActuatorBegin(h,fromPoint=[0,0,0])
{
    color([0.7,0.7,0.7])
    if (h) { // hull for shaft of actuator
        hull() {
            translate(fromPoint) linearActuatorEnd(h);
            children();
        }
    } else { // pins
        translate(fromPoint) linearActuatorEnd(h);
        children();
    }
}

// Endpoint of a linear actuator
module linearActuatorEnd(h) {
    if (h) { // round shaft of actuator
        fn=6; // number of sphere segments
        r=actuatorR;
        rotate([0,90,0]) //<- put pole along better axis
        sphere($fn=fn,r=r);
    } else { // pins at ends of actuator
        cube([2*actuatorR+2*wiper+2*frameWall,9,9],center=true);
    }
}

/********* Narrow ore storage scoop / bucket on the front of the robot *******
Target: 50 kg payload, minimally heaped
Design points: 
700 x 280 x 280mm triangle -> 32 liter capacity
300x300 -> 37 liter
350x350 -> 50.8 liter

Things to watch:
    - Scoop pivots 120 deg.  Frame pivots about 45 deg.  Total should be nearly 180 deg to allow fully emptying bucket.
    - Leave room for 38mm wide x 150mm strain gauges on lower supports
    - Watch interference with top frame
*/
strainGaugeSize=[38,150,25]; // exterior dimensions of strain gauge (180kg version)

scoopSize=[740-30-4*frameSteel,350,350];
scoopPivot=[0,100,-frameSteel/2];
scoopTrimAngle=30; // cut out front at this angle (from vertical when loading; from horizontal while hauling)

module scoopSolid(shrink=0)
{
    s2=[2*shrink,2*shrink,2*shrink];
    dy=scoopSize[1]/2;
    dz=scoopSize[2]/2;

    translate(scoopPivot) // put rotational axis at right spot
    {
        
        intersection() {
            translate([0,-dy,dz])
                cube(scoopSize-s2,center=true);
            
            hull() {
                baseSquare=120;
                topTrim=120; // narrower top edge
                // Wide base below
                translate([0,0,dz])
                   cube([scoopSize[0],2*baseSquare,scoopSize[2]]-s2,center=true);
                // Narrower top
                translate([0,-scoopSize[1],dz])
                    cube([scoopSize[0]-topTrim,10,scoopSize[2]]-s2,center=true);
                    
            }
        }
    }
}

// Cut out front side of scoop
module scoopTrim() 
{
    translate(scoopPivot)
    translate([0,0,scoopSize[2]]) rotate([30,0,0])
    translate([0,0,-1000])
        cube([scoopSize[0]+1,2000,2000],center=true);
}

// For computing the interior volume of the scoop:
module scoopVolume() {
    intersection() {
        scoopSolid();
        scoopTrim();
    }
}

// Steel frame around scoop
module scoopFrameSolid(shrink)
{
    // pivot box (leaves inward space)
    symmetryX()
    translate([scoopSize[0]/2+frameSteel/2,0,0]) 
    {
        y=scoopPivot[1]+frameSteel/2; // underneath box
        x=scoopSize[0]/2; // center of box
        z=scoopSize[2]; // front of box
        steelFramePoints=[
            //[frameSteel,0,250], // taper to forward
            [0,-80,80], // forward (linear actuator bolts on here)
            [0,0,0], // pivot point
            [0,y,0], // underneath
            [x,y,0], // center
        ];
        steelExtrude(steelFramePoints,0) steelCube(shrink,frameSteel);
        
        // Tapered support beams under box
        for (dx=[frameSteel+0.1,(frameSteel+x)*2/3]) translate([-dx,0,0])
        {
            // Under
            steelExtrude([[0,y,frameSteel/2],[0,y-frameSteel,z-70]],0) 
                steelCube(shrink,frameSteel);
            // Back
            if (dx>2.0*frameSteel)
            steelExtrude([[0,y,-frameSteel/2],[0,y-scoopSize[1]+100,0]],0) 
                steelCube(shrink,frameSteel);
        }
        
        translate([frameSteel,0,0]) // spacer
            steelCube(shrink,frameSteel);
    }
}

// Graphical version of box:
module scoopBox(solid=0) 
{
    wall=1.0;
    
    difference() {
        scoopFrameSolid(0);
        if (!solid)
            scoopFrameSolid(wall);
        // Keep frame out of interior of box
        scoopSolid();
        // Holes for pivot
        rotate([0,90,0]) cylinder(d=8,h=1000,center=true);
    }
    
    intersection() {
        scoopTrim();
        difference() {
            scoopSolid();
            scoopSolid(shrink=wall);
        }
    }
}


/********* Wide plow on the front of the robot ************/
plowPushForward=250; // length of bar from front axle to plow pivot
plowPushBack=0; // start relative to axle
plowPushUpright=120; // linear actuator push arm

// location of plow pivot point, in box coords
plowBoxPivot=[0,0,0];

// Centerline of plow pusher
plowPushX=axleX-wiper-frameSteel/2;
plowTiltX=-plowPushX+frameSteel;

// Total size of main box:
plowSize=[1300,170,140];

// Pivot point of box, in robot coords
plowFramePivot=[0,digAxle,axleZ];

module plowForkSolid(shrink) {
    crossY=50;
    crossZ=22;
    
    // Forward pusher prongs
    symmetryX()
    hull() for (y=[plowPushForward,plowPushBack])
        translate([-plowPushX,y,0])
        rotate([0,90,0])
            cylinder(d=frameSteel-shrink,h=frameSteel-shrink,center=true);
    /*
    plowFrame=[
        [-plowPushX,plowPushForward,0],
        [-plowPushX,plowPushBack,0]
    ];
    steelExtrude(plowFrame) steelCube(shrink,frameSteel);
    */
    
    // Crossbar
    plowCross=[
        [-plowPushX,crossY,crossZ],[+plowPushX,crossY,crossZ]
    ];
    steelExtrude(plowCross,0) steelCube(shrink,frameSteel);
    
    // Tilt/curl upright
    plowUpright=[
        [plowTiltX,0,0],[plowTiltX,0,plowPushUpright]
    ];
    rotate([45,0,0])
    steelExtrude(plowUpright) steelCube(shrink,frameSteel);
    
    symmetryX()
        translate([-plowPushX-frameSteel/2,plowPushForward,0])
            rotate([180,0,0]) scale([1,1,-1])
            cube(strainGaugeSize);
    
}

// Steel frame that lifts and pushes the plow.
//  Pivots off the front axle
module plowFork() {
    difference() {
        plowForkSolid(0.0);
        plowForkSolid(frameWall);
        
        // Holes for pivot
        for (y=[0,plowPushForward])
            translate([0,y,0])
                rotate([0,90,0]) cylinder(d=8,h=1000,center=true);
        
    }
}

// Steel frame for curl motion
module curlBox() {
    translate([plowTiltX,plowBoxPivot[1],0])
        linear_extrude(convexity=4,height=plowSize[2])
        difference() {
            square([frameSteel,frameSteel],center=true);
            square([frameSteel-frameWall,frameSteel-frameWall],center=true);
        }
}

// Steel box part of plow
module plowBox() {
    wall=frameWall;
    shrinkSz=plowSize-[wall,wall,wall];
    difference() {
        translate([0,plowSize[1]/2,plowSize[2]/2])
        difference() {
            cube(plowSize,center=true);
            cube(shrinkSz,center=true); //hollow inside
            // Trim off front
            rotate([-45,0,0]) translate([0,0,1000])
                cube([2000,2000,2000],center=true);
        }
    }
    
    // steel box for curl
    symmetryX() curlBox();
}

// Set front geometry: either scoop (on robot) or plow (old style)
module plowScoop(fork=0.0,dump=0.0) 
{
    color([0.5+0.1*fork,0.5,0.5]) 
    translate(plowFramePivot)
        rotate([-35+fork*50,0,0])
        {
            plowFork();
            translate([0,plowPushForward,0])
            rotate([-137+dump*120,0,0])
            translate(-plowBoxPivot)
            {
                //plowBox();
                scoopBox();
            }
        }
    
}

/*********** Frame at the bottom of the robot ***********/

// Steel frame
module frameSolid(shrink) {
    // Main sidebars hold wheels together
    x=axleX-frameSteel/2;
    frameSide=[
        [x,digAxle+wheelDia/2,0],
        [x,robotBackY,0] // eboxAxle-wheelDia/2,0]
    ];
    steelExtrude(frameSide) steelCube(shrink,frameSteel);
    
    // Front wheel welded stubs
    steelExtrude([
            [axleX+frameSteel/2,digAxle,0],
            [axleX+frameSteel/2,digAxle,axleZ],
        ]) steelCube(shrink,frameSteel);
    
    if (rockerBogie) {
        x=axleX+wiper+frameSteel/2;
        rocker=[
            [x,eboxAxle,axleZ],
            [x,eboxAxle,0],
            [x,middleAxle,0],
            [x,middleAxle,axleZ]
        ];
        steelExtrude(rocker) steelCube(shrink,frameSteel);
    }
    
    // Crossbars hold robot sides together
    for (y=[crossY,robotBackY])
    {
        frameCross=[ [+x,y,0], [-x,y,0] ];
        steelExtrude(frameCross,0) steelCube(shrink,frameSteel);
    }
    
    if (0) {
        // Reach up and support the boom in fully parked (haul) config
        support=boomElbow-[frameSteel/2,0,boomSteel/2+frameSteel/2+wiper];
        frameSupport=[support,
            [support[0],crossY,0] // reach down to crossbar
        ];
        steelExtrude(frameSupport) steelCube(shrink,frameSteel);
    }
    
    // Leg to support the back of the boom actuator
    boomActuatorSymmetry()
    {
        steelExtrude([boomFrameActuator,
            [boomFrameActuator[0],crossY,0]
          ],0) steelCube(shrink,frameSteel);
        // Diagonal to support that leg
        steelExtrude([
            [boomFrameActuator[0],boomFrameActuator[1],boomFrameActuator[2]*0.9],
            [x,crossY+boomFrameActuator[2]*1.5,0]
          ],0) steelCube(shrink,frameSteel/2);
    }
}

module frameHoles(shrink)
{
    difference() {
        // Pivot holes
        frameSolid(shrink);
        pivotHoles([
            boomShoulder,boomFrameActuator
        ],shrink);
        
        
        if (rockerBogie) 
            pivotHoles([[0,rockerAxle,0]],shrink);
        
        // Axle holes
        pivotHoles([
            [0,eboxAxle,axleZ],
            [0,middleAxle,axleZ],
            [0,digAxle,axleZ]
        ],shrink,3/8*inch);
    }
}

module frameModel(femWheel=0) {
    difference() {
        frameHoles(0.0);
        frameHoles(frameWall);
    }
    
    // Stubs for FEM supports
    if (femWheel)
    symmetryX() for (axle=[eboxAxle,digAxle])
        translate([axleX,axle,0]) {
            translate([50,0,0])
            cube([100,12,12],center=true);
            translate([100,0,0])
            cube([50,50,50],center=true);
        }
}


/********** Boom: first link, between frame and stick ********/
// Solid frame
module boomSolid(shrink=0)
{
    // Main frame
    boomFrame=[
        boomShoulder+[0,boomSteel/2+0.1*shrink,-3],
        boomLat,
        boomPreElbow,
        boomElbow-[0,boomSteel/2+0.1*shrink,0]
    ];
    
    symmetryX()  list_extrudeY(boomFrame)
        steelSquare(shrink,boomSteel,false);    
}

module boomPin() {
    cylinder(d=8,$fn=8,h=1.5*boomSteel);
}

// Saddle and diagonals on boom.
//  (Separate to avoid FEM issues with complex hole)
module boomSolidSaddle(side,shrink) {
    // Crossbar
    if (side) {
        attach=boomShoulder*0.9+boomLat*0.1;
            
        start=boomLat-[boomSteel*0.5,0,3]; // inset 
        boomCross=[start, boomSaddle,
            flipX(boomSaddle), flipX(start)];
        steelExtrude(boomCross,0) 
            steelCube(shrink,boomSteel);
            //rotate([0,90,0]) //<- put pole along better axis
            //sphere(d=saddleOD-2*shrink);
    }
    
    crossbarSteel=1/2*inch;
    if (0) {
        // Diagonal solid crossmember connecting sides
        diagStart=boomLat*0.9+boomPreElbow*0.1;
        diagEnd=flipX(boomLat*0.3+boomPreElbow*0.7);
        diag=[diagStart,diagEnd];
        steelExtrude(diag) 
            steelCube(shrink+1,crossbarSteel);
        //list_extrudeY(diag)
        //    steelSquare(shrink,crossbarSteel);
        
    }
    if (1) {
        // Solid crossmember connecting bottoms (needed?)
        crossR=wiper+boomSteel;
        crossDown=[0,0,-0.9*crossR];
        cross=boomLat*0.8+boomPreElbow*0.2+crossDown;
        steelExtrude([cross,flipX(cross)],0) 
            rotate([5,0,0]) steelCube(shrink+1,boomSteel);
        
        if (shrink==0) symmetryX() translate(cross) rotate([30,0,0]) boomPin();
    }
    
    
    // Connection down to stick actuator
    stickTrussBottom=boomStickActuator-[0,0,60];
    actLeg=[boomPreElbow,boomStickActuator,stickTrussBottom];
    steelExtrude(actLeg) steelCube(shrink+1,boomSteel);
    
    if (0) {
        // Reach down to truss underneath lat
        steelExtrude([boomLat,boomUnderLat]) 
            steelCube(shrink+2,boomSteel);
        
        // Diagonals supporting saddle
        diagShrink=shrink+boomSteel*0.25;
        s=boomSteel-2*diagShrink;
        
        // Bottom diagonals
        dbot=[boomShoulder,boomUnderLat,stickTrussBottom,boomElbow];
        d1=[boomStickActuator,boomUnderLat];
        d2=[boomLat*0.9+boomPreElbow*0.1,stickTrussBottom];
        for (diag=[dbot,d1,d2])
        symmetryX()  list_extrudeY(diag)
            rotate([0,0,15]) //<- for FEM, skew these elements
            square([s,s],center=true);
        
        // steelExtrude(actLeg,0) steelCube(shrink+1,boomSteel);
    }
    
}

boomHoleList=[boomShoulder,boomLat,// -[1500,0,0],
            boomElbow,boomStickActuator];

module boomHoles(shrink) {
    difference() {
        boomSolid(shrink);
        pivotHoles(boomHoleList,shrink);
    }
}

// 2D profile of angle iron
//  Origin is outside corner
module angleSteel2D(wid,thick)
{
    bevel=thick*0.3;
    //offset(r=-bevel) offset(r=+bevel)
    //offset(r=+bevel) offset(r=-bevel)
    {
        square([wid,thick]);
        square([thick,wid]);
    }
}
//"Kneepads": angle iron pad to hold payload during haul
module boomKneepad() 
{
    translate(boomLat) 
    intersection() 
    {
        rotate([7,0,0]) // crudely match top profile
        { // angle iron brackets, to hold water tank and ore bucket while hauling
            flare=10;
            corner=[+boomSteel/2+2,0,boomSteel/2];
            run=0.5*[1.1*boomSteel,boomSteel*3,0];
            list_extrudeY([
                corner+run+[flare,flare,-0.5*flare], // flare entrance
                corner+run,
                corner-2*run, // close off back
                corner-2*run-[20,10,0]
            ],convexity=4) rotate([0,0,90]) angleSteel2D(1/8*inch, 1.5*inch);
        }
        cube([80,200,80],center=true);
    }
}

// Hollow frame with pivot holes
module boomModel(side,wipers,kneepads=1) 
{
    color(steelColor) {
        difference() {
            boomHoles(0.0); // outside of frame
            boomHoles(frameWall); // inside of tubes
        }
        difference() {
            boomSolidSaddle(side,0.0); // outside of frame
            boomSolidSaddle(side,frameWall); // inside of tubes
            boomHoles(frameWall/2); // don't touch inside of existing stuff
            
            pivotHoles(boomHoleList,0);
        }
    }
    
    //if (!$FEM_mode && kneepads)
    //    symmetryX() boomKneepad();
    
    if (wipers) translate(boomShoulder) wiperSteel(boomSteel);
}


module boomActuatorSymmetry() 
{
    symmetryX() // two boom actuators
        children();
}

// Transform into boom coordinates, with this extension
//    Boom coords are like frame coords when extend=0.0
module boomXform(boomExtend)
{
    boomRot=[-boomExtend*125,0,0];
    translate(boomShoulder) rotate(boomRot) 
    translate(-boomShoulder) //<- puts boom stuff back in world coords
        children();
}


/********** Stick: second link, provides reach.  Holds linear actuators ******/

stickBoxCenter=[0,460,140];
stickBoxSz=[320,200,155];

// Secondary warm electronics box for cameras, motor controllers, etc.
module stickBox()
{
    bevel=25;
    translate(stickBoxCenter)
    difference() {
        bevelcube(stickBoxSz,bevel=bevel,center=true);
        s=eBoxMLI;
        bevelcube(stickBoxSz-2*[s,s,s],bevel=bevel,center=true);
    }
}

// RealSense mounted on top of stick
use <camera_mount/realsense_mount/realsense_mount.scad>;
cameraBar=[stickCrossbar[0]-70,370,stickCrossbar[2]+stickSteel];
armCameraX=(6+7/8)*inch/2;
armCameraStart=[armCameraX,cameraBar[1]-1/4*inch,cameraBar[2]];
armCameraEnd=armCameraStart+[0,0,8*inch];

module stickSolid(shrink=0)
{
    diagShrink=shrink+stickSteel*0.25;
    
    // Main frame
    stickMain=[
        stickElbow-[0,stickSteel/2+0.1*shrink,0], // pivot from boom
        stickCrossbar, // big solid crossbar
        stickBoomActuator, // the boom linear pushes here
        stickCouplerPivot+[0,stickSteel/2+0.1*shrink,0] // the coupler pivots here
    ];
    
    //steelExtrude(stickMain) 
    //    steelCube(shrink,stickSteel);

    symmetryX() list_extrudeY(stickMain)
        steelSquare(shrink,stickSteel,0);
    
    // Camera mount crossbar
    steelExtrude([cameraBar,flipX(cameraBar)],0)
        steelCube(shrink,stickSteel);
    
    // Bottom crossbar
    inset=[stickSteel/2,0,0];
    steelExtrude([stickCrossbar-inset,flipX(stickCrossbar-inset)],0)
        steelCube(shrink+1,stickSteel);
    
    // Top crossbar
    top=stickBoomActuator-inset+[0,-25,0];
    steelExtrude([top,flipX(top)],0)
        steelCube(shrink+1,stickSteel/2);
        
    // Reach up for camera mast
    armCamera=[armCameraStart,armCameraEnd-[0,0,stickSteel/2]];
    steelExtrude(armCamera) scale([1,0.5,1]) steelCube(shrink,stickSteel);
    
    if (0) {
    // Crossbar gussets
    steelExtrude([
        [stickCrossbar[0]*0.7,stickCrossbar[1],stickCrossbar[2]],
        stickCrossbar*0.3+stickElbow*0.7
    ]) steelCube(diagShrink,stickSteel);
    }
    
    // Reach out for tilt linear actuator
    tiltCoupX=tiltActuatorX+actuatorR+wiper+stickSteel/2;
    tiltCoup=[
        [tiltCoupX,stickCrossbar[1],stickCrossbar[2]],
        [tiltCoupX,stickCrossbar[1],stickCrossbar[2]-25],
        [tiltCoupX,stickTiltActuator[1],stickTiltActuator[2]]
    ];
    tiltActuatorSymmetry()
    {
        steelExtrude(tiltCoup,0) scale([1,1,0.5]) steelCube(shrink+1,stickSteel);
    }
    
    // Reach up for boom linear actuator
    actBoomX=stickActuatorX-actuatorR-wiper-stickSteel/2;
    stickBoomActuatorOutside=[actBoomX,stickBoomActuator[1],stickBoomActuator[2]];
    actBoom=[
        stickBoomActuator+inset,
        stickBoomActuatorOutside
    ];
    stickActuatorSymmetry()
        steelExtrude(actBoom,0) steelCube(shrink+1,stickSteel);
    
    
    // Diagonals
    stickDiag=[
        stickCrossbar*0.85+stickBoomActuator*0.15,
        flipX(
        stickBoomActuatorOutside
        )
    ];
    steelExtrude(stickDiag,0) steelCube(diagShrink,stickSteel);
}

stickPivotHoles=[stickElbow, // pivot from boom
    stickTiltActuator, // the coupler linear 
    stickBoomActuator, // the boom linear pushes here
    stickCouplerPivot ];
module stickHoles(shrink) {
    difference() {
        stickSolid(shrink);
        pivotHoles(stickPivotHoles,shrink);
    }
}

module stickModel(wipers,box=0) 
{
    color(steelColor) 
    difference() {
        stickHoles(0.0); // outside of frame
        stickHoles(frameWall); // inside of tubes
    }
    
    translate([0,armCameraEnd[1],armCameraEnd[2]])
        cameraMountWithShroud();
    
    if (box) color(eColor) stickBox();
    
    if (wipers) {
        symmetryX() translate([stickXlo,0,0]) wiperSteel(stickSteel);
        symmetryX() translate(stickCouplerPivot) scale([-1,1,1]) wiperSteel(stickSteel);
    }
}

module stickActuatorSymmetry() 
{
    symmetryX() // two stick actuators
        children();
}

// Transform into stick coordinates, with this extension
module stickXform(stickExtend)
{
    stickStart=[0,boomElbow[1],boomElbow[2]];
    stickRot=[15+stickExtend*125,0,0];
    
    translate(stickStart) rotate(stickRot)
        children();
}

/*********** Coupler: holds actual tools at end of arm *******/
// Mates up the coupler with a tool.
//  Coupler is sitting on the -Z side of the origin,
//  flat along X and Y.
module couplerMating2D(shrink=0)
{
    szW=couplerWid-2*shrink;
    szH=couplerHt+2*12+2*shrink;
    
    translate([-szW/2,-szH/2])
        square([szW,szH]);
}

// Solid 3D version of tool mating
module couplerMating(shrink=0)
{
    translate([0,0,-couplerThick-shrink])
    linear_extrude(height=couplerThick,convexity=2)
        couplerMating2D(shrink);
}

// Coupler frame, solid version
module couplerSolid(shrink=0)
{
    $fa=10;
    sz=couplerSize-2*shrink;
    
    // Arm down to tilt actuator
    tiltActuatorSymmetry()
    steelExtrude([
        tiltActuator,
        [tiltActuator[0],tiltActuator[1],couplerPivot[2]],
        [tiltActuator[0],couplerPivot[1],couplerPivot[2]]
    ]) steelCube(shrink,couplerSteel);
    
    // Crossbar between pivot points
    steelExtrude([
        couplerPivot,flipX(couplerPivot)
    ],0) steelCube(shrink,couplerSteel);
    
    // Tool rotation "wrist" gearbox
    translate([0,0,-couplerBearingHeight]) 
    {
        translate([0,0,shrink])
    cylinder(d=couplerDriveDia-2*shrink,h=couplerBearingHeight-30-2*shrink); 
        
        // Steel plate behind the coupler gearbox
        if (shrink==0)
            cube([2*tiltActuator[0],175,0.050*inch],center=true);
        
        scale([1,1,-1]) // model for drive motor
            cylinder(d=50-2*shrink,h=75-shrink);
    }
}
module couplerHoles(shrink) 
{
    difference() {
        couplerSolid(shrink);
        pivotHoles([couplerPivot,tiltActuator],shrink);
    }
}

couplerLockingPinOD=0.5*inch;
module couplerLockingPin(clearance=1)
{
    // Center tool locking pin
    cylinder(d=couplerLockingPinOD+clearance,h=200,center=true);
}

// Sync these with geared_coupler motorPosition
couplerMotorPosition=[0,38.2,-couplerBearingHeight]; 
couplerMotorRotation=[0,0,90];
use <molon.scad>;
use <coupler_2pin/18mm_coupler/18mm_coupler.scad>;

// Coupler model, with Z facing toward attachment
module couplerModel(wipers)
{    
    difference() {
        couplerHoles(0.0);
        couplerHoles(frameWall);
        
        //couplerLockingPin(1);
    }
    
    // Drive motor
    if (0) if (!$FEM_mode)
    translate(couplerMotorPosition) rotate(couplerMotorRotation)
        motor_face_subtract();
        
}

// Electrical charge contacts, in wacky coupler_2pin horn coords (Z left, Y up, X out)
module couplerChargeHorn(expand=0)
{
    for (side=[-1,+1]) translate([-9,75,side*15])
        cube([5,25,25]+2*[expand,expand,expand],center=true);    
}

// Electrical charge contacts, in coupler coords (Z left, Y up, X out) charge contacts
module couplerCharge(expand=0)
{
    color([1,0.5,0.5]) 
    for (side=[-1,+1]) translate([side*15,-23,-6])
        cube([25,25,3]+2*[expand,expand,expand],center=true);    
}

// Coupler pickup horn
module couplerHorn()
{
    color([0.3,0.3,0.3])
    translate([0,0,-40])
    rotate([180,0,0])
    {
        difference() {
            // From coupler_2pin/ directory:
            couplerBaseplateCoordsInv()
                couplerBodySolid(); 
        }
    }
    
    // Electrical contacts
    couplerCharge();
}

// Symmetry for coupler linear actuator(s)
module tiltActuatorSymmetry()
{
    symmetryX() //<- two copies
    scale([-1,1,1]) // <- one copy on right side
        children();
}

// Translate from stick coords to coupler coords
module couplerXform(couplerExtend)
{
    couplerRot=[-170+140*couplerExtend,0,0];
    translate([0,stickCouplerPivot[1],stickCouplerPivot[2]])
    rotate(couplerRot)
    translate([0,-couplerPivot[1],couplerHeight-couplerPivot[2]])
        children();
}

// Used on tools: forms a coupler pickup 
//   Inside=1, outside=0
module couplerPickup(inside)
{
    couplerWall=frameWall;
    couplerClearance=1;
    shrink=inside?-couplerClearance:-couplerClearance-couplerWall;
    
    couplerMating(shrink);
    if (inside>0.5) // also add trim cube
    {
        // Sloped bottom trim, to leave slot to pick up tool
        //translate([0,90,-20]) rotate([-45,0,0]) cube([1.1*couplerSize,50,100],center=true);
        
        // Hole for coupler pin
        //couplerLockingPin(couplerClearance);
    }
}

// Complete prefab coupler pickup (tool side)
module couplerPickupFull()
{
    color([0.9,0.5,0.2])
    translate([0,-10.5,0]) //<- line up tool with horn
    {
        difference() {
            couplerPickup(0);
            couplerPickup(1);
        }
        // two pins:
        for (hole=[-couplerHt/2,+couplerHt/2])
            translate([0,hole,-16])
                rotate([0,90,0])
                    cylinder(d=8,h=couplerWid+8,center=true);
    }
}



/****************** Tool: Water Tank **********/
waterTankMLI=25; // thickness of water tank multi-layer insulation
waterTankD=550-2*waterTankMLI; // outside diameter, in mm, of water tank
waterTankR=waterTankD/2;

if (0)
{ // Recompute water tank height from interior volume
    waterTankV=130; // volume, in liters, of water tank and headspace
    vmm=waterTankV*1000*1000; // volume in cubic mm (L->cc->mm^3)
    vsph=4/3*3.141592*pow(waterTankR,3); // volume of spherical portion
    vcyl=vmm-vsph; // volume of cylindrical portion
    acyl=3.141592*pow(waterTankR,2); // area of cylindrical portion
    hs=vcyl/acyl;
    waterTankH=(hs>0)?hs:0; // don't let height go negative
    echo("waterTankH=",waterTankH);
} 
waterTankH=328.75;

waterTankWall=0.020*inch; // wall thickness of water tank (balloon tank)
waterTankStand=0.060*inch; // wall thickness of steel stand
waterTankStandSteel=steel34;
waterTankStandZ=-75; // stand height below bottom of tank
waterTankStandR=250; // outside of ring stand

// Make a hemispherical water tank.  
//  Stands up in +Z, origin in middle of bottom of tank
module waterTank(shrink=0) {
    r=waterTankD/2;
    h=waterTankH;
    
    $fa=2;
    $fs=3.0;

    // Body of tank:
    hull() {
        translate([0,0,r]) sphere(r=r-shrink);
        translate([0,0,r+h]) sphere(r=r-shrink);
    }
    // Drain/fill pipe: FIXME quick detatch?  Self-aligning plug?
    pipeDia=25.0; // ID of pipe: 200L in 1 hour = flowrate 0.12 m/s
    translate([0,0,waterTankStandZ+25-0.1*shrink])
    //rotate([-90,0,0])
        cylinder(d=pipeDia-shrink,h=waterTankR*0.9+0.1*shrink);
}

// Translate/rotate from tank coords (origin at ground) to coupler coords (origin at coupler) if dir=1, back if dir=-1
module waterTankXform(dir=+1) {
    rh=[0,0,waterTankR+waterTankH]; // up to top hemisphere
    rc=[0,600,waterTankStandSteel/2+waterTankR+waterTankMLI]; // radius to coupler
    locAngle=[90,0,0]; // locator angle on tank
    tiltAngle=[180,0,0]; // angle of coupler to tank
    if (dir==+1) {
        rotate(locAngle) 
        translate(rc) rotate(tiltAngle)
            children();
    } else /* dir==-1 */ {
        rotate(-tiltAngle) translate(-rc) 
        rotate(-locAngle)
            children();
    }
        
}

module waterTankStandSolid(shrink) {
    // Ground contact box
    standR=waterTankStandR;
    z=waterTankStandZ+waterTankStandSteel/2;
    r=standR-waterTankStandSteel/2-1;
    frame=[[+r,0,z],[0,+r,z],
           [-r,0,z],[0,-r,z]];
    $fa=5;
    
    // Ring tube around tank
    color(steelColor) 
    translate([0,0,waterTankStandZ])
    if (shrink==0) 
        difference() {
            cylinder(r=standR,h=waterTankStandSteel);
            translate([0,0,frameWall]) // inner carve out to angle
                cylinder(r=standR-frameWall,h=2*waterTankStandSteel);
            translate([0,0,-1]) // thru hole
                cylinder(r=standR-waterTankStandSteel,h=2*waterTankStandSteel);
        }
    
    // Tubes attaching down to the tank
    rotate([0,0,45]) //<- pure aesthetic rotation
    for (end=frame)
        steelExtrude([[0,0,waterTankR],end]) 
            steelCube(shrink,waterTankStandSteel);
    
    // Pickup attaching to the coupler
    waterTankXform() {
        
        translate([0,0,waterTankStandSteel/2+frameWall]) {
            range=couplerHt/2;
            ylo=-range; 
            yhi=+range;
            xlo=-couplerWid/2+waterTankStandSteel/2-4; 
            xhi=-xlo;
            for (y=[ylo,yhi])
                steelExtrude([
                    [xlo,y,0],[xhi,y,0],
                ],0) steelCube(shrink,waterTankStandSteel);
            // Vertical crossbars:
            for (x=[xlo,xhi])
                steelExtrude([
                    [x,ylo,500],
                    [x,ylo,0],
                    [x,yhi,0],
                    [x,300,100]
                ],0) steelCube(shrink,waterTankStandSteel);
        }
    }
}

// MLI overwrap around water tank
module waterTankMLI() 
{
    color(MLIColor)
    difference() {
        waterTank(-waterTankWall-waterTankMLI);
        waterTank(-waterTankWall);
    }
}

// WaterTank with mounting and anti-tip hardware
module waterTankStand(withMLI=1) {
    difference() {
        union() {
            waterTank(-waterTankWall);
            difference() {
                waterTankStandSolid(0.0);
                waterTankStandSolid(waterTankStand);
            }
            waterTankXform() 
                couplerPickupFull();
        }
        waterTank(0.0); // clean out whole inside of tank
    }
    // Wrap everything in a layer of MLI
    if (withMLI) waterTankMLI();
}

// WaterTank attached to coupler
module waterTankCoupled() {
    waterTankXform(-1)
        waterTankStand();
}



/************ Ripper bucket ******/
ripperBucketCutting=[300,150];
ripperBucketWide=200;
ripperBucketWall=1.5;
shovelCuttingAngle=0;
module ripperBucket2DSolid(shrink) {
    hull() {
        // Back side
        translate([shrink,-couplerSize/2+shrink/2,0])
            square([1,couplerSize]);
        
        // Rounded bottom
        intersection() {
            r=230;
            translate([70,-130+r])
                circle(d=2*r-2*shrink,$fa=10);
            
            // Trim top and back of cutting edge
            translate([shrink,100])
            scale([1,-1,1])
                square([1000,1000]);
            
            // Trim bottom so it lies flat
            translate([0,-240])
            rotate([0,0,45])
            translate([0,shrink])
                square([1000,1000]);
        }
        
        // Cutting tip
        translate(ripperBucketCutting)
        translate([-shrink,shrink])
            square([1,1]);
    }
}
//ripperBucket2DSolid(0);

module ripperBucket2D(wall=1.5) {
    difference() {
        ripperBucket2DSolid(0.0);
        ripperBucket2DSolid(wall);
    }
}

module shovel2Dto3D() {
    rotate([0,-90,0]) scale([1,-1,1])
        children();
}

module ripperBucketProxy(wide=10.0)
{
    shovel2Dto3D() linear_extrude(height=wide) ripperBucket2D(wide);
}
module ripperBucketInside() 
{
    shovel2Dto3D()
        linear_extrude(height=ripperBucketWide,center=true,convexity=4)
            ripperBucket2DSolid(ripperBucketWall);
}

// skew Z along Y axis
module skewZY(skew)
{
    M = [ 
      [ 1  , 0  , 0  , 0   ],
      [ 0  , 1  , skew  , 0   ],  
      [ 0  , 0  , 1  , 0   ],
      [ 0  , 0  , 0  , 1   ] ] ;
    multmatrix(M) children();
}

module ripperBucket3D(pickup=1,wide=ripperBucketWide,wall=ripperBucketWall) 
{
    color([0.6,0.7,0.8])
    difference() {
        union() {
            translate([0,0,2]) shovel2Dto3D()
            {
                linear_extrude(height=wide,center=true,convexity=4)
                    ripperBucket2D(wall);
                for (side=[-1,+1]) scale([1,1,side])
                    translate([0,0,wide/2])
                    linear_extrude(height=wall)
                        ripperBucket2DSolid(0.0);
            }
                
            // Sharpened ripper teeth
            toothWide=6;
            toothLong=40;
            toothHigh=12;
            del=(wide+2*wall-toothWide)/4;
            for (sharp=[-2*del:del:+2*del])
            translate([sharp,-ripperBucketCutting[1],ripperBucketCutting[0]-3.5])
                rotate([shovelCuttingAngle,0,0])
                skewZY(1.0)
                    cube([toothWide,toothLong,toothHigh],center=true);
        }
    }
            
    // Sheet metal pickup attachment
    if (pickup) couplerPickupFull();
}
//ripperBucket2D(10.0);

/************** Tool: Ore bucket, for bulk ore transport ************
Constraints:
    Haul hundreds of kg of ore back to the water extractor.
    Reach over using rock hammer to reduce movement costs?
*/
oreBucketSz=[1000,320,200];
oreBucketStart=[0,0,180]; // <- coupler relative to ore bucket
oreBucketWall=1.5; // thickness of sheet metal walls

module oreBucket3DSolid(shrink) {
    hull() {
        // Back side
        translate(oreBucketStart+[0,2+shrink,0])
            cube([couplerWid,1,couplerHt],center=true);
        
        // Big block
        translate([0,oreBucketSz[1]/2,0])
            cube(oreBucketSz-2*[shrink,shrink,shrink],center=true);
    }
}

// Translate ore bucket coords to coupler coords
module oreBucketToCoupler()
{
    rotate([90,0,0]) translate(-oreBucketStart)
                children();
}

// Solid 3D shapes reinforcing the ore bucket
module oreBucketReinforcing(shrink=0) 
{
    steelExtrude([
                [couplerWid/2-5,-couplerHt/2+15,0],
                [210,120,oreBucketSz[1]]
               ]) steelCube(shrink,couplerSteel/2);

    if (shrink==0)
    oreBucketToCoupler() translate([0,oreBucketSz[1]/2+300,-oreBucketSz[2]/2])
        for (isoangle=[0:60:120]) rotate([0,0,isoangle])
            for (isogrid=[-600:300:600]) translate([0,isogrid,0])
                cube([1600,1.5,150],center=true);
    
    /*
    symmetryX()
    {
        list_extrudeY([
            [60,-couplerSize/2,-15],
            [290,300,115]
           ]) steelSquare(shrink,couplerSteel);
        
        topY=-couplerSize/2+40;
        steelExtrude([
            [0,topY,-10],
            [400,topY,10]
           ]) steelCube(shrink,couplerSteel);
        
        bottomY=+couplerSize/2-60;
        steelExtrude([
            [0,bottomY,couplerSteel/2],
            [couplerSize/2,bottomY,couplerSteel/2],
            [360,bottomY,35]
           ]) steelCube(shrink,couplerSteel);
    }
    */
}
module oreBucket3D(wall=oreBucketWall) 
{
    color([0.6,0.7,0.8])
    translate([0,0,1])
    difference() {
        union() {
            oreBucketToCoupler() oreBucket3DSolid(0.0);
            
        }
        
        difference() {
            union() {
                // Clear out inside of bucket
                for (step=[0,10]) 
                oreBucketToCoupler() translate([0,0,step]) oreBucket3DSolid(wall);
            }
            // Put back in some metal to hold sides together
            difference() {
                oreBucketReinforcing(0.0); // outside
                oreBucketReinforcing(frameWall); // inside of tubes   
            }
        }
        
    }
            
    // Sheet metal pickup attachment
    couplerPickupFull();
}



/************** Tool: Hammer drill, for breaking rocks & ore ***********/
// Hammer drill, like held by coupler
module rockBreaker(bitonly=0) {
    if (!bitonly) //
    {
      couplerPickupFull();
      couplerCharge(-1.4);
      
      // Mini ripper bucket, to load broken rocks
      rotate([0,0,90]) 
      translate([0,-couplerSize/4,couplerSize/4]) 
          rotate([90,0,0]) 
           scale([1,0.4,1]) 
               ripperBucket3D(0);
    }
    translate([0,0,50])
    {
        if (!bitonly)
        // Drive box
        translate([0,-100,2])
            cube([100,400,100],center=true);
        
        
        len=300; // length of chisel from pivot center
        head=50;
        // Shank
        color(steelColor) 
        {
            rotate([-90,0,0])
                cylinder(d=12,h=len-head);
            hull() {
                // Transition to shank
                translate([0,len-head,0])
                    sphere(d=12);
                // Cutting edge
                translate([0,len,0])
                    cube([20,1,1],center=true);
            }
        }
    }
}


/****************** Entire robot arm *************/
// Pin used to connect modules together
module pin(dx=1) {
    translate([dx*frameSteel/2,0,0])
    rotate([0,90,0])
    cylinder($fn=8,h=frameSteel+2*wiper+frameSteel+1,d=8.1,center=true);
//    cube([frameSteel+2*wiper+frameSteel,7.9,7.9],center=true);
}

// Actual travel tends to overshoot these by a few mm:
actuatorType_20inch=[630,1140];
actuatorType_12inch=[415,720];

// Illustration ring for actuator travel
module actuatorRing(actuatorRadius)
{
    $fa=1;
    $fs=0.5;
    h=3;
    wid=1;
    rotate([0,90,0]) // all our actuators pivot around X
    difference() {
        cylinder(r=actuatorRadius+wid,center=true);
        cylinder(r=actuatorRadius-wid,h=10+h,center=true); // hole
    }
}

// Draw actual physical actuator travels (as min/max circles)
module actuatorTravel(center,actuatorType)
{
    translate(center) {
        actuatorRing(actuatorType[0]);
        actuatorRing(actuatorType[1]);
    }
}

boomActBegin=[-boomActuatorX,boomFrameActuator[1],boomFrameActuator[2]];
boomActType=actuatorType_20inch;

stickActBegin=[-stickActuatorX,boomStickActuator[1],boomStickActuator[2]];
stickActType=actuatorType_12inch;

couplerActBegin=[-tiltActuatorX,stickTiltActuator[1],stickTiltActuator[2]];
couplerActType=actuatorType_12inch;

module drawLinearActuator(config,
    linkBegin,actBegin,
    linkEnd,actEnd)
{
    for (s=[[1,1,1]]) // [1,1,1]
    color(actuatorColor)
    for (h=[0,1]) 
    if(h==1) { // outer surface of actuator
        hull() {
            linkXformWorld(config,linkBegin) scale(s) translate(actBegin) linearActuatorEnd(h);
            linkXformWorld(config,linkEnd) scale(s) translate(actEnd) linearActuatorEnd(h);
        }
    } else { // pins at ends of actuators
        linkXformWorld(config,linkBegin) scale(s) translate(actBegin) linearActuatorEnd(h);
        linkXformWorld(config,linkEnd) scale(s) translate(actEnd) linearActuatorEnd(h);
    }
}
    
// Main forward kinematics function:
//   Takes an arm configuration (config), a list of extension amounts.
//   Draws the arm and translates down
module arms(config,actuators=1,models=1,pins=1,wipers=1,travel=0)
{
    linkXformParent(config,boomLink)
    {
        if (models) boomModel(0,wipers);
        
        //linkXformParent(config,tiltLink)
        {
            linkXformParent(config,stickLink)
            {
                if (models) stickModel(wipers,actuators);
                
                linkXformParent(config,couplerLink)
                {
                    if (models) couplerModel(wipers);
                    
                    linkXformParent(config,wristLink)
                    {
                        if (models) couplerHorn();
                        // Tool origin: at face of coupler
                        children();
                    }
                }
                
                if (pins) symmetryX() translate(stickCouplerPivot) pin(-1);
                if (travel) actuatorTravel(couplerActBegin,couplerActType);
            }
            
            if (pins) symmetryX() translate(boomElbow) pin(-1);
            if (travel) actuatorTravel(stickActBegin,stickActType);
        }
    }
    
    if (pins) symmetryX() translate(boomShoulder) pin();
    if (travel) actuatorTravel(boomActBegin,boomActType);
    
    if (actuators) 
    {
        boomActuatorSymmetry()
        drawLinearActuator(config,
            undef,boomActBegin,
            boomLink,[-boomActuatorX,boomLat[1],boomLat[2]]);
        
        stickActuatorSymmetry()
        drawLinearActuator(config,
            boomLink,stickActBegin,
            stickLink,[-stickActuatorX,stickBoomActuator[1],stickBoomActuator[2]]);
        
        tiltActuatorSymmetry()
        drawLinearActuator(config,
            stickLink,couplerActBegin,
            couplerLink,[-tiltActuatorX,tiltActuator[1],tiltActuator[2]]);
    }
}


// Working volume study
module workingVolume(nBoom=8,nStick=8,nCoupler=8) 
{
            //for (tilt=[-1.0,+1.0])
    for (boomExtend=[0.0:1.0/nBoom:1.0])
        for (stickExtend=[0.0:1.0/nStick:1.0])
            if (stickExtend-2.0*boomExtend<0.60) // <- don't ram box
            for (couplerExtend=[0.0:1.0/nCoupler:1.0])
                //if (boomExtend<stickExtend+0.75) //<- don't curl in too close
                color([couplerExtend,stickExtend,boomExtend])
                arms([boomExtend,stickExtend,couplerExtend,0.0],0,0,0,0)
                    children();
}


// Rollcage / whip antenna, probably carbon or basalt fiber
module rollcage()
{
    $fa=5;
    thick=8; // thickness of rollcage material
    r=625; // radius of rollcage
    x=axleX-frameSteel; // where rollcage hits frame
    startZ=wheelDia/2; // need to stay above wheels
    centerZ=startZ+sqrt(r*r-x*x); // Z to put rollcage on base
    echo("Top of rollcage=",wheelDia/2+centerZ+r);
    
    cen=[0,(radiatorBoxCenter+0.5*radiatorBox)[1]-thick-eBoxMLI,centerZ];
    
    color([0.5,0.3,0.1])
    difference() {
        translate(cen) rotate([90,0,0])
            cylinder(r=r+thick,h=thick,center=true);
        translate(cen) rotate([90,0,0])
            cylinder(r=r,h=2*thick,center=true);
        
        // Trim off bottom
        translate([0,0,-2000+startZ]) 
            cube([4000,4000,4000],center=true);
    }
}

// Illustrate various mining depths.
module miningDepths() {
    translate([1000,2000,0]) {
        // 0.2m dust overburden
        color([0.3,0.3,0.3])
        translate([0,0,800])
            cube([1000,1000,200]);
        
        // 0.8m granular bench
        color([0.3,0.5,0.7])
        cube([1000,1000,800]);
        
        // 2.5m hard icy layer
        translate([0,0,-2500])
        color([0.3,0.7,0.8])
            cube([1000,1000,2500]);
    }
}

/**************** Whole robot *************/

configCarryBig=[0.0,0.6,0.05,0]; // carry big thing, like water tank
configCarryOre=[0.0,0.18,0.25,0]; // carry ore bucket, for hauling
configPickupOre=[0.65,0.05,1,0]; // pick up ore bucket from ground
configDumpOre=[0.6,0.9,0.25,-0.6]; // dumping ore bucket into water extractor
configPlow=[0.84,0.25,0.38,0]; // plow with ore bucket, for roadbuilding
//configWaterDrop=[0.05,0.2,0.38,0]; // putting down heavy thing right in front
configWaterDrop=[0.4,0.19,0.725,0]; // putting down heavy thing on plow

configDeployOverhang=[0.0,0.1,1.0,0]; // deployment position, hanging off side, electronics up
configDeployDown=[1.0,0.05,0.65,0]; // deployment position, mounted on the wall, electronics down

//configDigShovel=[1.0,0.5,0.75,1.0]; // dig down with ripper bucket
configDigShovel=[0.7,0.3,0.75,1.0]; // dig down with ripper bucket

configGrind=[0.7,0.4,0.5,1.0]; // mid-grind

configRipHoe=[1.0,0.8,0.75,1.0]; // mid-rip
configRipShovel=[0.7,0.4,0.5,0.0]; // mid-rip
configRipClose=[0.6,0.4,0.75,1.0]; // mid-rip

configBreakOut=[0.95,0.9,0.65,0]; // rockbreaking forward

configReachOut=[1,1,0.55,0]; // reaching out forward
configReachUp=[0.6,1.0,0.1,0]; // reaching up high
configPickUp=[0.8,0.3,1.0,0]; // tool pick-up
configCrunch=[0,0.15,1.0,0]; // scrunched up
configPhotoOp=[0.6,0.7,0.45,0]; // overview photo


module robot(config,plowUp=1,cameraArm=0,radiatorOpen=0.75) {
    translate([0,0,-axleZ+wheelDia/2]) {
        frameModel();
        
        if (eBoxAsBuilt==0)
            radiatorLouver(radiatorOpen);
        
        eBox();
        // Tow / charge block on back:
        if (eBoxAsBuilt==0)
            translate([0,eBoxBackY-2,100]) 
                rotate([-90,0,0]) couplerPickupFull();
        
        wheelAxles();
        
        // Plow motion study
        if (0)
        for (plowFork=[0,1]) // :1.0:1.0])
            for (plowDump=[0.0:0.25:1.0])
                plowScoop(plowFork,plowDump);
        if (0) {}
        else if (plowUp==-1) {
            plowScoop(0,0); // dumping position
            //plow(0.6,0.6);// scooping position
        } else if (plowUp==+1) {
            plowScoop(1,1);// fully upright, hauling position
        } else {
            plowScoop(0.40,0.50);// loading position
        }
        
        // Camera arm
        if (cameraArm) {
            cameraArm(-30.0); // upright version
            //#aboveGround() cameraArm(0.0) drawFOV(); // forward drive
            //#aboveGround() cameraArm(-45) drawFOV(); // mining
            //#aboveGround() cameraArm(-90) drawFOV(); // flat
            //#aboveGround() cameraArm(-100) drawFOV(); // stowed
        }
        // Range of motion:
        //for (angle=[-135:45:+135]) cameraArm(angle);
        
        
        // Travel check:
        if (0)
        for (travel=[0.6:0.1:1.0])
            arms([1,travel,0.6,0.0], 1,1,1,1,0)
                rockBreaker();

        arms(config) children();
        
        // Tool motion studies:
        //workingVolume(4,4,8) cube([20,200,couplerThick/3],center=true); // coupler face

        if (1) // motion study
        workingVolume(4,4,6) 
        //workingVolume(8,8,8) 
        //rotate([0,0,180]) // inverted attach (bucket facing down)
        {
            //children();
            //scale([1,-1,1]) ripperBucketProxy(1.0); // ripper bucket (curl in)
            //scale(0.3) oreBucket3D(10.0); // ore bucket
            
            //scale([1,-1,1]) // facing up
            //    rockBreaker(1); // tip of hammer drill (facing down)
        }
        
        //cube([180,1000,1000]); // robot cutaway
        
        // rollcage / antenna
        //rollcage();
    }
    
    //miningDepths();
}


// Whole steel frame, for mass calculation
module steelMass() {
    frameModel(0);
    translate(plowFramePivot) plowFrame();
    arms(configCarryBig,0,1,0,0); // steel only
}

// Row of tools
module toolsRow()
{
    translate([0,300,0]) {
        color([1,1,1]) cube([20000,20000,1],center=true);
        
        translate([0,1300,281]) rotate([-90,0,0]) oreBucket3D();
        
        translate([1100,1300,170]) rotate([-135,0,0]) ripperBucket3D();
        
        translate([1900,1100,675]) rotate([-90,0,-30]) waterTankCoupled();
        
        translate([2400,500,100]) rotate([-180,0,-70]) rockBreaker();
    }
    
    // For camera alignment: cubes
    cube([4,4,4]);
    translate([-500,200,250]) cube([3,3,3]);
}

module Excahaul_hauling() {
    robot(configCarryOre,0,1) oreBucket3D(); 
}


include <rockgrinder/rockgrinder_frame.scad>;

/*
// Ore bucket ready to receive ore:
translate([0,1100,320]) 
rotate([-180,0,0])
oreBucket3D();
*/

if (0)
color([0.3,0.5,0.7]) // permafrost
translate([1500,2000,0]) cube([1000,1000,800]);

if (is_undef($subpart)) 
{
// Outputs directly from this file: uncomment only one
    //fem();
    
    /*translate([245,0,0])
    rotate([0,0,14.7]) cube([25,600,25]);*/
    
    //difference() 
    {
        //robot();
        //robot(configPhotoOp,1,1);
        
        configAnimate=[configDigShovel[0],
            configDigShovel[1],$t,configDigShovel[3],configDigShovel[4]];
        //robot(configAnimate,0) ripperBucket3D();
        robot(configGrind,0) rockgrinder3D(1,1);
        //robot(configRipClose,0) ripperBucket3D();
        
        if (0) { // illustrates dig-haul cycle
            translate([2000,0,0]) 
                robot(configRipHoe,0) rockgrinder3D(1,1);
        
            robot(configPickupOre,1);
        
            translate([-2000,0,0])
                robot(configCarryOre,-1);
        }
        
        //robot(configCarryOre,1) oreBucket3D(); 
        //robot(configPickupOre,0) oreBucket3D(); 
        //robot(configPlow,0) oreBucket3D(); 
        //robot(configDumpOre,-1) oreBucket3D(); 
        
        //robot(configReachOut,0) rockBreaker(); // reaching out
        //robot(configBreakOut,0) rockBreaker(); // reaching out
        
        //robot(configCarryBig,1) waterTankCoupled(); // watertank carry position
        //robot(configWaterDrop,0) waterTankCoupled(); // watertank dropoff position
        
        // Body positions
        //robot(configPickUp); // tool pick-up
        //robot(configCrunch); 
        //robot(configDeployOverhang);
        //robot(configDeployDown);
        //robot(configReachUp);
        
        
        // Cutaway
        //translate([1000,0,0]) cube([2000,5000,5000],center=true);
    }
    //eBoxSolid(eBoxMLI);
    
    // 1m scale bar:
    //translate([-600,0,-100]) color([0,0,0]) cube([3,1000,3],center=true);

    //translate([-750,0,10]) color([0,0,0]) cube([3,1300,3],center=true);
    
    //translate([0,-800,10]) color([0,0,0]) cube([1200,3,3],center=true);

    //toolsRow();
    
// Ore bucket in rock hammer & pickup position
//translate([0,810,280]) rotate([-90,0,0]) oreBucket3D(); // upright (stack)
//translate([0,1100,310]) rotate([180-3,0,0]) oreBucket3D(); // forward (scoop)


//scale([1,1,-1]) cube([1,500,450]);

// Models:
//scale(0.001) // export meters for Blender & Unity
{ 
    $fs=0.1;
    //oreBucket3D();

    //waterTankStand(0);
    //waterTankMLI();

    //workingVolume() scale(0.3) couplerMating();
    //workingVolume(4,4,6) rotate([0,0,45]) rockBreaker();

    //frameModel();

    //radiatorLouver(0.0); // .21);
    //eBox();

    //wheel(+1,0,1); // spiral wheel
    //wheel(0,0,1); // straight wheel
    //wheel(-1,0,1); // spiral wheel

    //arms(configCrunch);
}

} // end subpart

