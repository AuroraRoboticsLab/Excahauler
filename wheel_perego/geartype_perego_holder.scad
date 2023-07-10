/*
 Parameters for the gears inside a Peg Perego motor gearbox.
 
 This version customized for the gear holder, not quite the same as the actual gears.
 
 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-06-30 (Public Domain)
*/
$fs=0.05; $fa=2;

use <../AuroraSCAD/gear.scad>;


pressureAngle=10; // 14.5;
add=0.4;
ded=0.4;

// Geartypes for each gear layer
geartype0 = [ 0.8, 9.0, pressureAngle, add, ded ]; // motor
geartype1 = [ 1.25, 10.5+1.2, pressureAngle, add, ded ]; // fastest gear output
geartype2 = [ 1.77, 12+1.7, pressureAngle, add, 0.3 ]; // intermediate gear
geartype3 = [ 2.25, 16, pressureAngle, add, ded ]; // output gear



