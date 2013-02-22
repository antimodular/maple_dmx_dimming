enum
{
  DMX_IDLE,
  DMX_BREAK,
  DMX_START,
  DMX_RUN
};

#define LED_PORT GPIOB //describes onboard LED at D33
#define LED_BIT  1 //describes onboard LED at D33

// We need to read the data register in order to avoid overrun errors,
// but we don't do anything with the value. This attribute silences an
// unused variable warning from GCC.
#define __unused __attribute__((unused))


volatile unsigned char dmx_state;

// this is the start address for the dmx frame
const unsigned int dmx_start_addr = 450;

// this is the current address of the dmx frame
volatile unsigned int dmx_addr;

// pins that will toggle based on dmx data
//unsigned char dmx_pin[DMX_NUM_CHANNELS] = {
//  19,20,21,22,28,29,30,31};

//// this is used to keep track of the channels
volatile unsigned int chan_cnt;


extern "C" {
  void __irq_usart1(void) {
    unsigned char status = USART1_BASE->SR;
    data = USART1_BASE->DR;

    //onboard LED at D33 get toggled when timer is called
    gpio_toggle_bit(LED_PORT, LED_BIT);

    switch (dmx_state)
    {
    case DMX_IDLE:
      if (status & 1<<USART_SR_FE_BIT)
      {
        dmx_addr = 0;
        dmx_state = DMX_BREAK;
        update = 1;
        //delayMicroseconds(8);
      }
      break;

    case DMX_BREAK:
      if (data == 0)
      {
        dmx_state = DMX_START;
      }
      else
      {
        dmx_state = DMX_IDLE;
      }
      break;

    case DMX_START:
      dmx_addr++;
      /*
      if(printTestStage == 1){

        dmx_test_data[dmx_addr] = data;
//        SerialUSB.print(dmx_addr);
//        SerialUSB.print(" , ");
//        SerialUSB.println(data);
      }
      */
      if (dmx_addr == dmx_start_addr)
      {
        chan_cnt = 0;
        dmx_data[chan_cnt++] = constrain(data,0,maxDMXvalue); //data;
        dmx_state = DMX_RUN;
      }
      break;

    case DMX_RUN:
      //for (int wasteTime =0; wasteTime <2; wasteTime++) {}
      dmx_data[chan_cnt++] = constrain(data,0,maxDMXvalue); //data;
      if (chan_cnt >= DMX_NUM_CHANNELS)
      {
       // printTestStage = 2;
        dmx_state = DMX_IDLE;
      }
      break;

    default:
      dmx_state = DMX_IDLE;
      break;
    }
  }
}



void setup_dmx(){
  update = 0;

  // set default DMX state
  dmx_state = DMX_IDLE;

  Serial1.begin(250000);

  // Set USART1 to 2 stop bits
  USART1_BASE->CR2 = 2;
}



