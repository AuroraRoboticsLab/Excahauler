/*
 Excahauler coupler gearbox, 3D printed version for prototype testing.
 This is a stepped planetary gearbox, which shifts the input and output ring gears eight (!) planets.
 (Spamming planets gives the 3D printed version lots of holding torque.)
 
 Developed 2021 by Dr. Orion Lawlor, lawlor@alaska.edu (Public Domain)
*/
$subpart=1; $FEM_active=0;
include <../Excahaul_latest.scad>
use <../molon.scad>;
use <../AuroraSCAD/gear.scad>;

$fs=0.2; $fa=10; // quick and dirty version

// This is the height of the bearing moving parts area
bearingHeight=28;
//bearingHeight=12; // short test
bearingOD=couplerDriveDia+2*14;
bearingOR=bearingOD/2;

bearingInsideHeight=18;
//bearingInsideHeight=8; // short test
bearingInsideStart=bearingHeight-bearingInsideHeight;

// Assembly uses these fasteners: #10-24, 0.190 inch OD, 4.83mm OD, 3.5mm tap diameter
asmBoltOD=4.8;
asmBoltTap=3.5;

// Diameter of spherical bearings, 6mm airsoft
//   (in the long run, tapered roller bearings are probably better)
bearingWall=8.0; //<- needs to be thick enough to tap in 
bearingBallOD=6.1; //<- airsoft BB, plus clearance
bearingBallR=bearingBallOD/2;
bearingFlange=4.0; //<- thickness of flange between races

// height of center of lower row of balls
bearingCenterR=bearingOR-bearingWall-bearingBallR; // center of balls
bearingCenterClearR=bearingCenterR-0.8*bearingBallR; // clear space between inner and outer
bearingFlangeR=bearingCenterR+0.8*bearingBallR;

bearingCenterZSplit=bearingHeight/2-1; // dividing line between outside rings
bearingCenterZ1=bearingCenterZSplit-bearingFlange/2-bearingBallR; 
bearingCenterZ2=bearingCenterZSplit+bearingFlange/2+bearingBallR; 

bearingInsideFlatR=bearingCenterR-bearingBallR; // flat of inside wall
bearingInsideR=bearingInsideFlatR-bearingWall*0.8; // open interior space (e.g., for locking pin)

// Mount bolts go upright through backplate and both outer races
bearingMountBolts=8;
bearingMountBoltInsideR=bearingInsideFlatR-bearingWall/2;
bearingMountBoltOutsideR=bearingOR-bearingWall/2;
echo("Mounting bolt inside radius=",bearingMountBoltInsideR);
echo("Mounting bolt outside radius=",bearingMountBoltOutsideR);

module bearingMountBoltRing(radius) {
    for (angle=[0:360/bearingMountBolts:360-1]) rotate([0,0,angle])
       translate([radius,0,-0.01]) children();
}
module bearingMountBoltsInside() {
    bearingMountBoltRing(bearingMountBoltInsideR) children();
}
module bearingMountBoltsOutside() {
    bearingMountBoltRing(bearingMountBoltOutsideR) children();
}

// Relative to the bearings, this is the Z coordinates of the start of the coupler
couplerStart=couplerHeight;

bearingSealClear=0.5; // clearance between moving halves of bearing
bearingTopClear=2.0; // clearance on top and bottom between moving parts


// The bearing drive geartrain:
//  height, pitch, pressure angle, addendum, dedendum

// Posible direct-drive RS550 motor type.
geartype_550 = [ 0.8, 10.0, 20, 0.32, 0.4 ]; // motor input (must match motor's sun gear)

// Fixed gears: convert motor to carrier ring
geartypeFixed=[1.56,0.0,20,0.4,0.4]; // fixed ring
fixedRingTeeth=80; // fixed ring tooth count (with pitch, sets output diameter)
planetInTeeth=12;
nPlanetGears=8; // if multiple of ring tooth count, all identical
gearplaneIn=[geartypeFixed,fixedRingTeeth-2*planetInTeeth,planetInTeeth,nPlanetGears];
gearFixedRing=gearplane_Rgear(gearplaneIn); // stationary
gearInPlanet=gearplane_Pgear(gearplaneIn);
gearInSun=gearplane_Sgear(gearplaneIn);

// Motor gears: driven directly by Molon gearmotor shaft:
geartypeMotor=[1.4,0.0,20,0.4,0.4]; // motor drive hollow sun
gearMotor=[geartypeMotor,13]; // on motor
gearHollowSun=[geartypeMotor,gear_nteeth(gearInSun)]; // sun side of motor, matches sun side on input for strength

