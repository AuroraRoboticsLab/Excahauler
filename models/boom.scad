$subpart=1;
include <../Excahaul_latest.scad>;
scale(0.001) 
	rotate([-145,0,0]) translate([0,-boomShoulder[1],0]) 
		boomModel(0,1);

