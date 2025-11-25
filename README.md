udping - kenko edit
======
a [love2d](https://love2d.org)-based network monitor, originally made by Xkeeper0.

this utility constantly messages a udp echo server with incrementing numbers, and measures the latency of those packets as they return. results will be biased on physical distance to server. lost packets are indicated by flashing red/white. this consumes very little traffic as it is primarily focused on tracking connection quality and not bandwidth.

using this, you can judge your internet's stability - a stable connection should be very consistent with no packet loss.

the release file is a standard [love2d executable](https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable).

## kenko edit

my only edits are that i ripped out all sound elements, and added commandline arguments to define which server you want to ping, so you can test different locations.

## commandline args
- `-a="[ip]"` - ip of server to ping
- `-p="[port]"` - port of server

## servers
by default, this still connects to `mini.xkeeper.net` at port `37800` if no arguments are given.
otherwise, you can try these servers:
- mine:
    - `91.98.80.75` - Falkenstein, Germany
    - `74.91.123.133` - NYC, New York, US
    - `5.161.235.112` - Ashburn, Virginia, US
- Xkeeper0:
    - `mini.xkeeper.net` - San Francisco, California, US?

## how to host server?
code for a simple ping server can be found here: http://mini.xkeeper.net/udpserver.c

you can compile it on linux with gcc: `gcc udpserver.c -o udpserver`

then launch: `./udpserver 37800`

if you spin up a 24/7 ping server on a stable VPS, let me know and i can add your location here!

## note

while no usage data is stored or tracked on any of these servers, please remember to be gentle with them.