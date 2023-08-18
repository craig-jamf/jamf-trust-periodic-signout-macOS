#!/bin/bash

if [[ -f /Library/Logs/JamfTrustSignout.log ]]; then
	timeOfLastAutoSignOut="$(tail -1 /Library/Logs/JamfTrustSignout.log | awk '/Trust/ {print $9, $10}')"
	echo "<result>$timeOfLastAutoSignOut</result>"
else
	echo "<result>1970-01-01 00:00:00</result>"
fi
