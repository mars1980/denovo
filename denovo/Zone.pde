/**
 * Zone class for Processing,
 * Nicolas Liautaud 2009
 * <br/>
 * Used by BoidsFlock class
 */
class Zone
{
  int x, y, w, h;
 
  Zone(int _x, int _y, int _w, int _h){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }
 
  // define if coord is in zone
  boolean isIn(PVector v){
    return isIn(int(v.x), int(v.y)); 
  }
  boolean isIn(int px, int py){
    if(px > x && px < x + w &&
      py > y && py < y + h)
      return true;
    else return false; 
  }
 
  // return a random pos vector in zone
  PVector randomPos(){
    return new PVector(random(x, x + w), random(y, y + h));
  }
 
  // display a border around zone
  void border(int a){
    noFill();
    noStroke();
    rect(x, y, w - 1, h - 1);
  }
}

