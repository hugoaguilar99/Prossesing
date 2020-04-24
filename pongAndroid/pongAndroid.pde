import oscP5.*;
import netP5.*;

import ketai.sensors.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

KetaiSensor sensor;

PVector acc, prevAcc;

void setup() {
  orientation(LANDSCAPE);
  textAlign(CENTER);
  textFont(createFont("FontsFree-Net-Proxima-Nova-Bold.otf", 64));
  
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("192.168.0.1",12001);
  
  sensor = new KetaiSensor(this);
  sensor.start();
}

void draw() {
  background(201, 223, 236);
  
  String text = "LOOK AT YOUR\nPC SCREEN!";
  textSize(80);
  fill(220, 234, 243);
  text(text, width/2, height/2 - 40);
  if(mousePressed) {
    OscMessage message = new OscMessage("/test");
    message.add("mouse");
    message.add(mouseX*1.0/width);
    message.add(mouseY*1.0/height);
    oscP5.send(message, myRemoteLocation);
  }
  if(frameCount%3 == 1 && acc != null && acc != prevAcc) {
    prevAcc = acc;
    OscMessage message = new OscMessage("/test");
    message.add("accelerometer");
    message.add(acc.x);
    message.add(acc.y);
    message.add(acc.z);
    oscP5.send(message, myRemoteLocation);
  }
}


void onAccelerometerEvent(float x, float y, float z){
  acc = new PVector(x, y, z);
}
