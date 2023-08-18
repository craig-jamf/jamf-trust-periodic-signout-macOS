#!/bin/bash

#Set removeFromDevice to 1 to remove all files and bootout the launch daemon. If using in conjunction with jamfTrustAutoSignOut_ExtensionAttribute.sh. That must be removed from Jamf Pro also.
removeFromDevice=0

#The sign out will trigger ever x number of seconds (signOutIntervalPeriod) from when the launch daemon is loaded. Set to 0 disable.
signOutPeriodiodically=1

#Set the Sign Out Interval Period in Seconds. Default is 8 hours.
signOutIntervalPeriod=120
#Signs the device out at the same time each day. If the device is offline during this time, signout will be triggered on each boot
signOutAtSetTimeDaily=1

#Sign out hour of day (0..23)
signOutHour=16

#Sign out minute of hour (0..59)
signOutMinute=30

#Set allowLogging to 0 to disable logging. 
allowLogging=1

#Logs will be saved at logPath. If using lastJamfTrustAutoSignout 
logPath="/Library/Logs/JamfTrustSignOut.log"

#Command to write time of last automatic sign out to the log
logCommand="echo \"Automatically signed out out of Jamf Trust at \$(date +%F\ %T)\" >> $logPath"

#Setting deleteLogsOnInstall to 1 will delete the existing log file if on exists.
deleteLogsOnInstall=1

#Run when the launchDaemon is loaded (when the computer boots). Set to false to only run when triggered.
runAtLoad=false

#Name of our Launch Daemon
launchDaemonName="com.jamftrust.automateSignOut"

#Where the Launch Daemon is stored
launchDaemonPath="/Library/LaunchDaemons/com.jamftrust.automateSignOut"

#Where the script is run
signOutScriptPath="/Library/Scripts/jamfTrustSignOut.sh"

#Command to sign out of Jamf Trust
signOutCommand="open -a \"Jamf Trust\" \"com.jamf.trust://?action=sign_out\""

#Remove Any Previous Configuration

echo "Cleaning up old files..."

#Delete launch daemon if it exists
if [[ -f "$launchDaemonPath.plist" ]];then
	rm "$launchDaemonPath.plist"
	fi

#Delete Sign Out script
if [[ -f $signOutScriptPath ]]; then
	rm $signOutScriptPath
fi

if [[ -f $logPath ]]; then
	rm $logPath
fi

#Bootout the daemon if its already running
if [[ $(launchctl list | grep $launchDaemonName) != "" ]]; then
	launchctl bootout system/$launchDaemonName
fi

#if removeFromDevice is set to 1. Exit code without installing. 
if [[ $removeFromDevice = 1 ]]; then
	echo "Jamf Trust Auto SignOut has been fully removed from your device."
	exit
fi

echo "Creating sign out script.."
touch $signOutScriptPath
chmod 777 $signOutScriptPath
echo $signOutCommand >> $signOutScriptPath

#Add logging to script if allowed
if [[ $allowLogging=1 ]]; then
	echo $logCommand >> $signOutScriptPath
fi

echo "Creating launch daemon..."
defaults write $launchDaemonPath Label -string com.jamftrust.automateSignOut
defaults write $launchDaemonPath ProgramArguments -array-add -string /bin/bash /Library/Scripts/jamfTrustSignOut.sh
defaults write $launchDaemonPath RunAtLoad -bool $runAtLoad

if [[ $signOutPeriodiodically = 1 ]]; then
	defaults write $launchDaemonPath StartInterval -int $signOutIntervalPeriod
fi

if [[ $signOutAtSetTimeDaily = 1 ]]; then
	defaults write $launchDaemonPath StartCalendarInterval -dict-add Minute -int $signOutMinute Hour -int $signOutHour
fi

echo "Setting permissions..."
chown root:wheel "$launchDaemonPath.plist"
chmod 644 "$launchDaemonPath.plist"

chown root:wheel $signOutScriptPath
chmod 744 $signOutScriptPath

echo "Launching daemon..."
launchctl bootstrap system "$launchDaemonPath.plist"
exit