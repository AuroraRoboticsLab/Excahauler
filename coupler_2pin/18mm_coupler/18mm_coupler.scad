/*
 2-pin tool coupler, slightly larger size using 18mm diameter pins.
 
 Assembly order:
    - Print two halves of main body
    - Glue halves together with 100m x 4mm basalt dowel rods
    - Weld retaining thumb assembly
        - Weld crossbar onto rods
        - Weld sideplates and pivot pin around 3D printed link 0
        - Weld link 0 - link 1 crossbar to steel pull rod
    - Drop in thumb and slide down
    - Attach pin 2 of thumb with thumb blocks
    - Verify travel
    - Close out inside with baseplate
    - Bolt to gearbox
 
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2022-01-06 (Public Domain)
*/
inch=25.4; // file units are mm

include <../tool_coupler_interface.scad>;

pinLen=pinSlot-2; // left-right pin length (minus a little space)
knuckleOR=knuckleSpace-3; // total pickup thickness around pins
knuckleTaper=10; // Z thickness of knuckle taper

include <../electric_coupler.scad>;

// Build parameters:
eSheet=0.032*inch; // sheet steel under electrical coupler
baseplateCenter=[0,-85,15]; // where gears sit relative to coupler

// Origin of the mini coupler's bottom pin
hasMini=true; // set to false for better closure, no mini hook (backward compatible tools)
miniOrigin=[0,-125+5,-knuckleOR+12];
miniHookSlot=80;
miniSideSlotWide=4; // sheet metal sits in this channel
miniSideSlotDeep=9; // sheet metal sticks this far up above pin centers
miniSideSlotEnd=32; // sticks this far down below lower pin

/* Top face center of electrical coupler */
ecoupler_center=ecoupler_top_corner+[0,-ecoupler_sz[1]/2,0];

// Parameters of the baseplate that mounts to the wrist gearbox
baseplateOD=150;
baseplateThick=8;
nBaseplateScrews=8;
baseplateScrewR=70.5; // <- from geared coupler print
baseplateMetal=0.065*inch; // thickness of metal under baseplate

// Under our baseplate, this is the gearbox space
gearboxOD=182;
//#translate(baseplateCenter+[0,0,0]) cylinder(d=gearboxOD,h=1);

module couplerBaseplateCoords()
{
    translate(baseplateCenter)
        children();
}
module couplerBaseplateScrewCenters()
{
    da=360/nBaseplateScrews;
    couplerBaseplateCoords()
        for (angle=[da/2:da:360-1])
            translate([0,0,(angle<180)?-24:0]) //<- thicker base for top screws
            rotate([0,0,angle])
            translate([baseplateScrewR,0,-baseplateThick])
                children();
}
module couplerBaseplateScrews()
{
    couplerBaseplateScrewCenters()
    translate([0,0,0])
    rotate([180,0,0])
    {
        cylinder(d=4.8,h=100,center=true); // screw shaft
        cylinder(d=0.39*inch,h=100); // screw head
    }
}

module couplerThumbHole()
{
    // Central hole for thumb actuator stick, wiring, etc
    couplerBaseplateCoords()
        cylinder(d=75,h=25,center=true);
}

module couplerBaseplate()
{
    couplerBaseplateCoords()
    difference()
        translate([0,0,-baseplateThick/2])
            cylinder(d=baseplateOD,h=baseplateThick+0.01,center=true);
}

// Cut geometry flush with back of baseplate
module couplerBaseplateFlush()
{
    couplerBaseplateCoords() { 
        // clearance for baseplate gearbox
        cylinder(d=gearboxOD,h=50);

        // clearance for baseplate screw heads
        screwHeadHt=4;
        screwHeadR=10;
        rotate_extrude() 
            translate([(gearboxOD+baseplateOD)/2/2,screwHeadR-screwHeadHt]) 
                circle(r=screwHeadR);

        // top half is just flat
        //translate([0,200,200]) cube([400,400,400],center=true);
    }
}


module symmetryX() {
    for (side=[-1,+1]) scale([side,1,1])
        children();
}


