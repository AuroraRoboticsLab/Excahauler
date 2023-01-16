/*
(AuroraSCAD/gears.scad is the modern replacement for this file.)

Massive gear reduction in a single stage planetary gearbox.

The basic idea is to *almost* match the input and output planets,
so the planets couple the input and output rings like a harmonic drive.

The key observation is that with 3D printed gears, you can choose the 
output gear plane's pitch to force the planet radius to match between planes.



Input: 550 type brushed DC
  38mm motor outside diameter
  https://www.amazon.com/RS550-15000-Speed-Gearbox-Engine/dp/B07GDBD2ZL
  10 tooth "32 pitch" (== 32 teeth around a 1 inch pitch diameter circle.)

Output: box shaft on ball bearings


Applications: robot arms, wheels, legs, etc.

Built by Dr. Orion Lawlor (lawlor@alaska.edu) starting from many
sources and much trial and error, 2019-2021.  (Public Domain)

See also:
John Kerr's planetary reduction gears:
	https://www.thingiverse.com/LoboCNC/designs

General gear design:
	https://www.engineersedge.com/gear_formula.htm

Observations and constraints on planetary gearsets:
	https://woodgears.ca/gear/planetary.html

Notes on 3D printed gears:	https://engineerdog.com/2017/01/07/a-practical-guide-to-fdm-3d-printing-gears/

*/
$fs=0.1;
$fa=3;

// Distance between inner and outer rings
ring_clearance=0.2;

// Distance between bearing balls and race
ball_clearance=0.1;

// Distance between gear teeth
tooth_clearance=0.0;

// showteeth=true: show actual gear teeth.  False: show only pitch circle.
showteeth=true;

// One geartype consists of a pitch and height for the teeth.
geartype_550 = [ 2.5, 10.0, 20, 0.32, 0.4 ]; // motor input (must match motor's sun gear)
geartype_out = [ 3, 12.0, 20, 0.32, 0.4 ]; // output ring


// Circular gear pitch = distance between teeth along arc of pitch circle
function geartype_Cpitch(geartype) = geartype[0];

// Diametral gear pitch = amount of diameter per gear tooth
function geartype_Dpitch(geartype) = geartype[0]/PI;

// Height of each tooth along Z (after extrusion)
function geartype_height(geartype) = geartype[1];

// Pressure angle (degrees)
function geartype_pressure(geartype) = geartype[2];

// Addendum = radial distance top of tooth sticks up from pitch circle
function geartype_add(geartype) = geartype[3]*geartype_Cpitch(geartype);

// Dedendum = radial distance down from pitch circle to bottom of root
function geartype_sub(geartype) = geartype[4]*geartype_Cpitch(geartype);

// A gear consists of a type and a tooth count
function gear_create(geartype,nteeth) = [ geartype, nteeth ];
function gear_geartype(gear) = gear[0];
function gear_nteeth(gear) = gear[1];

// Diameter of gear along pitch circle
function gear_D(gear) = geartype_Dpitch(gear[0])*gear[1];
function gear_ID(gear) = gear_D(gear)-2*geartype_sub(gear[0]);
function gear_OD(gear) = gear_D(gear)+2*geartype_add(gear[0]);

// Radius versions
function gear_R(gear) = gear_D(gear)/2;
function gear_IR(gear) = gear_ID(gear)/2;
function gear_OR(gear) = gear_OD(gear)/2;



// Draw one gear
module gear_2D(gear) {
	if (showteeth) {
		IR=gear_IR(gear);
		OR=gear_OR(gear);
		nT=gear_nteeth(gear);
		dT=360/nT; // angle per tooth (degrees)
		gt=gear_geartype(gear);
		Cpitch=geartype_Cpitch(gt);
		angle=geartype_pressure(gt);
		refR=IR;
		hO=OR-refR;
		hM=gear_R(gear)-refR;
		tilt = angle-0.5*dT;
		tI=Cpitch/4+geartype_sub(gt)*sin(tilt);
		tM=Cpitch/4;
		tO=Cpitch/4-geartype_add(gt)*(sin(tilt)+sin(dT));
		round=0.15*Cpitch;
		offset(r=-tooth_clearance/2)
		offset(r=+round) offset(r=-round) // round off inside corners
		offset(r=-round) offset(r=+round) // round outside corners
		intersection() {
			union() {
				circle(r=IR);
				// Loop over the gear's teeth 
				for (T=[0:nT-0.5])
					rotate([0,0,dT*T]) 
						translate([refR,0,0])
						polygon([
							[0,tI],
							[hM,tM],
							[hO,tO],
							[hO,-tO],
							[hM,-tM],
							[0,-tI]
						]);
			}
			circle(r=OR);
		}
	}
	else
	{ // no teeth, just pressure circle (much faster)
		circle(d=gear_D(gear));
	}
}



// One gearplane consists of a geartype, (S) sun gear, (P) planet gears, and (R) ring gear.
function gearplane_geartype(gearplane) = gearplane[0];
function gearplane_height(gearplane) = geartype_height(gearplane[0]);
function gearplane_Cpitch(gearplane) = geartype_Cpitch(gearplane[0]);
function gearplane_Dpitch(gearplane) = geartype_Dpitch(gearplane[0]);

