import gab.opencv.*;
import java.util.Arrays;
import processing.serial.*;
import gab.opencv.*;
import milchreis.imageprocessing.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.core.CvType;
import org.opencv.core.Core;
import blobDetection.*;
import processing.sound.*;

SoundFile file1,file2,file3,file4;
Serial myPort;
OpenCV opencv;
BlobDetection blobDetection; // BlobDetection object for BlobDetection
PImage destImg;
boolean enableBlobDetection = true;
boolean drawBlobCenter = true;
boolean drawBlobContour = true;
boolean enableThreshold = true;

float thresholdBlob = 0.5f;
int thresholdBlobMin = 150;
int thresholdBlobMax = 255;

int MIN_THRESHOLD = 45;
int MAX_THRESHOLD = 125;

int xvals = 6;
int yvals = 6;
int squares = xvals*yvals;

int[] avgPoints = new int[squares];
int[] rawPoints = new int[squares];
int[] adjPoints = new int[squares];
int[] vals = new int[xvals+yvals];

int resizefactor = 1;

int squareSize; 
String val;
boolean calibrate;

PGraphics skinGraphic;
PImage skinImage;
PImage processedImage;

void setup () {
  //fullScreen();
  size(800, 800); //fullscreen height = 878
  squareSize = height/xvals; 
  noStroke();
  println("1");
  myPort = new Serial(this, Serial.list()[1], 115200);
  
  println("2");
  calibrate = true;
  skinGraphic = createGraphics(xvals*squareSize, yvals*squareSize);
  skinImage = createImage(skinGraphic.width, skinGraphic.height, GRAY);
  destImg = createImage(skinGraphic.width*resizefactor, skinGraphic.height*resizefactor, GRAY);
  opencv = new OpenCV(this, skinGraphic.width, skinGraphic.height);
  blobDetection = new BlobDetection(destImg.width, destImg.height);
  blobDetection.setThreshold(thresholdBlob);
  
  file1 = new SoundFile(this, dataPath("scream1.mp3"), true); //true for loading up audio in RAM
  file2 = new SoundFile(this, dataPath("scream2.mp3"), true); //true for loading up audio in RAM
  file3 = new SoundFile(this, dataPath("scream3.mp3"), true); //true for loading up audio in RAM
  file4 = new SoundFile(this, dataPath("scream4.mp3"), true); //true for loading up audio in RAM
}

void draw () {
  //==========calibration==============
  if (calibrate) {
    int[] tempPoints = new int[squares];
    for (int t = 0; t < 20; t++) {
      if (myPort.available() > 0) {  // If data is available,
        val = myPort.readStringUntil('\n');
      }
      if (val != null) {
        val = trim(val);
        vals = int(splitTokens(val, ","));
      }
      if(vals.length != 12){
        return;//if bad serial read, skip
      }
      int[] tempVals = getRawPoints(vals);
      for (int i =0; i < squares; i++) {
        tempPoints[i] += tempVals[i];
      }
    }
    for (int i =0; i < squares; i++) {
      tempPoints[i] = tempPoints[i]/20;
    }
    avgPoints = tempPoints;
    println("calibrated");
    calibrate = false;
  }
  //==========read serial==============
  if (myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');
  }
  if (val != null) {
    val = trim(val);
    vals = int(splitTokens(val, ","));
  }
  if(vals.length != 12){
        return; //if bad serial read, skip
  }
  
  //==========calculate points==============
  rawPoints = getRawPoints(vals);
  //print("rawPoints: ");
  //println(Arrays.toString(rawPoints));
  //print("avgPoints: ");
  //println(Arrays.toString(avgPoints));

  for (int i = 0; i < squares; i++) {
    int temp = avgPoints[i]-rawPoints[i];
    temp = constrain(temp, MIN_THRESHOLD, MAX_THRESHOLD);
    adjPoints[i] = int(map(temp, MIN_THRESHOLD, MAX_THRESHOLD, 0, 255)); //map to grayscale
  }

  drawSquares();
  //image(skinGraphic, 0, 0);

  skinGraphic.loadPixels();
  skinImage.loadPixels();
  skinImage.pixels = skinGraphic.pixels;
  skinImage.updatePixels();
  image(skinImage,0,0);
  //destImg = skinImage;
  
  //tried adding halftone for cool effects, too slow
  // image, dot size in pixel, foreground color, background color, spacing, yes/no grid
  //processedImage = Halftone.apply(skinImage, 2,#335764, 255,1,false);  
  //image(processedImage,200,0);
  //opencv stuff, optional, can be commented out.
  
  performCV();
  drawCV();
  if (enableBlobDetection) drawBlobs();

}

