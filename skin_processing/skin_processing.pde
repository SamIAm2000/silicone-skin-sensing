import processing.serial.*;
import gab.opencv.*;
Serial myPort;
OpenCV opencv;

int MIN_THRESHOLD = 250;
int MAX_THRESHOLD = 500;


int[] avgPoints = new int[9];
int[] rawPoints = new int[9];
int[] adjPoints = new int[9];
int[] vals = new int[9];
int squareSize = 80;
String val;
boolean calibrate;

void setup () {
  size(848, 512);
  noStroke();
  println("1");
  myPort = new Serial(this, Serial.list()[2], 115200);
  //opencv = new OpenCV(this, pg.width, pg.height);
  println("2");
  calibrate = true;
}

void draw () {
  if (myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');
  }
  if (val != null) {
    val = trim(val);
    vals = int(splitTokens(val, ","));
  }
  if (calibrate) {
    int[] tempPoints = new int[9];
    for (int t = 0; t < 20; t++) {
      if (myPort.available() > 0) {  // If data is available,
        val = myPort.readStringUntil('\n');
      }
      if (val != null) {
        val = trim(val);
        vals = int(splitTokens(val, ","));
      }
      int[] tempVals = vals;
      for (int i =0; i < 9; i++) {
        tempPoints[i] += tempVals[i];
      }
    }
    for (int i =0; i < 9; i++) {
      tempPoints[i] = tempPoints[i]/20;
    }
    avgPoints = tempPoints;
    println("calibrated");
    calibrate = false;
  }
  
  rawPoints = vals;
  for (int i = 0; i < 9; i++) {
    int temp = avgPoints[i]-rawPoints[i];
    temp = constrain(temp, MIN_THRESHOLD, MAX_THRESHOLD);
    adjPoints[i] = int(map(temp, MIN_THRESHOLD, MAX_THRESHOLD, 0, 255)); //map to grayscale
  }
  drawSquares();

  
}

void drawSquares() {
  PGraphics pg = createGraphics(3*squareSize, 3*squareSize);
  int k = 0;
  for (int i = 0; i < 3*squareSize; i+=squareSize) {
    for (int j = 0; j < 3*squareSize; j+=squareSize) {
      fill(adjPoints[k]);
      k++;
      rect(j, i, squareSize, squareSize);
    }
  }

  image(pg, 0, 0);
}

void keyPressed() {
  if (key == 'c') {
    calibrate = true;
  }
}
