//dip switch
int dipAmt = 5;
//int dipPins[] = {
//  7,6,A4,A5,A1,5,9}; //DIP Switch Pins
int dipPins[] = {
  14,13,12,11,10}; //DIP Switch Pins // 10,11,12,13,14};
int transAddress;


void setup_dipSwitch(){

  for(int i = 0; i<dipAmt; i++){
    pinMode(dipPins[i], INPUT_PULLUP);	// sets the digital pin 2-5 as input
    //digitalWrite(dipPins[i], HIGH); //Set pullup resistor on
  }

  readDipSwitch();
}

void readDipSwitch(){
  transAddress = address();
  myGroupID = transAddress;
  if(bDebug){
    SerialUSB.print("DIP switch = ");
    SerialUSB.print(transAddress,BIN);
    SerialUSB.print(", groupID = ");
    SerialUSB.print(myGroupID,DEC);
    SerialUSB.println();
  }

}

byte address(){
  int i,j=0;

  //Get the switches state
  for(i=0; i<dipAmt; i++){
    j = (j << 1) | !digitalRead(dipPins[i]);   // read the input pin. ! turns true in to false and vis versa
  }
  return j; //return address
}