// Thumb for locking the lower pin in place: fabricated from 1/2" steel box tubing
//   To lock pins, a rod pulls the linkage flat, from outside.
thumbOD=0.505*inch;
thumbWall=0.065*inch;
thumbRound=1.2; // corners rounded with this radius
thumbID=thumbOD-2*thumbWall; // inside hole
thumbLen=65; // length of thumb grabber rods
thumbTravel=15; // Y distance thumb moves in normal operation
thumbWiggle=0.3; // space around thumb travel slots
thumbCenterX=50; // centerline of thumbs (near edges is more secure)
thumbCenterZ=-pinOD/2-thumbWall+thumbOD/2; // puts inside wall on top of pin
thumbCrossbarZ=thumbCenterZ+thumbOD; // crossbar is welded below pins
thumbCrossbarY=-pinSep+thumbLen-thumbOD/2; // centerline of crossbar

thumbLinkageRod=3/16*inch; // steel rod connecting linkage parts
thumbLinkageOD=12; // printed linkage parts
thumbLinkageY=thumbCrossbarY+thumbOD/2+thumbLinkageOD/2+1; // link 0 bar location
thumbLinkageWidth=50; // total width of linkage blocks

thumbBlockSize=[12,thumbLinkageOD,25]; // blocks hold fixed end of linkage
thumbBlockCenter=[thumbLinkageWidth/2+thumbBlockSize[0]/2+3,
    thumbLinkageY+2*thumbTravel,
    baseplateCenter[2]-thumbBlockSize[2]/2];
thumbBlockBevel=2;
thumbBlockWiggle=[1,1,1]*0.2;

// Make thumb section centered on the origin
module thumbSection2D(shrink=0) {
    offset(r=thumbRound) offset(r=-thumbRound-shrink) square([thumbOD,thumbOD],center=true);
}

// Make thumb cross section, centered on X, with Y==0 at center of pin
module thumbExtrusion2D(shrink=0,hollow=1) {
    difference() {
        thumbSection2D(shrink);
        if (hollow)
            thumbSection2D(shrink+thumbWall);
    }
}

// Make a steel rod facing along +Y, centered on the origin in X and Z
module thumbRod3D(height,shrink=0,hollow=1) {
    rotate([-90,0,0]) linear_extrude(height=height,convexity=4) 
        thumbExtrusion2D(shrink,hollow);
}

// Beveled cube
module bevelcube(size,bevel,center=false,bz=1)
{
    translate(center?[0,0,0]:size/2)
    hull() {
        cube(size-[2*bevel,2*bevel,0],center=true);
        cube(size-[2*bevel,0,bz*2*bevel],center=true);
        cube(size-[0,2*bevel,bz*2*bevel],center=true);
    }
}

// Beveled cylinder
module bevelcylinder(d,h,bevel,center=false)
{
    translate(center?[0,0,0]:[0,0,h/2])
    hull() {
        cylinder(d=d-2*bevel,h=h,center=true);
        cylinder(d=d,h=h-2*bevel,center=true);
    }
}

// Slot where thumb slides back and forth
module thumbSlot3D()
{
    OD=thumbOD+2*thumbWiggle;
    shrink=-thumbWiggle; // space for thumb to travel freely
    extra=2; // extra space on ends
    hollow=0; // hole is solid
    
    // Rods that grab lower pin
    symmetryX() translate([thumbCenterX,-pinSep,thumbCenterZ])
            thumbRod3D(2*thumbLen+extra,shrink,hollow);
    
    // Crossbar
    translate([-thumbCenterX-OD/2,thumbCrossbarY-OD/2-extra,thumbCrossbarZ-thumbOD/2-thumbWiggle])
        bevelcube([2*thumbCenterX+OD,thumbLen+OD+2*extra,1*thumbOD+2*extra],bevel=thumbRound,bz=0);
    
    // Space for welded-on mini hook to travel
    if (hasMini) {
        miniHookDeep=12;
        len=thumbLen+miniHookDeep+thumbLinkageOD;
        //translate(miniOrigin) rotate([0,90,0]) cylinder(d=8,h=75,center=true);
        translate(miniOrigin+[0,len/2,10+4]) 
            bevelcube([thumbLinkageWidth+extra,len,30],center=true,bevel=thumbRound);
    }
    
