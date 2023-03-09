/*
  Hold an Intel RealSense D455 onto steel upright mounting bars. 

  Dr. Orion Lawlor, lawlor@alaska.edu, 2023-03-02 (Public Domain)
*/
$fs=0.1; $fa=5;

inch=25.4;
tube=4;

flatBack=2.0;

prongOD=[1.0*inch+0.8,0.5*inch+0.8]; // size of prongs, plus wiggle room for printing tolerance
prongLen=2.0*inch; // length of plastic around prongs
prongAround=flatBack; // wall around prongs
prongAngle=35; // prong relative to base plate
prongSpace=(6+7/8)*inch; // center-to-center distance between steel prongs
prongIR=prongSpace/2-prongOD[0]/2; // inside corner of each prong from center

prongBoltOD=3/16*inch; // pop rivet or #10-24
prongBoltDown=prongOD[0]/2+2; // distance from top to bolt hole

// children() on the inside corner of each prong
//  Output has +X facing outside, +Y forward, +Z down the prong
module prongStart(side=+1)
{
    scale([side,1,1]) translate([prongIR,flatBack,0])
        rotate([prongAngle,0,0]) scale([1,1,-1])
            children();
}

module prongBoth() {
    prongStart(+1) children();
    prongStart(-1) children();
}

module prongBoltCenter() {
    for (side=[-1,+1])
    scale([side,1,1]) translate([prongIR,flatBack,0])
        rotate([prongAngle,0,0]) scale([1,1,-1]) translate([prongOD[0]/2,0,prongBoltDown])
            rotate([90,0,0])
                children();
}


cameraDistance=8*inch; // distance from prong base to camera mount
cameraAngle=0; // camera centerline direction relative to base plate
cameraOD=30; // camera radius around mount
cameraWide=100; // center-to-center
cameraDepth=30; // camera housing depth
cameraWall=flatBack; // plastic around the camera
cameraScrew=4.0; // M4 thru holes in the back
cameraScrewSpace=95; // hole-to-hole distance between screws
cameraCenter=[0,flatBack,cameraDistance+cameraOD/2];

// General shape of camera housing
module cameraHousingSolid(fatten=0)
{
    translate(cameraCenter+[0,-fatten,0])
    hull() {
        for (side=[-1,+1]) translate([cameraWide/2*side,0,0])
            rotate([-90,0,0]) cylinder(d=cameraOD+2*fatten,h=cameraDepth+flatBack);
    }
}

module cameraHoles() {
    // Mount holes
    translate(cameraCenter)
        for (side=[-1,+1]) translate([cameraScrewSpace/2*side,0,0])
            rotate([90,0,0]) cylinder(d=cameraScrew,h=20,center=true);

    // USB-C connector
    translate(cameraCenter+[+37.5,flatBack+3.5,-cameraOD/2])
        cube([21,9,15],center=true);
}

module cameraMinus() {
    cameraHousingSolid(0);
    cameraHoles();
    prongBoth() 
        cube([prongOD[0],prongOD[1],prongLen]);
    prongBoltCenter() cylinder(d=prongBoltOD,h=25,center=true);
    
    // trim off top flush with camera
    translate([0,flatBack+cameraDepth+1000,0]) cube([2000,2000,2000],center=true);
}

rib=3;
ribHt=28;
IR=prongIR-rib/2;

// Extrude this like a back component
module backExtrude(h=rib, round=rib) {
    rotate([-90,0,0]) linear_extrude(height=h,convexity=6) 
    offset(r=-round) offset(r=+round)
        children();
}

// 2D camera outline
module backCamera() {
    translate([cameraCenter[0],-cameraCenter[2]])
    offset(r=-0.1)
    hull() {
        for (side=[-1,+1]) translate([cameraWide/2*side,0,0]) 
            circle(d=cameraOD+2*cameraWall-1);
    }
}

function flipX(p)=[-p[0],p[1],p[2]];

backLow=[IR,rib/2,0];
frontLow=backLow+[0,ribHt-rib,0];
backHigh=[-cameraWide/2,rib/2,cameraDistance];
frontHigh=backHigh+[0,ribHt-rib,0];
module sideDiagonals() {
    len=0.2;
    for (triangle=[
        [backLow,frontLow,len*backHigh+(1.0-len)*backLow],
        [flipX(backLow),flipX(frontLow),flipX(len*backHigh+(1.0-len)*backLow)],
        [backHigh,frontHigh,len*backLow+(1.0-len)*backHigh]
    ])
        hull() for (p=triangle) translate(p)
            sphere(d=rib,$fs=12);
}

// 2D back stringer connecting these sides, ready for standing up
module backStrap(prongside,cameraside) {
    hull() {
        translate([prongside*(IR),0,0]) circle(d=rib);
        translate([cameraside*(cameraWide/2),-cameraDistance,0]) circle(d=rib);
    }
}

// 2D reinforcing under the prongs
module backProngs(prongside,withH=1,withV=0) {
    scale([prongside,1]) translate([IR,-rib/2]) {
        if (withH) square([prongOD[0]*withH,rib]);
        if (withV) square([rib,0.8*prongLen*withV]);
    }
}

// Upright sidewalls
module sideRibs(offsetR,simple)
{
    backExtrude(h=ribHt,round=8) 
    offset(r=offsetR)
    {
        backCamera();

        for (cameraside=[-1,+1]) {
            prongside=cameraside; // same side (no crossing)
            backStrap(prongside,cameraside);
            backProngs(prongside,0,0.5);
            
            if (simple==0)
            {       
                // diagonal to support the sides
                scale([prongside,1,1]) 
                hull() {
                    translate([IR,-10]) circle(d=rib);
                    translate([IR+prongOD[0]+rib/2,+16]) circle(d=rib);
                }
            }
        }
    }
    
}

