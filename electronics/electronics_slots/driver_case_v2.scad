/*
 One driverrack holds: 
   - One Arudino nano daughterboard
   - Two green UN178 brushless motor drivers
 
 (Formerly called "daughterboard", since it had a separate 
  serial connection to a single "motherboard".)
 
 
*/
dxf_name="driverrack_v2_xport.dxf";

// Load a DXF file layer
module dxf(layer_name,convexity=2) {
	s=1; // previously needed to be 90/96 to fix cursed Inkscape DPI switch
	scale([s,s,1])
	import(dxf_name,layer=layer_name,convexity=convexity);
}

floor=1.5;
outerwall=1.5;
outerwall_z=floor+25;

innerwalls=1.5;

circuit_low_z=floor+2.2; // base of UN178 board
circuit_high_z=circuit_low_z+13.3; // base of driver board



// Round inside corners of this outline
module round(fillet) {
	//offset(r=+fillet) offset(r=-fillet)
	offset(r=-fillet) offset(r=+fillet)
		children();
}

// Outer walls
module outline_2D(thickness=outerwall) {
	offset(r=+thickness)
	offset(r=-3) // <- prepared with 3mm wall in mind 
	dxf("outline");
}

// Sensor plug insertion area
module sensors_2D() {
    round=4;
	offset(r=-round) offset(r=+round) 
	offset(r=+round) offset(r=-round) 
    union() {
		//for (shift=[+3,-3]) translate([0,0.5*shift])
				dxf("sensors",convexity=4);
	}
}

// Inner electronics bays
module bays_2D(extra=0) {
	offset(r=1) dxf("circuit");
	//sensors_2D();
	
	// Stiffening rib for electronics
	//if (extra)
	//translate([-14.0,-20]) square([2,23]);
}

// Make grid of thin wires
module dice() {
	difference() {
		children();
		
		union() {
		translate([50,0,0])
		for (dx=[-100:5:+100]) 
		for (plusminus=[+1,-1])
			rotate([0,0,plusminus*45]) translate([dx,0,0]) square([1.0,200],center=true);
		}
	}
}

// Reinforcing along the top edge
module reinforcing_bar(fatten=0)
{    
    offset(r=fatten)
    translate([-10,21.2]) square([1.5,95],center=true);
}

// Add mounting points for M3 hold-down screws
module screw_mounts(height,r,fatten,reinforcing) {
	difference() {
		linear_extrude(height=height,convexity=4)
        round(2.0)
        {
			offset(r=r+fatten) dxf("circuitholes");
            
            // Reinforcing along top edge
            if (reinforcing) reinforcing_bar(fatten);
            
        }
	}
}

// Add "ears" for securing wires with zipties
ear_size=4.5;
module ear_mounts() {
	perimeter=ear_size;
	linear_extrude(height=circuit_low_z,convexity=8)
	difference() {
		offset(r=+perimeter)
			children();
		children();
	}
}

// 2D profile of velcro mounting slot, facing in +Y
velcro_sz=[4,18];
module velcro() {
	round=1.2;
	offset(r=+round) offset(r=-round)
		square(velcro_sz);
	
}


// Main frame, with no add-ons or holes
module frame_3D() {
	// Outer walls
	linear_extrude(height=outerwall_z,convexity=4) 
	difference() {
		outline_2D();
		offset(r=-outerwall) outline_2D();
	}
	
	// Floor
	linear_extrude(height=floor)
	difference() {
		outline_2D();
		//dice() //dxf("vent");
        
        // Big wide ventilation / lightening holes in floor
        round=12;
        offset(r=+round) offset(r=-round) // very rounded
        translate([38,18.5])
        difference() {
            square([70,124],center=true); 
            square([100,15],center=true); // center stripe
        }
	}
	
	// Mini walls around electronics bays
	linear_extrude(height=circuit_high_z-3,convexity=6)
	difference() {
		offset(r=+innerwalls) bays_2D(1);
		bays_2D(1);
	}
}

module whole_frame() {	
	difference() {
		union() {
			difference() {
				frame_3D();
				
			}
			
			// Tapered wall intersection
			intersection() {
				for (taper=[0:0.5:2])
				linear_extrude(height=circuit_low_z-taper)
				round(4)
				{
					offset(4.0+taper) // bosses around UN holes
						dxf("holes");
                    reinforcing_bar(taper); //<- merge into bosses around holes
					//offset(ear_size+taper)
					//	velcro_and_bolts_2D();
					difference() {
						square([1000,1000],center=true);
						outline_2D(-taper);
					}
				}
				linear_extrude(height=outerwall_z)
					outline_2D();
			}
			
			// Back side walls
			difference() {
				union() {
					mount=4.0; // wall around circuit board screw mounts
					screw_mounts(circuit_high_z,mount,0,0);
					screw_mounts(circuit_high_z-5,mount,0,1);
					for (taper=[0:0.5:2]) // stepped bevel to floor
                        screw_mounts(circuit_low_z-taper,mount,taper,1);
				}
				linear_extrude(height=outerwall_z)
				{
					offset(r=0.5) dxf("un178");
					bays_2D();
				}
			}
			
			
				
		}
		
		// Openings for electronics
		translate([0,0,circuit_low_z])
		linear_extrude(height=outerwall_z)
			dxf("insert");
		
		// Punch holes for mounting screws all the way through everything
		translate([0,0,-0.1])
			linear_extrude(height=2*circuit_high_z)
			union() {
				dxf("holes");
				dxf("circuitholes");
			}
		
				
		// Thru holes for bottom-insert stuff
		translate([0,0,-0.1])
		linear_extrude(height=outerwall_z+2)
		union() {
			sensors_2D();
			dxf("rj45");
		}
	}
}

whole_frame();



// Drop raw DXF on top of everything
// color([1,0,0]) translate([0,0,3]) import(dxf_name);

