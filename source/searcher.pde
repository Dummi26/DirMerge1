import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

class searcher extends Thread {
  public void run() {
    println("SEARCHER STARTED");
    progress = "Deleting files from specified directories";
    println(dirTo);
    File[] filesToDelete = add(listFiles(dirTo),listFiles(dirDupes));
    for(int i=0;i<filesToDelete.length;i++){
      try{Files.delete(filesToDelete[i].toPath());}catch(IOException e){println(e);}
    }
    //
    File[] files = allFiles(dirIn);
    progress1 = 0;
    progress2 = files.length+1;
    progress = "Getting file sizes";
    long[] filesize = new long[files.length];
    boolean[] hasSameFile = new boolean[files.length];
    boolean[] isDupe = new boolean[files.length];
    int[][] sameFile = new int[files.length][0];
    for(int i=0;i<files.length;i++){
      progress1 = i;
      try {filesize[i] = Files.size(Paths.get(files[i].getPath()));
      } catch (IOException e) {exit();}
      //////////
    }
    progress1 = 0;
    progress = "Finding files with same size and checking their content";
    for(int i=0;i<filesize.length;i++){
      progress1 = i;
      long fs = filesize[i];
      byte[] bytes = null; // don't load a file if no other file of same size exists anyways
      for(int j=i+1;j<filesize.length;j++){ // anything before i was already checked and if i == j, comparing them would be stupid as they are one and the same
        if ( fs == filesize[j] ) { // file size is the same, check content
          if ( bytes == null ) { // only load file once as it will not change
            bytes = loadBytes(files[i]);
          }
          byte[] bytesCompare = loadBytes(files[j]);
          int[] isSame = match(bytes,bytesCompare);
          if ( isSame[0] == 2 ) {
            hasSameFile[i] = true;
            hasSameFile[j] = true;
            isDupe[j] = true;
            sameFile[i] = add(sameFile[i], j);
          } else if ( isSame[0] == 1 ) {
            println("FILE " + i + " DOES NOT MATCH PERFECTLY (" + (100*isSame[1]/max(1,isSame[2])) + "%)");
          } else {
            println("FILE " + i + " DOES NOT MATCH: " + isSame[0]);
          }
        }
      }
    }
    for(int i = 0; i < sameFile.length; i++) {
      int[] sameFiles = new int[0]; // files that perfectly match this one
      progress1 = i;
      byte[] bytes = loadBytes(files[i]);
      for(int j = 0; j < sameFile[i].length; j++) {
        byte[] bytesCompare = loadBytes(files[sameFile[i][j]]);
        int[] isSame = match(bytes,bytesCompare);
        if ( isSame[0] == 0 ) {
        } else if ( isSame[0] == 1 ) {
        } else if ( isSame[0] == 2 ) {
          print("+");
        }
      }
    }
    //
    //COPY FILES
    //
    for(int i = 0; i < files.length; i++) { // OUT
      if ( sameFile[i].length == 0 ) {
        Path copied = Paths.get(dirTo + File.separator + i + " " + files[i].getName());
        Path originalPath = files[i].toPath();
        try{Files.copy(originalPath, copied);}catch(IOException e){println(e);};
      }
    }
    for(int i = 0; i < files.length; i++) { // DUPES
      if ( isDupe[i] ) {
        Path copied = Paths.get(dirDupes + File.separator + i + " " + files[i].getName());
        Path originalPath = files[i].toPath();
        try{Files.copy(originalPath, copied);}catch(IOException e){println(e);};
      }
    }
    //
    //OUTPUT
    //
    println("----- HAS SAME FILE -----");
    for(int i=0;i<files.length;i++){
      if ( hasSameFile[i] ) {
        println(files[i].getPath());
      }
    }
    println("----- NO SAME FILE -----");
    for(int i=0;i<files.length;i++){
      if ( !hasSameFile[i] ) {
        println(files[i].getPath());
      }
    }
    //
    progress1 = 0;
    progress2 = 1;
    progress1 = 1;
    progress = "FINISHED!";
  }
}

int[] match(byte[] i1, byte[] i2) { // returns:
                                    //   [0]   : 0 = length does not match; 1 = partial match; 2 = matches exactly
                                    // [1]/[2] : [1] = same bytes; [2] = total bytes
  //
  int l = i1.length;
  if ( l != i2.length ) {
    return new int[] {0,0,0};
  } else {
    int matches = 0;
    for ( int i = 0; i < l; i++) {
      if ( i1[i] == i2[i] ) {
        matches++;
      }
    }
    int status = matches==l?2:1;
    return new int[] {status,matches,l};
  }
}
String arrayToString(int[][] in) {
  String o = "";
  for (int i = 0; i < in.length; i++) {
    o += "[";
    for (int j = 0; j < in[i].length; j++) {
      if(j!=0){o+=",";}
      o += in[i][j];
    }
    o += "]";
    if(i!=in.length-1){o+=", ";}
  }
  return o;
}

File[] allFiles(String path) {
  File[] theseFiles = listFiles(path);
  File[] out = new File[0];
  for (int i = 0; i < theseFiles.length; i++) {
    if ( theseFiles[i].isDirectory() ) {
      out = add(out,allFiles(theseFiles[i].getAbsolutePath()));
    } else {
      out = add(out,theseFiles[i]);
    }
  }
  return out;
}

File[] add(File[] i1, File i2){
  File[] o = new File[i1.length+1];
  for(int i=0;i<i1.length;i++){o[i]=i1[i];}
  o[i1.length]=i2;
  return o;
}
File[] add(File[] i1, File[] i2) {
  //if(i1==null){i1=new File[0];}if(i2==null){i2=new File[0];}
  File[] o = new File[i1.length+i2.length];
  for(int i=0;i<i1.length;i++){o[i] = i1[i];}
  for(int i=0;i<i2.length;i++){o[i1.length+i] = i2[i];}
  return o;
}

int[] add(int[] i1, int i2){
  int[] o = new int[i1.length+1];
  for(int i=0;i<i1.length;i++){o[i]=i1[i];}
  o[i1.length]=i2;
  return o;
}

int[][] add(int[][] i1, int[] i2){
  int[][] o = new int[i1.length+1][];
  for(int i=0;i<i1.length;i++){o[i]=i1[i];}
  o[i1.length]=i2;
  return o;
}
