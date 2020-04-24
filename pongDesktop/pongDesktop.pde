import oscP5.*;
import netP5.*;

final float PADDLE_WIDTH = 15;
final float PADDLE_HEIGHT = 75;
final float BALL_SIZE = 20;

OscP5 oscP5;
NetAddress myRemoteLocation;

PVector remoteMouse;

float enemyPaddle, myPaddle;
PVector ballPos, ballVel;

PVector accelerometer;

void setup() {
  size(822, 400);
  oscP5 = new OscP5(this,12001);
  
  enemyPaddle = height/2;
  myPaddle = height/2;
  ballPos = new PVector(width/2, height/2);
}

void draw() {
  background(0);
  moveGameObjects();
  drawGameObjects();
  
  if(accelerometer != null){
    textAlign(CENTER);
    textSize(16);
    fill(128);
    text("Accelerometer data:\n"
      + "x: " + roundTwoDecimals(accelerometer.x) + "\n"
      + "y: " + roundTwoDecimals(accelerometer.y) + "\n"
      + "z: " + roundTwoDecimals(accelerometer.z),
      width/2, height/5);
  }
}

void initRound() {
  ballPos = new PVector(width/2, height/2);
  
  // Starting min and max velocity
  int minXVel = 4;
  int maxXVel = 7;
  int minYVel = 2;
  int maxYVel = 8;
  
  float xVel = random(maxXVel - minXVel) + minXVel;
  if(random(1) < 0.5)
    xVel *= -1;
  float yVel = random(maxYVel - minYVel) + minYVel;
  if(random(1) < 0.5)
    yVel *= -1;
    
  ballVel = new PVector(xVel, yVel);
}

void moveGameObjects() {
  if(remoteMouse != null)
    myPaddle = remoteMouse.y;
    
   // Move enemy paddle
  PVector track = new PVector(0, ballPos.y - enemyPaddle);
  track.limit(9);
  enemyPaddle += track.y;
    
  if(ballVel != null) {
    ballPos.add(ballVel);
    ballVel.mult(1.00045);
  }
  
  // Bounce ball off upper wall
  if(ballPos.y < BALL_SIZE/2 && ballVel.y < 0) {
    ballVel.y *= -1;
  }
  
  // Bounce ball off bottom wall
  if(ballPos.y > height - BALL_SIZE/2 && ballVel.y > 0) {
    ballVel.y *= -1;
  }
  
  // Bounce ball off my padle
  if(checkMyPaddleCollision()) {ballVel.x *= -1;
  }
  
  // Bounce ball off enemy paddle
  if(checkEnemyPaddleCollision()) {
    ballVel.x *= -1;
    testY1 = null;
    testY2 = null;
  }
  
  
  if(ballPos.x < -BALL_SIZE || ballPos.x > width + BALL_SIZE) {
    initRound();
    testY1 = null;
    testY2 = null;
  }
}

Float testY1;
Float testY2;

void drawGameObjects() {
  fill(255);
  noStroke();
  rectMode(CENTER);
  
  // Draw ball
  ellipse(ballPos.x, ballPos.y, BALL_SIZE, BALL_SIZE);
  
  // Draw my paddle
  rect(width - PADDLE_WIDTH/2 - 20, myPaddle, PADDLE_WIDTH, PADDLE_HEIGHT);
  
  // Draw enemy paddle
  rect(PADDLE_WIDTH/2 + 20, enemyPaddle, PADDLE_WIDTH, PADDLE_HEIGHT);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage message) {
  String type = message.get(0).stringValue();
  switch(type){
    case "mouse":
      try {
        float x = message.get(1).floatValue() * width;
        float y = message.get(2).floatValue() * height;
        if(remoteMouse == null)
          initRound();
        remoteMouse = new PVector(x, y);
      } catch (Exception e) {
        println("Error parsing message: " + e);
      }
      break;
    case "accelerometer":
      try {
        float x = message.get(1).floatValue();
        float y = message.get(2).floatValue();
        float z = message.get(3).floatValue();
        accelerometer = new PVector(x, y, z);
      } catch (Exception e) {
        println("Error parsing message: " + e);
      }
      break;
  }
}

Boolean checkMyPaddleCollision() {
  if(ballVel == null || ballVel.x < 0) // Ball is not going towards my paddle
    return false;
    
  if(ballPos.y >= myPaddle - PADDLE_HEIGHT/2 && ballPos.y <= myPaddle + PADDLE_HEIGHT/2)
    return abs(width - PADDLE_WIDTH/2 - 20 - ballPos.x) < BALL_SIZE/2 + PADDLE_WIDTH / 2;
    
  if(ballPos.x >= width - PADDLE_WIDTH - 20 && ballPos.x <= width - 20)
    return abs(ballPos.y - myPaddle) < BALL_SIZE/2 + PADDLE_HEIGHT / 2;
  
  return false;
}

Boolean checkEnemyPaddleCollision() {
  if(ballVel == null || ballVel.x > 0) // Ball is not going towards enemy paddle
    return false;
    
  if(ballPos.y >= enemyPaddle - PADDLE_HEIGHT/2 && ballPos.y <= enemyPaddle + PADDLE_HEIGHT/2)
    return abs(PADDLE_WIDTH/2 + 20 - ballPos.x) < BALL_SIZE/2 + PADDLE_WIDTH / 2;
  
  if(ballPos.x >= 20 && ballPos.x <= PADDLE_WIDTH + 20)
    return abs(ballPos.y - enemyPaddle) < BALL_SIZE/2 + PADDLE_HEIGHT / 2;
  
  return false;
}

float roundTwoDecimals(float f) {
  return Math.round(f * 1000.0) / 1000.0;
}