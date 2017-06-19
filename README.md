# 3D Audio Rotator

A chuck script to rotate binaural audio files through ambisonics equations.

The aim is to generate several outputs with ambisonics rotations applied out of a single binaural input.

Note: This firts version performs rotations around the Z-axis only.

## Encoding Equations
( taken from: https://www.york.ac.uk/inst/mustech/3d_audio/ambis2.htm)

The position of a sound within a three dimensional soundfield is encoded in the four signals which make up the B format thus;

```

X = cosA.cosB (front-back)
Y = sinA.cosB (left-right)
Z = sinB (up-down)
W = 0.707 (pressure signal)

```

where A is the anti-clockwise angle from centre front and B is the elevation.

Since we are taking a binaural stereo wav file as input, we'll considere both channels as "virtual speakers" in front and at 45 degrees each other without elevation.
There might be better ways to obtain a b-format out of a binaural stereo input, and we know we are loosing data this way.
Anyway, these equations gets simplified as:

```

X = cosA (front-back)
Y = sinA (left-right)
Z = 0 (up-down)
W = 0.707 (pressure signal)

```


## Rotating around Z-axis

( taken from https://github.com/greekgoddj/ambisonic-lib/blob/master/source/AmbisonicProcessor.cpp )

Rotations can be performed in First Order Ambisonics by constructing a 3x3 matrix for each rotation angle ( roll, pitch, yaw)

![alt text](roll-pitch-yaw.png)


We will start with yaw angle only, then only `x` and `y` will be afected.


```

x' = x * cos A - y * sin A  
y' = x * sin A + y * cos A

```


## Decoding Equations
( taken from https://en.wikipedia.org/wiki/Ambisonic_decoding)

For the simplest (two dimensional) case (no height information),
and spacing the loudspeakers equally in a circle, we derive the
loudspeaker signals from the B-format W, X and Y channels:

```

  Pn = W + X * cos(An) + Y * sin(An)

```


where `An` is the angle of the speaker under consideration.

The coordinate system used in Ambisonics follows the right hand rule
convention with positive `X` pointing forwards, positive `Y` pointing to the left and positive `Z` pointing upwards. Horizontal angles run anticlockwise from due front and vertical angles are positive above the horizontal, negative below.
