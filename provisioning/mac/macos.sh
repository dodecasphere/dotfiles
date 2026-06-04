#!/usr/bin/env bash

# Ask for the computer name, defaulting to whatever it's currently set to.
DEFAULT_COMPUTER_NAME="$(scutil --get ComputerName 2>/dev/null || echo "MacBook")"
printf '%s' "Computer name [${DEFAULT_COMPUTER_NAME}]: "
read COMPUTER_NAME
COMPUTER_NAME="${COMPUTER_NAME:-$DEFAULT_COMPUTER_NAME}"
SCREENSHOTS_FOLDER="${HOME}/Screenshots"

#
# Run some miscellaneous commands
#

# Close any open System Settings panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Settings" to quit'

# Ask for the administrator password upfront (provision.sh already runs a sudo
# keep-alive loop for the whole run, so we don't start another one here).
sudo -v

###############################################################################
# Computer & Host name                                                        #
###############################################################################

# Set computer name (as done via System Settings → General → Sharing).
# ComputerName is the friendly display name and can contain anything, but
# HostName/LocalHostName only allow letters, digits, and hyphens (LocalHostName
# rejects anything else with "SCPreferencesSetLocalHostName() failed: Invalid
# argument"), so derive a sanitized variant: drop apostrophes, turn other
# invalid runs into hyphens (e.g. "Michael's MacBook Pro" → "Michaels-MacBook-Pro").
SAFE_NAME="$(printf '%s' "$COMPUTER_NAME" | sed -E "s/['’]//g; s/[^A-Za-z0-9-]+/-/g; s/^-+//; s/-+$//")"
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$SAFE_NAME"
sudo scutil --set LocalHostName "$SAFE_NAME"
# NetBIOS names are additionally capped at 15 characters, conventionally uppercase.
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$(printf '%.15s' "$SAFE_NAME" | tr '[:lower:]' '[:upper:]')"
echo "Computer name: $COMPUTER_NAME (hostname: $SAFE_NAME)"

###############################################################################
# General                                                                     #
###############################################################################

# Set highlight color to green
# defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# Don’t display the annoying prompt when quitting iTerm
doing "Disabling annoying iTerm quit prompt..."
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Expand save panel by default
doing "Expanding Save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
doing "Expanding Print panel by default..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
doing "Saving to disk (not iCloud) by default..."
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
doing "Enabling auto quit printer app when jobs complete..."
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
doing "Disabling 'are you sure?' dialog when opening apps..."
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable Resume system-wide
doing "Disabling Resume system-wide..."
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
doing "Disabling auto termination of inactive apps..."
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
doing "Enabling reveal of details under clock on login window..."
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set some login window text
# doing "Setting login window text..."
# defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Open the pod bay doors, Hal..."

# Set menubar date format
# Since Big Sur the menu bar clock is owned by ControlCenter (not SystemUIServer),
# and DateFormat alone is ignored — the companion keys + a ControlCenter restart
# are required for the format to actually take effect.
doing "Setting menubar date format..."
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 1
defaults write com.apple.menuextra.clock Show24Hour -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool false
killall ControlCenter 2> /dev/null

# # Set menubar items as visible/invisible
# doing "Setting menubar items as visible/invisible..."
# defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" -bool true
# defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.airplay" -bool true
# defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
# defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.textinput" -bool true
# defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true
# defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.vpn" -bool true
# defaults delete com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.clock"

# Disable automatically rearrange Spaces based on recent use
doing "Disabling automatically rearrange Spaces based on recent use..."
defaults write com.apple.dock mru-spaces -bool false

# Disable automatically switching to Space with open windows for that Application
# doing "Disabling automatically switching to Space with open windows for that Application..."
# defaults delete com.apple.dock workspaces-auto-swoosh

# Make Crash Reporter appear as a notification
doing "Making Crash Reporter appear as a notification..."
defaults write com.apple.CrashReporter UseUNC 1

# Disable smart quotes as they’re annoying when typing code
doing "Disabling smart quotes and dashes..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set a really fast keyboard repeat rate.
doing "Setting fast keyboard repeat rate..."
# defaults write -g KeyRepeat -int 0
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Disable press-and-hold for keys in favor of key repeat.
doing "Disabling press-and-hold for keys in favor of key repeat..."
defaults write -g ApplePressAndHoldEnabled -bool false

# Require password immediately after sleep or screen saver.
# The old `com.apple.screensaver askForPassword` defaults are no longer enforced
# (Sonoma+). sysadminctl sets the lock grace period and actually sticks.
# `-password -` prompts for your login password (no echo) when this runs.
doing "Requiring password immediately after the screen saver / display sleep..."
sysadminctl -screenLock immediate -password -

# Save screenshots to the ~/Screenshots folder
doing "Requiring saving screenshots to the ~/Screenshots folder..."
mkdir -p "${SCREENSHOTS_FOLDER}"
defaults write com.apple.screencapture location -string "${SCREENSHOTS_FOLDER}"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
doing "Require saving screenshots in PNG format..."
defaults write com.apple.screencapture type -string "png"

# Hot corners
# Possible values:
#   0: no-op
#   2: Mission Control
#   3: Show application windows
#   4: Desktop
#   5: Start screen saver
#   6: Disable screen saver
#   7: Dashboard
#  10: Put display to sleep
#  11: Launchpad
#  12: Notification Center
doing "Setting bottom-left hot corner to Start screen saver..."
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

doing "Setting top-left hot corner to Mission Control..."
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0

doing "Setting top-right hot corner to Show Desktop..."
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0

# Trackpad: enable tap to click for this user and for the login screen
doing "Enabling tap to click for this user and for the login screen..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1 # -bool true ??
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Use scroll gesture with the Ctrl (^) modifier key to zoom
doing "Using scroll gesture with the Ctrl (^) modifier key to zoom..."
sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
sudo defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
sudo defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
doing "Enabling finder quit..."
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
doing "Disabling finder window animations..."
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
doing "Setting user folder as default finder window..."
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Always open everything in Finder's list view. This is important.
# (domain is case-sensitive — must be lowercase `com.apple.finder`)
doing "Always open everything in Finder's list view..."
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# Enable snap-to-grid for icons on the desktop and in other icon views
doing "Setting up icon snap, size and spacing..."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy dateModified" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 96" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 96" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 96" ~/Library/Preferences/com.apple.finder.plist

# Restart Finder so the view-style and icon-view tweaks above take effect.
killall Finder

# Finder: show status bar
doing "Showing Status and Path bars in Finder..."
defaults write com.apple.finder ShowStatusBar -bool true
# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show file extensions by default
doing "Showing file extensions by default..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing file extensions
doing "Disabling the warning when changing file extensions..."
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
doing "Disabling creating .DS_Store files on network or USB volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Keep folders on top when sorting by name
doing "Enabling folders on top..."
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Enable spring loading for directories
doing "Enabling spring loading for directories..."
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
doing "Removing spring loading delay on directories..."
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Show ~/Library folder
doing "Showing ~/Library in Finder..."
chflags nohidden ~/Library

# Show the /Volumes folder
doing "Showing the /Volumes library in Finder..."
sudo chflags nohidden /Volumes

# Symlink ~/Sites to dropbox (safely — never blow away a real directory)
doing "Linking ~/Sites to Dropbox..."
if [ -L ~/Sites ]; then
  ln -sfn ~/Dropbox/Sites ~/Sites   # already a symlink: (re)point it
elif [ -e ~/Sites ]; then
  echo "~/Sites exists and is not a symlink — leaving it alone"
else
  ln -s ~/Dropbox/Sites ~/Sites
fi

# Symlink ~/Library/Fonts to dropbox
# doing "Linking ~/Library/Fonts to Dropbox..."
# sudo rm -rf ~/Library/Fonts
# ln -s ~/Dropbox/Fonts/installed ~/Library/Fonts

###############################################################################
# Energy saving                                                               #
###############################################################################

# Enable lid wakeup
doing "Enabling lid wakeup ..."
sudo pmset -a lidwake 1

# Restart automatically on power loss
doing "Enabling restart automatically on power loss ..."
sudo pmset -a autorestart 1

# Restart automatically if the computer freezes
doing "Enabling restart automatically if computer freezes ..."
sudo systemsetup -setrestartfreeze on

# Sleep the display after 15 minutes
doing "Enabling display sleep after 15 minutes ..."
sudo pmset -a displaysleep 15

# Disable machine sleep while charging
doing "Disabling sleep while charging ..."
sudo pmset -c sleep 0

# Set machine sleep to 5 minutes on battery
doing "Enabling sleep after 5 minutes while on battery power ..."
sudo pmset -b sleep 5

# Never go into computer sleep mode
doing "Setting never go into computer sleep mode ..."
sudo systemsetup -setcomputersleep Off > /dev/null

###############################################################################
# Dock                                                                        #
###############################################################################

# Set the icon size of Dock items to 64 pixels, 72 magnified
doing "Setting the icon size of Dock items to 64 pixels, 72 magnified..."
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 64
defaults write com.apple.dock largesize -int 80

# Autohide the Dock
doing "Setting the dock to autohide..."
defaults write com.apple.dock autohide -bool true

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use
# the Dock to launch apps.
doing "Clearing all apps from the Dock..."
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

doing "Adding System Settings to the Dock..."
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

doing "Adding Folders to the Dock..."
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${HOME}</string><key>_CFURLStringType</key><integer>0</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${HOME}/Documents</string><key>_CFURLStringType</key><integer>0</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${HOME}/Downloads</string><key>_CFURLStringType</key><integer>0</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>1</integer><key>arrangement</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${HOME}/Dropbox</string><key>_CFURLStringType</key><integer>0</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications</string><key>_CFURLStringType</key><integer>0</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"

###############################################################################
# TextEdit                                                                    #
###############################################################################

doing "Setting up TextEdit..."

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0
# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Activity Monitor                                                            #
###############################################################################

doing "Setting up Activity Monitor..."

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the automatic update check
doing "Enabling automatic update check..."
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
doing "Enabling checking for software updates daily..."
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
doing "Enabling downloading updates in the background..."
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
doing "Enabling installing system files and security updates..."
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
doing "Enabling app auto-update..."
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
doing "Preventing Photos from opening automatically when devices are plugged in..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Apps                                                                        #
###############################################################################

# Disable Chrome's annoying two-finger swipe gesture
doing "Disabling the Chrome annoying two-finger swipe..."
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

# Make Chrome windows reopen on their assigned desktops
doing "Making Chrome windows reopen on their assigned desktops..."
defaults write com.google.Chrome NSWindowRestoresWorkspaceAtLaunch -bool YES

# Make Chrome use the system-native print preview dialog
doing "Making Chrome use the system-native print preview dialog..."
defaults write com.google.Chrome DisablePrintPreview -bool true

# Make Chrome expand the print dialog by default
doing "Making Chrome expand the print dialog by default..."
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# Transmission.app                                                            #
###############################################################################

doing "Setting up Transmission..."

# Use `~/Documents/Torrents` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

# Use `~/Downloads` to store completed downloads
defaults write org.m0k.transmission DownloadLocationConstant -bool true

# Don’t prompt for confirmation before downloading
defaults write org.m0k.transmission DownloadAsk -bool false
defaults write org.m0k.transmission MagnetOpenAsk -bool false

# Don’t prompt for confirmation before removing non-downloading active transfers
defaults write org.m0k.transmission CheckRemoveDownloading -bool true

# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false
# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false

# IP block list.
# john.bitsurge.net has been dead for years; Naunter/BT_BlockLists is the
# maintained successor (https://github.com/Naunter/BT_BlockLists).
defaults write org.m0k.transmission BlocklistNew -bool true
defaults write org.m0k.transmission BlocklistURL -string "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz"
defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

# Randomize port on launch
defaults write org.m0k.transmission RandomPort -bool true

###############################################################################
# Finish                                                                      #
###############################################################################

doing "Restarting everything..."

for app in "Activity Monitor" "Calendar" "Contacts" "cfprefsd" \
    "Dock" "Finder" "Google Chrome" "Mail" "Messages" \
    "Photos" "Safari" "SystemUIServer" "Transmission"; do
    killall "${app}" &> /dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