// Output gears: bolt to output coupler
geartypeOut=[2.0396,0.0,20,0.4,0.4]; // output ring
outputRingTeeth=64; // output ring tooth count (sets gear ratio)
outputRingShift=[0,0,360/outputRingTeeth/2];
planetOutTeeth=12; // if same as input, easier to time planets
gearplaneOut=[geartypeOut,outputRingTeeth-2*planetOutTeeth,planetOutTeeth,nPlanetGears];
gearOutRing=gearplane_Rgear(gearplaneOut); // spins coupler
gearOutPlanet=gearplane_Pgear(gearplaneOut);
gearOutSun=gearplane_Sgear(gearplaneOut);

gearRatio=(gear_R(gearFixedRing)/gear_R(gearMotor)+1)/
    (gear_R(gearOutPlanet)/gear_R(gearInPlanet)*
     gear_R(gearFixedRing)/gear_R(gearOutRing)-1);
echo("Gear reduction ratio=",gearRatio);

pmatch=gearplane_Cpitch(gearplaneOut)
	*gearplane_Pradius(gearplaneIn)/gearplane_Pradius(gearplaneOut);
echo("Output pitch for matching planet spin radius",pmatch);

module gear_ring(OD,gear) {
    difference() {
        circle(d=OD);
        gear_2D(gear);
    }
}

module draw_planet(ring,planet) {
    r=gear_R(ring)-gear_R(planet);
    echo("Planet orbit r=",r);
    translate([r,0,0]) {
        gear_2D(planet);
    }
}

// Visualize all planetary gears
module entire_geartrain()
{
    // Output gears
    color([1,0.5,0])
    translate([0,0,20]) {
        gear_ring(140,gearOutRing);
        
        gearplane_planets(gearplaneOut)
            gear_2D(gearOutPlanet);
        draw_planet(gearOutRing,gearOutPlanet);
        
        
        // Idler sun, keeps top of output planets from tilting
        gearplane_sun(gearplaneOut) difference() {
            gear_2D(gearOutSun);
            circle(d=gear_ID(gearOutSun)-3);
        }
    }

    // Fixed gears
    gear_ring(140,gearFixedRing);
    draw_planet(gearFixedRing,gearInPlanet);
    gearplane_planets(gearplaneIn)
        gear_2D(gearInPlanet);

    difference() {
        gear_2D(gearMotor);
        circle(d=3/8*inch); // motor shaft
    }

    // Hollow sun, couples motor to fixed input
    gearplane_sun(gearplaneIn) difference() {
        gear_2D(gearInSun);
        gear_2D(gearHollowSun);
    }
    draw_planet(gearHollowSun,gearMotor);
}


// Coupler motor:
motorPosition=[0,gear_R(gearHollowSun)-gear_R(gearMotor),-17]; // <- makes motor mate with drive gear
echo("Motor position",motorPosition);
motorRotation=[0,0,90];

// This is the drive motor, which screws into the back plate
module motorDrive() {
    translate(motorPosition) rotate(motorRotation) 
        motor_face_subtract();
}

driveGearHeight=bearingHeight-3;
module driveGear() {
    difference() {
        translate(motorPosition) 
        linear_extrude(height=driveGearHeight,convexity=6)
            offset(r=-0.1) // <- add just a little clearance 
            //rotate([0,0,180/gear_nteeth(gearMotor)])
                gear_2D(gearMotor);
        
        // Leave hole inside for the drive gear shaft
        motorDrive();
    }
}
module bearingGearInside2D()
{
    difference() {
        circle(d=2*bearingInsideR+0.1);
        
        //rotate([0,0,180/gear_nteeth(gearOutRing)])
        rotate(outputRingShift)
            gear_2D(gearOutRing);
    }
}


// Labrinth seal geometry, viewed from outside
module bearingSeal2D() {
    
    // This will need to be split to be assembleable
    /*
    lip=3; // tiny dust lip, to channel dust down and away
    translate([bearingInsideFlatR,bearingHeight,0]) scale([1,-1])
    hull() {
        square([1,0.1],center=true);
        translate([0,lip])
            square([2*lip,0.1],center=true);
    }
    */
}

module bearingBalls2D() {
    translate([bearingCenterR,bearingCenterZ1]) circle(d=bearingBallOD,$fa=2);
    translate([bearingCenterR,bearingCenterZ2]) circle(d=bearingBallOD,$fa=2);
}

// Inner bearings are screwed to coupler mating pickup
module bearingRaceInside2D() {
    round=1;
    //offset(r=+round) offset(r=-round) // round edges
    difference() {
        union() {
            // Body of bearing
            translate([bearingInsideR,bearingInsideStart])
                square([bearingInsideFlatR-bearingInsideR,bearingInsideHeight]);
            
            // Flange
            translate([bearingInsideFlatR-1,bearingCenterZ1])
                square([bearingFlangeR-bearingInsideFlatR+1,bearingCenterZ2-bearingCenterZ1]);
            
            // Seal surface
            bearingSeal2D();
        }
        bearingBalls2D();
        
    }
}

