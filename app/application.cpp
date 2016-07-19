/*
 * Fluke 1900A interface
 *
 *  Created on: 17.07.2016
 *      Author: johndoe
 */

#include <user_config.h>
#include <SmingCore/SmingCore.h>
#include <user_interface.h>
#include <SmingCore/Network/TelnetServer.h>
#include "Fluke.h"
#include "wpsConnect.h"
#include "webserver.h"


#define debug

// definition of IO pins
#define SCL 	2
#define SDA		0

/*
 * tcp server for telnet connection
 */
#define MAXCLIENT 4
TcpServer *serialTelnet;
TcpClient *myClient[MAXCLIENT];

Fluke myFluke;

Timer cyclicTimer;

void cyclicProcess() {
	debugf("Read");
//#define debugWebServer
#ifdef debugWebServer
	float a = (float)rand()/(float)(RAND_MAX);

	sendMeasureToClients(a);
#else
	if (myFluke.readI2C()) {
		String message = myFluke.getPrintable();

		debugf("Mess: %s", message.c_str() );
		sendMeasureToClients((float)myFluke.getValue()/10);

		for (char i=0; i<MAXCLIENT; i++) {
			if (myClient[i]) {
				if (myFluke.isOverflow()) 	myClient[i]->writeString("Ovl ");
				else 						myClient[i]->writeString("    ");

				myClient[i]->writeString(message);
			}
		}
	}
#endif
}

// add up to 4 clients simultaneous
void onClient(TcpClient* client) {
	for (char i=0; i<MAXCLIENT; i++) {
		if (myClient[i] == NULL) {
			myClient[i] = client;
			return;
		}
	}
}

// unused, unknown
bool clientReceiveData (TcpClient& client, char *data, int size) {
	return true;
}

// remove client from the list
void clientComplete (TcpClient& client, bool successful){
	for (char i=0; i<MAXCLIENT; i++) {
		if (myClient[i] == &client) {
			myClient[i] = NULL;
		}
	}
}


//mDNS using ESP8266 SDK functions
void startmDNS() {
    struct mdns_info *info = (struct mdns_info *)os_zalloc(sizeof(struct mdns_info));
    info->host_name = (char *) "fluke"; // You can replace test with your own host name
    info->ipAddr = WifiStation.getIP();
    info->server_name = (char *) "http";
    info->server_port = 80;
    info->txt_data[0] = (char *) "path=/";
    espconn_mdns_init(info);
}

// start telnet server and cyclic process on connect
// announce name / IP with mDNS
void onConnect() {
	serialTelnet = new TcpServer(TcpClientConnectDelegate(onClient),TcpClientDataDelegate(clientReceiveData),TcpClientCompleteDelegate(clientComplete));
	serialTelnet->listen(23);
	startWebServer();
	cyclicTimer.initializeMs(100,TimerDelegate(&cyclicProcess)).start();
	startmDNS();  // Start mDNS "Advertise" of your hostname "test.local" for this example
}

// wps finished callback
void wpsFinished() {

}

// start wps pairing if no connection is possible
void noConnect() {
	wpsInit(WPSDelegate(wpsFinished));
}

/*
 * Init: start of application
 */
void init()
{
	WifiAccessPoint.enable(false);
	WifiStation.enable(false);

	Serial.begin(SERIAL_BAUD_RATE); // 115200 by default
	Serial.systemDebugOutput(false); // Disable debug output

	debugf("Starting");
	spiffs_mount(); // Mount file system, in order to work with files


#ifndef debugWebServer
	Wire.pins(SCL, SDA);
	Wire.begin();
#endif

	WifiStation.enable(true);
	WifiStation.waitConnection(ConnectionDelegate(&onConnect),10,ConnectionDelegate(&noConnect));
}
