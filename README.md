# maple_dmx_dimming


stephan schulz
www.antimodular.com

using the maple mini to dim 16 LEDs via dmx

- arm micro controller maple: http://leaflabs.com/devices/
- dimming 16 LEDs with timer3
- receive dmx communication via irq_usart1
- find links to the maple forum and related posts inside the code


## Update:

After many years i had to get this code working again. Surprisingly even in 2019 on macOS 10.12.6 i was able to run the MapleIDE v0.0.12.

The IDE can be downloaded here:
[http://docs.leaflabs.com/static.leaflabs.com/pub/leaflabs/maple-docs/latest/maple-ide-install.html](http://docs.leaflabs.com/static.leaflabs.com/pub/leaflabs/maple-docs/latest/maple-ide-install.html)

For the DMX code to work a change needed to be made in:
`/Applications/MapleIDE2.app/Contents/Resources/Java/hardware/leaflabs/cores/maple/usart.c`
as mentioned in this forum post:
[http://forums.leaflabs.com/forums.leaflabs.com/topicf26b.html?id=1134#post-7453](http://forums.leaflabs.com/forums.leaflabs.com/topicf26b.html?id=1134#post-7453)

Basically i commented out the following from usart.c.
```
/*void __irq_usart1(void) {
usart_irq(USART1);
}*/
```
This now modified version of the Maple IDE allowe me to compile and upload the dmx dimmer code over USB to the maple mini rev5 2014.

For now i'm providing the modified version as a direct [macOS download](https://www.dropbox.com/s/lynbcosmasy0hax/MapleIDE_mod.zip?dl=0).
