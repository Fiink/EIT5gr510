//Define gearing for the motor system
#define PM_gear 9
#define ME_gear 3.33333
#define steps 24
float step_grade;

static int pinA = 2;          //Interupt 0
static int pinB = 3;          //Interupt 1
volatile byte aFlag = 0;      // determin
volatile byte bFlag = 0;      // Check if pin is high
volatile float encoderPos = 0;//position of the encoder real time
volatile float oldEncPos = 0; //stores the last encoder position
volatile int reading = 0;     //what is read from the pins


//define what happens upon interupt
void PinA(){
  cli(); //stop interrupts
  reading = PIND & 0xC; //read the value B00001100 (pin 2 and 3)
  if(reading == B00001100 && aFlag) { //if other pin was high first
    encoderPos = encoderPos - step_grade; //decrement the enc.position
    if (encoderPos < 0.0) encoderPos = 359.0 + step_grade;
    bFlag = 0; //reset flags for the next turn
    aFlag = 0; //reset flags for the next turn
  }
  else if (reading == B00000100) bFlag = 1; //if A is first pin high
  sei(); //enables interupts
}

void PinB(){ //same principle for the second pin
  cli(); 
  reading = PIND & 0xC; 
  if (reading == B00001100 && bFlag) { 
    encoderPos = encoderPos + step_grade;
    if (encoderPos > 359.0 + step_grade) encoderPos = 0.0;
    bFlag = 0; 
    aFlag = 0; 
  }
  else if (reading == B00001000) aFlag = 1; 
  sei();
}

//initialize controller code and load libraries
#include<math.h>
#define pinPos 5 //positive pwm signal pin
#define pinNeg 9 //negative pwm signal pin
int kp, ki, integral, proportional, speed, x = 1, turn=0;
float target, error;
float current=0;

void setup() {
  //make PI controller:
  kp = 1; //p-constant
  ki = 1; //i-contant
  integral = 0; //reset the integral to be zero
  cw(0);  //stop any motor activity clockwise
  ccw(0); //stop any motor activity counter clockwise
  Serial.begin(115200);
  pinMode(pinPos, OUTPUT); // Digital pin 3 (Clockwise)
  pinMode(pinNeg, OUTPUT); // Digital pin 5 (Counter-clockwise)
  analogWrite(pinPos, 0);
  analogWrite(pinNeg, 0);

//Rotary Encoder Setup Enviroment>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  pinMode(pinA, INPUT_PULLUP); // set pinA as an input
  pinMode(pinB, INPUT_PULLUP); // set pinB as an input
  attachInterrupt(digitalPinToInterrupt(2),PinA,RISING);//interrupt on PinA
  attachInterrupt(digitalPinToInterrupt(3),PinB,RISING);//interrupt on PinB
  step_grade=(360)/(PM_gear*ME_gear*steps);
  
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
}
char t;
int timestart=0;

void waitingForSignal() {
  while (Serial.available()) {
    t = Serial.read();
  }
  Serial.flush();
  while (Serial.available() == 0) {}
  target = Serial.parseFloat();
}


void readEncoder() {
  if(oldEncPos != encoderPos) { //number between 0 and 359.5
    oldEncPos = encoderPos;
    current = encoderPos; //tranfer the position to the float "current".
  }
}
void loop() {
  turn=0; //if we have stable readings in a row turn will increment
  while (x == 1) {
    readEncoder(); //read initial encoder position
    x++;  
  }
  waitingForSignal(); //wait for input from computer with angle
  setSpeed();         //set speed of motor based on the error
  while (abs(error) > 0.5 || turn < 5.0) {
      if(oldEncPos == encoderPos) {
      turn=turn+1; //stable reading, increment count
      }
      if(oldEncPos != encoderPos) {
      turn=0; //the reading moved, so we reset stable readings
      }
    setSpeed(); //set speed based on error
  }
  //Re-initialize variables for a new reading
  integral = 0;
  speed = 0;
  cw(speed);
  Serial.flush();
  delay(1000);
  //goto: top of loop
}


void setSpeed() { //sets an appropriate speed based on the angle and error
  readEncoder();//read last logged encoder position
  bool inv, neg;

  error = target - current; //error is how far of the target

if (abs(error) > 180.0) { // Invert direction
    inv = 1;
    if (error < 0.0) {  // Direction is already inverted
      neg = 1;
    }
    else {  // Direction not previously inverted
      neg = 0;
    }
    }
  else {  //No inversion
    inv = 0;
    if (error < 0.0) {  // Drection is already inverted
      neg = 1;
    }
    else {  // Direction not previously inverted
      neg = 0;
    }
    error = abs(error);
  }
  proportional = error * kp;
  integral = integral + error * ki;
  speed = integral + proportional;
  switch (neg) {
    case 0: // Positive error
      switch (inv) {
        case 0: // Don't invert
          cw(speed);
          break;
        case 1: // Invert
          ccw(speed);
          break;
      }
      break;
    case 1: // Negative error
      switch (inv) {
        case 0: // Don't re-invert
          ccw(speed);
          break;
        case 1: // Re-invert
          cw(speed);
          break;
      }
      break;
  }
}

void ccw(int pwm) {
  analogWrite(pinNeg, 0);  // Turn off counter-clockwise signal
  analogWrite(pinPos, pwm); // Turn on clockwise signal
}

void cw(int pwm) {
  analogWrite(pinPos, 0);  // Turn off clockwise signal
  analogWrite(pinNeg, pwm); // Turn on counter-clockwise signal
}
