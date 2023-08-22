#!/bin/bash

#To be used in conjunction with Jamf Trust Periodic SignOut Script

#If you changed the patch in the Jamf Trust Periodic SignOut Script, you'll need to change the path here to match.
logPath="/Library/Logs/JamfTrustSignOut.log"

if [[ -f /Library/Logs/JamfTrustSignout.log ]]; then
	timeOfLastAutoSignOut="$(tail -1 $logPath | awk '/Trust/ {print $9, $10}')"
	echo "<result>$timeOfLastAutoSignOut</result>"
else
	echo "<result>1970-01-01 00:00:00</result>"
fi
