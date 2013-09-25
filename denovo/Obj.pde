/**
 * Obj class for Processing,
 * Nicolas Liautaud 2009
 * <br/>
 * Used for boids simulation
 */
 
class Obj
{
  PVector pos;
  float rad;
  float aura;
 
  Obj(){
    init(boids.zone.randomPos());
  }
  Obj(int x, int y){
    init(new PVector(x, y));
  }
  void init(PVector p){
    pos = p;
    rad = random(10, 30);
    aura = 3 * rad;
  }
 
  void display(){
    display(100, 100, 100);
  }
  void display(int r, int g, int b){
    fill(r, g, b, 50);
    stroke(r, g, b);
    ellipse(pos.x, pos.y, rad * 2, rad * 2);
  }
}

