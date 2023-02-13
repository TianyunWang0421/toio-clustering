import oscP5.*;
import netP5.*;

//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;


//we'll keep the cubes here
Cube[] cubes;
Cube[] slider_cubes;

boolean mouseDrive = false;
boolean chase = false;
boolean spin = false;
int shake_count = 0;

void setup_toio() {
  // for OSC
  // receive messages on port 3333
  oscP5 = new OscP5(this, 3333);

  //send back to the BLE interface
  //we can actually have multiple BLE bridges
  server = new NetAddress[1]; //only one for now
  //send on port 3334
  server[0] = new NetAddress("127.0.0.1", 3334);
  //server[1] = new NetAddress("192.168.0.103", 3334);
  //server[2] = new NetAddress("192.168.200.12", 3334);


  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i, true);
  }

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  frameRate(30);
}

int getWeekSlider() {
  return constrain(floor(map(constrain(cubes[0].y, 70, 430), 25, 430, 1, 51)), 1, 51);
}

int getOpacityKnob() {
  
  return cubes[0].deg;
}

float[] sim_to_toio_mat(float x, float y) {
  float mapped_x = map(x, 0, 1, 45, 865);
  float mapped_y = map(y, 0, 1, 45, 455);
  if (mapped_x >= 455) mapped_x += 90;
  
  return new float[]{mapped_x, mapped_y};
}

float[] toio_to_sim(float x, float y) {
  if (x >= 455 + 90) x -= 90;
  
  float mapped_x = map(x, 45, 865, 0, 1);
  float mapped_y = map(y, 45, 455, 0, 1);
  
  return new float[]{mapped_x, mapped_y};
}

void setCubeTarget(int cube_i, float x, float y) {
  float[] mapped_coords = sim_to_toio_mat(x, y);
  
  cubes[cube_i].targetx = mapped_coords[0];
  cubes[cube_i].targety = mapped_coords[1];
}

void update_toio(ArrayList<ClusterCenter> centers) {
  long now = System.currentTimeMillis();
  
  for (int i = 0; i < centers.size(); i++) {
    ClusterCenter center = centers.get(i);
    setCubeTarget(center.id, center.pos.x, center.pos.y);
  }

  for (int i = 1; i < nCubes; ++i) {
    if (cubes[i].isLost==false) {
      PVector move_vec = new PVector(cubes[i].targetx, cubes[i].targety).sub(new PVector(cubes[i].x, cubes[i].y)).normalize().mult(17);
      
      if (cubes[i].distance(cubes[i].targetx, cubes[i].targety) > 0.02) {
        aimCubeSpeed(i, cubes[i].x + move_vec.x, cubes[i].y + move_vec.y);
      }
      println(move_vec.x);
    }
  }
  
  //if (cubes[0].prev_shake_level != cubes[0].shake_level) {
  //  cubes[0].prev_shake_level = cubes[0].shake_level;
  //  togglePoints = !togglePoints;
  //}
  
  if (cubes[0].shake_level > 0) {
    shake_count += 1;
    
    if (shake_count > 20) {
      shake_count = 0;
      togglePoints = !togglePoints;
      try {
        midi(0, 57, 255, 10);
        java.util.concurrent.TimeUnit.MILLISECONDS.sleep(50);
        midi(1, 62, 255, 10);
        java.util.concurrent.TimeUnit.MILLISECONDS.sleep(50);
        midi(2, 67, 255, 10);
        java.util.concurrent.TimeUnit.MILLISECONDS.sleep(50);
        midi(3, 62, 255, 10);
        java.util.concurrent.TimeUnit.MILLISECONDS.sleep(50);
        midi(4, 67, 255, 10);
      } catch(InterruptedException e) {
      System.out.println("got interrupted!");
    } 
    }
  } else {
   shake_count = 0; 
  }
  
  if (now % 25 == 0) {
    toio_feedback();
  }

  // ---------- START DO NOT EDIT ----------
  //did we lost some cubes?
  for (int i=0; i<nCubes; ++i) {
    // 500ms since last update
    cubes[i].p_isLost = cubes[i].isLost;
    if (cubes[i].lastUpdate < now - 275 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
    }
  }
  // ---------- END DO NOT EDIT ----------
}
