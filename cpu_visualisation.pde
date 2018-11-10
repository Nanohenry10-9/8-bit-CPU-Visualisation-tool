final int padding = 15; // 15!

int cmpWidth = 400;
int cmpHeight = 200;
int busWidth = 300;

int tx, ty, ttx, tty;
boolean mv;
int src, des;

PFont font, segment;

float angley;

float speed = 1; // <5 is good
String speedStr = "1.0";

int animator, cover;

int rot, urot;

float osx, osy;
float zoom = 2000;

boolean rotl, rotr;
int rott;

boolean rotu, urotd;

String programStrs[] = {
  "none", 
  "addition", 
  "fibonacci"
};

String umodeStr = "signed";
int program;
boolean umode;
boolean pressed;

long lastTick;

byte instPhase = 0;

boolean PCinc, ALUsub;

byte cmpCon[] = {
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000"), 
  (byte)unbinary("00000000")
};

byte ramCon[] = {
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

byte programs[][] = {{
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
    (byte)unbinary("00000001"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000001"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 

    (byte)unbinary("00010000"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("00110000"), 
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
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 

    (byte)unbinary("01111010"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("01111011"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("10011011"), 
    (byte)unbinary("10001100"), 
    (byte)unbinary("00010000"), 
    (byte)unbinary("10110000"), 
    (byte)unbinary("10011100"), 
    (byte)unbinary("00110101"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000001"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000"), 
    (byte)unbinary("00000000")
}};

String instructionStr[] = {
  "ERROR", 
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

String rawInstructionStr[] = {
  "NONE", 
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

String getInst(byte b) {
  switch ((b >> 4) & 0xF) {
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
    if ((b & 0xF) == 0) {
      return instructionStr[(b >> 4) & 0xF] + String.format("%4s", Integer.toBinaryString(b & 0xF)).replace(' ', '0') + " (start)";
    }
    if ((b & 0xF) == 15) {
      return instructionStr[(b >> 4) & 0xF] + String.format("%4s", Integer.toBinaryString(b & 0xF)).replace(' ', '0') + " (end)";
    }
    return instructionStr[(b >> 4) & 0xF] + String.format("%4s", Integer.toBinaryString(b & 0xF)).replace(' ', '0') + " (" + str(b & 0xF) + ")";
  }
  if (umode) {
    return "Value " + str(b & 0xFF);
  }
  return "Value " + str(b);
}

void setProgram() {
  for (int i = 0; i < 8; i++) {
    cmpCon[i] = programs[program][i];
  }
  for (int i = 0; i < 16; i++) {
    ramCon[i] = programs[program][i + 8];
  }
}

String getActionStr() {
  if (instPhase == 1) {
    return "Fetching instruction (1/2)";
  }
  if (instPhase == 2) {
    return "Fetching instruction (2/2)";
  }
  if (instPhase == 3) {
    return "Incrementing PC";
  }
  if (instPhase == 4) {
    return "Executing instruction " + rawInstructionStr[(cmpCon[5] & 0xF0) >> 4] + " (1/2)";
  }
  if (instPhase == 5) {
    return "Executing instruction " + rawInstructionStr[(cmpCon[5] & 0xF0) >> 4] + " (2/2)";
  }
  return "";
}

void mouseWheel(MouseEvent e) {
  zoom += e.getCount() * 100;
  zoom = constrain(zoom, 1000, 3000);
}

void setup() {
  fullScreen(P3D);
  font = loadFont("Consolas-Bold-32.vlw");
  segment = createFont("7-segment.ttf", 100);
  textFont(font);
  textAlign(CENTER);
  frameRate(120);
  noSmooth();
  //hint(ENABLE_DEPTH_SORT);
}

void draw() {
  background(0);
  rotateX(radians(urot));
  rotateY(radians(rot));
  rotateX(radians(90));
  translate(0, 0, height / 2 + 100);
  stroke(127);
  fill(0);
  translate(0, 0, 16);
  box(cmpWidth * 3, cmpWidth * 3, 15);
  translate(0, 0, -16);
  fill(255);
  textSize(48);
  rotateZ(radians(rot));
  text("Processor Architecture\n(Von Neumann)", 0, cmpWidth * -1.5 + 400, 32);
  textSize(32);
  translate(0, 0, 32);
  text("The Von Neumann architecture means that the processor and all of it's components have access to the same Random Accesss Memory (also called the same address space). Another option (though not the only one) would be the Harvard architecture, with separate memory locations and data buses for the instructions and data. This would make it faster, but also a lot more error-prone.", -400, 0, 800, 400);
  translate(0, 0, -32);
  rotateZ(radians(-rot));
  translate(0, 0, -height / 2 - 100);
  rotateX(radians(-180));
  stroke(127);
  fill(0);
  translate(0, 0, height / 2 + 116);
  box(cmpWidth * 3, cmpWidth * 3, 15);
  translate(0, 0, -height / 2 - 116);
  rotateX(radians(90));
  rotateY(radians(-90));
  translate(0, 0, height / 2 + 300);
  stroke(127);
  fill(0);
  translate(0, 0, 16);
  box(cmpWidth * 3, cmpHeight * 4, 30);
  translate(0, 0, -16);
  textSize(32);
  fill(255);
  text("[U] toggle unsigned/signed display mode: " + umodeStr + "\n[P] select executed program: " + programStrs[program] + "\n[+/-] increase/decrease clock speed: " + speedStr + "\n[R] reset", 0, 0, 32);
  textSize(48);
  text("Configuration", 0, -330, 32);
  textSize(32);
  translate(0, 0, -height / 2 - 300);
  rotateY(radians(-90));

  translate(0, 0, height / 2 + 300);
  stroke(127);
  fill(31);
  translate(0, 0, 16);
  box(cmpWidth * 3.5, cmpHeight * 5.5, 30);
  translate(0, 0, -16);
  fill(255);
  textAlign(LEFT);
  textSize(48);
  text("Name", -cmpWidth * 1.75 + 100, -cmpHeight * 2.75 + 100, 32);
  textSize(28);
  text("Register A (A)\n\n\nRegister B (B)\n\n\nArithmetic Logic Unit (ALU)\n\n\nProgram Counter (PC)\n\n\nOutput Register (OR)\n\n\nInstruction Register (IR)\n\n\nOperand Register (OP)\n\n\nMemory Address Register (MAR)\n\n\nControl Unit (CU)", -cmpWidth * 1.75 + 100, -350, 32);
  textSize(48);
  text("What does it do?", -50, -cmpHeight * 2.75 + 100, 32);
  textSize(28);
  text("Also known as the accumulator, stores\na temporary value\n\nStores another temporary value\n\n\nPerforms all computations\nand comparison operations\n\nStores current executed address\nof program\n\nThe value in this register will\nbe shown on the display\n\nStores the current instruction\nbeing executed\n\nContains the lower 4 bits of the\nInstruction Register, AKA the operand\n\nTells the RAM what address\nto read/write\n\nControls all the registers and what they do,\nand also shows the currently performed action\n(in red), the clock pulse and the instruction\nphase", -50, -350, 32);
  textAlign(CENTER);
  translate(0, 0, -height / 2 - 300);
  rotateY(radians(-90));

  translate(0, 0, height / 2 + 300);

  translate(0, 0, 16);
  stroke(127);
  fill(0);
  box(cmpWidth * 3, cmpHeight * 4, 30);
  translate(0, 0, -16);
  translate(0, 30, 32);
  stroke(0);
  for (int i = 0; i < 16; i++) {
    fill(255 - (ramCon[i] & unbinary("10000000")) * 255, 255 - (ramCon[i] & unbinary("10000000")) * 255, 255);
    ellipse(-140 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("01000000")) * 255, 255 - (ramCon[i] & unbinary("01000000")) * 255, 255);
    ellipse(-100 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00100000")) * 255, 255 - (ramCon[i] & unbinary("00100000")) * 255, 255);
    ellipse(-60 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00010000")) * 255, 255 - (ramCon[i] & unbinary("00010000")) * 255, 255);
    ellipse(-20 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00001000")) * 255, 255 - (ramCon[i] & unbinary("00001000")) * 255, 255);
    ellipse(20 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00000100")) * 255, 255 - (ramCon[i] & unbinary("00000100")) * 255, 255);
    ellipse(60 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00000010")) * 255, 255 - (ramCon[i] & unbinary("00000010")) * 255, 255);
    ellipse(100 - 300, i * 40 - 300, 30, 30);
    fill(255 - (ramCon[i] & unbinary("00000001")) * 255, 255 - (ramCon[i] & unbinary("00000001")) * 255, 255);
    ellipse(140 - 300, i * 40 - 300, 30, 30);
    fill(255);
    text(String.format("%8s", Integer.toBinaryString(ramCon[i] & 0xFF)).replace(' ', '0'), 0, i * 40 - 290);
    textAlign(LEFT);
    text(getInst(ramCon[i]), -140 + 300, i * 40 - 290);
    textAlign(CENTER);
  }
  translate(0, -30, -32);
  fill(255);
  textSize(48);
  text("Random Access Memory contents", 0, -330, 32);
  textSize(32);

  translate(0, 0, -height / 2 - 300);
  rotateY(radians(-90));
  /*noFill();
  stroke(255);
  strokeWeight(10);
  box(height + 600, height + 200, height + 600);*/
  translate(-cmpWidth * 1.5 - busWidth / 2, -height / 2, height / 2 + 300);
  drawParts();
  updateMove();
  camera(osx, osy, zoom, osx, osy, 0, 0, 1, 0);

  if (keyPressed && key == ' ' && speed == 0 && millis() - lastTick > 500) {
    lastTick = millis();
    update();
  }
  if (speed != 0 && millis() - lastTick >= 1000 / speed) {
    lastTick = millis();
    update();
  }

  animator += 1;
  if (animator > padding * 5) {
    animator = -2;
  }

  if (mousePressed) {  
    osx += pmouseX - mouseX;
    osy += pmouseY - mouseY;
  }

  if (keyPressed && key == 'r') {
    osx = 0;
    osy = 0;
    zoom = 2000;
  }

  if (keyPressed && keyCode == RIGHT && !rotl && !rotr) {
    rotl = true;
    rott = rot - 90;
    if (rott < 0) {
      rott += 360;
    }
  }
  if (keyPressed && keyCode == LEFT && !rotr && !rotl) {
    rotr = true;
    rott = rot + 90;
    if (rott > 360) {
      rott -= 360;
    }
  }
  if (keyPressed && keyCode == UP && !rotu && urotd) {
    rotu = true;
    urotd = false;
  }
  if (keyPressed && keyCode == DOWN && rotu && urotd) {
    rotu = false;
    urotd = false;
  }
  if (rot != rott) {
    if (rotl) {
      rot -= max(abs(rot - rott) / 8, 1);
      if (rot < 0) {
        rot += 360;
      }
    }
    if (rotr) {
      rot += max(abs(rot - rott) / 8, 1);
      if (rot > 360) {
        rot -= 360;
      }
    }
  } else {
    rotl = false;
    rotr = false;
  }
  
  if (!urotd) {
    if (rotu) {
      urot -= max(abs(urot + 90) / 8, 1);
      if (urot < -90) {
        urot = -90;
        urotd = true;
      }
    } else {
      urot += max(abs(urot) / 8, 1);
      if (urot > 0) {
        urot = 0;
        urotd = true;
      }
    }
  }

  if (rot == 90 && keyPressed && key == 'u') {
    if (!pressed) {
      if (umode) {
        umodeStr = "signed";
      } else {
        umodeStr = "unsigned";
      }
      umode = !umode;
    }
    pressed = true;
  } else if (rot == 90 && keyPressed && key == 'p') {
    if (!pressed) {
      program = (program + 1) % programs.length;
      setProgram();
    }
    pressed = true;
  } else if (rot == 90 && keyPressed && key == '+') {
    if (!pressed && speed < 10) {
      if (speed >= 1) {
        speed += 0.5;
      } else {
        speed += 0.25;
      }
      if (speed != 0) {
        speedStr = str(speed);
      } else {
        speedStr = "Manual stepping";
      }
    }
    pressed = true;
  } else if (rot == 90 && keyPressed && key == '-') {
    if (!pressed && speed > 0) {
      if (speed > 1) {
        speed -= 0.5;
      } else {
        speed -= 0.25;
      }
      if (speed != 0) {
        speedStr = str(speed);
      } else {
        speedStr = "Manual stepping";
      }
    }
    pressed = true;
  } else if (rot == 90 && keyPressed && key == 'r') {
    instPhase = 0;
    setProgram();
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
    cmpCon[3]++;
    if (cmpCon[3] > 0xF) {
      cmpCon[3] = 0;
    }
  } else {
    PCinc = false;

    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00010000") & 0xF0)) { // ADD
      ALUsub = false;
      moveData(1, 0);
    } else if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00100000") & 0xF0)) { // SUB
      ALUsub = true;
      moveData(1, 0);
    } 
    if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("00110000") & 0xF0)) { // JMP
      moveData(6, 3);
    } else if (instPhase == 4 && (cmpCon[5] & 0xF0) == ((byte)unbinary("01100000") & 0xF0)) { // HLT
      speed = 0;
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
}

void moveData(int s, int d) {
  if (s == d) {
    return;
  }
  src = s;
  des = d;
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
  mv = true;
}

void updateMove() {
  int centerx = cmpWidth + busWidth / 2;
  float tmp = speed;
  if (speed == 0) {
    speed = 0.2;
  }
  if (mv) {
    if (ty != tty) {
      if (tx != centerx) {
        tx += (centerx - tx) / abs(centerx - tx) * 20 * speed;
        if (abs(tx - centerx) < 20 * speed) {
          tx = centerx;
        }
      } else {
        ty += (tty - ty) / abs(tty - ty) * 20 * speed;
        if (abs(ty - tty) < 20 * speed) {
          ty = tty;
        }
      }
    } else {
      tx += (ttx - tx) / abs(ttx - tx) * 20 * speed;
      if (abs(tx - ttx) < 20 * speed) {
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
    }
  }
  speed = tmp;
}

void drawParts() {
  translate(0, 0, 1);
  if (mv && (src == 0 || des == 0)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src <= 1 || des <= 1)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src <= 2 || des <= 2)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src <= 3 || des <= 3)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 + padding + 100);

  if (mv && (src == 0 || des == 0)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src == 1 || des == 1)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src == 2 || des == 2)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src == 3 || des == 3)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth - padding, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 - 50 - (cmpWidth + busWidth / 2 - 50 - cmpWidth) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);

  if (mv && (src == 4 || des == 4)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && ((src <= 5 & src >= 4) || (des <= 5 && des >= 4))) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && ((src <= 6 & src >= 4) || (des <= 6 && des >= 4))) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && ((src <= 7 & src >= 4) || (des <= 7 && des >= 4))) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 + padding + 100);

  if (mv && (src == 4 || des == 4)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src == 5 || des == 5)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight * 2 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src == 6 || des == 6)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight * 3 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);
  if (mv && (src == 7 || des == 7)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + 25 + (cmpWidth + busWidth + padding - (cmpWidth + busWidth / 2 + 25)) / 2, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2, cmpWidth + busWidth + padding, cmpHeight * 4 - padding - (cmpHeight - padding - (cmpHeight / 2 + 25)) / 2);

  if (mv && (src == 8 || des == 8)) {
    stroke(0, 0, 255);
    strokeWeight(10);
  } else {
    stroke(63);
    strokeWeight(2);
  }
  line(cmpWidth + busWidth / 2 + (cmpWidth + busWidth / 2 - padding), (cmpHeight * 4 + padding + 50) + ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2, cmpWidth * 2 + busWidth + cmpWidth / 2 + 50 - (cmpWidth / 2 - padding), (cmpHeight * 4 + padding + 50) + ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2);

  translate(0, 0, 2);
  noStroke();
  fill(0, 127, 0);
  rect(cmpWidth + busWidth / 2 - 25, cmpHeight / 2 - 25, 50, (cmpHeight * 4 + padding) - (cmpHeight / 2 - 25));
  rect(cmpWidth - padding, cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth - padding, cmpHeight + cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth - padding, cmpHeight * 2 + cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth - padding, cmpHeight * 3 + cmpHeight / 2 - 25, busWidth + padding * 2, 50);
  rect(cmpWidth + busWidth / 2 - 25, cmpHeight * 4 + padding, busWidth / 2 + cmpWidth + padding * 2 + 100, 50);
  translate(0, 0, -3);

  stroke(0);
  strokeWeight(2);
  fill(127);
  beginShape(QUAD_STRIP);
  vertex(-25, -25, 1);
  vertex(-25, -25, 40);
  vertex(cmpWidth * 2 + busWidth + 25, -25, 1);
  vertex(cmpWidth * 2 + busWidth + 25, -25, 40);
  vertex(cmpWidth * 2 + busWidth + 25, height + 25, 1);
  vertex(cmpWidth * 2 + busWidth + 25, height + 25, 40);
  vertex(-25, height + 25, 1);
  vertex(-25, height + 25, 40);
  vertex(-25, -25, 1);
  vertex(-25, -25, 40);
  endShape(CLOSE);

  /*fill(127); // CPU cover
   beginShape();
   vertex(-25 - cover, -25, 40);
   vertex(cmpWidth * 2 + busWidth + 25 - cover, -25, 40);
   vertex(cmpWidth * 2 + busWidth + 25 - cover, height + 25, 40);
   vertex(-25 - cover, height + 25, 40);
   endShape(CLOSE);*/

  stroke(0);
  strokeWeight(2);

  if (mv && (src == 0 || des == 0)) {
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

  fill(0, 0, 160);
  translate(cmpWidth / 2, cmpHeight - padding * 2 + animator, 15);
  box(100, padding * 2, 20);
  translate(cmpWidth / -2, -cmpHeight + padding * 2 - animator, -15);

  if (ALUsub) {
    cmpCon[1] = (byte)(cmpCon[0] - cmpCon[2]);
  } else {
    cmpCon[1] = (byte)(cmpCon[0] + cmpCon[2]);
  }
  if (mv && (src == 1 || des == 1)) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth / 2, cmpHeight + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[1] & unbinary("10000000")) * 255, 255 - (cmpCon[1] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("01000000")) * 255, 255 - (cmpCon[1] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00100000")) * 255, 255 - (cmpCon[1] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00010000")) * 255, 255 - (cmpCon[1] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00001000")) * 255, 255 - (cmpCon[1] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00000100")) * 255, 255 - (cmpCon[1] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00000010")) * 255, 255 - (cmpCon[1] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[1] & unbinary("00000001")) * 255, 255 - (cmpCon[1] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(cmpWidth / -2, -cmpHeight + cmpHeight / -2, -16);
  fill(255);
  textSize(24);
  text("Arithmetic Logic Unit", cmpWidth / 2, cmpHeight + cmpHeight / 2 - 30, 32);
  textSize(32);

  fill(0, 0, 160);
  translate(cmpWidth / 2, cmpHeight * 2 + padding * 2 - animator, 15);
  box(100, padding * 2, 20);
  translate(cmpWidth / -2, -cmpHeight * 2 - padding * 2 + animator, -15);

  if (mv && (src == 2 || des == 2)) {
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

  if ((mv && (src == 3 || des == 3)) || PCinc) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[3] & unbinary("10000000")) * 255, 255 - (cmpCon[3] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("01000000")) * 255, 255 - (cmpCon[3] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00100000")) * 255, 255 - (cmpCon[3] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00010000")) * 255, 255 - (cmpCon[3] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00001000")) * 255, 255 - (cmpCon[3] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00000100")) * 255, 255 - (cmpCon[3] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00000010")) * 255, 255 - (cmpCon[3] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[3] & unbinary("00000001")) * 255, 255 - (cmpCon[3] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(cmpWidth / -2, -cmpHeight * 3 + cmpHeight / -2, -16);
  fill(255);
  text("Program Counter", cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2 - 30, 32);

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
  if (umode) {
    dispStr = str(cmpCon[4] & 0xFF);
  }
  text(dispStr, cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight + 30, 33);
  textFont(font);
  textSize(32);

  if (mv && (src == 4 || des == 4)) {
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

  fill(0, 0, 160);
  translate(cmpWidth * 2 + busWidth - padding * 2 + animator * 2, cmpHeight / 2, 15);
  box(padding * 2, 100, 20);
  translate(-cmpWidth * 2 - busWidth + padding * 2 - animator * 2, -cmpHeight / 2, -15);

  if (mv && (src == 5 || des == 5)) {
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

  fill(0, 0, 160);
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 2 - padding * 2 + animator, 15);
  box(100, padding * 2, 20);
  translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight * 2 + padding * 2 - animator, -15);

  cmpCon[6] = (byte)(cmpCon[5] & 0xF);
  if (mv && (src == 6 || des == 6)) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 2 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[6] & unbinary("10000000")) * 255, 255 - (cmpCon[6] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("01000000")) * 255, 255 - (cmpCon[6] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00100000")) * 255, 255 - (cmpCon[6] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00010000")) * 255, 255 - (cmpCon[6] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00001000")) * 255, 255 - (cmpCon[6] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00000100")) * 255, 255 - (cmpCon[6] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00000010")) * 255, 255 - (cmpCon[6] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[6] & unbinary("00000001")) * 255, 255 - (cmpCon[6] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight * 2 + cmpHeight / -2, -16);
  fill(255);
  text("Operand Register", cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 2 + cmpHeight / 2 - 30, 32);

  if (mv && (src == 7 || des == 7)) {
    fill(40);
  } else {
    fill(85);
  }
  translate(cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2, 16);
  box(cmpWidth - padding * 2, cmpHeight - padding * 2, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - (cmpCon[7] & unbinary("10000000")) * 255, 255 - (cmpCon[7] & unbinary("10000000")) * 255, 255);
  ellipse(-105, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("01000000")) * 255, 255 - (cmpCon[7] & unbinary("01000000")) * 255, 255);
  ellipse(-75, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00100000")) * 255, 255 - (cmpCon[7] & unbinary("00100000")) * 255, 255);
  ellipse(-45, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00010000")) * 255, 255 - (cmpCon[7] & unbinary("00010000")) * 255, 255);
  ellipse(-15, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00001000")) * 255, 255 - (cmpCon[7] & unbinary("00001000")) * 255, 255);
  ellipse(15, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00000100")) * 255, 255 - (cmpCon[7] & unbinary("00000100")) * 255, 255);
  ellipse(45, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00000010")) * 255, 255 - (cmpCon[7] & unbinary("00000010")) * 255, 255);
  ellipse(75, 0, 20, 20);
  fill(255 - (cmpCon[7] & unbinary("00000001")) * 255, 255 - (cmpCon[7] & unbinary("00000001")) * 255, 255);
  ellipse(105, 0, 20, 20);
  translate(0, -30, -16);
  translate(-cmpWidth - busWidth - cmpWidth / 2, -cmpHeight * 3 + cmpHeight / -2, -16);
  fill(255);
  textSize(24);
  text("Memory Address Register", cmpWidth + busWidth + cmpWidth / 2, cmpHeight * 3 + cmpHeight / 2 - 30, 32);
  textSize(32);

  fill(127);
  translate(cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight * 2 + (height - cmpHeight * 2) / 2, 16);
  box(cmpWidth - padding * 2, (height - cmpHeight * 2) - padding * 2, 30);
  translate(0, 30, 16);
  for (int i = 0; i < 16; i++) {
    if (cmpCon[7] == i) {
      stroke(127, 127, 255);
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
  text("Random Access Memory", cmpWidth * 2 + busWidth + cmpWidth / 2 + 50, cmpHeight * 2 + cmpHeight / 2 - 30, 32);
  textSize(32);

  fill(85);
  translate(cmpWidth + busWidth / 2, (cmpHeight * 4 + padding + 50) + ((height + 25) - (cmpHeight * 4 + padding + 50)) / 2, 16);
  box(cmpWidth * 2 + busWidth - padding * 2, (height + 25) - (cmpHeight * 4 + padding + 50) - padding * 2 - 50, 30);
  translate(0, 30, 16);
  stroke(0);
  fill(255 - int((speed == 0 && keyPressed && key == ' ') || (speed != 0 && millis() - lastTick < 1000 / speed / 4)) * 255, 255 - int((speed == 0 && keyPressed && key == ' ') || (speed != 0 && millis() - lastTick < 1000 / speed / 4)) * 255, 255);
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

  if (mv) {
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
    fill(255 - (data & unbinary("10000000")) * 255, 255 - (data & unbinary("10000000"))* 255, 255);
    ellipse(-70, 0, 15, 15);
    fill(255 - (data & unbinary("01000000")) * 255, 255 - (data & unbinary("01000000")) * 255, 255);
    ellipse(-50, 0, 15, 15);
    fill(255 - (data & unbinary("00100000")) * 255, 255 - (data & unbinary("00100000")) * 255, 255);
    ellipse(-30, 0, 15, 15);
    fill(255 - (data & unbinary("00010000")) * 255, 255 - (data & unbinary("00010000")) * 255, 255);
    ellipse(-10, 0, 15, 15);
    fill(255 - (data & unbinary("00001000")) * 255, 255 - (data & unbinary("00001000")) * 255, 255);
    ellipse(10, 0, 15, 15);
    fill(255 - (data & unbinary("00000100")) * 255, 255 - (data & unbinary("00000100")) * 255, 255);
    ellipse(30, 0, 15, 15);
    fill(255 - (data & unbinary("00000010")) * 255, 255 - (data & unbinary("00000010")) * 255, 255);
    ellipse(50, 0, 15, 15);
    fill(255 - (data & unbinary("00000001")) * 255, 255 - (data & unbinary("00000001")) * 255, 255);
    ellipse(70, 0, 15, 15);
    translate(0, 0, -6);

    translate(-tx, -ty, -11);
  }
}
