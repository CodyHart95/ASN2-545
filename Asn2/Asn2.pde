int[] rCounts = new int[256];  //bins for red histogram
int[] gCounts = new int[256];  //bins for green histogram
int[] bCounts = new int[256];  //bins for blue histogram
int[] brightCounts = new int[256];
int posR = 10, posG = 275, posB = 540, a, b, c, d, hCountTotal;
String fname[] = {"low_contrast_woman.jpg","IDontKnowWhatThisIs.gif","man_overexposed.jpg"};
PImage img, sImg, eImg, currentImg; //Original, brightened, darkened, current
boolean showHists = false;
int pixValue = 0;
int pixCount = 0;

void setup() {
  size(400, 400);
  surface.setResizable(true);
  img = loadImage(fname[2]);

  
  sImg = stretchedHist(img);
  eImg = equalize(img);
  surface.setSize(img.width, img.height);
  currentImg = img;
  textAlign(LEFT);
  textSize(32);
}

void draw() {
  if (showHists){
    displayHists();
    if(mouseX >= posR && mouseX <= posR + 255){
      pixValue =  mouseX - posR;
      pixCount = rCounts[pixValue];
    }
    
    else if( mouseX >= posG && mouseX <= posG + 255){
      pixValue = mouseX - posG;
      pixCount = gCounts[pixValue];
    }
    
    else if( mouseX >= posB && mouseX <= posB + 255){
      pixValue = mouseX - posB;
      pixCount = bCounts[pixValue];
    }
    text("Pixle Value: " + str(pixValue), 0, 50);
    text("Pixle Count: " + str(pixCount), 0, 100); 
  }
  
  else image(currentImg, 0, 0);
  stroke(0);
  strokeWeight(2);
  noFill();
  rect(a,b,c,d);
}


//calculates the hist values
void calcHists(PImage img) {
  //sets all values of Counts to zero
  for (int i = 0; i < rCounts.length; i++) {
    rCounts[i] = 0; 
    gCounts[i] = 0; 
    bCounts[i] = 0;
  }
  //gets r, g, b values as ints
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color c = img.get(x, y);
      int r = int(red(c));
      int g = int(green(c));
      int b = int(blue(c));
      rCounts[r] += 1;
      gCounts[g] += 1;
      bCounts[b] += 1;
    }
  }
}

void displayHists() {
  //Displays global histogram held in rCounts, etc
  background(0);
  int maxval = 0;
  //Find maxval in all hists
  for (int i = 0; i < rCounts.length; i++) {
    if (rCounts[i] > maxval) maxval = rCounts[i];
    if (gCounts[i] > maxval) maxval = gCounts[i];
    if (bCounts[i] > maxval) maxval = bCounts[i];
  }
  stroke(255, 0, 0);
  //Use map() to scale line values
  for (int i = 0; i < rCounts.length; i++) {
    //Scale line from 0 to height/2
    int val = int(map(rCounts[i], 0, maxval, 0, height/2));
    line(i + posR, height, i + posR, height - val);
  }
  stroke(0, 255, 0);  //Display green hist in green
  for (int i = 0; i < gCounts.length; i++) {
    //Scale line from 0 to height/2
    int val = int(map(gCounts[i], 0, maxval, 0, height/2));
    line(i + posG, height, i + posG, height - val);
  }
  stroke(0, 0, 255);
  for (int i = 0; i < bCounts.length; i++) {
    //Scale line from 0 to height/2
    int val = int(map(bCounts[i], 0, maxval, 0, height/2));
    line(i + posB, height, i + posB, height - val);
  }
}

void printHists() {
  //Use a for (int i...) loop to println i, rCounts[i], gCounts[i], and bCounts[i]
  for (int i = 0; i < rCounts.length; i++) {
    println(i, rCounts[i], gCounts[i], bCounts[i]);
  }
}

