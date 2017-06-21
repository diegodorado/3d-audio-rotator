if(me.args() < 4){
  cherr <= "Wrong number of arguments\n";
  cherr <= "Try with:\n";
  cherr <= "chuck -s process.ck:input:output:freq:phase\n";
  me.exit();
}

me.arg(0) => string inputFilename;
me.arg(1) => string outputFilename;
me.arg(2) => Std.atof => float rotationFreq;
me.arg(3) => Std.atof => float rotationPhase;

// stereo input sample wav file
SndBuf2 i;
inputFilename => i.read;

// stereo output wav file
WvOut2 w;
outputFilename => w.wavFilename;

now + i.length()/1 => time quit;

Step s[2];
i => blackhole;
s  => w => blackhole;

// left and right input chanel angles
Math.PI/4.0 => float lA;
-Math.PI/4.0 => float rA;
[ 0.707       , 0.707        ] @=> float wCoeff[];
[ Math.cos(lA), Math.cos(rA) ] @=> float xCoeff[];
[ Math.sin(lA), Math.sin(rA) ] @=> float yCoeff[];
[ 0.0         , 0.0          ] @=> float zCoeff[];
// b-format encoding matrix
[ wCoeff, xCoeff, yCoeff, zCoeff] @=> float eM[][];


// Decoding matrix from b-format to stereo
// Pn = W + X * cos(An) + Y * sin(An)
Math.PI/4.0 => float A0; // left
-Math.PI/4.0 => float A1; // right
//  W ,      X      ,      Y      ,  Z  ]
[  1.0, Math.cos(A0), Math.sin(A0), 0.0 ] @=> float leftSpeakerCoeff[];
//  W ,      X      ,      Y      ,  Z  ]
[  1.0, Math.cos(A1), Math.sin(A1), 0.0 ] @=> float rightSpeakerCoeff[];
// stereo decoding matrix
[ leftSpeakerCoeff, rightSpeakerCoeff ] @=> float dM[][];




// connect SinOsc to dac
SinOsc rotation => blackhole;
// set initial frequency (see next section)
rotationFreq => rotation.freq;

while(now < quit){
  // this is where i read the input wav sample by sample
  // and where i can perform the transformation needed
  i.chan(0).last() => float l;
  i.chan(1).last() => float r;

  // encode binaural input as b-format
  // treating left and right channel as being in front at 45 degrees
  eM[0][0] * l + eM[0][1] * r  => float w;
  eM[1][0] * l + eM[1][1] * r  => float x;
  eM[2][0] * l + eM[2][1] * r  => float y;
  eM[3][0] * l + eM[3][1] * r  => float z;


  // rotation in degrees, trasnformed to rads
  rotationPhase + rotation.last()*180.0 => float rot;
  Math.PI/180.0 *=>  rot;
  /*
  ROTATING ABOUT THE Z-AXIS
  -------------------------
  x' = x * cos A - y * sin A
  y' = x * sin A + y * cos A
  */

  x *  Math.cos(rot) - y * Math.sin(rot) => float temp;
  x *  Math.sin(rot) + y * Math.cos(rot) => y;
  temp => x;

  // decodes from b-format to stereo
  dM[0][0] * w + dM[0][1] * x + dM[0][2] * y + dM[0][3] * z  => s[0].next;
  dM[1][0] * w + dM[1][1] * x + dM[1][2] * y + dM[1][3] * z  => s[1].next;

  1::samp => now;
}


w.closeFile();
