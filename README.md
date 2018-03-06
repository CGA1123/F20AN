# Advanced Network Security (F20AN) 2017/18 Coursework
## Investigation of DNS Rebinding Attacks
This repo contains work submitted as part of F20AN Advanced Network Security at Heriot-Watt University in the 2nd Semester of the 2017/18 Academic Year.

This project investigated DNS Rebinding Attacks. It implements an exploit against a vulnerability in the Transmission BitTorrent Client in versions < 2.9.3 (or pre transmission/transmission@cf7173df930cfa7ac1b1b0e9027c1deffd0b3c84 See transmission/transmission#468 for more details).

There is a [guide](./HOW_TO.md) to help set up the VMs required to demonstrate this exploit.

The attack will attempt to download a `.profile` file into the targets home directory.
