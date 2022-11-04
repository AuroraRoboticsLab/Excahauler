/*

Suitable steel sheet: 
30 gauge 36x24 (0.012") for $14 https://www.lowes.com/pd/IMPERIAL-24-in-x-3-ft-Galvanized-Steel-Sheet-Metal/3234805

26 gauge 48x24 galvanized 
    https://www.lowes.com/pd/Hillman-24-in-x-48-in-Steel-Solid/3054567

22 gauge weldable 36x24 cold rolled (0.030" | 0.76 mm) for $40  https://www.lowes.com/pd/Hillman-24-in-x-36-in-Cold-Rolled-Steel-Solid/3054579
*/
$subpart=1;
include <../Excahaul_latest.scad>;

projection(cut=true) translate([0,0,-1])
{

    // top wall
    translate([0,-(scoopSize[1]+2),scoopSize[2]]) 
    rotate([90,0,0]) translate(-scoopPivot) scoopVolume();

    // back wall
    translate(-scoopPivot) scoopVolume();

    // bottom wall
    translate([0,2,0]) rotate([-90,0,0]) translate(-scoopPivot) scoopVolume();


    // side wall
    translate([scoopSize[0]/2+25,0,0]) rotate([0,90,0]) 
        translate(-scoopPivot) scoopVolume();

}



