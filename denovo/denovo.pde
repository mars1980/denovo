/**
 * Boid class for Processing,
 * Nicolas Liautaud 2009
 * <br/>
 * Used by BoidsFlock class
 ------------------------------
 2013 - Manuela Donoso, Crys Moore, Ricardo Dodds. 
 */

import hypermedia.video.*;
import processing.video.*;
import java.awt.*;
import processing.serial.*;

boolean showOpenCVImage = false;
long passedTime, savedTime, initTime;

OpenCV opencv;
Blob[] blobs;
float threshold = 50;
float fingerX; //THIS IS AN APPROXIMATION OF WHERE THE FINGER WOULD BE
float fingerY;


ArrayList foodList;
int foodNbr, boidsNbr;
boolean displayAura, displayPerception;
boolean changeObstAura, changeFoodAura;
float foodAuraFactor;
BoidsFlock boids;

//ARDUINO
Serial myPort;
int finger;

void setup()
{
  // canvas
  size(1200, 400);
  smooth();
  noCursor();

  initTime = millis();
  savedTime = millis();

  opencv = new OpenCV(this);
  // opencv.allocate(320, 240);
  opencv.capture(320, 240,4);  
  //opencv.capture(1080, 720, 4);

  //ARDUINO
  //DON'T FORGET TO CHOOSE CORRECT SERIAL PORT
  String portName = Serial.list()[4];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');  //this is important!!! otherwise we get 1 and 0s unstable


  // initialize food
  foodList = new ArrayList();
  foodNbr  = 0;
  foodAuraFactor = 3;
  // initialize boids
  boids = new BoidsFlock();
  boidsNbr = 100;

  // create foods
  for (int i=0; i < foodNbr; i++)
  {
    foodList.add(new Obj());
    Obj o = (Obj)foodList.get(i);
    o.aura = o.rad * foodAuraFactor;
  }

  // create boids
  for (int i=0; i < boidsNbr; i++)
  {
    boids.add();
  }
}

void draw()
{
      background(0);
      fill(255);
 
      //opencv.flip( OpenCV.FLIP_VERTICAL );
    
      // initial calibration during first 2 seconds
      if ((millis() - initTime) < 2000) opencv.remember();
    
      // draw details (controls manipulation)
      if (displayPerception) boids.displayPerception();
      if (displayAura) boids.displayAura();
      if (changeFoodAura) changeObjAura(foodList, foodAuraFactor, 100, 255, 100);
    
      // draw food
      for (int i=0; i<foodList.size(); i++)
      {
        Obj f = (Obj) foodList.get(i);
        f.display(120, 255, 120);
      }
    
      opencv.read();
    
      opencv.absDiff();
      opencv.threshold(threshold, 255, OpenCV.THRESH_BINARY/* + OpenCV.THRESH_OTSU*/);
    
      // working with blobs
//      blobs = opencv.blobs(100, width*height/4, 1, false);
        int blobMax=6000;
        int blobMin=100;
        blobs = opencv.blobs(blobMin,blobMax , 1, false);


      
      // println("Num of blobs: " + blobs.length);
    
      passedTime = millis() - savedTime;
      if (blobs.length == 0 && passedTime > 200) {
        opencv.remember();
        savedTime = millis();
      }
    
      if (showOpenCVImage) {////////////////
        //this code will drop this sketch to 10fps!!!!!!11!!!
        image(opencv.image(OpenCV.GRAY), 0, 0); // absolute difference image
    
        // draw blob results
        for ( int i=0; i<blobs.length; i++ ) {
    
          Rectangle bounding_rect  = blobs[i].rectangle;
          float area = blobs[i].area;
          float circumference = blobs[i].length;
          Point centroid = blobs[i].centroid;
          Point[] points = blobs[i].points;
    
          // rectangle
          noFill();
          stroke( blobs[i].isHole ? 128 : 64 );
          rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );
          ///THIS IS AN APPROXIMATION OF THE TIP OF THE FINGER
          fill(250,255,5);
          ellipseMode(CENTER);
          fingerX = bounding_rect.x+bounding_rect.width/2;
          fingerY= bounding_rect.y;
          ellipse(bounding_rect.x+bounding_rect.width/2,bounding_rect.y,5, 5 );
    //      println(fingerX);
    
          // centroid
          stroke(0, 0, 255);
          line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
          line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
          noStroke();
          fill(0, 255, 0);
          text( area,centroid.x+5, centroid.y+5 );
          //println(area);
    
          fill(255, 0, 255, 64);
          stroke(255, 0, 255);
          if ( points.length>0 ) {
            beginShape();
    
            for ( int j=0; j<points.length; j++ ) {
              vertex( points[j].x, points[j].y );
                }
    
            endShape(CLOSE);
          }
    
          noStroke();
          fill(0, 255, 0);
          //text( circumference, centroid.x+5, centroid.y+15 );
          //println(circumference);
    
          ellipse(centroid.x, centroid.y, 5, 5);
        }
      }///////////////
    
    
      // draw boids and zone border
      boids.display();
      boids.zone.border(150);
    
      // hide control zone background and draw fps
      //  fill(255);
      // noStroke();
      //  rect(0, 0, width, 50);
    
      // compute
      boids.update(blobs);
      // println(finger);
}


void mousePressed()
{
  foodList.add(new Obj(round(fingerX),round(fingerY)));
  /*
  // check if clic is in sim zone
  if (boids.zone.isIn(mouseX, mouseY))
  {
    // add food on left clic
    if (mouseButton == LEFT)
    {
      foodList.add(new Obj(mouseX, mouseY));
    }
    // delete things with middle clic
    else if (mouseButton == CENTER)
    {
      // delete food if mouse is on it
      for (int i=0; i<foodList.size(); i++) 
      {
        Obj o = (Obj) foodList.get(i);
        if (dist(o.pos.x, o.pos.y, mouseX, mouseY) < o.rad)
        {
          foodList.remove(o);
          break;
        }
      }
    }
  }*/
}

// stop displaying details on mouse releasing
void mouseReleased()
{
  displayAura = false;
  displayPerception = false;
  changeFoodAura = false;
  changeObstAura = false;
  //println("fingerX=" + fingerX +"," + "fingerY= " + fingerY);

}

// reset on SPACE press
void keyPressed()
{
  if (key == ' ') {
    // setup();
    opencv.remember();
  } 
  else if (key == 'f') {
    showOpenCVImage = !showOpenCVImage;
  }
}

// change aura value and display it (controls manipulation)
void changeObjAura(ArrayList l, float f, int r, int g, int b)
{
  fill(r, g, b, 20);
  stroke(r, g, b, 50);
    for (int i=0; i < l.size(); i++)
  {
    Obj o = (Obj) l.get(i);
    o.aura = o.rad * f;
    ellipse(o.pos.x, o.pos.y, o.aura * 2, o.aura * 2);
  }
}

//ARDUINO
void serialEvent(Serial myPort) {
  // read a byte from the serial port:   
  finger = int(myPort.readString().trim());
  //println("finger = " + finger);
}

