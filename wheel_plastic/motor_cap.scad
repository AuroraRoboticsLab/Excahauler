// motor_cap.scad
// New design for motor caps w/ circulation

wiggle=0.3;
epsilon = 0.1;

cap_rounding=1; // rounds all exterior dimensions this much

cap_upper_height = 17.5;
cap_upper_diam = 34+wiggle;
cap_diam_inner = 36+wiggle;
cap_inner_height = 19;
cap_hole_diam = 25;
cap_diam_jacket = 38+wiggle;
cap_jacket_height = 20;
cap_thickness = 4;


cap_wirebox_width = 3+cap_thickness;
cap_wirebox_length = 7+cap_thickness;

slit_width = 7;
slit_offset = 10+cap_upper_height;
slit_height = 24;
slit_number = 10;

difference() {
    minkowski(convexity=6) {
        difference() {
            union() {
                // Cap outside
                cylinder(d=cap_diam_jacket+cap_thickness-2*cap_rounding, h=cap_upper_height+cap_inner_height+cap_jacket_height+cap_thickness);
                // Column for wires
                translate([-cap_diam_inner/2-cap_wirebox_width/2-cap_thickness+cap_rounding, -cap_wirebox_length/2+cap_rounding, 0]) {
                    cube([cap_wirebox_width-2*cap_rounding, cap_wirebox_length-2*cap_rounding, cap_upper_height+ cap_inner_height+cap_jacket_height+cap_thickness]);
                }
            }
            // Make circulation holes
            for(i=[1:slit_number-1]) {
                rotate([0,0, i*360/slit_number+90]) { 
                    translate([-slit_width/2, (cap_diam_inner+cap_thickness)/2-10/2, slit_offset]) {
                        cube([slit_width+2*cap_rounding,20,slit_height]);
                    }
                }
            }
        }
		
		// Comment out this line for speed:
        sphere(r=cap_rounding,$fs=cap_rounding/3);
    }
    // Room for wires
    translate([0,0,cap_thickness]) {
        cylinder(d=cap_upper_diam, h=cap_upper_height+epsilon);
    }
    // Room without jacket
    translate([0,0,cap_thickness+cap_upper_height]) {
        cylinder(d=cap_diam_inner, h=cap_inner_height+epsilon);
    }
    // Room with jacket
    translate([0,0,cap_thickness+cap_upper_height+cap_inner_height]) {
        cylinder(d=cap_diam_jacket, h=cap_jacket_height+20*epsilon);
    }
    
    // Make air hole in bottom
    translate([0,0,-20*epsilon]) {
        cylinder(d=cap_hole_diam, h=cap_thickness+30*epsilon);
    }

    // Wire hole
    translate([-cap_diam_inner/2-(cap_wirebox_width-cap_thickness)/2-cap_thickness, -(cap_wirebox_length-cap_thickness)/2, +cap_thickness]) {
            cube([cap_wirebox_width/*-cap_thickness*/, cap_wirebox_length-cap_thickness, cap_upper_height+cap_inner_height+cap_jacket_height+20*epsilon]);
    }
}



/*cylinder(d=cap_diam_inner+cap_thickness, h=cap_inner_height);
translate([0,0,cap_inner_height]) {
    cylinder(d=cap_diam_jacket+cap_thickness, h=cap_jacket_height);
}*/

// Trianglular fins around 
fin_length = 6;
fin_number = 10;

/*module triangle_equilateral(length) {
    polygon(points = [ [0,0], [length/sqrt(3),0], [0, 2*length/sqrt(3)] ]);
    mirror([1,0,0]){
        polygon(points = [ [0,0], [length/sqrt(3),0], [0, 2*length/sqrt(3)] ]);
    }
}

module cap_fin( length, height ) {
    union() {
        translate([0, (cap_diam_inner+cap_thickness)/2]) {
            linear_extrude(height=cap_height) {
                triangle_equilateral(fin_length);
            }
            translate([-length/sqrt(3), -cap_thickness, 0]) {
                cube([2*length/sqrt(3), cap_thickness, height]);
            }
        }
    }
}*/



/*difference() {
    union() {
        difference() {
            cylinder(d=cap_diam_inner+cap_thickness, h = cap_height);
            
            // Make circulation holes
            for(i=[0:fin_number-1]) {
                rotate([0,0, i*360/fin_number+360/(fin_number*2)]) {
                    translate([-slit_width/2, (cap_diam_inner+cap_thickness)/2-10/2, slit_offset]) {
                        cube([slit_width,10,slit_height]);
                    }
                }
            } 
        }
        translate([-cap_diam_inner+cap_wirebox_width/2+cap_thickness, -cap_wirebox_length/2, 0]) {
            cube([cap_wirebox_width, cap_wirebox_length, cap_height]);
        }
    }
    translate([0,0, cap_thickness]) {
        cylinder(d=cap_diam_inner, h = cap_height);
    }
    
    // hole for wires
    translate([-cap_diam_inner+(cap_wirebox_width-cap_thickness)/2+cap_thickness*2, -(cap_wirebox_length-cap_thickness)/2, +cap_thickness]) {
        cube([cap_wirebox_width-cap_thickness, cap_wirebox_length-cap_thickness, cap_height]);
    }
}



        // Make fins
       /* for(i=[0:fin_number-1]) {
            rotate([0,0,i*360/fin_number]) {
                cap_fin(fin_length, cap_height);
            }
        }*/
        
        
   // }