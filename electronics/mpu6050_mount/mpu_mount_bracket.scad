/*
MPU-6050 / 9150 IMU mounting bracket.

M3 mounting screws go beside the board

Holds a female 0.1" pin header in place.


Board dimensions:
20.9mm long
15.9mm wide
1.5mm thick
15.3mm hole to hole
3.05mm hole dia

L pins: 
2.6mm wide
2.5mm high
9mm long
*/

$fs=0.1; $fa=5;
inch=25.4;
wiggle=0.25; // printed clearance around printed parts, so parts actually fit
pinspacing=0.1*inch;
wall=2.0;
floor=2.5;
board_thick=1.3+0.1*inch; // board and first layer of headers
solder_thick=1.5;
pin_thick=0.1*inch+0.5;
overall=floor+pin_thick+board_thick+floor;

board_height=22;
board_width=17;

tube_OD=25.4;
module tube2D() {
    round=1.5;
    offset(r=+round) offset(r=-round)
        square([tube_OD,tube_OD]);
}
module tube3D() {
    translate([board_width/2-tube_OD/2,100,floor+pin_thick+board_thick])
        rotate([90,0,0])
            linear_extrude(height=200) tube2D();
}
//#tube3D();


module mpu_board2D() {
    square([board_width,board_height]);
}

module mpu_pins2D() {
    translate([4,0])
        scale([-1,1])
            square([11,board_height]);
}

module mpu_holes2D() {
    hole=5;
    for (y=[-hole,board_height+hole])
        translate([board_width/2,y])
            children();
}

module mpu_case2D() {
    difference() {
        hull() {
            offset(r=wall) mpu_board2D();
            for (dy=[-wall,+wall]) translate([0,dy])mpu_pins2D();
            mpu_holes2D() circle(d=6+2*wall);
        }
        mpu_holes2D() circle(d=3.2);
    }
}

module mpu_case3D() {
    difference() {
        // Outside shape
        linear_extrude(height=overall,convexity=4) mpu_case2D();

        // Space to silicone in the board
        translate([0,0,floor])
            linear_extrude(height=overall) mpu_board2D();
        
        // Extra space for solder on board
        scale([0.2,1]) translate([0,0,floor-solder_thick])
            linear_extrude(height=overall) mpu_board2D();
        
        // Space for the pins
        translate([0,0,floor+board_thick])
            linear_extrude(height=overall) mpu_pins2D();
        
        // Space for M3 bolt heads
        mpu_holes2D() cylinder(d=7,h=3);
        
        // Clearance for the frame tube
        tube3D();
    }
}

mpu_case3D();
