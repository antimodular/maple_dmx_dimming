//made by stephan schulz @ antimodular.com

//using interupt for DMX
//http://forums.leaflabs.com/topic.php?id=1134#post-6992

//ways to implement DMX
//http://playground.arduino.cc//DMX/Ardmx

/*
http://www.diodes.com/datasheets/ZXLD1350.pdf  page 2
 output current
 3.3v = 264% = 255 dmx
 2.5v = 200% = 193 dmx - >absolut max otherwise led driver burns
 1.25v =100% = 96 dmx
 0.3v = 25% = 24 dmx
 */

const char version[] = "maple_dmx_fading";
const int maxDMXvalue = 255; //160;

//---------------------------------------debug--------------------------------
boolean bDebug = true; //false; //

boolean bPrintDMXData = false;

unsigned long myTimer = 0;

boolean bMainLEDswitch = true;
int mainLEDswitchPin = 2;
boolean bPrintTest = false;
int printTestStage = 0;

unsigned char dmx_test_data[513];

//--------------------------------------init sequence-----------------------------
unsigned long initTimer;
unsigned long initTime;
boolean bInitDone;
int initStage;
int cnt0;

//--------------------------------------dimming----------------------------------

#define DMX_NUM_CHANNELS 16

//---------------------------------------DMX-------------------------------------
//// this holds the dmx data
volatile unsigned char dmx_data[DMX_NUM_CHANNELS];

// tell us when to update the pins
volatile unsigned char update;
volatile unsigned char data;


//--------------------------------------dip switch--------------------------------
byte myGroupID = 0; //default will be changed once DIP switch is read


//--------------------------------------------------------------------------------
void setup() {
  //--debug
  if(bDebug){
    SerialUSB.println(version); //"voiceArray_1"); 
    showHelp();
  } 

  //init sequnce

  //----dip switch
  setup_dipSwitch();

  pinMode(BOARD_LED_PIN, OUTPUT);
  pinMode(BOARD_BUTTON_PIN, INPUT);

  //turn the mosfet on; i.e. main light switch
  pinMode(mainLEDswitchPin, OUTPUT); 
  digitalWrite(mainLEDswitchPin, bMainLEDswitch);

  //-----dimming
  setup_dimming();

  //---dmx
  // setup_dmx();

  //SerialUSB.read();

  resetInit();
}

//--------------------------------------------------------------------------------
void loop() {


  if(bDebug){
    if (SerialUSB.available()){
      handleInput(SerialUSB.read());
    }
  }

  if(bInitDone == false){
    //chase all 16 leds
    if(initStage == 0){

      for(int i=0; i<DMX_NUM_CHANNELS; i++){
        dmx_data[i] = 0;
      }

      dmx_data[cnt0] = 128;

      if(millis() - initTimer > initTime ){
        initTimer = millis();
        cnt0++;
      }

      if(cnt0 >= DMX_NUM_CHANNELS){
        //initTimer = millis();
        initStage = 1;
        initTime = 4000;
      }
    }//if(initStage == 0)

    //illuminate one led to indicate it's dip switch setting
    if(initStage == 1){
      for(int i=0; i<DMX_NUM_CHANNELS; i++){
        dmx_data[i] = 0;
      }
      dmx_data[myGroupID%16] = 128;
      if(millis() - initTimer > initTime){
        setup_dmx();
        initStage++;
        bInitDone = true;
      }
    }//end if(initStage == 1)

  }//if(bInitDone == true)

  if (isButtonPressed()){
    // bPrintDMXData =! bPrintDMXData;
    resetInit();
  }
  //  if(millis() - myTimer > 15){
  //    myTimer = millis();
  //    toggleLED();
  //  }

  if (update) {
    update = 0;

    if(bPrintDMXData == true){
      for (int i=0; i<DMX_NUM_CHANNELS; i++)
      {
        SerialUSB.print(dmx_data[i]);
        SerialUSB.print(" ");
      }
      SerialUSB.println(".");
    }//end if(bPrintDMXData == true)

  }//end if (update)


  /*
   if(printTestStage == 2 && bPrintTest){
   for(int i = 0; i< 513; i++){
   SerialUSB.print(i);
   SerialUSB.print(" ' ");
   SerialUSB.println(dmx_test_data[i]);
   }
   printTestStage = 0;
   bPrintTest = false;
   }
   */
  // delay(100);

}

void resetInit(){
  initTimer = millis();
  initTime = 250;
  bInitDone = false;
  initStage = 0;
  cnt0 = 0; 
  Serial1.end();
  readDipSwitch();
}


//--------------------------------------------------------------------------------
void showHelp(){
  if(bDebug) {
    SerialUSB.println();
    SerialUSB.print("version = ");
    SerialUSB.println(version);
    SerialUSB.println();
    SerialUSB.println("number,letter");
    SerialUSB.println("p = toggle print dmx data");
    SerialUSB.println("l = toggle main led switch");
    SerialUSB.println("s = read dip switch");
    SerialUSB.println("r = reset init sequence");
    SerialUSB.println("h = show help");
  }
}

























