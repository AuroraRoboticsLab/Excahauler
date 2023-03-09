/*
Beveled primitives, designed as drop-in replacements for builtins.

 Dr. Orion Lawlor, lawlor@alaska.edu, 2023-01-18 (Public Domain)

*/


// Beveled cube
module bevelcube(size,bevel,center=false,bz=1)
{
    translate(center?[0,0,0]:size/2)
    hull() {
        cube(size-[2*bevel,2*bevel,0],center=true);
        cube(size-[2*bevel,0,bz*2*bevel],center=true);
        cube(size-[0,2*bevel,bz*2*bevel],center=true);
    }
}

// Beveled cylinder
module bevelcylinder(d,h,bevel,center=false)
{
    translate(center?[0,0,0]:[0,0,h/2])
    hull() {
        cylinder(d=d-2*bevel,h=h,center=true);
        cylinder(d=d,h=h-2*bevel,center=true);
    }
}




