/*
 * Fluke.cpp
 *
 *  Created on: 17.07.2016
 *      Author: johndoe
 */

#include "Fluke.h"

#define BYTES2READ 4

Fluke::Fluke() {
	// TODO Auto-generated constructor stub

}

Fluke::~Fluke() {
	// TODO Auto-generated destructor stub
}

bool Fluke::readI2C() {
	uint8_t ret = Wire.requestFrom(I2CAddress,BYTES2READ,true);
	if (ret == 0) {
		Wire.endTransmission(true);
	}
#ifdef debug
	debugf("Read %d bytes",ret);
#endif
	for (int i=0; i<ret; i++) {
		if (Wire.available()) {
			data[i] = Wire.read();
		}
	}

#ifdef debug
	for (int i=0; i<ret; i++) {
		String a = "data [";
		a += String(i);
		a += "]: ";
		a += String(data[i]);
		debugf("%s",a.c_str());
	}
#endif

	if (this->newMeasurementAvailable()) {
		calculateFrequency();
		return true;
	} else {
		return false;
	}
}

void Fluke::addDigit(int digit) {
	int temp;
	value *= 10;
	temp = digit & 0x0f;
	value  += temp;
	value *= 10;
	temp = digit & 0xf0;
	temp >>= 4;
	value += temp;
}

void Fluke::calcNumberFromDigits() {
	value=0;
	this->addDigit(data[2]);
	this->addDigit(data[1]);
	this->addDigit(data[0]);
}


void Fluke::calculateFrequency() {
	calcNumberFromDigits();

	if (data[3] & EINER) {

	} else if (data[3] & ZENER) {
		value *= 10;
	} else if (data[3] & HUNDERTER) {
		value *= 100;
	}

	if (data[3] & MEGA) {
		value *= 1000;
	}
}

String Fluke::getPrintable() {
	String test = "          ";
	test += String(float(value/10),1);
	test = test.substring(test.length()-9);

	if (data[3] & FREQ) {
		test += " Hz";
	} else {
		test += " ns";
	}
	return test;
}
