# Excahauler Mining Robot

OpenSCAD source code for building a large autonomous mining robot.  Uses a combination of welded and 3D printed parts.

This is a photo from the front of the robot, showing our first rough physical prototype.
![Photo of robot holding tool.](documentation/excahauler_front.jpg?raw=true "Front view of the robot")


## Parts of the Robot
This is a side view of the entire robot, in Excahaul_latest.scad, holding the rockgrinder tool.
![CAD overview of robot: frame at the bottom, large arm reaching forward, mining tool on front.](documentation/excahauler_sideview.png?raw=true "Overview of the robot")

The overall coordinate system has +Y forward (as required by Unity for simulation), +X to the robot's right, and +Z up.

The base of the robot is the welded steel frame, MIG welded from 1 inch / 25mm steel box tubing like the rest of the robot.  The wheels bolt directly to the frame, the large rear electronics box also bolts on directly, and the front fork and arm boom mount on as well.
![Diagram of main robot frame: sparse steel tubes in a rough U shape.](documentation/render/frame.jpg?raw=true "Frame: holds the wheels and everything else.")

The robot arm moves via two links.  The arm boom connects to the robot frame and provides front-back motion.
![Diagram of boom.](documentation/render/boom.jpg?raw=true "Boom")

The second robot arm is the "stick", following excavator naming conventions.  The stick has an Intel RealSense D455 depth camera on top, and small electronics box for motor controllers and interfacing.
![Diagram of stick.](documentation/render/stick.jpg?raw=true "Stick")

The next link tilts the tool forward and backward via linear actuators, and spins the tool via a stepped planetary geartrain. 
![Diagram of tilt and spin links.](documentation/render/spin.jpg?raw=true "Tilt front-back (YZ) and spin (around Y)")

The tool coupler lets us pick up tools using a 2-pin approach similar to excavator quick-change.  The origin is centered on the top pin.  The bottom pin can be locked in place with a rather complex linkage wedged inside.
![Diagram of coupler.](documentation/render/coupler.jpg?raw=true "Coupler top pin shown")


A variety of tools could be used, but the highest productivity tool is a rock grinder, which spins a drum to mill material directly into the front scoop.  The large ammo can stores the batteries, motor controller, and has space for cooling oil as well.
![Diagram of rock grinder.](documentation/render/rockgrinder.jpg?raw=true "Rock grinder tool")


We move excavated material around in the front scoop.  The "fork" linear actuator raises and lowers this scoop relative to the frame; the "dump" linear actuator pivots the scoop to unload material.
![Diagram of fork.](documentation/render/fork.jpg?raw=true "Fork")

The front scoop has a volume of 50 liters, which lets it carry a payload of about 50 kg of broken-up regolith simulant chips.
![Diagram of scoop.](documentation/render/scoop.jpg?raw=true "Scoop")





Unless marked otherwise, these source code files are released to the public domain. 



