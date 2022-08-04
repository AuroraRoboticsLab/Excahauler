/*
Model of a Molon gearmotor, "24VDC CHM-2450-1"

Dr. Orion Lawlor, lawlor@alaska.edu, 2021-01-01 (Public Domain)
*/
$fs=0.1;
$fa=2;

inch=25.4; // file units = mm

// Space to leave around printed holes for press fit parts
clearance=0.1;

// The upward-facing output shaft, on bushings
motor_shaft_OD=9.5+clearance;
motor_shaft_Z=18.0; // from start of flat
motor_shaft_flat_Z=7.0; // from face to start of flat
motor_shaft_flat_D=8.1+clearance; // from back of shaft to face of flat

// The zinc gearbox
motor_box_x=76.6;
motor_box_y=70.1;
motor_box_z=14.2;
motor_box_round=4;

// The actual electrical barrel of the DC motor
motor_barrel_OD=37.8;
motor_barrel_z=60;

// Face of gearmotor
motor_dx=63.5; // distance between boltholes
motor_dy=60.3; 
motor_Z=0; // Z height of flat face of motor

motor_bolt_OD=0.190*inch; // thru hole for #10 mounting bolts

// The boss around the output shaft
motor_boss_OD=14.85; // reference area on boss
motor_boss_Z=5.2; // height of whole boss and bushing
motor_boss_TD=18.2; // outer OD, tapered up
motor_boss_TZ=2.0; // height of taper area

// Centerline of the output shaft relative to mounting bolts
motor_center_x=motor_dx/2-9.5-motor_boss_OD/2;

// The bump over the mounting face for the motor internal gear
motor_bump_x=37.7;
motor_bump_OD=17.5;
motor_bump_z=2.3;


// 2D outline of motor's gearbox
module motor_gearbox_2D(shrink=0) {
	translate([motor_center_x,0,0])
        offset(r=+motor_box_round) offset(r=-motor_box_round-shrink)
            square([motor_box_x,motor_box_y],center=true);
}

// 3D outline of motor's gearbox
module motor_gearbox_3D(shrink=0) {
    translate([0,0,-motor_box_z])
        linear_extrude(convexity=2,height=motor_box_z)
            motor_gearbox_2D(shrink);
}

// Instance the center of each motor mounting bolt
module motor_bolts() {
	translate([motor_center_x,0,0])
	for (leftright=[-1,+1]) translate([motor_dx/2*leftright,0,0])
	for (updown=[-1,+1]) translate([0,motor_dy/2*updown,0])
		children();
}

// Create 3D motor face geometry, subtract this to fit onto motor.
//   Z==0 means the face of the motor here
module motor_face_subtract() {
	translate([0,0,motor_Z]) {
        motor_gearbox_3D();
        
        translate([motor_bump_x,0,-motor_box_z-motor_barrel_z])
            cylinder(d=motor_barrel_OD,h=motor_barrel_z);
		
        translate([0,0,-motor_box_z-4.1]) // back side output boss
            cylinder(d=motor_boss_OD,h=5);
        
		translate([0,0,-0.01]) {
			// Main shaft bosses
			cylinder(d1=motor_boss_TD,d2=motor_boss_OD,h=motor_boss_TZ);
			cylinder(d=motor_boss_OD,h=motor_boss_Z);
			cylinder(d=motor_shaft_OD,h=motor_shaft_flat_Z);
			intersection() {
				r=motor_shaft_OD/2;
				z=motor_shaft_Z+motor_shaft_flat_Z;
				cylinder(r=r,h=z);
				translate([-r,-r,0])
					cube([motor_shaft_flat_D,2*r,z]);
			}

			// Minibump
			translate([motor_bump_x,0,0]) cylinder(d=motor_bump_OD,h=motor_bump_z);
					
			// Holes for mounting bolts
			motor_bolts() cylinder(d=0.190*inch,h=5);
		}
	}
}

projection(cut=true) translate([0,0,-1]) {
    translate([0,50,0]) cube([50,50,50]);

    difference() {
        translate([0,0,2])
            motor_gearbox_3D(0);
        motor_face_subtract();
    }
}

