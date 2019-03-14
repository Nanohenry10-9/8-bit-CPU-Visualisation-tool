int padding = 15; // Padding of the CPU parts, 15 works best

int cmpWidth = 400; // Layout
int cmpHeight = 200;
int busWidth = 300;

int tx, ty, ttx, tty; // "Data carrier" location and target
boolean mv; // "Data carrier" is moving
int src = 9, des = 9; // Source and destination registers (values > 8 means not in use)
boolean fourbit; // 4-bit "data carrier" mode

PFont font, segment; // Fonts for general text and display
PImage twitter; // Twitter-handle

float speed = 0.5; // Clock frequency
String speedStr = "0.5Hz"; // Clock frequency display string

//int cover; // CPU cover location

int angY, angX; // Cube angles in y- and x-directions (sideways and up/down)

float osx, osy; // Camera location (offset)
float zoom = 2000; // Zoom (default 2000)

boolean rotLeft, rotRight; // Rotation towards left/right
int rotTarget; // Target angle

int rotUpDown;// Target angle up/down
boolean rotDone = true; // Up/down rotation done

String programStrs[] = { // The program titles
  "None", 
  "Counter", 
  "Fibonacci"
};

String uModeStr = "Signed"; // The unsigned/signed display mode setting (string)
int program; // The selected program
boolean uMode; // The unsigned/signed display mode setting (boolean)
boolean pressed; // A key is pressed

long lastTick; // Last clock update in milliseconds since start of application

byte instPhase = 0; // Instruction phase (1, 2, 3, 4 or 5)

boolean PCinc, ALUsub; // PC increment happening, ALU in subtraction mode
int PCincAnim = 0;
boolean ALUfr; // ALU flag update
boolean ALUc, ALUz; // ALU flags (carry, zero
boolean ALUcd, ALUzd; // Displayed ALU flags (carry, zero)

int preMov; // Animation stuffs

int bgOpacity = 255; // Background parts opacity
boolean bgHidden = false; // Hide background when in processor view
String bhHiddenStr = "Show"; // Display string for above option

int cursorX, cursorY; // RAM edit cursor position

boolean halted, reset; // halted (on HLT instruction), R pressed (machine reset)

byte cmpCon[] = { // Component data in order
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000")
};

byte ramCon[] = { // RAM data
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000")
};

