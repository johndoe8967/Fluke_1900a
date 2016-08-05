/*
 * webserver.h
 *
 *  Created on: 19.06.2016
 *      Author: johndoe
 */

#ifndef INCLUDE_WEBSERVER_H_
#define INCLUDE_WEBSERVER_H_
#include <SmingCore/SmingCore.h>


void startWebServer();
void sendMeasureToClients(float value, unsigned long time);

extern int reduction;
extern long ovlFreq;

#endif /* INCLUDE_WEBSERVER_H_ */
