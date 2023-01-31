Basic idea: instead of one big monolithic Arduino, we have dedicated motor controller micros, in their own 3D-printed cases.  E.g., one left side, one right side, one for mining head.


+ Use simpler, more reliable parts (spare electronics possible)
+ Less wire crossing the robot
- More parts to build


-------------------
Standard electronics slot microcontroller is an Arduino Nano 328P with a CH-341 USB serial.


Daniel Kling's 5-pin breakout board:

const unsigned char breakoutPins[6]={ 11,10,9,8,A0,12 };

Arduino Nano  Motor Control Board
D11           [0] signal pin
D10           [1] signal pin
D9            [2] signal pin
D8            [3] signal pin
A0            [4] signal pin?
D12           [5] signal pin

5V             V+  (requires jumper soldered on Nano board)
Gnd            Gnd



Motor drivers, UN178 green brushed boards:

un178_motor_single_t hardware_motor[NANOSLOT_COMMAND_MY::n_motors]={
    un178_motor_single_t(11,12,A0),
    un178_motor_single_t(10,9,8),
    un178_motor_single_t(3,2,4),
    un178_motor_single_t(6,5,7),
  };


----------------
UN178 motor controller x2, each doing 2 motors (4 total motors)

	2x PWM inputs, one each for A and B motors
	4x digital inputs for A and B sides
	gnd in

3-pin encoder inputs (6 copies, including Arduino I2C lines).  Servo 3-pin cables: gnd, 5v, encoder
	1 per controlled motor
	Plus 2 spares: redundant encoders, bag up/down, etc.


With short jumpers, 121ohm current limiters, and 2Kohm pull-up resistors, analog pins read:
  dn 1022-1023 when open
  dn 16-17 when shorted to ground
Probably a dn threshold of 200 or higher would be about right.

RJ-45 serial uplink to main controller: 5v (orange), ground (orange-white), tx0 (brown), rx0 (green)

Nano PWM-capable pins: 3, 5, 6, 9, 10, 11

m[0] LA motor: dir 12(green),A0(red)  PWM 11
m[1] LB motor: dir 9(green),8(red)   PWM 10   (both 490Hz)

m[2] RA motor: dir 2(green),4(red)  PWM 3    (normal 490Hz pin)
m[3] RB motor: dir 5(green),7(red)  PWM 6    (the fast 980Hz pin)

With two UN178's plugged in, current draw is 0.07-0.15A at 12VDC side.


If we target a 500Hz motor update, we have 2ms per cycle.
At 115200 baud, we should be pushing 10KB/sec, or 10 bytes/ms.
So blipping out an A-packet with 6 byte-long encoder counts is probably fine.


