/*
This is an example how to use Touch Intrrerupts and read touch values
just touch the pins themselves to get different values
*/

int threshold = 60; //originally 40
// bool touch1detected = false;
// bool touch2detected = false;
uint8_t touch1Val =0, touch3Val=0, touch4Val=0, touch5Val=0, touch6Val= 0;
uint8_t touch2Val = 0;
int points[9] = {0};
int xvals[3] = {0};
int yvals[3] = {0};

// void gotTouch1(){
//  touch1detected = true;
//  touch1Val = touchRead(2);
// }
// void gotTouch2(){
//  //touch2detected = true;
//  touch2Val = touchRead(15);
// }
// void gotTouch3(){
//  //touch3detected = true;
//  touch3Val = touchRead(13);
// }

// void gotTouch4(){
//  //touch4detected = true;
//  touch4Val = touchRead(32);
// }
// void gotTouch5(){
//  //touch5detected = true;
//  touch5Val = touchRead(33);
// }
// void gotTouch6(){
//  //touch6detected = true;
//  touch6Val = touchRead(27);
// }

void setup() {
  Serial.begin(115200);
  delay(1000); // give me time to bring up serial monitor
  Serial.println("ESP32 Touch Interrupt Test");
  // touchAttachInterrupt(2, gotTouch1, threshold);
  // touchAttachInterrupt(15, gotTouch2, threshold);
  // touchAttachInterrupt(13, gotTouch3, threshold);
  // touchAttachInterrupt(32, gotTouch4, threshold);
  // touchAttachInterrupt(33, gotTouch5, threshold);
  // touchAttachInterrupt(27, gotTouch6, threshold);
}

void loop(){
  // if(touch1detected){
  //   touch1detected = false;
  //   Serial.printf("T2: %i", touch1Val);
  // }
  // if(touch2detected){
  //   touch2detected = false;
  //   Serial.printf("T9: %i", touch2Val);
  //   Serial.println();
  // }

  
  xvals[0] = touchRead(2);
  xvals[1] = touchRead(15);
  xvals[2] = touchRead(13);
  yvals[0] = touchRead(32);
  yvals[1] = touchRead(33);
  yvals[2] = touchRead(27);
  
  int k = 0;
  for (int i = 0; i < sizeof(yvals)/sizeof(yvals[0]); i++){
    if (yvals[i] == 0){return;}
    for (int j = 0; j < sizeof(xvals)/sizeof(xvals[0]); j++){
      if (xvals[i] == 0){return;}
      points[k] = yvals[i]*xvals[j];
      k++;
    }
  }
  for (int m = 0; m < sizeof(points)/sizeof(points[0]); m++){
    Serial.print(points[m]);
    if (n != sizeof(points)/sizeof(points[0]) -1){
      Serial.print(",");
    }
  }
  //Serial.printf("%i %i %i %i %i %i %",touch1Val, touch2Val,touch3Val ,touch4Val,touch5Val,touch6Val);
  Serial.println();
  delay(30);
}