module cameraPlus(simple=0) {
    cameraHousingSolid(cameraWall);
    
    prongBoltCenter() cylinder(d1=prongOD[0],d2=12,h=4);
    
    translate([0,-flatBack,0])
        prongBoth() 
            translate([-prongAround,0,0])
                cube([prongOD[0]+2*prongAround,prongOD[1]+2*prongAround,prongLen]);

    // flat back
    backExtrude(round=8) {
        translate([0,+rib,0]) backCamera();
        for (prongside=[-1,+1]) {
            for (cameraside=[-1,+1]) backStrap(prongside,cameraside);
            if (simple==0) backProngs(prongside);
        }
    }
    
    // Upright side ribs
    difference() {
        sideRibs(0,simple); // full width
        
        // Narrower sections to save plastic in middle
        round=5;
        if (simple==0)
        rotate([-90,0,0]) rotate([0,-90,0])
        linear_extrude(height=300,center=true,convexity=4) 
        offset(r=+round) offset(r=-round)
            translate([ribHt/2,-cameraDistance/2-5])
            difference() {
                square([ribHt*0.7,cameraDistance*0.8],center=true);
                square([100,rib],center=true);
            }
    }
    
    // Thinner side ribs act as support material in middle
    if (simple==0)
        sideRibs(-rib*0.2,simple); //<- thinner in middle
    
    // Diagonals
    sideDiagonals();
}

// Full 3D printable part
module cameraHousing(simple=0) {
    difference() {
        cameraPlus(simple);
        cameraMinus();
    }
}


// 2D cross section, for fit check / camera field of view check
module crossCheck(deltaAngle=0) {
	square([cameraDistance,tube]);
	
	rotate([0,0,90-prongAngle]) 
	difference() {
		sz=[prongOD[1],prongLen];
		square(sz);
		translate([prongAround,prongAround])
			square(sz);		
	}

	translate([cameraDistance,0]) rotate([0,0,cameraAngle])
	difference() {
		sz=[cameraOD,cameraDepth];
		//square(sz+[cameraAround*2,0]);
        square([cameraWall,cameraDepth]); // thin base
		translate([cameraWall,cameraWall])
			square(sz);
	}
}

// Camera shroud blocks direct sunlight, and holds an acrylic cover.
//  This fits over the main housing, held on with tape.
module cameraShroud2D() {
    hull() {
        for (side=[-1,+1]) translate([side*cameraWide/2,0,0])
            circle(d=cameraOD+2*cameraWall);
    }
}

cameraShroudLen=40; // length of shroud beyond front of camera
cameraShroudFlare=15; // amount shroud widens
cameraShroudAttach=(cameraDepth+flatBack)/2; // length of shroud behind camera

// This is the camera's field of view (plus a little wiggle room)
module cameraShroudSolid(fatten=0) {
    hull() {
        linear_extrude(height=1) offset(r=cameraShroudFlare+fatten) scale([1.30,1,1]) {        //cameraShroud2D();
            square([cameraWide+cameraOD+2*cameraWall,cameraOD+2*cameraWall],center=true);
        }
        translate([0,0,cameraShroudLen])
        linear_extrude(height=1) offset(r=-2+fatten) cameraShroud2D();
    }
}

module cameraShroud() {
    wall=1.5;
    difference() {
        union() {
            cameraShroudSolid(wall);
            linear_extrude(height=cameraShroudLen+cameraShroudAttach) offset(r=wall) cameraShroud2D();
        }
        
        // Open the field of view
        translate([0,0,-0.1])
        cameraShroudSolid();
        
        // Open the back, to fit on the camera 
        //  (Leaves a little step to glue on an acrylic dust lens)
        translate([0,0,cameraShroudLen+0.5])
            linear_extrude(height=50) offset(r=0.1) cameraShroud2D();

        // Remove the bottom, to avoid the legs
        translate([0,-200,0]) cube([cameraWide+3*rib,400,400],center=true);
    }
}

cameraShroudTrimRot=[20,0,0];
cameraShroudTrimCenter=[0,-cameraShroudFlare-cameraOD/2-cameraWall,0];
module cameraShroudTrim() {
    difference() {
        rotate(cameraShroudTrimRot) translate(cameraShroudTrimCenter)
                cameraShroud();
        
        // trim base flat, so it prints
        translate([0,0,-200+1]) cube([400,400,400],center=true);
    }
}

// Imported from main robot, in stick coordinates
module cameraMountWithShroud() {
    translate([0,-prongOD[1]/2,2])
    rotate([-prongAngle,0,0]) 
    {
        color([0.3,0.3,0.3]) {
            cameraHousing(simple=1);
            
            // Shroud on top of housing
            translate([0,cameraDepth+cameraShroudLen,cameraDistance+cameraOD/2])
            rotate([90,0,0])
            translate(-cameraShroudTrimCenter) rotate(-cameraShroudTrimRot) 
                cameraShroudTrim();
        }
        color([0.8,0.8,0.8]) { // model of realsense
            translate([0,1,0])
            backExtrude(h=cameraDepth-2) offset(r=-cameraWall-2) backCamera();
        }
    }
}


cameraMountWithShroud();
//cameraShroud2D(); // save SVG / DXF for cutting acrylic panel

//cameraShroudTrim(); // 3D printable shroud
//import("realsense_shroud_v3.stl");

//translate([0,-cameraDistance-cameraOD/2,cameraShroudLen+cameraDepth+flatBack]) rotate([180,0,0]) cameraShroud();


// rotate([0,-90,0]) linear_extrude(height=1.5) crossCheck();

//rotate([0,0,-90]) rotate([90,0,0]) // printable flat on its back
//cameraHousing(); // operational config



