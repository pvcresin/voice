import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
FFT fft;

int w = 400, h = w, sampleN = 512;
float R = w/4.0, waveH = R * 0.8;

void setup() {
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, sampleN);

  fft = new FFT(in.bufferSize(), in.sampleRate());

  size(400, 400);  // w, h
  //frameRate(15);
  smooth();
}

void draw() {
  background(0);
  stroke(255);
  fft.forward(in.mix);  // frequency -> spectrum

  for (int i = 0; i < fft.specSize (); i++) {  // fft center lines
    float x = map(i, 0, fft.specSize(), 0, width);
    line(x, height, x, height - fft.getBand(i) * 8);  // get Volume
    line(x, 0, x, fft.getBand(fft.specSize() - i) * 8);
  }

  for (int i = 0; i < in.bufferSize (); i++) {  // top and buttom lines
    float d = (width - in.bufferSize() ) / 2.0;
    point(d + i, width/6.0 + in.left.get(i) * waveH);
    point(d + i, width * 5/6.0 + in.right.get(i) * waveH);
  }

  noFill();
  ellipse(width/2.0, height/2.0, 4 * R, 4 * R);

  float leftR = 0, rightR = 0, t;
  for (int i=0; i<sampleN; i+=4) {  // wave circle
    t = radians(i * 360/sampleN);    // 512 -> 360
    if (in.left.get(i) > 0) leftR = -in.left.get(i) * waveH;  // inner
    if (in.right.get(i) > 0) rightR = in.left.get(i) * waveH * 0.3;  // outer

    pushMatrix();
    translate(width/2.0, height/2.0);
    strokeWeight(1);
    stroke(255);
    line(R * cos(t), R * sin(t), (leftR + R) * cos(t), (leftR + R) * sin(t));
    line(R * cos(t), R * sin(t), (rightR + R) * cos(t), (rightR + R) * sin(t));

    strokeWeight(2);
    point(R * cos(t), R * sin(t));
    popMatrix();
  }
}

void stop() {
  in.close();
  minim.stop();
  super.stop();
}