    // Space for thumb blocks
    thumbBlocks(1);
}

// Full welded 3D thumb piece: slides back and forth in its slot
module thumbs3D(shrink=0,hollow=1) {
    // Side thumbs grab the bottom pin
    difference() {
        symmetryX() translate([thumbCenterX,-pinSep,thumbCenterZ])
            thumbRod3D(thumbLen,shrink,hollow);
        // Round off front of tubes to match pin
        toolCouplerPins();
    }
    // Crossbar holds the sides together
    difference() {
        translate([-thumbCenterX-thumbOD/2,thumbCrossbarY,thumbCrossbarZ])
            rotate([0,0,-90])
                thumbRod3D(2*thumbCenterX+thumbOD,shrink,hollow);
    }
    // Blocks welded on crossbar hold the link 0 rod
    difference() {
        symmetryX() thumbLinkOrigin(0) translate([thumbLinkageWidth/2+thumbWall,0,0])
            cube([thumbWall,2+thumbLinkageOD,3+thumbLinkageRod],center=true);
        thumbLinkOrigin(0) rotate([0,90,0]) cylinder(d=thumbLinkageRod+1,h=thumbLinkageWidth+2*thumbWall+20,center=true);
    }
}


// Thumb 2D outlines, for fabrication
module thumbAssembly2D() 
{
    projection() thumbs3D();
    projection() translate([100,0,0]) rotate([0,90,0]) thumbs3D();
    projection() translate([0,-50,0]) rotate([90,0,0]) thumbs3D();
}

// Move to the origin of link i (0 is the thumb, 1 is push/pulled, 2 is fixed)
module thumbLinkOrigin(link) {
    z=thumbCrossbarZ;
    zU=z-0.8*thumbTravel; // underneath Z
    origins=[ // center of each link bar
    [0,thumbLinkageY,z], // 0: on thumb
    baseplateCenter + [0,0,5], // 1: input, top center
    [0,thumbLinkageY+2.5*thumbTravel,z], // 2: pivot on blocks
    [0,thumbLinkageY+2.0*thumbTravel,zU], // 3: underneath pin
    [0,thumbLinkageY+0.5*thumbTravel,zU] // 4: arc point underneath
    
    ];
    translate(origins[link]) children();
}

module thumbLinkageRod(h=thumbLinkageWidth) {
    rotate([0,90,0]) cylinder(d=thumbLinkageRod,h=h,center=true);
}

// Thumb linkage is held together by these rods
module thumbLinkageRods() {
    for (link=[0:3]) thumbLinkOrigin(link)
        thumbLinkageRod(thumbLinkageWidth*(link==1?1:1.7)*(link==3?0.6:1));
}

// Holds link 2 pin in place
module thumbBlocks(wiggle=0) {
    symmetryX() translate(thumbBlockCenter) {
        bevelcube(thumbBlockSize+wiggle*thumbBlockWiggle,bevel=thumbBlockBevel,center=true);
        
        // Extend block backwards for support
        translate([-thumbBlockSize[0]/2,-thumbBlockSize[1]/2,-0.5])
            bevelcube([thumbBlockSize[0],20,13],bevel=thumbBlockBevel);
    }
}

thumbLinkBox=10;
thumbLinkThick=8; // X thickness of links
thumbLinkBevel=2;

module thumbLinkBevelBox(link,extraThick=0) {
    $fa=10;
    thumbLinkOrigin(link)
        //bevelcube([thumbLinkThick,thumbLinkBox,thumbLinkBox],center=true,bevel=thumbLinkBevel);
        rotate([0,90,0])
        bevelcylinder(d=thumbLinkBox,h=thumbLinkThick+extraThick,bevel=thumbLinkBevel,center=true);

}

// Connect these three links with a linkage bar
module thumbLinkageGeneral(bodyLinks,holeLinks)
{
    difference() {
        union() {    
            for (i=[0:len(bodyLinks)-2])
            hull() {
                thumbLinkBevelBox(bodyLinks[i]);
                thumbLinkBevelBox(bodyLinks[i+1]);
            }
            children();
        }
        for (holeLink=holeLinks)
            thumbLinkOrigin(holeLink) thumbLinkageRod();
    }
}

