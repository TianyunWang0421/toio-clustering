
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
ClusterController controller;
PGraphics offscreen;

boolean live_demo = true;//false;

void setup(){
   size(1900, 1000, P3D);
   ks = new Keystone(this);
   surface = ks.createCornerPinSurface(1700, 1000, 20);
   offscreen = createGraphics(1700, 1000, P3D);
   
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
   
   setup_toio();
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
    
    
    
    update_toio(controller.getCenters());
    
    if (live_demo) {
      check_active_toios();
    }
}

void toio_feedback() {
  ArrayList<ClusterCenter> centers = controller.getCenters();
  HashMap<Integer, PVector> pos = new HashMap<Integer, PVector>();

  for (int i = 0; i < nCubes; ++i) {
    float[] mapped_coords = toio_to_sim(cubes[i].x, cubes[i].y);
    pos.put(i, new PVector(mapped_coords[0], mapped_coords[1]));
  }
  
  controller.setCenters(pos);
}

void check_active_toios() {
  ArrayList<ClusterCenter> centers = controller.getCenters();
  
  for (int cube_i = 0; cube_i < nCubes; ++cube_i) {
    boolean hit = false;
    Cube cube = cubes[cube_i];
    
    for(int i = 0; i < centers.size(); ++i){
        if(centers.get(i).id == cube_i){
           hit = true;
           if (cube.isLost) {
             println("REMOVING " + cube_i);
             controller.removeCenter(cube_i);
           }
        }
     }
     if (cube.isLost == false && hit == false) {
       println("ADDING " + cube_i);
       float[] mapped_coords = toio_to_sim(cube.x, cube.y);
       controller.addCenter(cube_i, mapped_coords[0], mapped_coords[1]);
       
     }
    
  }
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
