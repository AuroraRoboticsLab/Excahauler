/*
 Holds a row of driver cases vertically in slots, holding them but letting them be accessed when needed.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-01-18 (Public Domain)
*/

$fs=0.1; $fa=2;

include <../../AuroraSCAD/bevel.scad>;
include <driver_case_interface.scad>;
driver_leg_gap=15; // clearance above mounting plate (room for wires)
driver_leg_thick=18; // total depth of mounting slots
driver_leg_wide=20; // length legs stick out to sides

nslots=2;
slotspace=10; // space between slots (ventilation, wires, access)
slot2slot=slotspace+driver_case_thick;
lastslot=nslots*slot2slot-slotspace;

rebarOD=4; // basalt fiber rebar (epoxied in)

spring_base=35; // undercut distance (gives space for flex)
springH=8; // horizontal distance for spring end
springV=12; // vertical distance for spring end
springW=14; 

floor=1.5; // thickness of back plates
total_height=floor + driver_leg_thick;

wall=2.0; // exterior walls (interior are cut in half by slot)
w2=wall/2;

// For each pair of adjacent points in this list, make hulls between children.
module chainhull(points) 
{
    for (p=[0:len(points)-2]) {
        hull() {
            translate(points[p]) children();
            translate(points[p+1]) children();
        }
    }
}

// Round off inside corners from this cross section
module round_inside(round=3)
{
    offset(r=-round) offset(r=+round) children();
}


// Basic slot U shape
module slot2D() {
    w2=wall/2;
    chainhull([
        [0,driver_case_vertical],
        [0,0],
        [driver_case_thick,0],
        [driver_case_thick,driver_case_vertical]
    ]) circle(d=wall);
}

// Slot back side, including wire ties
module slot_back2D() {
    difference() {
        hull() slot2D();
        // Lightening + vent hole in middle
        translate([driver_case_thick/2,driver_case_vertical/2])
            scale([1,3.5,1])
                circle(d=driver_case_thick*2/3);
    }
    
    // Wiring arc on top
    r=driver_case_thick/2; // radius of hole for wires
    translate([driver_case_thick/2,driver_case_vertical])
    rotate([0,0,45])
    difference() {
        circle(r=r,$fn=8);
        circle(r=r-6,$fn=8);
    }
}

// Triangulate the gap between slots
module slot_gap2D() {
    w=wall*0.5;
    L=driver_case_thick; R=driver_case_thick+slotspace;
    h=driver_case_vertical;
    n=8; // number of stops in diagonals
    chainhull([
        [L,0],[R,0],
        [L,h*1/n],[R,h*2/n],
        [L,h*3/n],[R,h*4/n],
        [L,h*5/n],[R,h*6/n],
        [L,h*7/n],[R,h*8/n],
        [L,h]
    ]) circle(d=w);
    
    // Space to glue in rebar
    translate([R-rebarOD,h/2])
    difference() {
        circle(d=2*rebarOD); // surrounds rebar
        circle(d=rebarOD); // hole for rebar
    }
}

// Lower leg cross section
module slot_leg2D(ht=driver_case_vertical) {
    w=wall;
    chainhull([
        [-driver_leg_wide,-driver_leg_gap],
        [-wall/2,-driver_leg_gap],
        [-wall/2,ht]
    ]) circle(d=w);
}

// Lower leg back side reinforcing plate
module slot_leg_back2D() {
    difference() {
        hull() slot_leg2D(5);
        
        translate([-driver_leg_wide/3,-driver_leg_gap*2/3])
            circle(d=7); //<- can tie wires on here
    }
}

// Top retaining spring cross section
module slot_spring2D() {
    w=wall;
    w2=w/2;
    difference() {
        chainhull([
            [0,driver_case_vertical-spring_base], // start inside
            [0,driver_case_vertical-spring_base/2], // get thicker
            [-w2,driver_case_vertical+w2], // inside corner
            [springH,driver_case_vertical+w2], // inside retainer
            [-w2-3,driver_case_vertical+springV], // sloped top
            [-w2,driver_case_vertical+w2] // close back for tip strength
        ]) circle(d=w);
        
        // Don't intrude into actual slot
        square([driver_case_thick,driver_case_vertical]);
    }
}

// Cross section of entire set of walls
module slots_wall2D() {
    round_inside(1) {
        slot_leg2D();
        
        for (s=[0:nslots-1]) translate([s*slot2slot,0])
        {
            slot2D();
            if (s<nslots-1) slot_gap2D();
        }
        
        translate([lastslot,0]) scale([-1,1,1]) slot_leg2D();
        
        // Diagonals to connect base to legs
        chainhull([
            [0,-driver_leg_gap],
            [driver_leg_gap,0],
            [lastslot-driver_leg_gap,0],
            [lastslot,-driver_leg_gap]
        ]) circle(d=wall);
    }
}

// Cross section of back plates and flat reinforcing
module slots_back2D() {
    round_inside(1) {
        slot_leg_back2D();
        
        round_inside(2)
        for (s=[0:nslots-1]) translate([s*slot2slot,0])
        {
            slot_back2D();
            
            h=driver_case_vertical/8;
            w=(s<nslots-1)?slot2slot:driver_case_thick;
            for (y=[0, driver_case_vertical/2-h/2, driver_case_vertical-h])
                translate([0,y]) square([w,h]);
        }
        
        translate([lastslot,0]) scale([-1,1,1]) 
            slot_leg_back2D();
    }
}

// Add a spring for each slot
module slot_spring_for() 
{
    for (s=[0:nslots-1]) 
    {
        if (s<nslots-1)
            translate([s*slot2slot,0])
                children();
        else // last one faces other way
            translate([lastslot,0]) scale([-1,1,1])
                children();
    }
}

// Whole 3D part
module slots3D() {
    difference() {
        translate([0,0,-floor])
        union() {
            linear_extrude(height=floor+0.1,convexity=4)
                slots_back2D();
            linear_extrude(height=total_height,convexity=6)
                slots_wall2D();
        }
        
        // Bays for each chunk
        for (s=[0:nslots-1]) translate([s*slot2slot,0])
            bevelcube([driver_case_thick,driver_case_vertical+wall,driver_case_horizontal],bevel=1);
        
        // Holes for mounting bolts
        for (x=[-driver_leg_wide*2/3,lastslot+driver_leg_wide*2/3])
            translate([x,-driver_leg_gap,driver_leg_thick/2])
                rotate([90,0,0]) cylinder(d=3.2,h=10,center=true);
        
        // Cut slot around the spring retainer
        slot=3; space=0.5;
        slot_spring_for() 
            translate([-5,driver_case_vertical-spring_base,total_height-floor-springW-slot])
            {
                bevelcube([10,slot,slot],bevel=slot/3); // strain relief cut
                // Separating cut
                translate([0,slot/2,slot-space])
                cube([10,spring_base+10,space]);
            }
    }
    
    // Add spring tips
    slot_spring_for() 
    {
        start=total_height-floor-springW;
        translate([0,0,start])
            linear_extrude(height=springW,convexity=4)
                slot_spring2D();
        
        // Support the overhang part of the spring
        spaceV=0.4;
        spaceH=0.6;
        translate([0,0,-floor])
        difference() {
            // Support the spring
            linear_extrude(height=start+floor-spaceV,convexity=4)
                offset(r=-spaceH) slot_spring2D();
            // Don't touch the backplate
            linear_extrude(height=floor+spaceV,convexity=4)
                offset(r=spaceH) slot_back2D();
       }
    }
}


slots3D();