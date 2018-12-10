//Rotary Encoder Enviroment>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*******Interrupt-based Rotary Encoder Sketch*******
by Simon Merrett, based on insight from Oleg Mazurov, Nick Gammon, rt, Steve Spence
*/
#define PM_gear 9
#define ME_gear 3.33333
#define steps 24
float step_grade;


static int pinA = 2; // Our first hardware interrupt pin is digital pin 2
static int pinB = 3; // Our second hardware interrupt pin is digital pin 3
volatile byte aFlag = 0; // let's us know when we're expecting a rising edge on pinA to signal that the encoder has arrived at a detent
volatile byte bFlag = 0; // let's us know when we're expecting a rising edge on pinB to signal that the encoder has arrived at a detent (opposite direction to when aFlag is set)
volatile float encoderPos = 0; //this variable stores our current value of encoder position. Change to int or uin16_t instead of byte if you want to record a larger range than 0-255
volatile float oldEncPos = 0.1; //stores the last encoder position value so we can compare to the current reading and see if it has changed (so we know when to print to the serial monitor)
volatile int reading = 0; //somewhere to store the direct values we read from our interrupt pins before checking to see if we have moved a whole detent

void PinA(){
  cli(); //stop interrupts happening before we read pin values
  reading = PIND & 0xC; // read all eight pin values then strip away all but pinA and pinB's values
  if(reading == B1100 && aFlag) { //check that we have both pins at detent (HIGH) and that we are expecting detent on this pin's rising edge
    encoderPos =encoderPos - step_grade; //decrement the encoder's position count
    if(encoderPos<0.0)encoderPos=359.0+step_grade;
    bFlag = 0; //reset flags for the next turn
    aFlag = 0; //reset flags for the next turn
  }
  else if (reading == B01000) bFlag = 1; //signal that we're expecting pinB to signal the transition to detent from free rotation
  sei(); //restart interrupts
}

void PinB(){
  cli(); //stop interrupts happening before we read pin values
  reading = PIND & 0xC; //read all eight pin values then strip away all but pinA and pinB's values
  if (reading == B1100 && bFlag) { //check that we have both pins at detent (HIGH) and that we are expecting detent on this pin's rising edge
    encoderPos=encoderPos+step_grade; //increment the encoder's position count
    if(encoderPos>359.0+step_grade)encoderPos=0.0;
    bFlag = 0; //reset flags for the next turn
    aFlag = 0; //reset flags for the next turn
  }
  else if (reading == B01000) aFlag = 1; //signal that we're expecting pinA to signal the transition to detent from free rotation
  sei(); //restart interrupts
}

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#include<math.h>
#define pinPos 7
#define pinNeg 5
int kp, ki, integral, proportional, speed;
float target, error;
float current=0;

void setup() {
  kp = 1; // P-constant, set to 1 to disable
  ki = 1; // I-constant, set to 0 to disable
  integral = 0;

  Serial.begin(9600);

  pinMode(pinPos, OUTPUT); // Digital pin 3 (Clockwise)
  pinMode(pinNeg, OUTPUT); // Digital pin 5 (Counter-clockwise)
  analogWrite(pinPos, 0);
  analogWrite(pinNeg, 0);
  
  //Rotary Encoder Setup Enviroment>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
  pinMode(pinA, INPUT_PULLUP); // set pinA as an input, pulled HIGH to the logic voltage (5V or 3.3V for most cases)
  pinMode(pinB, INPUT_PULLUP); // set pinB as an input, pulled HIGH to the logic voltage (5V or 3.3V for most cases)
  attachInterrupt(0,PinA,RISING); // set an interrupt on PinA, looking for a rising edge signal and executing the "PinA" Interrupt Service Routine (below)
  attachInterrupt(1,PinB,RISING); // set an interrupt on PinB, looking for a rising edge signal and executing the "PinB" Interrupt Service Routine (below)
  step_grade=(360)/(PM_gear*ME_gear*steps);
  
  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
}

void waitingForSignal() {
  // Kode som venter på et input fra serial (= Fra computeren)
  while (Serial.available() == 0) {}
  target = Serial.parseFloat();
}


void readEncoder() {
  if(oldEncPos != encoderPos) { //number between 0 and 359.5
    Serial.println(encoderPos);
    oldEncPos = encoderPos;
  }
  if (oldEncPos >= 359.5){
    oldEncPos = 0;
  }
  current = oldEncPos; //tranfer the position to the float "current".
}

void loop() {
  waitingForSignal();
  Serial.println("Signal Recieved");
  Serial. println(target);
  readEncoder();
  setSpeed();
  while (error > 1 ) {
    readEncoder();
    setSpeed();
  }
}


void setSpeed() {
  bool inv, neg;

  //Determine error
  error = target - current;
/*
  // If error loops around 360 | This is only possible, if target is bigger than 360 degrees, in this case it would be a problem with the matlab script.
  if (error > 360) {
    error = error - 360;
  }
*/

  // Determine direction
  if (abs(error) > 180) { // Invert direction
    inv = 1;
    if (error < 0) {  // Direction is already inverted
      neg = 1;
    }
    else {  // Direction not previously inverted
      neg = 0;
    }
    error = 359.5 -abs(error);
  }
  else {  //No inversion
    inv = 0;
    if (error < 0) {  // Drection is already inverted
      neg = 1;
    }
    else {  // Direction not previously inverted
      neg = 0;
    }
    error = abs(error);
  }

  //P-controller gain
  proportional = error * kp;

  //I-controller gain
  integral = integral + error * ki;
  /*//Limit integral
    if(integral>=255) {
    integral = 255;
    }
    else if(integral<=-254)
    {
    integral = -254;
    }
  */

  speed = integral + proportional;

  // Set output
  switch (neg) {
    case 0: // Positive error
      switch (inv) {
        case 0: // Don't invert
          ccw(speed);
          break;
        case 1: // Invert
          cw(speed);
          break;
      }
    case 1: // Negative error
      switch (inv) {
        case 0: // Don't re-invert
          cw(speed);
          break;
        case 1: // Re-invert
          ccw(speed);
          break;
      }
  }
}

void cw(int pwm) {
  // Convert to 0-255 resolution
  // <magic>

  analogWrite(pinNeg, 0);  // Turn off counter-clockwise signal
  analogWrite(pinPos, pwm); // Turn on clockwise signal
}

void ccw(int pwm) {
  // Convert to 0-255 resolution
  // <magic>

  analogWrite(pinPos, 0);  // Turn off clockwise signal
  analogWrite(pinNeg, pwm); // Turn on counter-clockwise signal
}
