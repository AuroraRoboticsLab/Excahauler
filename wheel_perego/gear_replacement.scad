/*
 3D printable replacement gears.  Ideally print from nylon or polycarbonate.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-06-30 (Public Domain)
*/
include <geartype_perego.scad>;

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
        count=round(gapR*2*PI/(lightenOD+2.0));
        for (a=[0:360/count:360-1]) rotate([0,0,a])
            translate([gapR,0,-0.1])
            {
                r=(lightenOD/2-gear_clearance);
                circle(r=r,$fn=16);
            } 
    }     
}

module solid_gear() 
{
    bevel=3; //<- avoid stress riser at hi root
    bevelR=gear_OR(hi_gear)+2.5;
    
    difference() {
        // low gear teeth
        linear_extrude(height=loZ,convexity=8) 
        difference() {
            gear_2D(lo_gear);
            // holes reduce curl
            offset(r=-1) hole_ring(lo_gear,hi_gear);
        }
        
        // Chop out space for bevel to happen
        lowR=gear_IR(lo_gear)-2;
        translate([0,0,loZ+0.1]) scale([1,1,-1])
            cylinder(r1=lowR,r2=lowR-bevel,h=bevel);
    }
    
    // hi gear teeth
    linear_extrude(height=loZ+hiZ,convexity=8) 
    difference() {
        gear_2D(hi_gear);
    }
    
    // Bevel connecting lower and upper gears
    translate([0,0,loZ-bevel-0.01])
        cylinder(r1=bevelR,r2=gear_IR(hi_gear),h=bevel);
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
        
        if (0) {
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

//twopart_lo();
//translate([43,0,-cutZ]) rotate([0,0,30]) twopart_hi();