byte programs[][] = {{ // Programs
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000")
  }, {
    (byte)unbinary("10010100"), 
    (byte)unbinary("00010000"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("00110001"), 
    (byte)unbinary("00000001"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000")
  }, {
    (byte)unbinary("01111100"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("01111101"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("10011101"), 
    (byte)unbinary("10001110"), 
    (byte)unbinary("00010000"), 
    (byte)unbinary("01011011"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("10011110"), 
    (byte)unbinary("00110101"), 
    (byte)unbinary("01100000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000001"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000")
}};

String instructionStr[] = { // Instruction descriptions
  "No operation", 
  "Add B to A", 
  "Subtract B from A", 
  "Jump to ", 
  "Jump on zero to ", 
  "Jump on carry to ", 
  "Halt", 
  "Load A from ", 
  "Store A to ", 
  "Load B from ", 
  "Store B to ", 
  "Output A"
};

String asmInstructionStr[] = { // Instruction mnemonics (when decoding opcode)
  "NOP", 
  "ADD", 
  "SUB", 
  "JMP", 
  "JZ", 
  "JC", 
  "HLT", 
  "LDA", 
  "STA", 
  "LDB", 
  "STB", 
  "OUT"
};

String getInst(byte b) { // Strings used for RAM data explanation
  switch ((b >> 4) & 0xF) {
    //case 0:
  case 1:
  case 2:
  case 6:
  case 11:
    return instructionStr[(b >> 4) & 0xF];
  case 3:
  case 4:
  case 5:
  case 7:
  case 8:
  case 9:
  case 10:
    return instructionStr[(b >> 4) & 0xF] + String.format("%4s", Integer.toBinaryString(b & 0xF)).replace(' ', '0') + " (" + str(b & 0xF) + ")";
  }
  if (uMode) {
    return "Value " + str(b & 0xFF);
  }
  return "Value " + str(b);
}

void setProgram() { // Switch program
  for (int i = 0; i < 16; i++) {
    ramCon[i] = programs[program][i];
  }
}

void resetRegisters() { // Reset the registers to 0
  for (int i = 0; i < 8; i++) {
    cmpCon[i] = 0;
  }
  instPhase = 0;
}

String getActionStr() { // Get current CU information display text
  if (halted) {
    return "Machine halted, please reset";
  }
  if (speed > 5) {
    return "Running in fast mode";
  }
  if (instPhase == 1) {
    return "Moving address from PC to MAR";
  }
  if (instPhase == 2) {
    return "Moving value from RAM to IR";
  }
  if (instPhase == 3) {
    return "Incrementing Program Counter";
  }
  if (instPhase == 4) {
    return "Executing instruction " + asmInstructionStr[(cmpCon[5] & 0xF0) >> 4] + " (1/2)";
  }
  if (instPhase == 5) {
    return "Executing instruction " + asmInstructionStr[(cmpCon[5] & 0xF0) >> 4] + " (2/2)";
  }
  return "";
}

void mouseWheel(MouseEvent e) { // Keep track of scrolling (for zoom)
  zoom += e.getCount() * 100;
  zoom = constrain(zoom, 1000, 3000);
}

boolean keys[] = new boolean[128];
final int PLUS = 45;
final int MINUS = 47;

void keyPressed() {
  if (keyCode > 127) {
    return;
  }
  keys[keyCode] = true;
}

void keyReleased() {
  if (keyCode > 127) {
    return;
  }
  keys[keyCode] = false;
}

void setup() {
  font = loadFont("Consolas-Bold-32.vlw");
  segment = createFont("7-segment.ttf", 100);
  twitter = loadImage("twitter.png");
  textFont(font);
  textAlign(LEFT);
  noCursor();
  noSmooth();
  for (int i = 0; i < 128; i++) {
    keys[i] = false;
  }
  fullScreen(P3D);
  //size(1920, 1080, P3D);
}

void draw() {
  camera(osx, osy, zoom, osx, osy, 0, 0, 1, 0); // Make sure the view is centered
  background(0); // Initialise frame
  // Apply rotations
  rotateX(radians(angX));
  rotateY(radians(angY));
  // Top side
  rotateX(radians(90));
  translate(0, 0, height / 2 + 100);
  stroke(127, bgOpacity);
  fill(0, bgOpacity);
  translate(0, 0, 16);
  box(cmpWidth * 3, cmpWidth * 3, 15);
  translate(0, 0, -16);
  fill(255, bgOpacity);
  textSize(48);
  rotateZ(radians(angY));
  text("Processor Architecture\n(Von Neumann)", 0, cmpWidth * -1.5 + 400, 32);
  textSize(32);
  translate(0, 0, 32);
  textAlign(LEFT);
  text("The Von Neumann architecture means that the processor and all of its components have access to the same Random-Access Memory (also called the same address space), unlike for example the Harvard architecture, which is more complicated. However, the Von Neumann architecture is still widely used due to its simplicity.", -400, 0, 800, 400);
  translate(0, 0, -32);
  rotateZ(radians(-angY));
  translate(0, 0, -height / 2 - 100);
  // Bottom side
  rotateX(radians(-180));
  stroke(127, bgOpacity);
  fill(0, bgOpacity);
  translate(0, 0, height / 2 + 116);
  box(cmpWidth * 3, cmpWidth * 3, 15);
  rotateZ(radians(-angY));
  noStroke();
  fill(255);
  translate(0, 0, 8);
  ellipse(0, 0, 500, 500);
  beginShape(QUAD);
  texture(twitter);
  vertex(-185, -65, 1, 0, 0);
  vertex(185, -65, 1, 330, 0);
  vertex(185, 65, 1, 330, 110);
  vertex(-185, 65, 1, 0, 110);
  endShape(CLOSE);
  translate(0, 0, -8);
  rotateZ(radians(angY));
  translate(0, 0, -height / 2 - 116);
  rotateX(radians(90));
  // Left (configuration) view
  rotateY(radians(-90));
  translate(0, 0, height / 2 + 300);
  stroke(127, bgOpacity);
  fill(0, bgOpacity);
  translate(0, 0, 16);
  box(cmpWidth * 3, cmpHeight * 4, 30);
  translate(0, 0, -16);
  textSize(36);
  fill(255, bgOpacity);
  textAlign(LEFT);
  text("[U]    Display mode:\n[P]    Executed program:\n[+/-]  Clock frequency:\n[H]    Sides in background:\n\n\n[R]    Reset (CTRL+R to reset RAM)", -420, -20, 32);
  textAlign(LEFT);
  text(uModeStr + "\n" + programStrs[program] + "\n" + speedStr + "\n" + bhHiddenStr, 160, -20, 32);
  textAlign(CENTER);
  textSize(48);
  text("Configuration", 0, -170, 32);
  textSize(32);
  translate(0, 0, -height / 2 - 300);
  // Behind (part explanation) view
  rotateY(radians(-90));
  translate(0, 0, height / 2 + 300);
  stroke(127, bgOpacity);
  fill(31, bgOpacity);
  translate(0, 0, 16);
  box(cmpWidth * 3.5, cmpHeight * 5.5, 30);
  translate(0, 0, -16);
  fill(255, bgOpacity);
  textAlign(LEFT);
  textSize(48);
  text("Name", -cmpWidth * 1.75 + 100, -cmpHeight * 2.75 + 100, 32);
  textSize(28);
  text("Register A (A)\n\n\nRegister B (B)\n\n\nArithmetic Logic Unit (ALU)\n\n\nProgram Counter (PC)\n\n\nOutput Register (OR)\n\n\nInstruction Register (IR)\n\n\nOperand Register (OP)\n\n\nMemory Address Register (MAR)\n\n\nControl Unit (CU)", -cmpWidth * 1.75 + 100, -350, 32);
  textSize(48);
  text("What does it do?", -50, -cmpHeight * 2.75 + 100, 32);
  textSize(28);
  text("Also known as the accumulator, stores\na temporary value\n\nStores another temporary value\n\n\nPerforms all computations and comparison\noperations, the two extra bits are flags\n\nStores current executed address\nof program\n\nThe value in this register will\nbe shown on the display\n\nStores the current instruction\nbeing executed\n\nContains the lower 4 bits of the\nInstruction Register, AKA the operand\n\nTells the RAM what address\nto read/write\n\nControls all the registers and what they do,\nand also shows the currently performed action\n(in red), the clock pulse and the instruction\nphase", -50, -350, 32);
  textAlign(CENTER);
  translate(0, 0, -height / 2 - 300);
  // Right (RAM explanation) view
  rotateY(radians(-90));
  translate(0, 0, height / 2 + 300);
  translate(0, 0, 16);
  stroke(127, bgOpacity);
  fill(0, bgOpacity);
  box(cmpWidth * 3, cmpHeight * 4, 30);
  translate(0, 0, -16);
  translate(0, 30, 32);
  noStroke();
  for (int i = 0; i < 16; i++) {
    fill(255, bgOpacity);
    textSize(28);
    textAlign(RIGHT);
    text(i, -140 - 340, i * 40 - 300 + 10);
    textAlign(CENTER);
    fill(255 - (ramCon[i] & unbinary("10000000")) * 255, 255 - (ramCon[i] & unbinary("10000000")) * 255, 255, bgOpacity);
    ellipse(-140 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("01000000")) * 255, 255 - (ramCon[i] & unbinary("01000000")) * 255, 255, bgOpacity);
    ellipse(-100 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00100000")) * 255, 255 - (ramCon[i] & unbinary("00100000")) * 255, 255, bgOpacity);
    ellipse(-60 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00010000")) * 255, 255 - (ramCon[i] & unbinary("00010000")) * 255, 255, bgOpacity);
    ellipse(-20 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00001000")) * 255, 255 - (ramCon[i] & unbinary("00001000")) * 255, 255, bgOpacity);
    ellipse(20 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00000100")) * 255, 255 - (ramCon[i] & unbinary("00000100")) * 255, 255, bgOpacity);
    ellipse(60 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00000010")) * 255, 255 - (ramCon[i] & unbinary("00000010")) * 255, 255, bgOpacity);
    ellipse(100 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00000001")) * 255, 255 - (ramCon[i] & unbinary("00000001")) * 255, 255, bgOpacity);
    ellipse(140 - 300, i * 40 - 300, 30, 30);
    fill(255, bgOpacity);
    text(String.format("%8s", Integer.toBinaryString(ramCon[i] & 0xFF)).replace(' ', '0'), 0, i * 40 - 290);
    textAlign(LEFT);
    text(getInst(ramCon[i]), -140 + 300, i * 40 - 290);
    textAlign(CENTER);
  }
  noFill();
  stroke(sin(frameCount / 10.0) * 50 + 205, 0, 0, bgOpacity);
  strokeWeight(5);
  ellipse((-140 + cursorX * 40) - 300, cursorY * 40 - 300, 30, 30);
  translate(0, -30, -32);
  fill(255, bgOpacity);
  textSize(48);
  text("Random-Access Memory contents", 0, -330, 32);
  textSize(32);
  translate(0, 0, -height / 2 - 300);
  // Front (main) view
  rotateY(radians(-90));
  translate(-cmpWidth * 1.5 - busWidth / 2, -height / 2, height / 2 + 300);
  drawParts(); // Draw CPU inside function
  updateMove(); // Update "data carrier"
  
  if (reset && halted && angY % 360 == 0 && angX == 0) {
    reset = false;
    halted = false;
  }

  if ((!halted && keys[' '] && speed == 0 && millis() - lastTick > 100 && !mv) || (!halted && speed != 0 && millis() - lastTick >= 1000 / speed)) {
    lastTick = millis();
    update();
  }

  if (preMov != 0) {
    preMov += 3 * max(speed, 1);
    if (preMov > padding * 4) {
      switch (src) {
      case 1:
        if (ALUsub) {
          cmpCon[1] = (byte)(cmpCon[0] - cmpCon[2]);
        } else {
          cmpCon[1] = (byte)(cmpCon[0] + cmpCon[2]);
        }
        ALUcd = ALUc;
        ALUzd = ALUz;
        break;
      case 6:
        cmpCon[6] = (byte)(cmpCon[5] & 0xF);
        break;
      }
      moveData(src, des);
    }
  }

  if (PCincAnim != 0) {
    PCincAnim++;
    if (PCincAnim > 35) {
      PCincAnim = 0;
    }
  }

  if (angY % 360 == 0 && angX == 0 && bgHidden) {
    if (bgOpacity > 0) {
      bgOpacity -= 10;
    }
  } else if (bgOpacity < 255) {
    bgOpacity += 10;
  }

  if (((mousePressed && mouseX > width * (4.0 / 5.0)) || keys[RIGHT]) && !rotLeft && !rotRight) {
    rotLeft = true;
    rotTarget = angY - (90 / 2);
    if (rotTarget < 0) {
      rotTarget += 360;
    }
  }
  if (((mousePressed && mouseX < width * (1.0 / 5.0)) || keys[LEFT]) && !rotRight && !rotLeft) {
    rotRight = true;
    rotTarget = angY + (90 / 2);
    if (rotTarget > 360) {
      rotTarget -= 360;
    }
  }
  if (((mousePressed && mouseY < height * (1.0 / 5.0)) || keys[UP]) && rotUpDown > -90 && rotDone) {
    rotUpDown = angX - 90;
    rotDone = false;
  }
  if (((mousePressed && mouseY > height * (4.0 / 5.0)) || keys[DOWN]) && rotUpDown < 90 && rotDone) {
    rotUpDown = angX + 90;
    rotDone = false;
  }
  if (angY != rotTarget) {
    if (rotLeft) {
      angY -= max(abs(angY - rotTarget) / 8, 1);
      if (angY < 0) {
        angY += 360;
      }
    }
    if (rotRight) {
      angY += max(abs(angY - rotTarget) / 8, 1);
      if (angY > 360) {
        angY -= 360;
      }
    }
  } else {
    rotLeft = false;
    rotRight = false;
  }

  if (!rotDone) {
    float d = (rotUpDown - angX) / 8.0;
    if (d >= 0 && d < 1) {
      d = 1;
    } else if (d <= 0 && d > -1) {
      d = -1;
    }
    angX += d;
    if (abs(angX - rotUpDown) < EPSILON) {
      rotDone = true;
    }
  }

  if (angY == 270 && angX == 0 && keys['D']) {
    if (!pressed) {
      cursorX = (cursorX + 1) & unbinary("00000111");
    }
    pressed = true;
  } else if (angY == 270 && angX == 0 && keys['A']) {
    if (!pressed) {
      cursorX = (cursorX - 1) & unbinary("00000111");
    }
    pressed = true;
  } else if (angY == 270 && angX == 0 && keys['W']) {
    if (!pressed) {
      cursorY = (cursorY - 1) & unbinary("00001111");
    }
    pressed = true;
  } else if (angY == 270 && angX == 0 && keys['S']) {
    if (!pressed) {
      cursorY = (cursorY + 1) & unbinary("00001111");
    }
    pressed = true;
  } else if (angY == 270 && angX == 0 && keys[' ']) {
    if (!pressed) {
      ramCon[cursorY] ^= (1 << (7 - cursorX));
    }
    pressed = true;
  } else if (angY == 90 && angX == 0 && keys['U']) {
    if (!pressed) {
      if (uMode) {
        uModeStr = "Signed";
      } else {
        uModeStr = "Unsigned";
      }
      uMode = !uMode;
    }
    pressed = true;
  } else if (angY == 90 && angX == 0 && keys['P']) {
    if (!pressed) {
      program = (program + 1) % programs.length;
      setProgram();
    }
    pressed = true;
  } else if (angY == 90 && angX == 0 && keys[PLUS]) {
    if (!pressed && speed < 100) {
      if (speed >= 10) {
        speed += 5;
      } else if (speed >= 1) {
        speed += 0.5;
      } else {
        speed += 0.25;
      }
      if (speed != 0) {
        if (speed > 5) {
          speedStr = str(speed) + "Hz (fast mode)";
        } else {
          speedStr = str(speed) + "Hz";
        }
      } else {
        speedStr = "Manual";
      }
    }
    pressed = true;
  } else if (angY == 90 && angX == 0 && keys[MINUS]) {
    if (!pressed && speed > 0) {
      if (speed > 10) {
        speed -= 5;
      } else if (speed > 1) {
        speed -= 0.5;
      } else {
        speed -= 0.25;
      }
      if (speed != 0) {
        if (speed > 5) {
          speedStr = str(speed) + "Hz (fast mode)";
        } else {
          speedStr = str(speed) + "Hz";
        }
      } else {
        speedStr = "Manual";
      }
    }
    pressed = true;
  } else if (angY == 90 && angX == 0 && keys['H']) {
    if (!pressed) {
      bgHidden = !bgHidden;
      if (bgHidden) {
        bhHiddenStr = "Hide";
      } else {
        bhHiddenStr = "Show";
      }
    }
    pressed = true;
  } else if (angY == 90 && angX == 0 && keys['R']) {
    instPhase = 0;
    ALUc = false;
    ALUz = false;
    resetRegisters();
    if (keys[CONTROL]) {
      setProgram();
    }
    halted = true;
    reset = true;
  } else {
    pressed = false;
  }
}

void update() {
  instPhase++;
  if (instPhase > 5) {
    instPhase = 1;
  }
  if (instPhase == 1) {
    moveData(3, 7);
  } else if (instPhase == 2) {
    moveData(8, 5);
  } else if (instPhase == 3) {
    PCinc = true;
    PCincAnim = 1;
    cmpCon[3]++;
    if (cmpCon[3] > 0xF) {
      cmpCon[3] = 0;
    }
  } else {
    PCinc = false;

    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00010000") & 0xF0)) { // ADD (1)
      ALUsub = false;
      ALUfr = true;
    }
    if (instPhase == 5 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00010000") & 0xF0)) { // ADD (2)
      ALUfr = false;
      moveData(1, 0);
    }
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00100000") & 0xF0)) { // SUB (1)
      ALUsub = true;
      ALUfr = true;
    }
    if (instPhase == 5 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00100000") & 0xF0)) { // SUB (2)
      ALUfr = false;
      moveData(1, 0);
    }
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00110000") & 0xF0)) { // JMP
      moveData(6, 3);
    }
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("01000000") & 0xF0) && ALUz) { // JZ (Z = 1)
      moveData(6, 3);
    }
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("01010000") & 0xF0) && ALUc) { // JC (C = 1)
      moveData(6, 3);
    }
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("01100000") & 0xF0)) { // HLT
      halted = true;
    } 
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("01110000") & 0xF0)) { // LDA 1
      moveData(6, 7);
    } 
    if (instPhase == 5 && (cmpCon[5] & 0xF0) == ((byte)unbinary("01110000") & 0xF0)) { // LDA 2
      moveData(8, 0);
    } 
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10010000") & 0xF0)) { // LDB 1
      moveData(6, 7);
    } 
    if (instPhase == 5 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10010000") & 0xF0)) { // LDB 2
      moveData(8, 2);
    } 
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10000000") & 0xF0)) { // STA 1
      moveData(6, 7);
    } 
    if (instPhase == 5 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10000000") & 0xF0)) { // STA 2
      moveData(0, 8);
    } 
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10100000") & 0xF0)) { // STB 1
      moveData(6, 7);
    } 
    if (instPhase == 5 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10100000") & 0xF0)) { // STB 2
      moveData(2, 8);
    } else if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("10110000") & 0xF0)) { // OUT
      moveData(0, 4);
    }
  }
  if (speed > 5) {
    if (ALUsub) {
      cmpCon[1] = (byte)(cmpCon[0] - cmpCon[2]);
    } else {
      cmpCon[1] = (byte)(cmpCon[0] + cmpCon[2]);
    }
  }
  if (ALUfr) {
    if (cmpCon[1] == 0) {
      ALUz = true;
    } else {
      ALUz = false;
    }
    if ((ALUsub && int(cmpCon[0] & 0xFF) - int(cmpCon[2] & 0xFF) < 0) || (!ALUsub && int(cmpCon[0] & 0xFF) + int(cmpCon[2] & 0xFF) > 255)) {
      ALUc = true;
    } else {
      ALUc = false;
    }
  }
  if (speed > 5) {
    cmpCon[6] = (byte)(cmpCon[5] & 0xF);
  }
}

