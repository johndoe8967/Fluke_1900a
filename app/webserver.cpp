/*
 * webserver.cpp
 *
 *  Created on: 19.06.2016
 *      Author: johndoe
 */

#include "webserver.h"

int totalActiveSockets = 0;
HttpServer server;

WebSocketsList &clients=server.getActiveWebSockets();

void onIndex(HttpRequest &request, HttpResponse &response)
{
	TemplateFileStream *tmpl = new TemplateFileStream("index.html");
	auto &vars = tmpl->variables();
	response.sendTemplate(tmpl); // this template object will be deleted automatically
}

void onFile(HttpRequest &request, HttpResponse &response)
{
	String file = request.getPath();
	if (file[0] == '/')
		file = file.substring(1);

	if (file[0] == '.')
		response.forbidden();
	else
	{
		response.setCache(86400, true); // It's important to use cache for better performance.
		response.sendFile(file);
	}
}

void wsConnected(WebSocket& socket)
{
	totalActiveSockets++;
}
void wsMessageReceived(WebSocket& socket, const String& message)
{
	debugf("WebSocket message received:\r\n%s", message.c_str());

	DynamicJsonBuffer jsonBuffer;
	JsonObject& root = jsonBuffer.parseObject(message);

	String value = root["type"].asString();
	if (value==String("JSON")) {
		value = root["msg"].asString();
		if (value==String("reduction")) {
			reduction = root["value"];
		}
		if (value==String("ovlFreq")) {
			ovlFreq = root["value"];
		}
		if (value==String("WIFI")) {
			String SSID = root["SSID"].asString();
			String PWD = root["PWD"].asString();
			WifiStation.config(SSID,PWD);
		}
	}
}

void wsBinaryReceived(WebSocket& socket, uint8_t* data, size_t size)
{
	Serial.printf("Websocket binary data recieved, size: %d\r\n", size);
}

void wsDisconnected(WebSocket& socket)
{
	totalActiveSockets--;
}

void sendMeasureToClients(float value, unsigned long time) {
	String message = "{\"type\": \"JSON\", \"msg\": \"measure\", \"value\": " + String(value,2) + ", \"time\": " + String((float)(time/10)/100,2) + "}";
	for (int i = 0; i < clients.count(); i++)
		clients[i].sendString(message);
}

void startWebServer()
{
	server.listen(80);
	server.addPath("/", onIndex);
	server.setDefaultHandler(onFile);

	// Web Sockets configuration
	server.enableWebSockets(true);
	server.setWebSocketConnectionHandler(wsConnected);
	server.setWebSocketMessageHandler(wsMessageReceived);
	server.setWebSocketBinaryHandler(wsBinaryReceived);
	server.setWebSocketDisconnectionHandler(wsDisconnected);

	Serial.println("\r\n=== WEB SERVER STARTED ===");
	Serial.println(WifiStation.getIP());
	Serial.println("==============================\r\n");

}
