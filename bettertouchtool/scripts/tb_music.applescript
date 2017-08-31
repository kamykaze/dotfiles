-- This script can be used in conjunction with Better Touch Tool to display the currently playing track on the MacBook Pro TouchBar
-- Original script here: https://lucatnt.com/2017/02/display-the-currently-playing-track-in-itunesspotify-on-the-touch-bar
-- Adapted by Kam to loop through multiple apps

-- list of available music apps to check (start with most used first to avoid unnecessary checks)
set musicApps to {"Spotify", "iTunes"}

repeat with i from 1 to (count musicApps)
    set currentApp to item i of musicApps
    using terms from application "iTunes" -- using terms is needed for compiling (support player state), but not actually used
        if application currentApp is running then
            tell application currentApp
                set playerstate to get player state
                if playerstate is playing then
                    return (get artist of current track) & " - " & (get name of current track)
                end if
            end tell
        end if
    end using terms from
end repeat

