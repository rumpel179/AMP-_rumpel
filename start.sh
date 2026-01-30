#!/bin/bash

export WINEPREFIX="/home/amp/wineprefixes/echo_of_elysium"
export WINEDEBUG="-all"

cd /home/amp/servers/echo_of_elysium || exit 1

wine EchoOfElysiumServer.exe