void drawSquares() {
  skinGraphic.beginDraw();
  skinGraphic.noStroke();
  int k = 0;
  for (int i = 0; i < xvals*squareSize; i+=squareSize) {
    for (int j = 0; j < yvals*squareSize; j+=squareSize) {
      //println(adjPoints[k]);
      skinGraphic.fill(adjPoints[k]);
      k++;
      skinGraphic.rect(j, i, squareSize, squareSize);
    }
  }
  skinGraphic.endDraw();
}


void keyPressed() {
  if (key == 'c') {
    calibrate = true;
  }
}

int[] getRawPoints(int[] vals){
  int[] xvalues = new int[xvals];
    int[] yvalues = new int[yvals];
    for (int i=0; i<yvals; i++) {
      yvalues[i] = vals[5-i]/4;
    }
    for (int i=0; i<xvals; i++) {
      xvalues[i] = vals[6+i]/4;
    }
    int k = 0;
    for (int i = 0; i < yvals; i++) {
      //if (yvalues[i] == 0) {
      //  return;
      //}
      for (int j = 0; j < xvals; j++) {
        //if (xvalues[j] == 0) {
        //  return;
        //}
        rawPoints[k] = yvalues[i]*xvalues[j];
        k++;
      }
    }
    return rawPoints;
}


//==========computer vision and blob detection==============
//THE FOLLOWING CODE WORKS, HOWEVER DUE TO THE LIMITED ABOUT OF SENSORS,
//IT'S HARD TO FIND BLOBS WITH SUCH LARGE SQUARES AND IT DEFEATS THE PURPOSE
// PERHAPS SAVE FOR THE FUTURE?

  void performCV() {
    opencv.loadImage(skinImage); // load image
    Mat skinImageBlackWhite = opencv.getGray(); // get grayscale matrix

    Mat skinImageRezied = new Mat(destImg.width, destImg.height, skinImageBlackWhite.type()); // new matrix to store resize image
    Size sz = new Size(destImg.width, destImg.height); // size to be resized

    // Imgproc.resize(skinImageBlackWhite, skinImageRezied, sz, 0, 0, Imgproc.INTER_CUBIC ); // resize // INTER_NEAREST // INTER_CUBIC  Imgproc.INTER_LANCZOS4
    Imgproc.resize(skinImageBlackWhite, skinImageRezied, sz, 0, 0, 0); // resize // INTER_NEAREST

    if (enableThreshold) Imgproc.threshold(skinImageRezied, skinImageRezied, thresholdBlobMin, thresholdBlobMax, Imgproc.THRESH_BINARY);


    opencv.toPImage(skinImageRezied, destImg); // store in Pimage for drawing later

    if (enableBlobDetection) {
      blobDetection.computeBlobs(destImg.pixels);
      blobDetection.setThreshold(thresholdBlob);
      blobDetection.setPosDiscrimination(true); //find bright areas, false for dark areas
    }
  }
void drawCV() {
    // Draw the final image
    image(destImg, 0, 0, 50, 50);
  }

  public void drawBlobs() {
    Blob blob;
    EdgeVertex edgeA, edgeB;
    for (int n = 0; n < blobDetection.getBlobNb(); n++) {
      blob = blobDetection.getBlob(n);
      if (blob != null) {
        // Edges
        if (drawBlobContour) {
          strokeWeight(2);
          stroke(0, 255, 0);
          for (int m = 0; m < blob.getEdgeNb(); m++) {
            edgeA = blob.getEdgeVertexA(m);
            edgeB = blob.getEdgeVertexB(m);
            if (edgeA != null && edgeB != null)
              //   line(eA.x, eA.y, eB.x, eB.y);
              line(edgeA.x * destImg.width, edgeA.y * destImg.height, edgeB.x * destImg.width, edgeB.y * destImg.height); // when full width
            // line(eA.x * width, eA.y * height, eB.x * width, eB.y * height); // when full width
          }
          destImg.loadPixels();
        }

        // Blobs
        if (drawBlobCenter) {
          strokeWeight(5);
          point(blob.x * destImg.width, blob.y * destImg.height);
          loadPixels();
        }
        float blobsize = blob.w * blob.h;
        //println(blobsize);
        playSound(int(blob.x * destImg.width), int(blob.y * destImg.height), blob.w);        
      
      }
    }
  }
  
void playSound(int x, int y, float size){
  size = map(size%0.5, 0, 0.5, 0, 1);
  if (size < 0.03 && !file1.isPlaying()){
    file1.amp(size);
    file1.play();
    println("played 1");
    print(size);
  } else if (x < 300 && !file2.isPlaying()){
    file2.amp(size);
    file2.play();
    println("played 2");
    print(size);
  } else if (size > 0.3 && !file4.isPlaying()){
    file4.amp(size);
    file4.play();
    println("played 4");
    print(size);
  } else if (size != 0 && !file3.isPlaying()){
    file3.amp(size);
    file3.play();
    println("played 3");
    print(size);
  }
}