// Outer bearings are screwed to coupler steel frame
module bearingRaceOutside2D()
{
    round=0.7; // <- a little rounding guides dust out
    offset(r=+round,$fa=20) offset(r=-round,$fa=20) // round edges
    difference() {
        // Outside wall:
        union() {
            translate([bearingCenterClearR,0,0])
                square([bearingOR-bearingCenterClearR,bearingHeight-bearingTopClear]);
            // becomes fixed bearing face
            square([bearingOR,bearingInsideStart-0.5]);
        }
        
        hull() bearingBalls2D();
        
        // split between lower and upper rings
        translate([bearingCenterR,bearingCenterZSplit])
            square([50,bearingSealClear],center=true);
        
        
        offset(r=bearingSealClear) 
        hull() {
            bearingSeal2D();
            translate([bearingCenterR,100])
                square([100,1],center=true);
        }
    }
}

module bearingBoltholesInside() {
    // Inside bolts are just purely tapped all the way through
    bearingMountBoltsInside() {
        cylinder(d=asmBoltTap,h=bearingHeight+1);
    }
}

// Bolt holes for the bearing assembly
module bearingBoltholesOutside() 
{
    // Assembly bolts: through top surface, thread into bottom surface
    bearingMountBoltsOutside() {
        translate([0,0,bearingCenterZSplit])
            cylinder(d=asmBoltOD,h=bearingHeight-bearingCenterZSplit);
        cylinder(d=asmBoltTap,h=bearingHeight);
        
        asmBoltRim=12;
        translate([0,0,bearingHeight]) scale([1,1,-1])
            cylinder(d1=asmBoltRim,d2=asmBoltOD,h=(asmBoltRim-asmBoltOD)/2);
    }
}

// The entire bearing assembly
module bearingAssembly(inside=1,outside=1,cutaway=0) {
    $fa=2; $fs=0.1;
    difference() {
        union() {
            $fa=2;
            //cylinder(d=bearingOD,h=bearingHeight);
            if (inside) {
                rotate_extrude() bearingRaceInside2D();
                translate([0,0,bearingInsideStart])
                    linear_extrude(height=bearingInsideHeight,convexity=8)
                        bearingGearInside2D();
            }
            if (outside) rotate_extrude() bearingRaceOutside2D();
        }
        
        if (outside) // cut away fixed bearing
           translate([0,0,-0.1]) linear_extrude(height=bearingInsideStart+0.2,convexity=8)
                        gear_2D(gearFixedRing);
        
        bearingBoltholesInside();
        bearingBoltholesOutside();
        
        // Don't interfere with the motor parts
        motorDrive();      
        
        if (cutaway) translate([0,0,-100]) cube([1000,1000,1000]);
    }
}

// For reference, this is the rest of the coupler parts
module couplerParts() {
    color([0.5,0.5,0.5])
    translate([0,0,couplerStart]) {
        couplerMating();
        couplerHoles(0.0);
    }
}


module driveGearPrintable() {
    translate([0,0,driveGearHeight])
    rotate([180,0,0])
    translate(-motorPosition)
        driveGear();
}

module bearingInsidePrintable() {
    difference() {
        translate([0,0,-bearingInsideStart])
            bearingAssembly(1,0,0);
        // trim bottom flush
        translate([0,0,-1000]) cube([2000,2000,2000],center=true);
    }
    /*
    // Support the outer bearing ring:
    supportH=bearingCenterZ1+bearingBallR*0.5;
    supportR=bearingCenterR+bearingBallR*0.7;
    supportW=0.4;
    $fa=2; $fs=0.1;
    difference() {
        cylinder(r=supportR+supportW,h=supportH);
        translate([0,0,-0.1])
        cylinder(r=supportR,h=supportH+1);
    }
    */
}

// Extract the lower bearing
module bearingLowerCut() {
    cube([1000,1000,2*bearingCenterZSplit],center=true);
}

module bearingLowerPrintable() {
    intersection() {
        bearingAssembly(0,1,0);
        bearingLowerCut();
    }
}

module bearingUpperPrintable() {
    translate([0,0,bearingHeight-bearingTopClear])
    rotate([180,0,0])
    difference() {
        bearingAssembly(0,1,0);
        bearingLowerCut();
    }
}

module printableSamples() {
    driveGearPrintable();
    intersection() {
        translate([0,500,0]) cube([32,1000,1000],center=true);
        union() {
            bearingInsidePrintable();
            translate([0,20,0]) bearingLowerPrintable();
            translate([0,40,0]) bearingUpperPrintable();
        }
    }
}
//printableSamples();