void moveData(int s, int d) { // Set up "data carrier"
  if (mv && preMov == 0) {
    if (des == 8) {
      ramCon[cmpCon[7] & 0xF] = cmpCon[src];
    } else if (src == 8) {
      cmpCon[des] = ramCon[cmpCon[7] & 0xF];
    } else {
      cmpCon[des] = cmpCon[src];
    }
  }
  if (s == d) {
    return;
  }
  src = s;
  des = d;
  if (s == 1 && speed <= 5) {
    if (preMov == 0) {
      preMov = 1;
      mv = true;
      return;
    } else {
      preMov = 0;
    }
  }
  if (s == 6 && speed <= 5) {
    if (preMov == 0) {
      preMov = 1;
      mv = true;
      return;
    } else {
      preMov = 0;
    }
  }
  if (s == 8) {
    tx = cmpWidth  * 2 + busWidth + cmpWidth / 2;
    ty = cmpHeight * 4 + padding + 25;
  } else {
    if (s > 3) {
      tx = cmpWidth + busWidth + cmpWidth / 2;
    } else {
      tx = cmpWidth / 2;
    }
    ty = cmpHeight * (s % 4) + cmpHeight / 2;
  }
  if (d == 8) {
    ttx = cmpWidth * 2 + busWidth + cmpWidth / 2;
    tty = cmpHeight * 4 + padding + 25;
  } else {
    if (d > 3) {
      ttx = cmpWidth + busWidth + cmpWidth / 2;
    } else {
      ttx = cmpWidth / 2;
    }
    tty = cmpHeight * (d % 4) + cmpHeight / 2;
  }
  fourbit = (src == 3 || src == 6 || src == 7);
  /*if (src == 1) {
   ALUopAnim = 1;
   }*/
  if (speed > 5) {
    if (d == 8) {
      ramCon[cmpCon[7] & 0xF] = cmpCon[s];
    } else if (s == 8) {
      cmpCon[d] = ramCon[cmpCon[7] & 0xF];
    } else {
      cmpCon[d] = cmpCon[s];
    }
    return;
  }
  mv = true;
}