// Input link of the thumb linkage, that pivots
module thumbLinkagePivot(link) {
    thumbLinkageGeneral([1,2,3],[1,2,3]);
    
    // Close off the input pin holes, to pinch input pin in place
    thumbLinkOrigin(1)
    translate([-thumbLinkThick/2,0,0])
    rotate([0,90,0]) cylinder(d=thumbLinkBox-2*thumbLinkBevel,h=2);
}

// Output of the thumb linkage, that pushes the thumb down
module thumbLinkagePusher(link) {
    thumbLinkageGeneral([0,4,3],[0,3]);
    
    // Clear the middle area by attaching pusher to thumb with #10-24 machine screw
    thumbLinkOrigin(0) difference() {
        translate([-thumbLinkThick/2,0,0])
        rotate([0,90,0]) cylinder(d=thumbLinkBox,h=12);
        
        // Tap this hole for #10-24
        rotate([0,90,0]) cylinder(d=0.145*inch,h=20,center=true);
    }
}


// Full thumb linkage, assembled for operation
module thumbLinkageAssembled() 
{
    color([0.3,0.5,1.0]) thumbs3D();

    #thumbLinkageRods();
    //#couplerThumbHole();
    
    delta=thumbLinkThick+0.5;
    symmetryX() translate([2*delta,0,0]) 
        thumbLinkagePusher();
    
    symmetryX() translate([delta,0,0])
        thumbLinkagePivot();
    
    //for (link=[0,1]) thumbLinkOrigin(link) thumbLinkageLink(link); 

    thumbBlocks();
}


// Thumb linkage parts, 3D printable versions
module thumbPrintable(withLinks=1,withThumbBlocks=1,withJig=1)
{
    if (withLinks) difference() {
        symmetryX()
        translate([40,20,thumbLinkThick/2]) 
        rotate([0,-90,0]) {
            thumbLinkagePusher();
            translate([0,0,thumbLinkThick+5])
                thumbLinkagePivot();
        }
        // Trim bottom flat
        translate([0,0,-200]) cube([400,400,400],center=true);
    }
    
    
    if (withThumbBlocks)
    for (side=[+1,-1]) {
        translate([20*side,50,-thumbBlockCenter[0]+thumbBlockSize[0]/2])
        intersection() {
            translate([0,0,200]) cube([400,400,400],center=true);
            rotate([0,side*90,0])
            difference() {
                thumbBlocks();
                thumbLinkageRods();
                if (hasMini) pickupMiniSideSlots();
            }
        }
    }
    
    // Jig for marking the ends of the thumb rods
    wiggle=0.2;
    if (withJig)
    translate([0,-20,0])
    difference() {
        linear_extrude(height=20,convexity=4)
        difference() {
            thumbSection2D(-wiggle-thumbWall); thumbSection2D(-wiggle);
        }
        translate([0,thumbCenterZ,20])
            rotate([0,90,0]) cylinder(d=pinOD,h=50,center=true);
    }
}

// Main outside of pickup tool
module pickupBodySolid() 
{
    $fs=0.5;
    $fa=10;
    ID=pinOD+2*3;
    OD=2*knuckleOR;
    bevelDist=2;
    hull() 
    {
        for (y=[0,-pinSep])
        symmetryX() 
            translate([pinLen/2,y,0])
                rotate([0,-90,0.01])
                {
                    cylinder(d=ID,h=0.1);
                    translate([0,0,1]) cylinder(d=ID+4,h=0.1);
                    translate([0,0,knuckleTaper/2]) cylinder(d=(ID+OD)/2+4,h=0.1);
                    translate([0,0,knuckleTaper]) cylinder(d=OD,h=0.1);
                }

    }
    
    // mounting block for ecoupler
    difference() {
        wall=3;
        support=10; // overlap in Y with body
        translate(ecoupler_center+[0,support/2,ecoupler_sz[2]/2+wall/2])
            bevelcube(ecoupler_sz+[2*wall,support+2*wall,wall],center=true,bevel=wall/2);
    }
}

