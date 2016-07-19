/*
 * Fluke.h
 *
 *  Created on: 17.07.2016
 *      Author: johndoe
 */

#ifndef APP_FLUKE_H_
#define APP_FLUKE_H_

#include <SmingCore/SmingCore.h>

#define I2CAddress 0x03

// definitions of status bit masks
#define EINER 0x01
#define ZENER 0x02
#define HUNDERTER 0x04
#define MEGA 0x08
#define FREQ 0x10
#define OVL 0x20
#define TRIG 0x40

class Fluke {
public:
	Fluke();
	virtual ~Fluke();
	String getPrintable();
	long getValue() const {return value;}
	bool readI2C();

	bool newMeasurementAvailable() const { return data[3] & TRIG;}
	bool isFrequency() const {return data[3] & FREQ;}
	bool isOverflow() const {return data[3] & OVL;}

private:
	void addDigit(int digit);
	void calcNumberFromDigits();
	void calculateFrequency();

	long value;
	int data[4];
};

#endif /* APP_FLUKE_H_ */
