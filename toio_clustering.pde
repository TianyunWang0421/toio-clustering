
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
ClusterController controller;
PGraphics offscreen;
ArrayList<DataPoint> dataSet;


int week = 1;
String week_start = "";

void settings() {
    size(displayWidth, displayHeight, P3D);
 
}

void setup(){
   ks = new Keystone(this);
   //surface = ks.createCornerPinSurface(410, 820, 20);
   //offscreen = createGraphics(410, 820, P3D);
    surface = ks.createCornerPinSurface(820, 410, 20);
   offscreen = createGraphics(820, 410, P3D);
   
   controller = new ClusterController(offscreen);

   
   dataSet = loadData("filtered_df_5.csv");
   controller.setData(dataSet.get(1).data);
   
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
    
    offscreen.stroke(125);
    offscreen.fill(153);
    offscreen.rect(0, 0, 0.1 * offscreen.width, offscreen.height);
    
    offscreen.rect(0.1 * offscreen.width, 0, 0.06 * offscreen.width, 0.4 * offscreen.height);
    
    offscreen.pushMatrix();
    float angle1 = radians(90);
    offscreen.fill(255);
    offscreen.translate(0.12 * offscreen.width, 0.01 * offscreen.height);
    offscreen.rotate(angle1);
    offscreen.textSize(32);
    offscreen.text(week_start, 0, 0);
    offscreen.popMatrix();
    
    offscreen.endDraw(); // TODO: maybe consolidate into single controller function?
    
    surface.render(offscreen);
    
    
    
    update_toio(controller.getCenters());
    update_controls();
    
    if (live_demo) {
      check_active_toios();
    }
}

void update_controls() {
  int new_week = getWeekSlider();
  if (new_week != week) {
    week = new_week;
    controller.setData(dataSet.get(week).data);
    week_start = dataSet.get(week).start;
  }
  
  //maxMotorSpeed = max(50, getSpeedKnob());
}


void toio_feedback() {
  HashMap<Integer, PVector> pos = new HashMap<Integer, PVector>();

  for (int i = 1; i < nCubes; ++i) {
    float[] mapped_coords = toio_to_sim(cubes[i].x, cubes[i].y);
    pos.put(i, new PVector(mapped_coords[0], mapped_coords[1]));
  }
  
  controller.setCenters(pos);
}

void check_active_toios() {
  ArrayList<ClusterCenter> centers = controller.getCenters();
  
  for (int cube_i = 1; cube_i < nCubes; ++cube_i) {
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
