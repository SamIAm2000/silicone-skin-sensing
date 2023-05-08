import gab.opencv.*;

import processing.serial.*;
import gab.opencv.*;

import org.opencv.imgproc.Imgproc;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.core.CvType;
import org.opencv.core.Core;
import blobDetection.*;

Serial myPort;
OpenCV opencv;
BlobDetection blobDetection; // BlobDetection object for BlobDetection
PImage destImg; 
boolean enableBlobDetection = true;
boolean drawBlobCenter = true;
boolean drawBlobContour = true;
boolean enableThreshold = true;

float thresholdBlob = 0.8f;
int thresholdBlobMin = 150;
int thresholdBlobMax = 255;

int MIN_THRESHOLD = 200;
int MAX_THRESHOLD = 350;

int[] avgPoints = new int[9];
int[] rawPoints = new int[9];
int[] adjPoints = new int[9];
int[] vals = new int[9];

int squareSize = 150;
String val;
boolean calibrate;

PGraphics skinGraphic;
PImage skinImage;

void setup () {
  size(848, 512);
  noStroke();
  println("1");
  myPort = new Serial(this, Serial.list()[2], 115200);
  //opencv = new OpenCV(this, pg.width, pg.height);
  println("2");
  calibrate = true;
  skinGraphic = createGraphics(3*squareSize, 3*squareSize);
  skinImage = createImage(skinGraphic.width, skinGraphic.height, GRAY);
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
  image(skinGraphic, 0, 0);
  
  skinGraphic.loadPixels();
  skinImage.loadPixels();
  skinImage.pixels = skinGraphic.pixels;
  skinImage.updatePixels();
  
  performCV();
}

void drawSquares() {
  
  skinGraphic.beginDraw();
  skinGraphic.noStroke();
  int k = 0;
  for (int i = 0; i < 3*squareSize; i+=squareSize) {
    for (int j = 0; j < 3*squareSize; j+=squareSize) {
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

void performCV() {
  opencv.loadImage(skinImage); // load image
  Mat skinImageBlackWhite = opencv.getGray(); // get grayscale matrix

  Mat skinImageRezied = new Mat(destImg.width, destImg.height, skinImageBlackWhite.type()); // new matrix to store resize image
  Size sz = new Size(destImg.width, destImg.height); // size to be resized

  // Imgproc.resize(skinImageBlackWhite, skinImageRezied, sz, 0, 0, Imgproc.INTER_CUBIC ); // resize // INTER_NEAREST // INTER_CUBIC  Imgproc.INTER_LANCZOS4
  //Imgproc.resize(skinImageBlackWhite, skinImageRezied, sz, 0, 0, imageProcessing); // resize // INTER_NEAREST

  if (enableThreshold) Imgproc.threshold(skinImageRezied, skinImageRezied, thresholdBlobMin, thresholdBlobMax, Imgproc.THRESH_BINARY);

  opencv.toPImage(skinImageRezied, destImg); // store in Pimage for drawing later

  if (enableBlobDetection) {
    blobDetection.computeBlobs(destImg.pixels);
    blobDetection.setThreshold(thresholdBlob);
  }
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
        fill(0, 255, 0);
        strokeWeight(5);
        text(n, blob.x * destImg.width - 10, blob.y * destImg.height- 10);
        point(blob.x * destImg.width, blob.y * destImg.height);
        loadPixels();
      }


      PVector pos =  new PVector(blob.x* destImg.width, blob.y* destImg.height);
    }
  }
}
