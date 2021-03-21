rpipoweroff v0.80

rpipoweroff - Service to reboot or poweroff the raspberry pi
=========== = ======= == ====== == ======== === ========= ==

pigpio is used for IO to rapsberry pi 

Install this script to poweroff the rpi.

Short press > 0.3 is reboot
Long press > 3 s is poweroff

Pinning
-------
Poweroff switch:
PIN 5 (GPIO 3) is poweroff
PIN 6 (GND) for ground

If you also want to use a power LED, attach this on to:
PIN 8 (GPIO 14) anode (3.3 V, use resistor depending on LED)
PIN 9 (GND) for ground

EEPROM
------
The rpi can also be powered on using this button.
To do so, the bootloader EEPROM needs to be set correctly.
* Try 'sudo rpi-eeprom-config'
* If rpi-eeprom-config is not installed, install it with 'sudo apt install rpi-eeprom' (available on ubuntu and raspbian)
* Run 'sudo rpi-eeprom-config' again
* Check the current settings:
    * BOOT_UART=0 (required for power LED to work)
    * WAKE_ON_GPIO=1 (required for powering on)
    * POWER_OFF_ON_HALT=0 (however is overruled by WAKE_ON_GPIO=1)
* If these settings are incorrect:
    * run 'sudo -E rpi-eeprom-config --edit' and edit the settings
    * reboot the rpi for the settings to apply (sudo reboot)
* Now it should work (background info: https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md)

That's all for now ...

Please send Comments and Bugreports to hellyrulez@home.nl