function gearplane_Steeth(gearplane) = gearplane[1];
function gearplane_Sgear(gearplane) = gear_create(gearplane[0],gearplane_Steeth(gearplane));

function gearplane_Pteeth(gearplane) = gearplane[2];
function gearplane_Pgear(gearplane) = gear_create(gearplane[0],gearplane_Pteeth(gearplane));

function gearplane_Pcount(gearplane) = gearplane[3];
function gearplane_Pradius(gearplane) = gear_R(gearplane_Sgear(gearplane))+gear_R(gearplane_Pgear(gearplane));

function gearplane_Rteeth(gearplane) = gearplane_Steeth(gearplane)+2*gearplane_Pteeth(gearplane);
function gearplane_Rgear(gearplane) = gear_create(gearplane[0],gearplane_Rteeth(gearplane));

// Gear ratio if ring gear is fixed, planet carrier from sun gear
function gearplane_ratio_Rfixed(gearplane) = gearplane_Steeth(gearplane) / (gearplane_Rteeth(gearplane) + gearplane_Steeth(gearplane));

gearplane_in = [geartype_550, 10,  14,4 ];
gearplane_out = [ geartype_out, 8, 12,4 ];

pmatch=gearplane_Cpitch(gearplane_out)
	*gearplane_Pradius(gearplane_in)/gearplane_Pradius(gearplane_out);
echo("Output pitch for matching planet spin radius",pmatch);


// Return x rounded to the nearest multiple of step
function find_nearest_multiple(x,step) = step*round(x/step);

// Rotate to align the sun gear
module gearplane_sun(gearplane) {
	P=gearplane_Pteeth(gearplane);
	timing=(P%2)?0.0:0.5;
	rotate([0,0,360/gearplane_Steeth(gearplane)*timing])
		children();
}

// Translate (and rotate) to the positions of each planet gear
module gearplane_planets(gearplane) {	
	S=gearplane_Steeth(gearplane);
	P=gearplane_Pteeth(gearplane);
	nP=gearplane_Pcount(gearplane);
	Pradius=gearplane_Pradius(gearplane);
	
	// Planet gear positions must be a multiple of this to match ring
	Pconstraint=360/(gearplane_Rteeth(gearplane)+gearplane_Steeth(gearplane));
	
	for (P=[0:nP-0.5])
	{
		target=360/nP*P;
		ring=find_nearest_multiple(target,Pconstraint);
		timing = ring/360*S;
		rotate([0,0,ring])
			translate([Pradius,0,0])
				rotate([0,0,360/gearplane_Pteeth(gearplane)*timing])
					children();
	}
}

module gearplane_ring_2D_inside(gearplane) {
	offset(+tooth_clearance)
	gear_2D(gearplane_Rgear(gearplane));
}
module gearplane_ring_2D(gearplane,rim_thick=4) {
	difference() {
		circle(d=rim_thick+gear_OD(gearplane_Rgear(gearplane)));
		gearplane_ring_2D_inside(gearplane);
	}
}
module gearplane_hex_2D(gearplane,rim_thick=4) {
	difference() {
		circle(d=(rim_thick+gear_OD(gearplane_Rgear(gearplane)))/cos(30),$fn=6);
		gearplane_ring_2D_inside(gearplane);
	}
}


// Draw a full plane of gears
module gearplane_2D(gearplane) {
	Sgear=gearplane_Sgear(gearplane);
	Pgear=gearplane_Pgear(gearplane);
	Rgear=gearplane_Rgear(gearplane);
	
	// Gear timing:
	//   Ring gear defines alignment, right side always has tooth hole
	//   First planet gear fits into tooth hole
	//   Sun gear needs to match first planet
	//   Other planets need to match sun
	
	// Sun
	gearplane_sun(gearplane)
		gear_2D(Sgear);
	
	// Planets
	gearplane_planets(gearplane)
		gear_2D(Pgear);
	
	// Ring
	gearplane_ring_2D(gearplane);
}

// Make a 3D gear
module gear_3D(gear,bevel=1) 
{
	h=geartype_height(gear_geartype(gear));
	intersection() {
		hull() {
			cylinder(d1=gear_ID(gear),d2=gear_OD(gear),h=bevel);
			translate([0,0,h]) scale([1,1,-1])
			cylinder(d1=gear_ID(gear),d2=gear_OD(gear),h=bevel);
		}
		linear_extrude(height=h,convexity=8)
			gear_2D(gear);
	}
}

// Tattoo to get planet timing right
module gearplane_tattoo(gearplane,depth=0.5,thick=0.7) {
	nP=gearplane_Pcount(gearplane);
	translate([0,0,-depth]) {
		linear_extrude(height=2*depth,convexity=10) {
			r=gearplane_Pradius(gearplane);
			difference() {
				circle(r=r+0.1);
				circle(r=r-thick);
			}
			for (clock=[0:nP-0.5])
				rotate([0,0,360/nP*clock]) {
					wid=(clock+1)*thick;
					polygon([ [2*r,+wid], [2*r,-wid], [r,-wid/2], [r,+wid/2] ]);
				}
		}
	}
}

module gearplane_top_tattoo(gearplane,depth=0.5,thick=0.7) {
	translate([0,0,gearplane_height(gearplane)])
		gearplane_tattoo(gearplane,depth,thick);
}


