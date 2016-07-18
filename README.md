# Fluke 1900A interface
ESP8266 + CPLD interface to the DOU connector


## Summary
* I2C connection to a custom built CPLD
* receives the actual value and status bits
* calculates 
	frequency
	period time
	overflow
* triggered updates of the measurement
* telnet server sends measurement to remote PC
	useable in combination with virtual serial ports (e.g. com0com) and multimess
* mDNS 
* stationary (WIFI client) with WPS authentication
* webserver hosts a simple google chart based diagram

## Additional needed software
* Sming framework https://github.com/SmingHub/Sming
* com0com
* bonjour service

