
int serialNode = 0;

static void handleInput (char c) {

  if ('0' <= c && c <= '9')
    serialNode = 10 * serialNode + c - '0'; //combines any number with multiple digits, i.e. multiple char
  else if (c == ',') {

  } 
  else if ('a' <= c && c <='z') {
    if(bDebug){ 
      SerialUSB.print("\n> ");
      SerialUSB.print((int) serialNode);
      SerialUSB.println(c);
    }
    switch (c) {
    case 'h':
      showHelp();
      break;

      //control one
    case 'l':
      bMainLEDswitch =! bMainLEDswitch;
      digitalWrite(mainLEDswitchPin, bMainLEDswitch);
      //DEBUG_PRINT("-------- overwrite -------");
      break;

    case'p':
      bPrintDMXData =! bPrintDMXData;
      //reset
      //restart();
      break;
    case't':
     bPrintTest = true;
     printTestStage = 1;
      //reset
      //restart();
      break;

    case 's':
      readDipSwitch();
      dmx_start_addr = myGroupID * 16 + 1;
      break;
    }
    serialNode  = 0;
  } 
}






