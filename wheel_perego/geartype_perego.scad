/*
 Parameters for the gears inside a Peg Perego motor gearbox.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-06-30 (Public Domain)
*/
$fs=0.05; $fa=2;

use <../AuroraSCAD/gear.scad>;


pressureAngle=14.5;
add=0.32;
ded=0.4;

// Geartypes for each gear layer
geartype0 = [ 0.8, 9.0, pressureAngle, add, ded ]; // motor
geartype1 = [ 1.235, 10.5+1.2, pressureAngle, add, ded ]; // fastest gear output
geartype2 = [ 1.76, 12+1.7, pressureAngle, add, ded ]; // intermediate gear
geartype3 = [ 2.23, 16, pressureAngle, add, ded ]; // output gear


gear1lo=gear_create(geartype0,75);
gear1hi=gear_create(geartype1,14);

gear2lo=gear_create(geartype1,45);
gear2hi=gear_create(geartype2,12);

gear3lo=gear_create(geartype2,30);
gear3hi=gear_create(geartype3,13);

