/*
 3D printable replacement gears.  Ideally print from nylon or polycarbonate.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-06-30 (Public Domain)
*/
include <geartype_perego.scad>;
use <../AuroraSCAD/gear_poly.scad>;

inch=25.4; // file units are mm

gear_clearance=0.1;

// Gear2:
loZ=9;
hiZ=12;
lo_gear=gear2lo;
hi_gear=gear2hi;

axleOD=10.1; //<- slip fit for bushings
axleHt=8.0; // height of bushings (so they don't shift inwards)

echo("Gear12 axle distance: ",gear_R(gear1hi)+gear_R(gear2lo));
echo("Gear23 axle distance: ",gear_R(gear2hi)+gear_R(gear3lo));

module hole_ring(gearLow,gearHigh)
{
    gapI=gear_OR(gearHigh)+1;
    gapO=gear_IR(gearLow)-1;
    gapR=(gapI+gapO)/2;
    lightenOD=(gapO-gapI);
    if (lightenOD>3) {
        count=round(gapR*2*PI/(lightenOD+2.0)/2)*2;
        da=360/count;
        for (a=[da/2:da:360-1]) rotate([0,0,a])
            translate([gapR,0,-0.1])
            {
                r=(lightenOD/2-gear_clearance);
                circle(r=r,$fn=16);
            } 
    }     
}

module solid_gear() 
{
    bevel=4; //<- avoid stress riser at hi root
    bevelR=gear_OR(hi_gear)+2.5;
    
    difference() {
        gear3D_via_PolyGear(lo_gear,loZ,2*gear_clearance);
        
        // low gear teeth
        linear_extrude(height=loZ,convexity=8) 
        difference() {
            //offset(r=-gear_clearance) gear_2D(lo_gear);
            // holes reduce curl
            offset(r=-1) hole_ring(lo_gear,hi_gear);
        }
        
        // Chop out space for bevel to happen
        lowR=gear_IR(lo_gear)-2;
        translate([0,0,loZ+0.1]) scale([1,1,-1])
            cylinder(r1=lowR,r2=lowR-bevel,h=bevel);
    }
    
    // hi gear teeth
    if (1) {
        gear3D_via_PolyGear(hi_gear,loZ+hiZ,2*gear_clearance);
    }
    else 
    { // old 2D gear
        linear_extrude(height=loZ+hiZ,convexity=8) 
        difference() {
            offset(r=-gear_clearance) gear_2D(hi_gear);
        }
    }
    
    // Bevel connecting lower and upper gears
    translate([0,0,loZ-bevel-0.01])
        cylinder(r1=bevelR,r2=gear_IR(hi_gear),h=bevel);
    
    // Bars connecting lower and upper gears, for torque
    barsink=1;
    bar=2*bevel-2*barsink;
    translate([0,0,loZ-barsink-bar/2])
        for (angle=[0,90]) rotate([0,0,angle])
            rotate([0,90,0]) cylinder(d=bar,h=gear_ID(lo_gear)-1,center=true);
}

module axled_gear() {
    difference() {
        solid_gear();
        // Top and bottom (sticks out) bushings
        for (z=[-1,loZ+hiZ-axleHt])
            translate([0,0,z])
                cylinder(d=axleOD,h=axleHt);
        
        // Thru hole for shaft, to stop bushings moving
        cylinder(d=axleOD-1,h=100,center=true);
        
        if (1) {
            // Tiny holes for reinforcing wire (to transmit torque, prevent part from cracking along layer lines)
            rebarN=3;
            rebarOD=0.050*inch+0.1;
            rebarR=(axleOD/2+gear_IR(hi_gear))/2;
            for (angle=[0:360/rebarN:360-1]) rotate([0,0,angle])
                translate([rebarR,0,0])
                    cylinder(d=rebarOD,h=100,center=true);
        }
        
        if (0) {
            // Bump in the bottom side to reduce curl and save plastic
            bumpZ=3;
            bumpR=gear_OR(hi_gear)+1;
            bumpDR=3;
            translate([0,0,-0.01])
            difference() {
                cylinder(r1=bumpR+bumpDR,r2=bumpR,h=bumpZ);
                cylinder(r1=bumpR-bumpDR,r2=bumpR,h=bumpZ);
            }
        }
    }
}


cutZ=3; // Z height of cut plane
cutN=6; // sides
cutR=gear_OR(hi_gear)/cos(360/cutN/2);

// Replaceable center version
//  (The center wears faster, but is easier and faster to print as a wear part)
module twopart_cut(enlarge=0) 
{
    translate([0,0,cutZ-enlarge]) 
        cylinder(r=cutR+enlarge,$fn=cutN,h=loZ+hiZ);
}

module twopart_lo() {
    difference() {
        union() {
            axled_gear();
            
            // Reinforce area around intersection
            intersection() {
                twopart_cut(enlarge=2.0);
                difference() {
                    cylinder(d=100,h=loZ-1);
                    cylinder(d=axleOD+1,h=100,center=true);
                }
            }
        }
        twopart_cut(enlarge=0.1);
    }
}

module twopart_hi() {
    intersection() {
        axled_gear();
        twopart_cut();
    }
}

axled_gear();

//#cylinder(d=12/cos(30),$fn=6,h=loZ+hiZ+1); // on a 12mm hex shaft

//twopart_lo();
//translate([43,0,-cutZ]) rotate([0,0,30]) twopart_hi();