void updateMove() { // Update "data carrier"
  if (preMov != 0) {
    return;
  }
  int centerx = cmpWidth + busWidth / 2;
  float tmp = speed;
  if (speed == 0) {
    speed = 0.2;
  }
  if (mv) {
    if (ty != tty) {
      if (tx != centerx) {
        tx += (centerx - tx) / abs(centerx - tx) * 30 * speed;
        if (abs(tx - centerx) < 30 * speed) {
          tx = centerx;
        }
      } else {
        ty += (tty - ty) / abs(tty - ty) * 30 * speed;
        if (abs(ty - tty) < 30 * speed) {
          ty = tty;
        }
      }
    } else {
      tx += (ttx - tx) / abs(ttx - tx) * 30 * speed;
      if (abs(tx - ttx) < 30 * speed) {
        tx = ttx;
      }
    }
    if (tx == ttx && ty == tty) {
      mv = false;
      if (des == 8) {
        ramCon[cmpCon[7] & 0xF] = cmpCon[src];
      } else if (src == 8) {
        cmpCon[des] = ramCon[cmpCon[7] & 0xF];
      } else {
        cmpCon[des] = cmpCon[src];
      }
      des = 9;
      src = 9;
    }
  }
  /*if (ALUopAnim != 0) {
   ALUopAnim++;
   if (ALUopAnim >= cmpHeight) {
   ALUopAnim = 0;
   }
   }
   fill(255, 0, 0);
   textSize(64);
   text(ALUopAnim, -300, 0);*/
  speed = tmp;
}

