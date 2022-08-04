/*
 Excahauler rigid-caracass wheels.
   This file is included by Excahaul_latest.scad, and for various wheel prototypes.
 
*/

// Wheels
wheelDia=300; // diameter of wheels (less grousers)
wheelRad=wheelDia/2;
wheelThick=200; // thickness of wheels along axles
wheelWall=3.0; // thickness of wheel cylinder material
wheelBevel=15; // corners of wheels beveled for turning
ngrouser=24;  // grouser count from (Intosume et al, 2019)
grouserHt=0.075*wheelDia/2; // height = 7.5% of wheel radius
grouserSize=2.8; // thickness of grousers

// Basic wheel outline, including bevel
module wheelBasicOutline(extraR=0) {

        translate([0,0,wheelThick/2])
            hull() {
                cylinder(d=wheelDia+2*extraR,h=wheelThick-2*wheelBevel,center=true);
                cylinder(d=wheelDia+2.15*extraR-0.6*wheelBevel,h=wheelThick-1.0*wheelBevel,center=true);
                cylinder(d=wheelDia+2.3*extraR-2*wheelBevel,h=wheelThick-0.02*extraR,center=true);
            }
}

// Wheel outline, including bevel and middle hole in spokes
module wheelOutline(extraR=0) {
    difference() {
        wheelBasicOutline(extraR);
        
        translate([0,0,75-extraR])
            cylinder(d1=50,d2=wheelDia,h=wheelThick);
    }
}

module wheelRim() {
    difference() {
        wheelOutline();
        wheelOutline(-wheelWall);
    }
}

// Grousers add traction to wheels
module wheelGrousers(twist=0) 
{
    intersection() {
        difference() {
            wheelOutline(grouserHt);
            wheelOutline(-0.5);
        }
        union() {
            r=wheelDia/2+grouserHt;
            startR=wheelDia/4;
            twistRate=360.0/1400.0; // degrees of grouser twist per mm of wheel height
            
            translate([0,0,wheelThick/2])
            for (bevel=[1])
            {
                h=wheelThick-2*wheelBevel*bevel;
                twistDeg=twist*h*twistRate;
                rotate([0,0,-bevel*wheelBevel*twistRate]) //<- line up two sections
                linear_extrude(twist=twistDeg,slices=twist?4:0,height=h,convexity=8,center=true)
                {
                    for (grouser=[0:360/ngrouser:360-1])
                        rotate([0,0,grouser])
                        if (bevel) // bevel the grouser root
                            translate([wheelDia/2-0.2,0,0])
                                rotate([0,0,45])
                                {
                                    s=7; // bevel this far
                                    square([s,s],center=true);
                                }
                        else // plain grouser:
                            translate([startR,-grouserSize/2,0])
                                square([r-startR,grouserSize]);
                }
            }
            
            // Straight planar grousers (instead of helix above)
            for (grouser=[0:360/ngrouser:360-1])
                rotate([0,0,grouser+(twist?4.4:-4.1)])
                    translate([wheelDia/2,0,wheelThick/2])
                        rotate([twist*33.5,0,0]) //<- fixme: somehow related to twistRate
                            cube([100,grouserSize,2*wheelThick],center=true);
            
            if (twist==0) // ring stiffener / cross-slip preventer rings on middle wheels
                for (z=[wheelBevel+grouserSize/2,wheelThick-wheelBevel-grouserSize/2])
                translate([0,0,z])
                    cylinder(h=grouserSize,r=r,center=true);
            /*
            translate([0,0,wheelThick/2])
                for (grouser=[0:360/ngrouser:360-1])
                    rotate([0,0,grouser])
                    {
                        // Big blocks on outside of wheels
                        translate([wheelDia/2,0,0])
                            cube([2*grouserSize,grouserSize,wheelThick],center=true);
                        
                        // Small ribs on inside
                        rotate([5,0,0])
                        //translate([0,grouserSize/2,0])
                            cube([wheelDia-2*wheelBevel,2,wheelThick],center=true);
                    }
            */
        }
    }
}
