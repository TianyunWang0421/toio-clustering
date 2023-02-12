
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
ClusterController controller;
PGraphics offscreen;

void setup(){
   size(800, 800, P3D);
   ks = new Keystone(this);
   surface = ks.createCornerPinSurface(600, 600, 20);
   offscreen = createGraphics(600, 600, P3D);
   
   controller = new ClusterController(offscreen);
   
   // generate fake clusters
   ArrayList<PVector> centers = new  ArrayList<PVector>();
   for(int i = 0; i < 6; ++i){
      centers.add(new PVector(random(0, 1), random(0, 1))); 
   }
   ArrayList<PVector> data = new  ArrayList<PVector>();
   for(PVector pt : centers){
      float s1 = random(0.01, 0.1);
      float s2 = random(0.01, 0.1);
      for(int i = 0; i < 50; ++i){
         data.add(new PVector(
           constrain(pt.x + randomGaussian()*s1, 0, 1), 
           constrain(pt.y + randomGaussian()*s2, 0, 1)
         )); 
      }
   }
   
   controller.setData(data);
}

void draw(){
    background(0, 0, 0);
    offscreen.beginDraw();
    offscreen.background(255, 255, 255);
    controller.showBackground();
    controller.showData();
    controller.showCenters();
    controller.updateCenters();
    offscreen.endDraw(); // TODO: maybe consolidate into single controller function?
    
    surface.render(offscreen);
}

void keyReleased(){
    if(key >= '1' && key <= '8'){
       controller.toggleCenter(key-'1');
    }
}

void keyPressed() {
  switch(key) {
  case 'c':
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}
