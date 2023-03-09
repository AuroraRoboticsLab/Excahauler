/*
  Rock grinder tool in context, attached to robot.
*/
include <../Excahaul_latest.scad>;
$subpart=1;
include <rockgrinder_frame.scad>;

//rockgrinder3D(1,1);
//robot(configDigRockgrinder,0) rockgrinder3D(1,1);
//rockgrinderStorage();
//rockgrinderBucket2D();

if (0) { // 2D plate templates (laser print, plasma cut)
    rockgrinderBucketPlate2D(1,0);
    scale([1,-1,1]) rockgrinderBucketPlate2D(0,1);
}


