import java.util.Map;

color[] COLORS = {
   #FF0000,
    #FFC000,
    #E0FF00,
    #7EFF00,
    #21FF00,
    #00FF41,
    #00FF9F,
    #00FDFF,
    #009FFF,
    #003DFF,
    #2100FF,
    #8300FF,
    #E500FF,
    #0052FF,
    #FF007C,
    #1000FF,
    #FFFFFF
};


class ClusterCenter {
   public PVector pos; 
   public int id;
   color col;
   ArrayList<PVector> points;
   
   public ClusterCenter(PVector _pos, int _id, color _col){
     pos = _pos;
     id = _id;
     col = _col;
     points = new ArrayList<PVector>();
   }
}

class ClusterController {
    private ArrayList<PVector> data;
    private ArrayList<ClusterCenter> centers;
    private PGraphics offscreen;
      
    public ClusterController(PGraphics _offscreen){
       centers = new ArrayList<ClusterCenter>();
       data = new ArrayList<PVector>();
       offscreen = _offscreen;
    }
    
    void setData(ArrayList<PVector> vals){
      this.data = vals;
      for(PVector v : vals){
         assert(v.x >= 0 && v.x <= 1);
         assert(v.y >= 0 && v.y <= 1);
      }
    }
    
    void showBackground(){
      if(centers.size() == 0) return;
      offscreen.noStroke();
      int res = 5;
      for(int i = 0; i < offscreen.width; i += res){
         for(int j = 0; j < offscreen.height; j += res){
            int idx = closestCenterTo(new PVector((1.0*(i + res/2.0))/offscreen.width, (1.0*(j + res/2.0))/offscreen.height));
            offscreen.fill(centers.get(idx).col, 50);
            offscreen.rect(i, j, res, res);
         }
      }
    }
    
    void showData(){
      offscreen.strokeWeight(3);
      offscreen.stroke(0);
       for(PVector v : data){
          offscreen.point(v.x * offscreen.width, v.y * offscreen.height); 
       }
    }
    
    void showCenters(){
       for(ClusterCenter ct : centers){
          offscreen.stroke(ct.col);
          offscreen.strokeWeight(5);
          offscreen.point(ct.pos.x * offscreen.width, ct.pos.y * offscreen.height);
          offscreen.strokeWeight(3);
          offscreen.line(ct.pos.x*offscreen.width - 5, ct.pos.y * offscreen.height - 5, ct.pos.x*offscreen.width + 5, ct.pos.y * offscreen.height + 5);
          offscreen.line(ct.pos.x*offscreen.width + 5, ct.pos.y * offscreen.height - 5, ct.pos.x*offscreen.width - 5, ct.pos.y * offscreen.height + 5);
       }
    }
    
    void updateCenters(){
        if(centers.size() == 0) return;
        for(ClusterCenter ct : centers) ct.points.clear();
        
        for(PVector pt : data){
           centers.get(closestCenterTo(pt)).points.add(pt);
        }
        
        for(ClusterCenter ct : centers){
           if(ct.points.size() == 0) continue;
           
           PVector sm = new PVector(0, 0);
           for(PVector pt : ct.points) sm.add(pt);
           sm.div(ct.points.size());
           sm.sub(ct.pos);
           ct.pos.add(sm.mult(0.01));
        }
        
    }
    
    void setCenters(HashMap<Integer, PVector> pos){
       for(ClusterCenter ct : centers){
          if(pos.containsKey(ct.id)){
             ct.pos = pos.get(ct.id);
          }
       }
    }
    
    ArrayList<ClusterCenter> getCenters(){
       return centers; 
    }
    
    int closestCenterTo(PVector pt){
        int best = 0; 
         for(int i = 0; i < centers.size(); ++i){
             if(pt.dist(centers.get(best).pos) > pt.dist(centers.get(i).pos)){
                best = i; 
             }
         }
         return best;
    }
    
    void toggleCenter(int id){
      for(ClusterCenter ct : centers){
         if(ct.id == id){
            removeCenter(id);
            return;
         }
       }
        addCenter(id);
    }
    
    void removeCenter(int id){
       for(int i = 0; i < centers.size(); ++i){
          if(centers.get(i).id == id){
             centers.remove(i);
             return;
          }
       }
    }
    
    void addCenter(int id){
       for(ClusterCenter ct : centers){
         if(ct.id == id) return;
       }
       
       centers.add(new ClusterCenter(new PVector(0.5 + random(-0.1, 0.1), 0.5 + random(-0.1, 0.1)), id, COLORS[id]));
    }
   
}
