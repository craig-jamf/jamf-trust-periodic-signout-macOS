# jamf-trust-periodic-signout-macOS

A core tenant of Trusted Access is user identity. In simple terms, this is when an Identity Provider confirms that user is indeed who they say they are. This is typically achieved using authentication methods such as username & password, multifactor and passwordless.

As Jamf Trust requires that end users confirm their identity in order to enable Zero Trust Network Access, administrators may want to enforce periodic reauthentication against their IdP as a way to further ensure a trusted user is on a trusted device. This can be achieved by running a bash script which leverages Jamf Trust's [URL Schemes](https://learn.jamf.com/bundle/jamf-security-documentation/page/Pushing_the_App.html#ariaid-title7) to sign the user out of Jamf Trust on their MacOS device.

You can learn more about Jamf Trust at [jamf.com](https://jamf.com) and [trusted.jamf.com](https://trusted.jamf.com).
## Features

### Sign Out Triggers

As the script is configurable, it allows administrators to configure when the sign out is triggered on their device fleet. You can configure the scipt so it triggers based off the following criteria.

- Sign out at a set interval (e.g. every 8 hours)

- Sign out at a set time (e.g. 3pm daily)

- Sign out on device boot (e.g. user restarts Mac)

The script also support any combination of these working together. So for example, it could be every time the computer reboots and at 0:00 each day.

### Logging

The script also allows admins to log when a sign out is triggered on the Mac. By default this log is stored in `/Library/Logs/JamfTrustSignOut.log` but this can be changed by the script.

> Note that this is when a sign out is triggered, not necessarily when a sign out occurred. So, if a user is already signed out, a sign out will still trigger and this attempt will be logged.

## Jamf Pro Extension Attribute

If the admin is deploying the script via Jamf Pro and is enabling logging, they can take advantage of the jamfTrustAutoSignOut_ExtensionAttribute.sh script below. This will pull the last periodic sign out time from the logs into Jamf Pro, every time the device executes an inventory update with Jamf Pro.

## How it works

On a high level, the `jamfTrustPeriodicSignOut.sh` script is run, creates the following the Mac:

- A Launch Daemon at `/Library/LaunchDaemons/com.jamftrust.automateSignOut`
- A script at `/Library/Scripts/jamfTrustSignOut.sh`
- (If logging is enabled) A log file at `/Library/Logs/JamfTrustSignOut.log`

The Launch Daemon holds the values of when the script should trigger. You can define the trigger conditions by modifying the variables at the beginning of `jamfTrustPeriodicSignOut.sh`. All variables are commented explaining what they do.

When the script is triggered, it initiates a log out of the Jamf Trust application on the Mac and writes the logout time to the logfile.

## Deploying locally

To deploy locally, follow the steps below. Deploying locally should mainly be done for testing before deploying via a UEM to your larger fleet.

### Steps

1. Download `jamfTrustPeriodicSignOut.sh` to your local Mac.
2. Set owner on script (must be root) `chown root:wheel /path/to/jamfTrustPeriodicSignOut.sh`
3. Set permissions on script `chmod 744 /path/to/jamfTrustPeriodicSignOut.sh`
4. Edit flags in script to set your sign out paramaters and save file.
5. Execute script `bash /path/to/jamfTrustPeriodicSignOut.sh`

## Deploying via Jamf Pro

Periodic Sign Out was made to be deployed via Jamf Pro. Follow the  [YouTube tutorial](https://www.youtube.com/watch?v=kimkYnufFHg) or the steps below to deploy.

### Steps

1. Add `jamfTrustPeriodicSignOut.sh` as a script to Jamf Pro. Edit flags in script to set your sign out parameters.[Scripts Documentation](https://learn.jamf.com/bundle/jamf-pro-documentation-10.41.0/page/Scripts.html)
2. Add `jamfTrustPeriodicSignOut_ExtensionAttribute.sh` as extension attribute to Jamf Pro. Set `Data Type` to `Date`. [Extension Attributes Documentation](https://learn.jamf.com/bundle/jamf-pro-documentation-10.41.0/page/Computer_Extension_Attributes.html)
3. Create Policy in Jamf Pro. Add Script from step 1. Script only needs to be triggered once. [Policies Documentation](https://learn.jamf.com/bundle/jamf-pro-documentation-10.41.0/page/Policies.html)
4. Scope Policy to MacOS Devices [Scope Documentation](https://learn.jamf.com/bundle/jamf-pro-documentation-10.41.0/page/Scope.html)
5. Periodic Sign Out will add and load the Launch Daemon once the policy is executed on the MacOS Device. It will trigger a sign out immediately if `runAtLoad=true`. Otherwise, it will wait for the first periodic trigger.

6. The extension attribute will populate every time a Jamf Inventory Update is executed on the device.

## Uninstalling

As the script deploys a Launch Daemon and a log out script to your device, you must remove both from the device if you no longer to have periodic logouts.

> Removing the Policy from Jamf Pro, will not remove/stop the periodic sign out.

To uninstall this from the device, there is a flag in the script itself `removeFromDevice=0`. Simply set this to `1` and run the script again. This will remove the Launch Daemon and Script from the device.

To remove logs from the device you will need to set the `deleteLogsOnInstall` to `1`.
