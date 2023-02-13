class DataPoint {
   // datapoint containing useful stuff
   ArrayList<PVector> data;
   String start;
   String end;
   int index;
   
   
   DataPoint(ArrayList<PVector> data_, String start_, String end_, int index_){
      data = data_;
      start = start_;
      end = end_;
      index = index_;
   }
}

ArrayList<DataPoint> loadData(String fileName){
  Table table = loadTable(fileName, "header");
  
  println(table.getRowCount() + " total rows in table");
  
  ArrayList<DataPoint> ret = new ArrayList<DataPoint>();
  
  for(int i = 0; i < 52; ++i){
     ret.add(new DataPoint(new ArrayList<PVector>(), "", "", i));
  }
  
  for (TableRow row : table.rows()) {
    int week_index = row.getInt("week_index");
    float x = row.getFloat("y");
    float y = row.getFloat("x");
    //float x = row.getFloat("x");
    //float y = row.getFloat("y");
    String start = row.getString("Week Start");
    String end = row.getString("Week End");
    ret.get(week_index).data.add(new PVector(x, y));
    ret.get(week_index).start = start;
    ret.get(week_index).end = end;
  }
  
  return ret;
}
