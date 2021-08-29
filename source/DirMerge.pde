String dirIn;
String dirTo;
String dirDupes;
String progress = "Starting";
int progress1 = 0;
int progress2 = 0;

void setup() {
  size(1280,400);
  dirIn = sketchPath() + File.separator + "data" + File.separator + "In";
  dirTo = sketchPath() + File.separator + "data" + File.separator + "Out";
  dirDupes = sketchPath() + File.separator + "data" + File.separator + "Dupes";
  searcher s = new searcher();
  s.start();
}

void draw() {
  background(0);
  textSize(height/12);
  textAlign(CENTER, CENTER);
  fill(255);
  text(progress+"\n"+( progress2 > 0 ? (100*progress1/progress2)+"%" : "" ), width/2, height/2);
}
