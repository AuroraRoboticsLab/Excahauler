/*
 2-pin tool coupler.
 Slot width: 75mm
 Pin diameter: 5/16" or 8mm
 Distance between pins: 125mm
 
 At 0.6 scale:
    connector rebar are 3mm
    main pins are 3/16 instead of 5/16
*/

$fs=0.1; $fa=2;

inch=25.4; // file units:mm

wide=73; // fits in slot on tools
wall=7; // sidewall thickness
thumb=wide-2*wall-2; // width of locking thumb (with clearance)

pinOD=8.3; // <- leave space for pin motion due to thermal expansion
bottomPin=[0,0,0];
topPin=[0,125,0];

thumbPivot=[7.25,8.68,0];

mountCenter=[16,52,0]; // from bottom pin to center of mounting plate

baseplateOD=150;
baseplateThick=8;
nBaseplateScrews=8;
baseplateScrewR=70.5; // <- from geared coupler print

// Reinforcing rods hold halves together
rebarOD=4.7; // 3/16" rod (after drilling)
rebarList=[
    [-5,132,0], // above top pin
    [12,122,0], // below top pin
    [7,-7,0], // below bottom pin
];

module importDXF(layerName)
{
    import("coupler_cross_section.dxf",layer=layerName);
}

// Bevel outer perimeters of this 2D shape as it's extruded.
module bevel_extrude(ht,bevel,convexity)
{
    intersection() {
        // Raw (non-beveled) shape, to get the inside cavities correct
        linear_extrude(height=ht+0.1,convexity=convexity,center=true)
            children();
        
        // Bevel by shrinking in height, then inside
        hull() {
            linear_extrude(height=ht-2*bevel,convexity=convexity,center=true)
                children();
            linear_extrude(height=ht-0.9*bevel,convexity=convexity,center=true)
                offset(r=-0.25*bevel)
                    children();
            linear_extrude(height=ht,convexity=convexity,center=true)
                offset(r=-bevel)
                    children();
        }
    }
}

module extrudeDXF(layerName,ht,bevel=3,convexity=4)
{
    bevel_extrude(ht,bevel,convexity)
        importDXF(layerName);
}

// Trim coupler body, for easier alignment
module couplerBodyTrims()
{
    // Bevel sides (so it self-aligns while tilting in)
    translate(topPin) 
    for (angle=[0:15:90+45])
    rotate([0,0,-angle])
    translate([-5,0,wide/2])
    rotate([0,-35,0])
        translate([0,50,50])
            cube([100,400,100],center=true);
    /*
    // Bevel entrance around top pin (for easier coupling)
        rotate([-30,0,0])
            translate([0,0,50])
                cube([100,100,100],center=true);
    */
}

module symmetryZ() {
    for (side=[-1,+1]) scale([1,1,side])
        children();
}

module couplerBodySolid() {
    difference() {
        extrudeDXF("body",wide,3);
        
        symmetryZ()
            couplerBodyTrims();
    }
}

// Leave the coordinate system at the front of the coupler baseplate
module couplerBaseplateCoords()
{
    translate(mountCenter) rotate([0,-90,0]) 
        children();
}
module couplerBaseplateCoordsInv()
{
    rotate([0,90,0]) translate(-mountCenter)  
        children();
}

module couplerBaseplateScrewCenters()
{
    da=360/nBaseplateScrews;
    couplerBaseplateCoords()
        for (angle=[da/2:da:360-1])
            rotate([0,0,angle])
            translate([0,baseplateScrewR,0])
                children();
}
module couplerBaseplateScrews()
{
    couplerBaseplateScrewCenters()
    translate([0,0,23])
    {
        cylinder(d=4.8,h=100,center=true);
        cylinder(d=0.39*inch,h=50);
    }
}

