/*
 Mounts a steel upright tube on camera mast geared coupler.
*/

mast_OD=34;
mast_OR=mast_OD/2;

floor=2;
mast_center=[0,0,mast_OR+floor];

bolt_n=8; // number of mounting bolts we screw down to
bolt_R=70.5; // radius of circle in mounting bolt pattern
bolt_OD=5; // thru hole diameter
bolt_cap=11; // bolt head diameter

$fs=0.1;
$fa=5;

module mast_orient() {
    translate(mast_center) rotate([-90,0,0]) 
        children();
}

module mast_steel() {
    mast_orient() cylinder(d=mast_OD,h=200,center=true);
}

module bolt_pattern(dz=0) 
{
    for (bolt=[-1,0,+1]) rotate([0,0,360*bolt/bolt_n]) translate([0,bolt_R+(bolt==0?dz:0),0])
        children();
}

module mast_caps(cap=bolt_cap,dz=0)
{
    bolt_pattern(dz) circle(d=bolt_cap);
}
module mast_web2D(fatten=0,dz=0) 
{
    hull() offset(r=fatten) mast_caps(0.0,dz);
}

module mast_hull(fatten=0)
{
    hull() {
        linear_extrude(height=floor) mast_web2D(fatten);
        intersection() {
            //cube([200,200,50],center=true);
            mast_orient()
            translate([0,0,bolt_R+bolt_cap/2+fatten]) scale([1,1,-1])
                cylinder(d=mast_OD+fatten*2,h=32+fatten*2);
        }
    }
}

module lighten_holes() {
    round=5;
    shrink=3.5;
    linear_extrude(height=100,center=true)
        offset(r=+round) offset(r=-round) offset(r=-shrink)
        difference() {
            mast_web2D(0.0,5);
            //mast_caps();
            square([10,200],center=true);
        }
}

module mast_holder() {
    difference(){
        mast_hull(2.0);
        
        mast_steel();
        
        bolt_pattern() translate([0,0,floor]) {
            cylinder(d=bolt_cap,h=100);
            cylinder(d=bolt_OD,h=100,center=true);
            
        }
        
        lighten_holes();
    }
}

//#mast_steel();
mast_holder();

