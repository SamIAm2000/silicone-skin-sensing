/*********************************************************
This is a library for the MPR121 12-channel Capacitive touch sensor

Designed specifically to work with the MPR121 Breakout in the Adafruit shop 
  ----> https://www.adafruit.com/products/

These sensors use I2C communicate, at least 2 pins are required 
to interface

Adafruit invests time and resources providing this open source code, 
please support Adafruit and open-source hardware by purchasing 
products from Adafruit!

Written by Limor Fried/Ladyada for Adafruit Industries.  
BSD license, all text above must be included in any redistribution
**********************************************************/

#include <Wire.h>
#include "Adafruit_MPR121.h"

#ifndef _BV
#define _BV(bit) (1 << (bit)) 
#endif

unsigned int points[36] = {0};
unsigned int xvals[6] = {0};
unsigned int yvals[6] = {0};
// You can have up to 4 on one i2c bus but one is enough for testing!
Adafruit_MPR121 cap = Adafruit_MPR121();

// Keeps track of the last pins touched
// so we know when buttons are 'released'
uint16_t lasttouched = 0;
uint16_t currtouched = 0;

void setup() {
  Serial.begin(115200);

  while (!Serial) { // needed to keep leonardo/micro from starting too fast!
    delay(10);
  }
  
  Serial.println("Adafruit MPR121 Capacitive Touch sensor test"); 
  
  // Default address is 0x5A, if tied to 3.3V its 0x5B
  // If tied to SDA its 0x5C and if SCL then 0x5D
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");
}

void loop() {
  // Get the currently touched pads
  //currtouched = cap.touched();
  
  // for (uint8_t i=0; i<12; i++) {
  //   // it if *is* touched and *wasnt* touched before, alert!
  //   if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
  //     Serial.print(i); Serial.println(" touched");
  //   }
  //   // if it *was* touched and now *isnt*, alert!
  //   if (!(currtouched & _BV(i)) && (lasttouched & _BV(i)) ) {
  //     Serial.print(i); Serial.println(" released");
  //   }
  // }

  // reset our state
  //lasttouched = currtouched;

  // comment out this line for detailed data from the sensor!
  //return;
  
  // Serial.print("\t\t\t\t\t\t\t\t\t\t\t\t\t 0x"); Serial.println(cap.touched(), HEX);

  //change these according to how you've placed the conductive threads
  // for (uint8_t i=0; i<6; i++) {
  //   yvals[i] = cap.filteredData(5-i)/4;
  // }
  // for (uint8_t i=0; i<6; i++) {
  //   xvals[i] = cap.filteredData(6+i)/4;
  // }
  // int k = 0;
  // for (int i = 0; i < sizeof(yvals)/sizeof(yvals[0]); i++){
  //   if (yvals[i] == 0){return;}
  //   for (int j = 0; j < sizeof(xvals)/sizeof(xvals[0]); j++){
  //     if (xvals[j] == 0){return;}
  //     points[k] = yvals[i]*xvals[j];
  //     k++;
  //   }
  // }
  // for (int m = 0; m < sizeof(points)/sizeof(points[0]); m++){
  //   Serial.print(points[m]);
  //   if (m != sizeof(points)/sizeof(points[0]) -1){
  //     Serial.print(",");
  //   }
  // }
  // Serial.println();

// uncomment to see filtered values
  for (uint8_t i=0; i<12; i++) {
    Serial.print(cap.filteredData(i)); 
    if (i != 11){
      Serial.print(",");
    }
  }
  Serial.println();

// uncomment to see base values
  // Serial.print("Base: ");
  // for (uint8_t i=0; i<12; i++) {
  //   Serial.print(cap.baselineData(i)); Serial.print("\t");
  // }
  // Serial.println();
  
  // put a delay so it isn't overwhelming
  delay(100);
}
