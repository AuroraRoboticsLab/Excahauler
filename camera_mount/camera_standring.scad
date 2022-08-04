
$fs=0.1; $fa=2;
inch=25.4;
thru=0.2+0.25*inch;
OD=20*2;
Z=20;


difference() {
    cylinder(d=OD,h=Z);
    cylinder(d=thru,h=2*Z+1,center=true);
}

