
import android.os.Bundle;
import android.content.Intent;

import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

import ketai.sensors.*;

import cassette.audiofiles.SoundFile;

KetaiSensor sensor;
PVector accelerometer;
float light, proximity;
KetaiLocation location;
double longitude, latitude, altitude;

KetaiList connectionList;
String info = "";
boolean isConfiguring = true;
String UIText;

ArrayList<String> devices = new ArrayList<String>();
boolean isWatching = false;

String alerta;
int currentEvent = -1;

SoundFile sound;

void setup() {
  orientation(PORTRAIT);
  stroke(255);
    
  sensor = new KetaiSensor(this);
  sensor.start();
  sensor.list();
  accelerometer = new PVector();
  location = new KetaiLocation(this);

  textFont(createFont("FontsFree-Net-Proxima-Nova-Bold.otf", 64));
  sound = new SoundFile(this, "honk.mp3");
}

void draw() {
  background(201, 223, 236);

  int tSize = 128;
  textAlign(CENTER);
  textSize(tSize);
  while(textWidth(alerta) > width*0.8){
    tSize--;
    textSize(tSize);
  }
  fill(38, 174, 232);
  text(alerta, width/2, (height+tSize)/2 - (tSize*2/3 + 4));
}