// Sheet metal from mini tools fits in these slots
module pickupMiniSideSlots()
{
    $fa=15;
    rm=miniSideSlotWide*0.45;
    rp=2*miniSideSlotWide;
    translate(miniOrigin) {
        rotate([-90,0,0]) translate([0,0,-miniSideSlotEnd]) 
        linear_extrude(height=200,convexity=4) 
        offset(r=-rp) offset(r=+rp)
        offset(r=+rm) offset(r=-rm)
        {
            symmetryX() translate([73/2,-miniSideSlotDeep]) square([miniSideSlotWide,100]);
            // Front plate (for the rounding)
            translate([-pinSlot/2,rp/2-miniOrigin[2]]) square([pinSlot,100]);
        }
    }
}

module pickupMiniHook() {
    intersection() {
        translate(miniOrigin) import("coupler_2pin_solid.stl",convexity=4);
        // Trim back mini's front to match big's front profile
        pickupBodySolid();
    }
}


// Pickup plus mini-hook in front
module pickupBodyMini() {
    difference() {
        union() {
            difference() {
                pickupBodySolid();
                
                // Main cavity for the mini hook
                translate(miniOrigin+[0,125/2,-5]) 
                {
                    translate([0,6,0])
                    cube([miniHookSlot,150,25],center=true);
                    
                    // Extra space in front (so camera can see pickup)
                    translate([0,125/2+15,0])
                        cube([miniHookSlot,50,40],center=true);
                    
                    // Flare the big front pickups (so it's printable)
                    translate([0,125/2,1])
                    hull() {
                        cube([75,1,25],center=true);
                        translate([0,50,0])
                        cube([75+50,1,25],center=true);
                    }
                }
            }
            pickupMiniHook();
        }
            
        // Cut mini side slots
        pickupMiniSideSlots();
    }
}

pinWiggle=0.7; // clearance around each pin

// Sweep a pin out along the -Z axis, making a slot to capture it
module pinSweep(flareStart,flareSlope=1,flareRange=30)
{
    round=12;
    OD=pinOD+4*pinWiggle;
    rotate([0,90,0])
    linear_extrude(height=pinLen*1.1,center=true,convexity=4)
    offset(r=-round,$fa=15) offset(r=+round)
    {
        hull() {
            circle(d=pinOD+2*pinWiggle,$fa=1);
            translate([flareStart,0,0])
                circle(d=OD);
        }
        hull() {
            translate([flareStart,0,0])
                circle(d=OD);
            translate([flareStart+flareRange,0,0])
                circle(d=OD+flareSlope*flareRange);
        }
    }
}

// Tool pickup, with spaces for hooks to grab the pins
module pickupBodyHooks() {
    wiggle=0.5;
    difference() {    
        if (hasMini) pickupBodyMini(); else pickupBodySolid();
        
        rotate([90+20,0,0]) pinSweep(10,1.1); // upper pin: lean over to scoop up
        translate([0,-pinSep,0]) // lower pin
        union() {
            pinFlat=15;
            pinSweep(pinFlat,1.3); 
            
            // bevel the lip separating the lower pin and ecoupler
            round=5;
            translate([0,-pinOD/2-round,-pinFlat+0.3*round])
                rotate([45,0,0]) 
                translate([0,-10,0]) 
                    cube([pinSlot,20,20],center=true);
        }
        
        // Bottom pin rotates into place
        rotate([90,0,0]) rotate([0,90,0]) // revolve around X axis
        rotate_extrude(angle=30,$fs=0.1,$fa=1) {
            translate([-pinSep,0]) // tool bottom pin swing
                square([pinOD+2*pinWiggle,pinLen+2],center=true);
            translate([ecoupler_center[1],ecoupler_center[0]]) // tool ecoupler swing
                square([ecoupler_sz[1]+wiggle,2*ecoupler_sz[0]+wiggle],center=true);
        }
        
        // Sighting gap up front
        translate([0,20,25]) 
        hull() {
            cube([5,25,50],center=true);
            translate([0,0,25]) cube([5+20,25,1],center=true);
        }
        
        // Space for electrical coupler
        translate(ecoupler_center) 
        {
            wiggle=[1,1,1]*0.15;
            cube([ecoupler_sz[0],ecoupler_sz[1],ecoupler_sz[2]*2]+2*wiggle,center=true);
            rotate([180,0,0]) ecoupler_mountholes();
        }
        
    }
}

