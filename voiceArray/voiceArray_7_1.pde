//made by stephan schulz @ antimodular.com

//using interupt for DMX
//http://forums.leaflabs.com/topic.php?id=1134#post-6992

//ways to implement DMX
//http://playground.arduino.cc/DMX/Ardmx

//needs to be flashed on to maple with mapleIDE 2 which has usart disabled

/*
http://www.diodes.com/datasheets/ZXLD1350.pdf  page 2
 output current
 3.3v = 264% = 255 dmx
 2.5v = 200% = 193 dmx - >absolut max otherwise led driver burns
 1.25v =100% = 96 dmx
 0.3v = 25% = 24 dmx
 */
#include <gpio.h>
#include <digitalWriteFaster.h>

//#include <systemReset.h>


const char version[] = "voiceArray_7";
//const int maxDMXvalue = 255;

//---------------------------------------debug--------------------------------
boolean bDebug = false; //true; //

boolean bPrintDMXData = false;

unsigned long myTimer = 0;

boolean bMainLEDswitch = false; //true;
int mainLEDswitchPin = 2;
boolean bPrintTest = false;
int printTestStage = 0;

unsigned char dmx_test_data[513];

//--------------------------------------dimming--------------------------------

#define DMX_NUM_CHANNELS 16



//---------------------------------------DMX-------------------------------------
//// this holds the dmx data
volatile unsigned char dmx_data[DMX_NUM_CHANNELS];

// tell us when to update the pins
//volatile unsigned char update;
volatile unsigned char data;


//--------------------------------------dip switch--------------------------------
byte myGroupID = 0; //default will be changed once DIP switch is read


//-------------------------------------init-------------------------------
boolean bInitDone = false;
unsigned long startTimer;

int initStage = 0;

unsigned long resetTimer;

void setup() {
  //--debug
  if(bDebug){
    SerialUSB.println(version); //"voiceArray_1"); 
    showHelp();
  } 

  //----dip switch
  setup_dipSwitch();

  pinMode(BOARD_LED_PIN, OUTPUT);
  pinMode(BOARD_BUTTON_PIN, INPUT);

  //turn the mosfet on; i.e. main light switch
  pinMode(mainLEDswitchPin, OUTPUT); 
  digitalWrite(mainLEDswitchPin, LOW);


  //-----dimming
  setup_dimming();

  for(int i=0; i<DMX_NUM_CHANNELS; i++){
    dmx_data[i] = 0;
  }
  //---dmx
  //setup_dmx();

  //SerialUSB.read();
  
  resetTimer = millis();
}

//--------------------------------------------------------------------------------
void loop() {


  if(bDebug){
    if (SerialUSB.available()){
      handleInput(SerialUSB.read());
    }
  }

//http://forums.leaflabs.com/topic.php?id=74283
//http://forums.leaflabs.com/topic.php?id=16585#post-32097
if(millis() - resetTimer > 20000){
//NVIC_SystemReset(void);
 //NVIC();
// nvic_sys_reset;
}
  if(bInitDone == false) {

    toggleLED();

    if(initStage == 0 && millis() > 2000){
      bMainLEDswitch = true;
      digitalWrite(mainLEDswitchPin, bMainLEDswitch);

      initStage++;
      startTimer = millis();
    }
    if(initStage == 1){
      for(int i=0; i<DMX_NUM_CHANNELS; i++){
        dmx_data[i] = 0;
      }
 
       int temp_i = map(millis(), startTimer, startTimer+4000, 0,DMX_NUM_CHANNELS); //(int)(millis()-startTimer) % 300;
        dmx_data[temp_i] = 60;
      
      if(temp_i > DMX_NUM_CHANNELS-1){
        dmx_data[myGroupID%16] = 60;
        initStage++;
      }
    }

    if(initStage == 2 && millis() > 10000){
      setup_dmx();
      initStage++;
      bInitDone = true;
      digitalWrite(BOARD_LED_PIN,LOW);
    }
  }




  //if (isButtonPressed()) bPrintDMXData =! bPrintDMXData;
  //if(bMainLEDswitch == true) digitalWrite(mainLEDswitchPin, )

  //  if(millis() - myTimer > 15){
  //    myTimer = millis();
  //    toggleLED();
  //  }

/*
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
*/

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
    SerialUSB.println("h = show help");
  }
}




















