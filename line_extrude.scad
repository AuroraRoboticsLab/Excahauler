


// Tilt up child 2D section and extrude along Y,
//   moving from S to E
module line_extrudeY(S,E)
{
    D=E-S;
    
    // section(XY)  extrusion  translation
    m=[
        [1,0,D.x,S.x],
        [0,0,D.y,S.y],
        [0,1,D.z,S.z]
    ];
    multmatrix(m) {
        linear_extrude(height=1.00001)
            children();
        
    }
}

// Extrude 2D shape along a list of points.
//   2D shape is tilted up so it moves along +Y
module list_extrudeY(list) {
    for (i=[1:len(list)-1]) {
        line_extrudeY(list[i-1],list[i])
            children();
    }
}

list_extrudeY([[10,0,0],[0,10,10]]) circle(r=3.0);
