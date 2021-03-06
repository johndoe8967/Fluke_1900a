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


//#define debug

// definition of IO pins
#define SCL 	2
#define SDA		0
#define INT_PIN 3

/*
 * tcp server for telnet connection
 */
#define MAXCLIENT 2
TcpServer *serialTelnet;
TcpClient *myClient[MAXCLIENT];

//#define USEFTP
//#define debugWebServer
//#define USEINTERRUPT

#ifdef USEFTP
FTPServer ftp;
#endif

Fluke myFluke;

#ifdef USEINTERRUPT
Timer *interruptTimer;
bool interruptReady = false;
void interruptHandler();
#endif

Timer cyclicTimer;
int reduction=1;
int reductionCounter=0;
long ovlFreq=0;

void sendData(String message, long value) {
	unsigned long timestamp = millis();

	reductionCounter++;
	if ((reductionCounter % reduction) == 0) {
		reductionCounter=0;
		debugf("Mess: %s", message.c_str() );
		sendMeasureToClients((float)value/10, timestamp);

		for (char i=0; i<MAXCLIENT; i++) {
			if (myClient[i]) {
				String timeString = "          ";
				timeString += String(timestamp);
				timeString = timeString.substring(timeString.length()-10);

				if (myFluke.isOverflow()) 	timeString += " Ovl ";
				else 						timeString += "     ";

				timeString += message;
				timeString += "\r\n";
				myClient[i]->writeString(timeString);
			}
		}
	}
}

void processData() {
#ifdef USEINTERRUPT
	if (interruptReady==false) return;
	interruptReady = false;
	debugf("Interrupt");
#endif
	myFluke.setOverflowFreq(ovlFreq);
	if (myFluke.readI2C()) {
		String message = myFluke.getPrintable();
		sendData(message, myFluke.getValue());
	}
}

void cyclicProcess() {
#ifdef debugWebServer
	long a = rand();
	String message = String(float(a/10),1);
	sendData(message,a);
#else
	processData();
#endif
}

#ifdef USEINTERRUPT
void IRAM_ATTR interruptHandler()
{
	interruptReady = true;
}
#endif


// add up to 4 clients simultaneous
void onClient(TcpClient* client) {
	for (char i=0; i<MAXCLIENT; i++) {
		if (myClient[i] == NULL) {
			myClient[i] = client;
			return;
		}
	}
	client->writeString("to many clients\n\r");
	client->close();
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
#ifdef USEFTP

void startFTP()
{
	if (!fileExist("index.html"))
		fileSetContent("index.html", "<h3>Please connect to FTP and upload files from folder 'web/build' (details in code)</h3>");

	// Start FTP server
	ftp.listen(21);
	ftp.addUser("me", "123"); // FTP account
}
#endif

// start telnet server and cyclic process on connect
// announce name / IP with mDNS
void onConnect() {
	serialTelnet = new TcpServer(TcpClientConnectDelegate(onClient),TcpClientDataDelegate(clientReceiveData),TcpClientCompleteDelegate(clientComplete));
	serialTelnet->listen(23);
	startWebServer();

#ifdef USEFTP
	startFTP();
#endif

	cyclicTimer.initializeMs(5,TimerDelegate(&cyclicProcess)).start();

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

	Serial.begin(115200); // 115200 by default
#ifdef debug
	Serial.systemDebugOutput(true); // Disable debug output
#else
	Serial.systemDebugOutput(false); // Disable debug output
#endif

	spiffs_mount(); // Mount file system, in order to work with files

#ifndef debugWebServer
	Wire.pins(SCL, SDA);
	Wire.begin();
#endif

	WifiStation.enable(true);
	WifiStation.setHostname("Fluke1900a");
	WifiStation.waitConnection(ConnectionDelegate(&onConnect),10,ConnectionDelegate(&noConnect));

#ifdef USEINTERRUPT
	PIN_FUNC_SELECT(PERIPHS_IO_MUX_U0RXD_U, FUNC_GPIO3);
	pinMode(INT_PIN, INPUT_PULLUP);

	attachInterrupt(INT_PIN, interruptHandler, RISING);
#endif
}
