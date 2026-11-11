# Remote Desktop Users (Domain Users)
# Computer Configuration - Preferences - Control Panel Settings - Local Users and Groups
# Add Group - Update Remote Desktop Users - Domain Users

net localgroup "Remote Desktop Users" "CORP\Domain Users" /add