// 2D outline of front plate: wood block with holes for coupler, wiring, bolts
module frontplatePrintable2D() {
    $fa=2; $fs=0.1;
    difference() {
        couplerMating2D();
        
        circle(d=couplerLockingPinOD); // locking pin
        
        projection(cut=true) translate([0,0,-0.5]) 
            bearingBoltholesInside();
    }
}

// 2D outline of backplate: steel plate with holes for bolts and motor
module backplatePrintable2D() {
    $fa=2; $fs=0.1;
    difference() {
        union() {
            circle(d=bearingOD);
            translate(motorPosition) rotate(motorRotation) motor_gearbox_2D();
        }
        
        circle(d=couplerLockingPinOD);
        translate([0,-25,0]) circle(d=10); // wiring hole?
        
        projection(cut=true) translate([0,0,-0.5]) 
        {
            bearingBoltholesOutside();
            motorDrive();
        }
    }
    
    // Add frame parts, for reference
    projection(cut=true) translate([0,0,-couplerPivot[2]]) 
    difference() {
        couplerHoles(0);
        couplerHoles(frameWall);
    }
    
    // Cross section of arm
    projection(cut=true) 
    translate(-[couplerActuator[0],couplerPivot[1],couplerPivot[2]-4])
    rotate([0,90,0])
    difference() {
        couplerHoles(0);
        couplerHoles(frameWall);
    }
        
}

// Planet gears
module bearingPlanets() {
    h=bearingHeight-bearingTopClear;
    clearance=0.1;
    difference() {
        union() {
            gearplane_planets(gearplaneIn) // Input side
            {
                linear_extrude(height=h,convexity=6)
                    offset(r=-clearance)
                        gear_2D(gearInPlanet);
            }
            
            gearplane_planets(gearplaneOut) // Output side
            {
                translate([0,0,bearingInsideStart])
                intersection()
                {
                    linear_extrude(height=h-bearingInsideStart,convexity=6)
                        offset(r=-clearance)
                            gear_2D(gearOutPlanet);
                    
                    // bevel the approach to larger output gear
                    cylinder(d1=gear_ID(gearInPlanet),d2=50,h=bearingInsideHeight);
                }
            }
        }
        
        // hollow core
        gearplane_planets(gearplaneIn) 
        translate([0,0,h/2])
        cylinder(d=gear_ID(gearInPlanet)*0.6,h=h*0.8,center=true);
    }
    
}

// Motor drive ring / fixed side sun ring
module bearingMotorDrive(side=+1) 
{
    h=bearingInsideStart;
    gearplane_sun(gearplaneIn)
    difference() {
        // outside gear to spin inner planets
        linear_extrude(height=h,convexity=8) 
            gear_2D(gearInSun);
        
        // inside gear for motor to rotate
        translate([0,0,+side*1.5]) //<- +1 is printable, -1 is operational
        linear_extrude(height=h,convexity=8) 
            gear_2D(gearHollowSun);
        
        
        // big hole through middle, for lightening and wire clearance
        cylinder(d=gear_ID(gearHollowSun)-16,h=100,center=true);
    }
}

// Sun gear for output (unconnected, just keeps planets from tilting)
module bearingOutSun() 
{
    translate([0,0,bearingInsideStart])
    gearplane_sun(gearplaneOut) // Output side
    difference() {
        linear_extrude(height=bearingInsideHeight-bearingTopClear,convexity=6) gear_2D(gearOutSun);
        
        // lip for strength
        translate([0,0,1.5])
        cylinder(d=gear_ID(gearOutSun)-3,h=100);
        // thru hole
        cylinder(d=gear_ID(gearOutSun)-16,h=100,center=true);
    }
}

//entire_geartrain(); 

//frontplatePrintable2D();
//backplatePrintable2D();

batch=0; //<- part index, see below

if (batch==0) { // batch 0: preview cutaway
    difference() { 
        union() {
            bearingAssembly(1,1,1);
            bearingMotorDrive(-1.0);
            
            rotate(outputRingShift) {
                bearingPlanets();
                translate([0,0,1]) bearingOutSun();
            }
        }
        translate([0,0,-1]) cube([100,100,100]);
    }
    driveGear();
    #motorDrive();
}


if (batch==1)   // batch 1: lower, drivegear, motorshaft
{
    bearingLowerPrintable();
    driveGearPrintable();
    bearingMotorDrive();
}

if (batch==2) // batch 2: inner and output sun
{
    bearingInsidePrintable();
    rotate(outputRingShift) {
        translate([0,0,-bearingInsideStart]) bearingOutSun();
    }
}

if (batch==3) // batch 3: upper (top clamp) and planets
{
    bearingUpperPrintable();
    rotate(outputRingShift) {
        bearingPlanets();
    }
}

if (batch==4) // spare motor drive
    driveGearPrintable();
