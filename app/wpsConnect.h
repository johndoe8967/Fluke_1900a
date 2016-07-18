/*
 * wpsConnect.h
 *
 *  Created on: 18.07.2016
 *      Author: johndoe
 */

#ifndef APP_WPSCONNECT_H_
#define APP_WPSCONNECT_H_

typedef Delegate<void()> WPSDelegate;
void wpsInit(WPSDelegate delegate);

#endif /* APP_WPSCONNECT_H_ */