void drawParts() { // Draw the processor view (not in draw() because too long)
  translate(0, 0, 1);
  // Upper-upper left vertical line
  if ((src == 0 || des == 0) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  // Upper-lower left vertical line
  if ((src <= 1 || des <= 1) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  // Lower-upper left vertical line
  if ((src <= 2 || des <= 2) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  // Lower-lower left vertical line
  if (((src <= 3 || des <= 3) && !halted) || PCinc) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 + padding + 100);

  // Upper-upper left horizontal line
  if ((src == 0 || des == 0) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  // Upper-lower left horizontal line
  if ((src == 1 || des == 1) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  // Lower-upper left horizontal line
  if ((src == 2 || des == 2) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  // Lower-lower left horizontal line
  if (((src == 3 || des == 3) && !halted) || PCinc) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);

  if ((src == 4 || des == 4) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (((src <= 5 & src >= 4) || (des <= 5 && des >= 4)) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (((src <= 6 & src >= 4) || (des <= 6 && des >= 4)) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (((src <= 7 & src >= 4) || (des <= 7 && des >= 4)) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 + padding + 100);

  if ((src == 4 || des == 4) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if ((src == 5 || des == 5) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if ((src == 6 || des == 6) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if ((src == 7 || des == 7) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);

  if ((src == 8 || des == 8) && !halted) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + (cmpWidth + busWidth / 2 - padding), (cmpHeight * 4 + padding + 50) + ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2, cmpWidth * 2 + busWidth + cmpWidth / 2 + 50 - (cmpWidth / 2 - padding), (cmpHeight * 4 + padding + 50) + ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2);

  translate(0, 0, 2);

  // Green bus

  noStroke();
  fill(0, 127, 0, 255);
  rect(cmpWidth + busWidth / 2 - 25, cmpHeight / 2 - 25, 50, (cmpHeight * 4 + padding) - (cmpHeight / 2 - 25));
  rect(cmpWidth - padding, cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth - padding, cmpHeight + cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth - padding, cmpHeight * 2 + cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth - padding, cmpHeight * 3 + cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth + busWidth / 2 - 25, cmpHeight * 4 + padding, busWidth / 2 + cmpWidth + padding * 2 + 100, 50);
  translate(0, 0, -3);

  // CPU case

  stroke(0);
  strokeWeight(2);
  fill(127);
  beginShape(QUAD_STRIP);
  vertex(-25, -25, -20);
  vertex(-25, -25, 40);
  vertex(cmpWidth * 2 + busWidth + 25, -25, -20);
  vertex(cmpWidth * 2 + busWidth + 25, -25, 40);
  vertex(cmpWidth * 2 + busWidth + 25, height + 25, -20);
  vertex(cmpWidth * 2 + busWidth + 25, height + 25, 40);
  vertex(-25, height + 25, -20);
  vertex(-25, height + 25, 40);
  vertex(-25, -25, -20);
  vertex(-25, -25, 40);
  endShape(CLOSE);

  /*beginShape(QUAD);
   vertex(-25, -25, -20);
   vertex(cmpWidth * 2 + busWidth + 25, -25, -20);
   vertex(cmpWidth * 2 + busWidth + 25, height + 25, -20);
   vertex(-25, height + 25, -20);
   endShape(CLOSE);*/

  /*fill(127); // CPU cover
   beginShape();
   vertex(-25 - cover, -25, 40);
   vertex(cmpWidth * 2 + busWidth + 25 - cover, -25, 40);
   vertex(cmpWidth * 2 + busWidth + 25 - cover, height + 25, 40);
   vertex(-25 - cover, height + 25, 40);
   endShape(CLOSE);*/

  // Components: A>ALU<B PC OR IR>OP MAR
  // < or > = hardwiring

  stroke(0);
  strokeWeight(2);

  if (mv && (src == 0 || des == 0) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth / 2, cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[0] & unbinary("10000000")) * 255, 255 - (cmpCon[0] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("01000000")) * 255, 255 - (cmpCon[0] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("00100000")) * 255, 255 - (cmpCon[0] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("00010000")) * 255, 255 - (cmpCon[0] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("00001000")) * 255, 255 - (cmpCon[0] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("00000100")) * 255, 255 - (cmpCon[0] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("00000010")) * 255, 255 - (cmpCon[0] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[0] & unbinary("00000001")) * 255, 255 - (cmpCon[0] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(cmpWidth / -2, cmpHeight / -2, -16);
  fill(255);
  text("Register A", cmpWidth / 2, cmpHeight / 2 - 30, 32);

  if (src == 1 && preMov > 0) {
    fill(0, 0, 160);
    translate(cmpWidth / 2, cmpHeight - padding * 2 + preMov, 15);
    box(100, padding * 2, 20);
    translate(cmpWidth / -2, -cmpHeight + padding * 2 - preMov, -15);
  }

  if (mv && (src == 1 || des == 1) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth / 2, cmpHeight + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - int(ALUcd) * 255, 255 - int(ALUcd) * 255, 255);
  ellipse(-165 + 15, 0, 20, 20);
  fill(255 - int(ALUzd) * 255, 255 - int(ALUzd) * 255, 255);
  ellipse(-135 + 15, 0, 20, 20);

  fill(255 - (cmpCon[1] & unbinary("10000000")) * 255, 255 - (cmpCon[1] & unbinary("10000000")) * 255, 255);
  ellipse(-75 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("01000000")) * 255, 255 - (cmpCon[1] & unbinary("01000000")) * 255, 255);
  ellipse(-45 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00100000")) * 255, 255 - (cmpCon[1] & unbinary("00100000")) * 255, 255);
  ellipse(-15 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00010000")) * 255, 255 - (cmpCon[1] & unbinary("00010000")) * 255, 255);
  ellipse(15 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00001000")) * 255, 255 - (cmpCon[1] & unbinary("00001000")) * 255, 255);
  ellipse(45 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00000100")) * 255, 255 - (cmpCon[1] & unbinary("00000100")) * 255, 255);
  ellipse(75 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00000010")) * 255, 255 - (cmpCon[1] & unbinary("00000010")) * 255, 255);
  ellipse(105 + 15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00000001")) * 255, 255 - (cmpCon[1] & unbinary("00000001")) * 255, 255);
  ellipse(135 + 15, 0, 20, 20);
  translate(0, -30, -16);
  textSize(24);
  fill(255);
  text("C", -165 + 25, 15, 32);
  text("Z", -135 + 25, 15, 32);
  translate(cmpWidth / -2, -cmpHeight + cmpHeight / -2, -16);
  text("Arithmetic Logic Unit", cmpWidth / 2, cmpHeight + cmpHeight / 2 - 30, 32);
  textSize(32);

  if (src == 1 && preMov > 0) {
    fill(0, 0, 160);
    translate(cmpWidth / 2, cmpHeight * 2 + padding * 2 - preMov, 15);
    box(100, padding * 2, 20);
    translate(cmpWidth / -2, -cmpHeight * 2 - padding * 2 + preMov, -15);
  }

  if (mv && (src == 2 || des == 2) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth / 2, cmpHeight * 2 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[2] & unbinary("10000000")) * 255, 255 - (cmpCon[2] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("01000000")) * 255, 255 - (cmpCon[2] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("00100000")) * 255, 255 - (cmpCon[2] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("00010000")) * 255, 255 - (cmpCon[2] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("00001000")) * 255, 255 - (cmpCon[2] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("00000100")) * 255, 255 - (cmpCon[2] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("00000010")) * 255, 255 - (cmpCon[2] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[2] & unbinary("00000001")) * 255, 255 - (cmpCon[2] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(cmpWidth / -2, -cmpHeight * 2 + cmpHeight / -2, -16);
  fill(255);
  text("Register B", cmpWidth / 2, cmpHeight * 2 + cmpHeight / 2 - 30, 32);

  if (((mv && (src == 3 || des == 3)) || PCinc) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[3] & unbinary("00001000")) * 255, 255 - (cmpCon[3] & unbinary("00001000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00000100")) * 255, 255 - (cmpCon[3] & unbinary("00000100")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00000010")) * 255, 255 - (cmpCon[3] & unbinary("00000010")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00000001")) * 255, 255 - (cmpCon[3] & unbinary("00000001")) * 255, 255);
  ellipse(45, 0, 20, 20);
  if (PCincAnim != 0 && speed <= 5) {
    fill(255, 255 - 255 * (PCincAnim / 30.0));
    textSize(28);
    text("+1", 80, 20 - PCincAnim);
  }
  translate(0, -30, -16);
  translate(cmpWidth / -2, -cmpHeight * 3 + cmpHeight / -2, -16);
  fill(255);
  textSize(32);
  text("Program Counter", cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2 - 30, 32);

  // Display

  fill(127);
  translate(cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight, 16);
  box(cmpWidth - padding * 2, cmpHeight * 2 - padding * 2, 30);
  fill(31, 0, 0);
  translate(0, 0, 16);
  rect(-150, -150, 300, 300);
  translate(0, 0, -16);
  translate(-cmpWidth * 2 - busWidth - cmpWidth / 2 - 50, -cmpHeight, -16);
  textSize(100);
  fill(255, 0, 0);
  textFont(segment);
  String dispStr = str(cmpCon[4]);
  if (uMode) {
    dispStr = str(cmpCon[4] & 0xFF);
  }
  text(dispStr, cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight + 30, 33);
  textFont(font);
  textSize(32);

  if (mv && (src == 4 || des == 4) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[4] & unbinary("10000000")) * 255, 255 - (cmpCon[4] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("01000000")) * 255, 255 - (cmpCon[4] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("00100000")) * 255, 255 - (cmpCon[4] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("00010000")) * 255, 255 - (cmpCon[4] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("00001000")) * 255, 255 - (cmpCon[4] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("00000100")) * 255, 255 - (cmpCon[4] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("00000010")) * 255, 255 - (cmpCon[4] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[4] & unbinary("00000001")) * 255, 255 - (cmpCon[4] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(-cmpWidth - busWidth - cmpWidth / 2, cmpHeight / -2, -16);
  fill(255);
  text("Output Register", cmpWidth + busWidth + cmpWidth / 2, cmpHeight / 2 - 30, 32);

  fill(60);
  translate(cmpWidth * 2 + busWidth + padding * 2, cmpHeight / 2, 16);
  box(padding * 6, 100, 10);
  translate(-cmpWidth * 2 - busWidth - padding * 2, -cmpHeight / 2, -16);

  if (mv && (src == 5 || des == 5) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[5] & unbinary("10000000")) * 255, 255 - (cmpCon[5] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("01000000")) * 255, 255 - (cmpCon[5] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("00100000")) * 255, 255 - (cmpCon[5] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("00010000")) * 255, 255 - (cmpCon[5] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("00001000")) * 255, 255 - (cmpCon[5] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("00000100")) * 255, 255 - (cmpCon[5] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("00000010")) * 255, 255 - (cmpCon[5] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[5] & unbinary("00000001")) * 255, 255 - (cmpCon[5] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight + cmpHeight / -2, -16);
  fill(255);
  textSize(28);
  text("Instruction Register", cmpWidth + busWidth + cmpWidth / 2, cmpHeight + cmpHeight / 2 - 30, 32);
  textSize(32);

  if (src == 6 && preMov > 0) {
    fill(0, 0, 160);
    translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 2 - padding * 2 + preMov, 15);
    box(100, padding * 2, 20);
    translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight * 2 + padding * 2 - preMov, -15);
  }

  if (mv && (src == 6 || des == 6) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 2 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[6] & unbinary("00001000")) * 255, 255 - (cmpCon[6] & unbinary("00001000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00000100")) * 255, 255 - (cmpCon[6] & unbinary("00000100")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00000010")) * 255, 255 - (cmpCon[6] & unbinary("00000010")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00000001")) * 255, 255 - (cmpCon[6] & unbinary("00000001")) * 255, 255);
  ellipse(45, 0, 20, 20);
  translate(0, -30, -16);
  translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight * 2 + cmpHeight / -2, -16);
  fill(255);
  text("Operand Register", cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 2 + cmpHeight / 2 - 30, 32);

  if (mv && (src == 7 || des == 7) && speed <= 5) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[7] & unbinary("00001000")) * 255, 255 - (cmpCon[7] & unbinary("00001000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00000100")) * 255, 255 - (cmpCon[7] & unbinary("00000100")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00000010")) * 255, 255 - (cmpCon[7] & unbinary("00000010")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00000001")) * 255, 255 - (cmpCon[7] & unbinary("00000001")) * 255, 255);
  ellipse(45, 0, 20, 20);
  translate(0, -30, -16);
  translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight * 3 + cmpHeight / -2, -16);
  fill(255);
  textSize(24);
  text("Memory Address Register", cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2 - 30, 32);
  textSize(32);

  // RAM

  fill(127);
  translate(cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight * 2 + (height - cmpHeight * 2) / 2, 16);
  box(cmpWidth - padding * 2, (height - cmpHeight * 2) - padding * 2, 30);
  translate(0, 30, 16);
  for (int i = 0; i < 16; i++) {
    if (cmpCon[7] == i) {
      stroke(0, 0, 255);
      strokeWeight(5);
      noFill();
      rect(-120, i * 30 - 235, 240, 30);
      line(-120, i * 30 - 220, -150, i * 30 - 220);
      line(-150, i * 30 - 220, -150, (cmpHeight * 3 + cmpHeight / 2) - ((cmpHeight * 2 + (height - cmpHeight * 2) / 2) + 30));
      line(-150, (cmpHeight * 3 + cmpHeight / 2) - ((cmpHeight * 2 + (height - cmpHeight * 2) / 2) + 30), (((cmpWidth + busWidth + cmpWidth / 2) + (cmpWidth / 2 - padding))) - (cmpWidth * 2 + busWidth + cmpWidth / 2 + 50), (cmpHeight * 3 + cmpHeight / 2) - ((cmpHeight * 2 + (height - cmpHeight * 2) / 2) + 30));
    }
    stroke(0);
    strokeWeight(2);
    translate(0, 0, 1);
    fill(255 - (ramCon[i] & unbinary("10000000")) * 255, 255 - (ramCon[i] & unbinary("10000000")) * 255, 255);
    ellipse(-105, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("01000000")) * 255, 255 - (ramCon[i] & unbinary("01000000")) * 255, 255);
    ellipse(-75, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("00100000")) * 255, 255 - (ramCon[i] & unbinary("00100000")) * 255, 255);
    ellipse(-45, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("00010000")) * 255, 255 - (ramCon[i] & unbinary("00010000")) * 255, 255);
    ellipse(-15, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("00001000")) * 255, 255 - (ramCon[i] & unbinary("00001000")) * 255, 255);
    ellipse(15, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("00000100")) * 255, 255 - (ramCon[i] & unbinary("00000100")) * 255, 255);
    ellipse(45, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("00000010")) * 255, 255 - (ramCon[i] & unbinary("00000010")) * 255, 255);
    ellipse(75, i * 30 - 220, 20, 20);
    fill(255 - (ramCon[i] & unbinary("00000001")) * 255, 255 - (ramCon[i] & unbinary("00000001")) * 255, 255);
    ellipse(105, i * 30 - 220, 20, 20);
    translate(0, 0, -1);
  }
  translate(0, -30, -16);
  translate(-cmpWidth * 2 - busWidth - cmpWidth / 2 - 50, -cmpHeight * 2 + (height - cmpHeight * 2) / -2, -16);
  fill(255);
  textSize(24);
  text("Random-Access Memory", cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight * 2 + cmpHeight / 2 - 30, 32);
  textSize(32);

  // CU

  fill(85);
  translate(cmpWidth + busWidth / 2, (cmpHeight * 4 + padding + 50) + ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2, 16);
  box(cmpWidth * 2 + busWidth - padding * 2, (height + 25) - (cmpHeight * 4 + padding + 50) - padding * 2 - 50, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - int(!halted && ((speed == 0 && keyPressed && key == ' ') || (speed != 0 && millis() - lastTick < 1000 / speed / 2))) * 255, 255 - int(!halted && ((speed == 0 && keyPressed && key == ' ') || (speed != 0 && millis() - lastTick < 1000 / speed / 2))) * 255, 255);
  ellipse((cmpWidth / 2 + busWidth / 4 - padding / 2 + 50) - 105, 0, 20, 20);
  fill(255 - int(instPhase == 1) * 255, 255 - int(instPhase == 1) * 255, 255);
  ellipse((cmpWidth / 2 + busWidth / 4 - padding / 2 + 50) - 15, 0, 20, 20);
  fill(255 - int(instPhase == 2) * 255, 255 - int(instPhase == 2) * 255, 255);
  ellipse((cmpWidth / 2 + busWidth / 4 - padding / 2 + 50) + 15, 0, 20, 20);
  fill(255 - int(instPhase == 3) * 255, 255 - int(instPhase == 3) * 255, 255);
  ellipse((cmpWidth / 2 + busWidth / 4 - padding / 2 + 50) + 45, 0, 20, 20);
  fill(255 - int(instPhase == 4) * 255, 255 - int(instPhase == 4) * 255, 255);
  ellipse((cmpWidth / 2 + busWidth / 4 - padding / 2 + 50) + 75, 0, 20, 20);
  fill(255 - int(instPhase == 5) * 255, 255 - int(instPhase == 5) * 255, 255);
  ellipse((cmpWidth / 2 + busWidth / 4 - padding / 2 + 50) + 105, 0, 20, 20);
  translate(0, -30, -16);
  fill(255);
  text("Control Unit", cmpWidth / 2 + busWidth / 4 - padding / 2 + 50, -30, 16);
  translate(cmpWidth / -2 + busWidth / -4 - padding / -2, 0, 16);
  fill(31, 0, 0);
  rect(-200, -50, 600, 100);
  fill(255, 0, 0);
  textSize(32);
  text(getActionStr(), 100, 12);
  translate(cmpWidth / 2 + busWidth / 4 - padding / 2, 0, -16);
  translate(-cmpWidth - busWidth / 2, -(cmpHeight * 4 + padding + 50) - ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2, -16);

  // The "data carrier"

  if (mv && preMov == 0) {
    fill(127, 127, 255);
    translate(tx, ty, 11);
    box(200, 50, 10);

    translate(0, 0, 6);
    stroke(0);
    byte data;
    if (src == 8) {
      data = ramCon[cmpCon[7]];
    } else {
      data = cmpCon[src];
    }
    if (!fourbit) {
      fill(255 - (data & unbinary("10000000")) * 255, 255 - (data & unbinary("10000000"))* 255, 255);
      ellipse(-70, 0, 15, 15);
      fill(255 - (data & unbinary("01000000")) * 255, 255 - (data & unbinary("01000000")) * 255, 255);
      ellipse(-50, 0, 15, 15);
      fill(255 - (data & unbinary("00100000")) * 255, 255 - (data & unbinary("00100000")) * 255, 255);
      ellipse(-30, 0, 15, 15);
      fill(255 - (data & unbinary("00010000")) * 255, 255 - (data & unbinary("00010000")) * 255, 255);
      ellipse(-10, 0, 15, 15);
    }
    fill(255 - (data & unbinary("00001000")) * 255, 255 - (data & unbinary("00001000")) * 255, 255);
    ellipse(10 - int(fourbit) * 40, 0, 15, 15);
    fill(255 - (data & unbinary("00000100")) * 255, 255 - (data & unbinary("00000100")) * 255, 255);
    ellipse(30 - int(fourbit) * 40, 0, 15, 15);
    fill(255 - (data & unbinary("00000010")) * 255, 255 - (data & unbinary("00000010")) * 255, 255);
    ellipse(50 - int(fourbit) * 40, 0, 15, 15);
    fill(255 - (data & unbinary("00000001")) * 255, 255 - (data & unbinary("00000001")) * 255, 255);
    ellipse(70 - int(fourbit) * 40, 0, 15, 15);
    translate(0, 0, -6);

    translate(-tx, -ty, -11);
  }
}
