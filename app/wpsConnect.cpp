/*
 * wps.c
 *
 *  Created on: 18.07.2016
 *      Author: johndoe
 */

#include <user_config.h>
#include <SmingCore/SmingCore.h>
#include <user_interface.h>
#include "wpsConnect.h"

#define LED_PIN 2 // GPIO2

/*
 * WPS variables
 */
bool blinkState = true;
char wpsRepeatCounter;

Timer *blinkTimer;
Timer *wpsTimer;
WPSDelegate connectDelegate;

/*
 * WPS Configuration methods
 */
// blink with LED to indicate active wps pairing
void wpsBlinkIndicator()
{
	digitalWrite(LED_PIN, blinkState);
	blinkState = !blinkState;
}

void wpsStart() {
	wifi_wps_start();
}

// WPS Status callback
// 	- use callback to signal success
//  - restart up to 10 times
//  - slow blink (0,5Hz) if no success -> restart necessary
void wpsStatus(int status) {
	if (status == WPS_CB_ST_SUCCESS) {
		Serial.println("WPS config successful");
		wifi_wps_disable();
		WifiStation.connect();
		blinkTimer->stop();
		if (connectDelegate) connectDelegate();

	} else {
		wifi_wps_disable();
		wpsRepeatCounter--;
		if (wpsRepeatCounter>0) {
			Serial.print("WPS repeat");
			wifi_wps_enable(WPS_TYPE_PBC);
			wifi_set_wps_cb(&wpsStatus);
			wpsTimer->initializeMs(15000,TimerDelegate(&wpsStart)).startOnce();
		} else {
			wifi_wps_disable();
			blinkTimer->initializeMs(1000, wpsBlinkIndicator).start();
			wpsTimer->stop();
		}
	}
}

// initialize WPS and start pairing
void wpsConnect() {
	wifi_wps_enable(WPS_TYPE_PBC);
	wifi_set_wps_cb(&wpsStatus);
	wpsStart();
}

void wpsInit(WPSDelegate delegate) {
	connectDelegate = delegate;
	wpsRepeatCounter=10;

	debugf("WPS config started");

	// blink with LED to display active WPS pairing
	pinMode(LED_PIN, OUTPUT);
	blinkTimer = new Timer();
	blinkTimer->initializeMs(100, wpsBlinkIndicator).start();

	// start WPS pairing after 5s delay
	wpsTimer = new Timer();
	wpsTimer->initializeMs(5000,TimerDelegate(&wpsConnect)).startOnce();

}

