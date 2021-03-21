#!/usr/bin/python3

# -*- coding: utf-8 -*-
#########################################################
# SERVICE : rpipoweroff.py                              #
#           Implementation of power off button on       #
#           Raspberry Pi                                #
#           I. Helwegen 2021                            #
#########################################################

####################### IMPORTS #########################
from subprocess import call
import signal

try:
    import pigpio
    ifinstalled = True                     
except ImportError:
    ifinstalled = False
#########################################################

####################### GLOBALS #########################
# pushbutton connected to this GPIO pin, using pin 5 (GPIO 3) also has the benefit of
# waking / powering up Raspberry Pi when button is pressed
shutdownGpio = 3

# if button pressed for at least this long then shut down. if less then reboot.
shutdownMinSeconds = 3

# button debounce time in seconds
debounceSeconds = 0.3
#########################################################

buttonPressedTime = None

###################### FUNCTIONS ########################

def exit_app(signum, frame):
    print("rpipoweroff: Ready")
    exit()

def buttonStateChanged(gpio, level, tick):
    global buttonPressedTime
    
    if gpio != shutdownGpio:
        return

    if not level:
        # button is down
        if buttonPressedTime is None:
            buttonPressedTime = tick
    else:
        # button is up
        if buttonPressedTime is not None:
            elapsed = (tick - buttonPressedTime) / 1000000
            buttonPressedTime = None
            if elapsed >= shutdownMinSeconds:
                # button pressed for more than specified time, shutdown
                print("rpipoweroff: System is shutting down")
                call(['wall', 'rpipoweroff: System is shutting down'], shell=False)
                call(['shutdown', '-h', 'now'], shell=False)
            elif elapsed >= debounceSeconds:
                # button pressed for a shorter time, reboot
                print("rpipoweroff: System is rebooting")
                call(['wall', 'rpipoweroff: System is rebooting'], shell=False)
                call(['shutdown', '-r', 'now'], shell=False)

#########################################################

######################### MAIN ##########################
if __name__ == "__main__":   
    signal.signal(signal.SIGINT, exit_app)
    signal.signal(signal.SIGTERM, exit_app)
    
    print("rpipoweroff: Started")
        
    if ifinstalled:
        pi = pigpio.pi()
    else:
        pi = None
        print("rpipoweroff: PiGpio is not installed")
    pass
    
    if pi:
        pi.set_mode(shutdownGpio, pigpio.INPUT)
        pi.set_pull_up_down(shutdownGpio, pigpio.PUD_UP)
    
        pi.callback(shutdownGpio, pigpio.EITHER_EDGE, buttonStateChanged)
    
    signal.pause()