// Extra "wings" for stiffening, and side support of loads
module couplerBaseplateWings() {
    wingThick=9;
    difference() {
        cylinder(d=baseplateOD,h=27);
        // thru hole in middle
        cylinder(d=baseplateOD-2*wingThick,h=100,center=true);
        // Clear out middle area with rounded corners
        r=6;
        hull() {
            for (dz=[0,1])
                for (dx=[-1,+1])
                    translate([dx*(wide/2+r+10*dz),0,2+r+dz*50])
                        rotate([90,0,0])
                            cylinder($fn=16,r=r,h=250,center=true);
        }
    }
}

module couplerBaseplate()
{
    couplerBaseplateCoords()
    {
        translate([0,0,-baseplateThick/2])
            cylinder(d=baseplateOD,h=baseplateThick+0.01,center=true);
        
        //couplerBaseplateWings();
    }
}

// The thumb rotational axis hole, and space to add/remove it 
//  (riveted steel pin)
module thumbPivotClears() 
{
    // Hole for the thumb pivot
    translate(thumbPivot)
    {
        cylinder(d=rebarOD,h=100,center=true);
        symmetryZ()
            translate([0,0,wide/2+4]) cylinder(d=0.375*inch,h=100);
    }
}

// Space for the thumb's push/pull rod
module thumbPushPullHole()
{    
    // push-pull rod hole (with room for welding on)
    translate([-8,55,0]) rotate([0,90,0])
        cylinder(d=25,h=40);
}

// The thumb holds the bottom pin in place
module thumb() {
    difference() {
        extrudeDXF("thumb",thumb,1.7);
        
        thumbPushPullHole();
        //thumbPivotClears();//<- numerical issues
    }
}

// Blend the body to the baseplate
module couplerBodyFillets() {
    translate([16,mountCenter[1],wide/2-0.5]) rotate([0,45,0])
        cube([8,125,8],center=true);
}

// Space inside coupler for thumb
module couplerBodySlot() {
    extrudeDXF("bodySlot",wide-2*wall,3);
}

module couplerBody() {
    difference() {
        union() {
            couplerBodySolid();
            
            symmetryZ() couplerBodyFillets();
            
            // Big flat baseplate
            couplerBaseplate();
        }
        couplerBodySlot();
        
        couplerBaseplateScrews();
        
        thumbPushPullHole();
        thumbPivotClears();
        
        for (p=[bottomPin,topPin]) translate(p)
            cylinder(d=pinOD,h=wide+1,center=true);
        for (p=rebarList) translate(p)
            cylinder(d=rebarOD,h=65,center=true);
        
        // Dust vent in bottom
        symmetryZ() translate([15,0,18]) rotate([90,0,0]) cylinder(d=rebarOD,h=50);
        
        // Cutaway:
        //translate([100,0,100]) cube([200,240,200],center=true);
    }
}


// Draw everything in the in-use configuration
module couplerAssembled() {
    couplerBaseplateCoords()
    difference() 
    {
        union() {
            couplerBody();
            thumb();
            if (0) // gearbox
            couplerBaseplateCoords() 
            {
                translate([0,0,-baseplateThick])
                color([0,1,0])
                scale([1,1,-1]) cylinder(d=176,h=30);
                cylinder(d=3,h=100,center=true); // center mark
            }
        }
        
        if (0) translate([0,0,27+50])
        cube([200,250,100],center=true); // top cutaway
        if (1) translate([0,0,-50])
        cube([200,50,100],center=true); // thumb cutaway
    }
}

// Remove everything below Z=0 on subobjects
module trimFlat() {
    difference() {
        children();
        translate([0,0,-200]) cube([400,400,400],center=true);
    }
}

// slight rotation puts layer lines across the assembly, to hold it together
printTilt=[10,0,0];

// Draw everything in the 3D printable configuration
module couplerPrintable() 
{
    for (half=[0,1]) translate([-half*50,0,0])
        trimFlat() rotate(printTilt+half*[180,0,0]) 
        translate(-mountCenter) couplerBody();
}

if (1) 
     rotate([0,-90,0])  difference() {
        couplerBodySolid();
        //couplerBodySlot();
    }
//couplerAssembled();
//couplerPrintable();
//translate([30,0,thumb/2]) thumb();


