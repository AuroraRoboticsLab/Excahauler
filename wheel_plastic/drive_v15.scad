/*
  This part connects a Peg Perego gearbox output spline
  to a blow-molded Barbie Jeep wheel. 
  
  This is a trimmed-down version of the highly tuned drive_v14.stl, which was prepared in FreeCAD circa 2014.
  
  Orion Lawlor, lawlor@alaska.edu, 2023-06 (Public Domain)
*/
$fs=0.1;
$fa=2;

inch=25.4;

module times4() {
    for (angle=[0:90:360-1])
        rotate([0,0,angle])
            children();
}

encoder_ring_dia=58;
encoder_ring_bevel=5;
module encoder_ring(extraH=0) {
    linear_extrude(height=12+extraH) {
        intersection() {
            circle(d=encoder_ring_dia);
            
            side=52;
            rotate([0,0,45])
            square([side,side],center=true);
        }
    }
    cylinder(d1=2*encoder_ring_bevel+encoder_ring_dia,
        d2=encoder_ring_dia, h=encoder_ring_bevel*0.5);
    cylinder(d1=encoder_ring_bevel+encoder_ring_dia,
        d2=encoder_ring_dia, h=encoder_ring_bevel);
}

module gearbox_driver() 
{
    difference() {
        union() {
            import("drive_v14.stl",convexity=6);
            // plug screw holes in base
            base=12.5;
            times4() translate([18,0,base/2]) cube([10,10,base],center=true);
            // plug thru holes
            rotate([0,0,45]) times4()
                translate([25,0,0])
                    cylinder(d=14,h=26);
        }
        
        // Lightening holes underneath
        rotate([0,0,45]) {
            //cube([100,100,100]); // cutaway
            times4()
            translate([23,0,0]) scale([1,1.5,1.5]) sphere(d=20);
        }
        
        // Taper outer legs
        times4() translate([74,0,-1]) hull()
            for (del=[[0,0,0],[50,50,0],[50,-50,0]]) translate(del)
                 cylinder(d=85,h=20);
        
        // Trim out encoder ring mount
        translate([0,0,15.001]) difference() {
            cylinder(d=200,h=20);
            encoder_ring();
        }
        
        // Bearing mount:
        translate([0,0,-0.01])
        difference() {
            cylinder(d=7/8*inch-0.05,h=8);
            
            cylinder(d=13.7,h=20,center=true); // ring for support
        }
    }
}

gearbox_driver();
