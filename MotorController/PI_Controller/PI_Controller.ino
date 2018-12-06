#include<math.h>

int kp, ki, integral, proportional, speed;
float target, error, current;

void readEncoder();
void setSpeed();

void setup() {
  kp = 1; // P-constant, set to 1 to disable
  ki = 1; // I-constant, set to 0 to disable
  integral = 0;

  // Lav noget kode som venter på et input fra serial (= Fra computeren)
}

void loop() {
  readEncoder();
  setSpeed();
}

void readEncoder() {
  // Read rotary encoder
  current = 1.0;

}
void fwd(){
    
  }
void setSpeed() {
  bool inv, neg;
  
  //Determine error
  error = target - current;

  // If error loops around 360
  if (error > 360) {
    error = error - 360;
  }

  // Determine direction
  if (abs(error) > 180) { // Invert direction
    inv = 1;
    error = error + 180;
    if (error < 0) {  // Direction is already inverted
      neg = 1;
      error = error + 180;
    }
    else {  // Direction not previously inverted
      neg = 0;
    }
    error = 180 - abs(error);
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
    break;
    switch (inv){
      case 0: // Don't invert
        fwd(error);
        break;
      case 1: // Invert
        bwd(error);
        break;
      }
    case 1: // Negative error
    switch (inv){
      case 0: // Don't re-invert
        bwd(error);
        break;
      case 1: // Re-invert
        fwd(error);
        break;
      }
    }

}


