# UART_US_VHDL

**1.1 Overview**

This IP Core is an implementation of the Universal Asynchronous Receiver/Transmitter
(UART) protocol. This core is designed for FPGA and ASIC that need to interface with other
devices and who share this standard.

A reference design has been provided in order to test the system using an UltraSound Sensor and send the measurement to an external device. Please read documentation for more details. 

**1.2 Features**

Here are the main features :

- Single channel UART
- Programmable baud rates : 9600, 19200, 38400, 57600, 115200 bps
- 8-N-1 format : 1 start bit, 8 bits data, no parity bit, 1 stop bit
- Entirely portable IP
- Fully synchronous design

**1.3 Deliverables**

- Synthesizable VHDL source code
- Verification testbenches
- User Guide