// Cut in rebar rods, to hold halves together
module pickupRebarRods() {
    rebarCenters=[
        [0,-25,10], // behind top pin
        [0,-pinSep+45,10], // above bottom pin
        [0,-pinSep-10,15], // below bottom pin
    
        miniOrigin+[0,10,-6], // above mini bottom pin
        miniOrigin+[0,125-15,-5] // below mini top pin
    ];
    rebarOD=4.3; // 4mm basalt rod, plus space for epoxy
    rebarLen=100; // long enough to hold halves together mostly
    for (rebar=rebarCenters) translate(rebar) 
        rotate([0,90,0]) cylinder(d=rebarOD,h=(rebar[2]<0?rebarLen/2:rebarLen),center=true);
}

// Voids just to print less plastic overall
module pickupLightenHoles()
{
    // hollow in front of bottom pin
    translate([0,-pinSep+31,-6]) bevelcube([60,30,22],center=true,bevel=4);
    // hollow underside of mini pickup
    translate(miniOrigin+[0,125/2-5,1]) bevelcube([50,85,20],center=true,bevel=4);
}

module pickupCuts() {
    //toolCouplerPins();
    couplerThumbHole();
    thumbSlot3D();
    couplerBaseplateScrews();
    pickupRebarRods();
    pickupLightenHoles();
    
    if (hasMini) {
        pickupMiniSideSlots();
        pickupMiniHook();
    }
}


// Final finished baseplate with all the trimmings
module pickupBaseplate() {
    difference() {
        union() {
            difference() {
                pickupBodyHooks();
                couplerBaseplateFlush();
            }
            couplerBaseplate();
            
        }
        thumbSlot3D();
        couplerThumbHole();
        couplerBaseplateScrews();
        
        pickupRebarRods();
        pickupLightenHoles();
    }
            
}

// 2D sections of the pickup, to test fit with a tiny print
module pickupSlice2D() {
    intersection() {
        rotate([0,90,0]) {
            pickupBaseplate(); // centerline cut
            translate([pinSlot/2-14,0,50]) pickupBaseplate();
        }
        cube([500,500,1],center=true);
    }
}

// Includes support material for more reliable 3D printing
module pickupSupported(half=0) {
    pickupBaseplate();
    symmetryX() {
        beam=6; thick=1; // self-supporting beam, to support far edge of overhangs
        for (start=[
            [-thumbCenterX-thumbOD/2-1,thumbCrossbarY-thumbOD/2,baseplateCenter[2]], // outside top pocket
            [-(thumbLinkageWidth+2)/2,thumbCrossbarY,thumbCrossbarZ-thumbOD/2-thumbWiggle] // above thumb slot
        ])
            translate(start-[0,0,thick])
                cube([beam,85,thick]);
            
    }
    
    // support under front hook
    hookDia=7;
    if (half==0) translate(miniOrigin+[0,125,0]) 
        rotate([0,90,0]) linear_extrude(height=41,convexity=4) 
            difference() { circle(d=hookDia); circle(d=hookDia-2); }
}

// Printable in two halves
module pickupPrintableHalf(half=0,printTiltAngle=15)
{
    intersection() {
        translate([0,0,200]) cube([400,400,400],center=true);
        
        rotate([0,half?+90:-90,0])
        rotate([0,0,printTiltAngle]) // slight tilt to make overhangs more printable
        translate(-baseplateCenter) pickupSupported(half);
    }
}

// Demo of pickup and parts
module pickupDemo() {
    pickupBaseplate();
    
    thumbLinkageAssembled(); 
    
    translate(ecoupler_center) {
        rotate([180,0,0]) ecoupler_demo(0);
        //ecoupler_frame(); // tool side
    }
}

//#pickupCuts();
//pickupBaseplate();
//pickupSlice2D();
pickupDemo();

//thumbAssembly2D();

//thumbPrintable(1,1,0); // small parts for thumb
//translate([55,0,0]) scale([1,1,1]*0.25) 
if (0) {
//translate([20,0,0]) pickupPrintableHalf(0); // left half
//translate([-20,0,0]) pickupPrintableHalf(1); // right half
}