PImage stretchedHist(PImage img) {
  PImage copyImg = img.get(); 
  //will alter copy image according to the stretched histogram equation
   calcHists(copyImg);
   int rMin = minPixleValue(rCounts);
   int gMin = minPixleValue(gCounts);
   int bMin = minPixleValue(bCounts);
      
   for (int y = 0; y < copyImg.height; y++) {
    for (int x = 0; x < copyImg.width; x++) {
      color c = copyImg.get(x,y);
      int newRed = int(red(c) - rMin);
      //println(str(red(c)), str(rMin));
      int newGreen = int(green(c)- gMin);   
      int newBlue = int(blue(c) - bMin);
      copyImg.set(x,y,color(newRed,newGreen,newBlue)); 
    }
  }
  
  calcHists(copyImg);
  int rMaxVal = maxPixleValue(rCounts);
  int gMaxVal = maxPixleValue(gCounts);
  int bMaxVal = maxPixleValue(bCounts);
  println(rMaxVal);
   for (int y = 0; y < copyImg.height; y++) {
    for (int x = 0; x < copyImg.width; x++) {
      color c = copyImg.get(x,y);
      int newRed = constrain(int(red(c) * (255/rMaxVal)),0,255);
      int newGreen = constrain(int(green(c) * (255/gMaxVal)),0,255);
      int newBlue = constrain(int(blue(c)* (255/bMaxVal)),0,255);
      copyImg.set(x,y,color(newRed,newGreen,newBlue)); 
      println(newRed);
    }
  }
  
  return copyImg;
}
void calcBrightHist(PImage copyImg){
 for (int y = 0; y < copyImg.height; y++) {
    for (int x = 0; x < copyImg.width; x++) {
      color c = copyImg.get(x,y);
      brightCounts[int(brightness(c))]++;
    }
 }
}
 PImage equalize(PImage img) {
  PImage copyImg = img.get();
  calcHists(copyImg);
  //will alter and return copy that has been equalized
  float[] cumulRed = cumulHist(rCounts, copyImg);
  float[] cumulGreen = cumulHist(gCounts, copyImg);
  float[] cumulBlue = cumulHist(bCounts, copyImg);
  int maxRed = maxPixleValue(rCounts);
  int maxGreen = maxPixleValue(gCounts);
  int maxBlue = maxPixleValue(bCounts);
  //println(str(maxRed), str(maxGreen), str(maxBlue));
  for(int i = 0; i < cumulRed.length; i++){
    cumulRed[i] = round(cumulRed[i] * maxRed);
    cumulGreen[i] = round(cumulGreen[i] * maxGreen);
    cumulBlue[i] = round(cumulBlue[i] * maxBlue);
  }
  
  for (int y = 0; y < copyImg.height; y++) {
    for (int x = 0; x < copyImg.width; x++) {
      color c = copyImg.get(x,y);
      int newRed = int(cumulRed[int(red(c))]);
      int newGreen = int(cumulGreen[int(red(c))]);
      int newBlue = int(cumulBlue[int(red(c))]);
      copyImg.set(x,y, color(newRed, newGreen, newBlue));
    }
  }
  
  return copyImg;
}
float[] cumulHist(int[] hist, PImage copyImg){
  float[] cumul = new float[256];
  for (int i = 1; i < hist.length; i++){
    cumul[i] = (hist[i] + cumul[i - 1])/(copyImg.width * copyImg.height);
  }
  return cumul;
}
int maxPixleValue(int[] hist){
  for(int i = hist.length - 1; i > -1; i--){
    if(hist[i] > 0){ 
     return i;
    }
  }
  return 0;
}
int minPixleValue(int[] hist){
 for (int i = 0; i < hist.length;i++){
    if(hist[i] != 0) return i;
  }
  return 0;
}
void mousePressed() {
  if(!showHists){
  a=mouseX;
  b=mouseY;
  }
}


void mouseDragged() {
  if(!showHists){
  c=mouseX-a;
  d=mouseY-b;
  rect(a, b, c, d);
  }
}

void mouseReleased() {
  //needs to call the hists to color inside of rectangle
}
void keyReleased() {
  background(0);
  if (key == '1') {
    currentImg = img;
    showHists = false;
    surface.setSize(currentImg.width, currentImg.height);
    calcHists(currentImg);
    //printHists();
  } else if (key == '2') {
    //display stretched Hist
  } else if (key == '3') {
    //display equalized hist
  } else if (key == 'h') {
    calcHists(currentImg);
    showHists = true;
    surface.setSize(posB + bCounts.length, currentImg.height);
  } else if (key == 's') {
    currentImg = sImg;
    calcHists(currentImg);
  } else if (key == 'e') {
    currentImg = eImg;
    calcHists(currentImg);
  }
}