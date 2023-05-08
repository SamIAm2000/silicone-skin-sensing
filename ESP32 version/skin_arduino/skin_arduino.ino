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

void setup() {
  Serial.begin(115200);
  delay(1000); // give me time to bring up serial monitor
  Serial.println("ESP32 Touch Interrupt Test");

}

void loop(){
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
      if (xvals[j] == 0){return;}
      points[k] = yvals[i]*xvals[j];
      k++;
    }
  }
  for (int m = 0; m < sizeof(points)/sizeof(points[0]); m++){
    Serial.print(points[m]);
    if (m != sizeof(points)/sizeof(points[0]) -1){
      Serial.print(",");
    }
  }
  //Serial.printf("%i %i %i %i %i %i %",touch1Val, touch2Val,touch3Val ,touch4Val,touch5Val,touch6Val);
  Serial.println();
  delay(30);
}