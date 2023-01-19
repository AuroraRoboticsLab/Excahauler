/*
 Holds a row of DPDT switches, for manually moving
 excahauler robot arm.
*/

switch_box=[12.6,20.5,21.3];
nswitch=4;
floor=2;
wall=3;

module switches() 
{
    for (s=[0:nswitch-0.5])
        translate([(switch_box[0]+4)*s,0,-floor])
            children();
}

module switchrow(bigger,higher=0) {
    switches() 
        translate([-bigger,-bigger,+floor+higher])
            cube(switch_box+[2*bigger,2*bigger,-10]);
}

module handle_stick(shrink=0) {
    intersection() {
        translate([0,0,100-0.01*shrink]) cube([200,200,200],center=true);
        hull() {
            translate([10,-70,5]) sphere(d=25-2*shrink);
            translate([shrink,shrink,-3+shrink])
                cube([40-2*shrink,10-2*shrink,12-2*shrink]);
        }
    }
}

module handle_outside()
{
    hull() switchrow(wall,0);
    
    difference() {
        handle_stick(0);
        handle_stick(2);
        translate([15,-15,0]) cylinder(d=20,h=100);
    }
}

difference() {
    handle_outside();
    switchrow(0.0,-0.1); // hole for switch
    switchrow(1.0,2.0); // clearance around switch
}
