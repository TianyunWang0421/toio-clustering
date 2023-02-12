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

void control_toio(Cube control_cube_i) {
  float val = map(control_cube_i.y, 0, 100, 0, 100);
  float spin = map(control_cube_i.deg, 0, 360, 0, 100);
  
  //println(control_cube_i.deg);
}

float[] sim_to_toio_mat(float x, float y) {
  float mapped_x = map(x, 0, 1, 45, 865);
  float mapped_y = map(y, 0, 1, 45, 455);
  //if (mapped_x >= 455) mapped_x += 90;
  
  return new float[]{mapped_x, mapped_y};
}

float[] toio_to_sim(float x, float y) {
  //if (x >= 455 + 90) x -= 90;
  
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

  for (int i = 0; i < nCubes; ++i) {
    if (cubes[i].isLost==false) {
      if (cubes[i].distance(cubes[i].targetx, cubes[i].targety) > 1) {
        aimCubeSpeed(i, cubes[i].targetx, cubes[i].targety);
      }
    }
  }
  
  if (now % 50 == 0) {
    toio_feedback();
  }
  
  
  control_toio(cubes[0]);

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
