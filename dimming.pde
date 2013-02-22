#include <gpio.h>

volatile unsigned int counter = 0;



//int ledAmt = 16;
const int counterLimit = 255; //160;

volatile boolean dimStates [] = {
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  
const char ledPin[] = {
  15,16,17,18,19,20,21,22,27,28,29,30,31,0,1,6};//the pins are per silkscreen on maple mini

const int LED_PORTref_ARRAY[] = {
  1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,0}; //0 = GPIOA, 1 = GPIOB
const int LED_BIT_ARRAY[] = {
  7,6,5,4,3,15,14,13,8,15,14,13,12,11,10,5}; //pins bit numbers as refert to by their port

//15 ,16 ,17 ,18 ,19 ,20  ,21  ,22  ,27 ,28  ,29  ,30  ,31  ,0   ,1   ,6
//b7 ,b6 ,b5 ,b4 ,b3 ,a15 ,a14 ,a13 ,a8 ,b15 ,b14 ,b13 ,b12 ,b11 ,b10 ,a5 

void timer3_dimming_handler(void) {
  for(int i=0; i<DMX_NUM_CHANNELS; i++){

    if(dmx_data[i] > counter){
      dimStates[i] = true;
    }
    else{
      dimStates[i] = false;
    }
    if(LED_PORTref_ARRAY[i] == 0) gpio_write_bit(GPIOA, LED_BIT_ARRAY[i],dimStates[i]);
    if(LED_PORTref_ARRAY[i] == 1) gpio_write_bit(GPIOB, LED_BIT_ARRAY[i],dimStates[i]);
    //digitalWrite(ledPin[i],dimStates[i]);

  }

  counter++;
  if(counter > counterLimit) counter = 0;
}

void setup_dimming(){
  for(int i=0; i<DMX_NUM_CHANNELS; i++){

    //use regular OUTPUT when dimming directly connected LEDs
    pinMode(ledPin[i],OUTPUT); 

    //use OUTPUT_OPEN_DRAIN with ZXLD1350 LED-driver
    //ZXLD1350 goes off when pulled to ground
    //http://leaflabs.com/docs/lang/api/pinmode.html?highlight=pinmode
    //maybe using open drain will eliminated the need to clamp the dmx value ??? 
   // pinMode(ledPin[i],OUTPUT_OPEN_DRAIN);
  }

  Timer3.setPrescaleFactor(1);
  Timer3.setOverflow(500); //1079);
  Timer3.attachCompare1Interrupt(timer3_dimming_handler);
}



