/*
 3D printed screw-on grousers for
  Peg perego powerwheels tire (black polypropylene, blow molded)
*/ 

$fs=0.1;
$fa=5;

tire_OD=275; // diameter of tire at rim
tire_Z=178; // total tire height
tirebump1_OD=tire_OD+3; // diameter at middle ridge
tirebump1_Z=140; // width of middle ridge
tirebump2_OD=tire_OD+6; // diameter at middle ridge
tirebump2_Z=70; // width of middle ridge

// Round outside edges
module round2D(radius)
{
    offset(+radius) offset(-radius)
        children();
}

// Peg perego powerwheels tire: rotate only approximation
module tire_cylinders() {
    rotate_extrude() 
    difference() {
        union() {
            round2D(15)
            square([tire_OD,tire_Z],center=true);
            
            // middle ridge
            round2D(3)
            square([tirebump1_OD,tirebump1_Z],center=true);
            
            // middle ridge
            round2D(3)
            square([tirebump2_OD,tirebump2_Z],center=true);
        }
        // trim off -X stuff (rotate_extrude can't deal with it)
        translate([-1000,0]) square([2000,2000],center=true);
    }
}

// Peg perego powerwheels tire outside
module tire_outer() {
    rotate_extrude() 
    difference() {
        union() {
            round2D(12)
            square([tire_OD-8,tire_Z],center=true);
        }
        // trim off -X stuff (rotate_extrude can't deal with it)
        translate([-1000,0]) square([2000,2000],center=true);
    }
}

// Include SVG image of tread section
module tire_strip(filename,OD)
{
    intersection() {
        rotate([0,90,0])
        linear_extrude(height=OD+2,center=true,convexity=4)
        import(filename);
        
        cylinder(d=OD,h=tire_Z,center=true);
    }
}

// Tire with extruded treads
module tire_lumpen()
{
    for (ang=[-1:+1]) rotate([0,0,360/24*ang])
    {
        tire_strip("tire_scan_3A.svg",275);
    }
    tire_strip("tire_scan_3B.svg",275+6);
    tire_strip("tire_scan_3C.svg",275+6+6);
    
    tire_outer();
}

// Grouser has flat sides
module grouser_base() {
    side=32;
    z=tire_Z-10;
    
    difference() {
            
        scale([1,1/sqrt(3),1]) // sharpen by squishing along Y
        rotate([0,0,45])
            cube([side,side,tire_Z],center=true);
        
        for (side=[-1,+1]) scale([1,side,side])
        {
            // Bolt down both sides (and adhesive in middle)
            translate([9,3,z*0.3])
            rotate([0,90,0])
            {
                cylinder(d=5,h=20,center=true);
                cylinder(d1=13,d2=10,h=10);
            }
            
            // Bevel both ends so it rides over rocks while turning
            translate([0,0,z/2])
                rotate([0,45,0])
                    translate([0,0,100])
                        cube([200,200,200],center=true);
        }
        
        // Metal wear strip along ridge
        
    }
}

// Make a grouser to be tilted this way
module grouser(side=+1) {
    difference() {
        grouser_base();
        rotate([side*20,0,0]) // tilt grouser, to make spin easier
        translate([-tire_OD/2+5,0,0]) 
            tire_lumpen();
    }
}

module grouser_printable(side) {
    rotate([90,0,0])
    rotate([0,0,-30]) // lay flat
        grouser(side);
}

grouser_printable(+1);
translate([50,0,0]) grouser_printable(-1);
