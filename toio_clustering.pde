
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
ClusterController controller;
PGraphics offscreen;
ArrayList<DataPoint> dataSet;

void setup(){
   size(1000, 1000, P3D);
   ks = new Keystone(this);
   surface = ks.createCornerPinSurface(410, 820, 20);
   offscreen = createGraphics(410, 820, P3D);
   
   controller = new ClusterController(offscreen);

   
   dataSet = loadData("data.csv");
   
   controller.setData(dataSet.get(1).data);
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
