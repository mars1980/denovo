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
long passedTime, savedTime;

OpenCV opencv;
Blob[] blobs;
int threshold = 40;

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
  size(600, 300);
  smooth();
  
  savedTime = 0;
  opencv = new OpenCV(this);
//  opencv.allocate(320, 240);
  opencv.capture(320, 240);
  
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
  boidsNbr = 500;

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
  
  passedTime = millis() - savedTime;
  if (passedTime > 10000) {
//    opencv.remember();
    savedTime = millis();
  }
  
  opencv.absDiff();
  opencv.threshold(threshold);

  if (showOpenCVImage){
    //this code will drop this sketch to 10fps!!!!!!11!!!
    image(opencv.image(OpenCV.GRAY), 0, 0); // absolute difference image
  }
  // working with blobs
  blobs = opencv.blobs(100, width*height/4, 2, false);
//  println("Num of blobs: " + blobs.length);

  // draw boids and zone border
  boids.display();
  boids.zone.border(150);

  // hide control zone background and draw fps
  //  fill(255);
  // noStroke();
  //  rect(0, 0, width, 50);

  // compute
  boids.update(blobs);
       println(finger);

}


void mousePressed()
{
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
      for (int i=0; i<foodList.size(); i++) {
        Obj o = (Obj) foodList.get(i);
        if (dist(o.pos.x, o.pos.y, mouseX, mouseY) < o.rad)
        {
          foodList.remove(o);
          break;
        }
      }
    }
  }
}

// stop displaying details on mouse releasing
void mouseReleased()
{
  displayAura = false;
  displayPerception = false;
  changeFoodAura = false;
  changeObstAura = false;
}

// reset on SPACE press
void keyPressed()
{
  if (key == ' ') {
//    setup();
    opencv.remember();
  } else if (key == 'f'){
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


}

