# Excahauler Mining Robot

OpenSCAD source code for building a large autonomous mining robot.  Uses a combination of welded and 3D printed parts.

To build this source code, download OpenSCAD 2020 or newer, and:
```
    git clone https://github.com/AuroraRoboticsLab/AuroraSCAD
    openscad Excahaul_latest.scad
```

The subdirectories contain a variety of subassemblies which are primarily 3D printed, held onto a frame which is primarily welded steel. This is a photo from the front of the robot, showing our first rough physical prototype.
![Photo of robot holding tool.](documentation/excahauler_front.jpg?raw=true "Front view of the robot")


## Parts of the Robot
This is a side view of the entire robot, in Excahaul_latest.scad, holding the rockgrinder tool.
![CAD overview of robot: frame at the bottom, large arm reaching forward, mining tool on front.](documentation/excahauler_sideview.png?raw=true "Overview of the robot")

The overall coordinate system has +Y forward (as required by Unity for simulation), +X to the robot's right, and +Z up. This is right handed.

The base of the robot is the welded steel **frame**, which is MIG welded from 1 inch / 25mm steel box tubing like most of the robot's fabricated parts.  The front wheels bolt directly to the frame for stability, and the middle and rear wheels are on a rocker to conform to the ground. The large rear electronics box also bolts on directly, and the front fork and arm boom are bolted directly on the frame as well.
![Diagram of main robot frame: sparse steel tubes in a rough U shape.](documentation/render/frame.jpg?raw=true "Frame: holds the wheels and everything else.")

The robot arm moves via two links.  The arm **boom** connects to the robot frame and provides front-back motion. (The boom coordinate system is rotated by 25 degrees from the longer bar, because the boom inertial measurement unit is mounted on the shorter angled bar.)
![Diagram of boom.](documentation/render/boom.jpg?raw=true "Boom")

The second robot arm link is the **stick** (following the odd excavator naming convention).  The stick has an Intel RealSense D455 depth camera mounted on top, and small electronics box for motor controllers and interfacing.
![Diagram of stick.](documentation/render/stick.jpg?raw=true "Stick")

The next link **tilt**s the tool forward and backward via linear actuators, and **spin**s the tool via a stepped planetary geartrain. 
![Diagram of tilt and spin links.](documentation/render/spin.jpg?raw=true "Tilt front-back (YZ) and spin (around Y)")

The tool coupler lets us pick up tools using a 2-pin approach similar to excavator quick-change.  The origin is centered on the top pin.  The bottom pin can be locked in place with a rather complex linkage wedged inside.
![Diagram of coupler.](documentation/render/coupler.jpg?raw=true "Coupler top pin shown")


A variety of excavation **tool**s could be used, but the highest productivity tool is a rock grinder, which spins a drum to mill material directly into the front scoop.  The large ammo can stores the batteries, motor controller, and has space for cooling oil as well.
![Diagram of rock grinder.](documentation/render/rockgrinder.jpg?raw=true "Rock grinder tool")


We move excavated material around in the front scoop.  The **fork** linear actuator raises and lowers the scoop relative to the frame via this part; the **dump** linear actuator rides on the fork and pivots the scoop to unload material.
![Diagram of fork.](documentation/render/fork.jpg?raw=true "Fork")

The front **scoop** has a volume of 50 liters, which lets it carry a payload of about 50 kg of broken-up regolith simulant chips.
![Diagram of scoop.](documentation/render/dump.jpg?raw=true "Scoop")


Each OpenSCAD file has some comments, but we are adding comments and README to make this easier to follow.  Please contact lawlor@alaska.edu if you have questions or suggestions!

Unless marked otherwise, these source code files are released to the public domain. 



