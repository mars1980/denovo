

class BoidsFlock
{
  // Simulation zone
  Zone zone;
  // Keep in zone by looping or bouncing
  boolean loopZone;
  // Boids list
  ArrayList list;
  // Boids try to approach other boids (factor)
  float cohesion;
  // Boids try to keep a minimum distance between others (factor)
  float avoidance;
  // Boids try to move in the same way than other boids (factor)
  float imitation;
  // Boids radius
  int size = 7;
  // Distance for which boids touch things (avoidance, collisions)
  float aura;
  // Distance for which boids sees and responds to its environment
  float perception;
  // Define cruise-speed and stress-speed limit
  float speedLimit;
  
  boolean addedFood = false;

  /**
   * Class constructor.
   */
  BoidsFlock()
  {
    zone = new Zone(0, 0, width, height);
    loopZone = true;
    list = new ArrayList();
    cohesion = 10;
    avoidance = 10;
    imitation = 10;
    size = 2;
    aura = 3 * size;
    perception = 10 * size;
    speedLimit = 0;
  }


  /**
   * Add a boid to flock.
   */
  void add() {
    list.add(new Boid());
  }
  /**
   * Add a boid to flock at the defined position.
   */
  void add(int x, int y) {
    list.add(new Boid(x, y));
  }
  /**
   * Add a boid to flock at the defined position.
   */
  void add(PVector p) {
    list.add(new Boid(p));
  }

  /**
   * Add a boid to flock outside object list auras or don't create it.
   *
   * @param  objs Obj ArrayList : list of objects which areas should be avoided
   */
  void addOutside(ArrayList objs)
  {
    boolean collide = false;
    int it = 0, itMax = 50000;
    PVector pos;
    // do this while random pos is in Obj zone
    do {
      it++;
      pos = boids.zone.randomPos();
      for (int i=0; i<objs.size(); i++)
      {
        Obj o = (Obj) objs.get(i);
        if (PVector.dist(pos, o.pos) < o.aura)
        {
          collide = true;
          break;
        }
      }
    } 
    while (collide && it < itMax);
    if (!collide) list.add(new Boid(pos));
  }

  /**
   * Delete boid from flock.
   *
   * @param  i boid index
   */
  void del(int i) {
    list.remove(i);
  }

  /**
   * Return the number of boids in flock.
   */
  int size() {
    return list.size();
  }

  /**
   * Return the specified boid.
   *
   * @param i boid index
   * @return Boid
   */
  Boid get(int i) {
    return (Boid) list.get(i);
  }

  /**
   * Update each boid position and velocity according to simulation rules.
   */
  void update(Blob[] blobs)
  {
    for (int i=0; i<list.size(); i++)
    {
      Boid b = (Boid) list.get(i);

      // basic flock rules
      //
      b.keepDistance();
      b.matchVelocity();

      // additionnal rules
      b.keepInZone(zone, loopZone);

      // Cruise-speed limitation


      // food attraction and eat
      boolean contact;
      for (int j=0; j<foodList.size(); j++)
      {
        Obj f = (Obj) foodList.get(j);
        // medium attraction when perceived
        b.effector(int(f.pos.x), int(f.pos.y), f.aura + boids.perception, 1.2);
        // big repulsion on contact
        b.effector(int(f.pos.x), int(f.pos.y), f.rad + boids.size, -40);
        // if contact
        if (PVector.dist(f.pos, b.pos) < f.rad + boids.size)
        {
          f.rad -= .03;// reduce obj size
          // if size is too small delete it and update control value
          if (f.rad <= 5) {
            foodList.remove(j);
            //            Slider s = (Slider) controlP5.controller("food");
            //            s.setValue(foodList.size());
          }
        }
      }

      // obstacles boids.avoidance
      //      for(int j=0; j<obstList.size(); j++)
      //      {
      //        Obj o = (Obj) obstList.get(j);
      //        // small repulsion when perceived (anticipation)
      //        b.effector(int(o.pos.x), int(o.pos.y), o.aura + boids.perception, -0.2);
      //        // big repulsion on contact (collision)
      //        b.effector(int(o.pos.x), int(o.pos.y), o.rad + boids.size, -20);
      //      }
      PVector blob = new PVector();
      if (finger == 1) 
      {
        speedLimit = 3.5;
        b.goToCenter();
        b.limitVelocity(speedLimit);
        //if (boids.zone.isIn(mouseX, mouseY))
        for (int j=0; j<blobs.length; j++) 
        {
          blob.x = blobs[j].centroid.x*width/360; //this maps the image(from camera) to the sketch
          blob.y = blobs[j].centroid.y*height/240;

          // test
          if (!addedFood && boids.zone.isIn(round(blob.x), round(blob.y)))
          {
            foodList.add(new Obj(round(blob.x), round(blob.y)));
            addedFood = true;
          }
          // end test 
          //      Rectangle bounding_rect = blobs[i].rectangle;
          noFill();
          stroke(237, 205, 41, 0);
          ellipse(blob.x-10, blob.y+10, 30, 30); //debug the blob position

          b.effector((int)blob.x, (int)blob.y, 80, 2);
        }
      }
      else if (finger == 0)
      {
        addedFood = false;
        speedLimit -= 0.0001;

        if (speedLimit < 1)  speedLimit = 1;

        b.limitVelocity(speedLimit);
      }





      //        else if (finger == 0)
      //        b.friction;


      //      b.effector(mouseX, mouseY, 80, 2);

      // Max-speed limitation
      //b.limitVelocity(speedLimit * 2);

      // finally update position
      b.pos.add(b.vel);
    }
  }

  /**
   * Draw each boid.
   */
  void display()
  {
    for (int i=0; i < list.size(); i++)
    {
      Boid b = (Boid) list.get(i);
      b.display();
    }
  }

  /**
   * Draw perception distance of boid alpha.
   */
  void displayPerception()
  {
    fill(150, 180, 255, 50);
    stroke(150, 180, 255);
    Boid b = (Boid) boids.get(0);
    ellipse(b.pos.x, b.pos.y, boids.perception * 2, boids.perception * 2);
  }

  /**
   * Draw aura distance of boid alpha.
   */
  void displayAura()
  {
    fill(255, 180, 150, 50);
    stroke(255, 180, 150);
    Boid b = (Boid) boids.get(0);
    ellipse(b.pos.x, b.pos.y, boids.aura * 2, boids.aura * 2);
  }
}

/*void friction()
 {
 //slow down the boids
 
 }*/
