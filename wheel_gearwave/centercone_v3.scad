
$fs=0.1;
$fa=2;

inch=25.4;

difference() {
    import("centercone_v2.stl",convexity=4);
    translate([0,0,-0.01])
    difference() {
        cylinder(d=7/8*inch,h=8);
        
        cylinder(d=14,h=20,center=true); // ring for support
    }
};

