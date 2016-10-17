#!/bin/bash

while read -r _; do
	winid="$(herbstclient attr clients.focus.winid 2>/dev/null)"
	err="$?"
	# When there is no window focused, skip this one
	if [[ "$err" -ne 0 ]]; then
		# notify-send "Skipping" 
		continue
	fi
	# echo "Switching to $winid"

	xwininfo="$(xwininfo -id "$winid")"

	# pos[0] is x of the top-left corner, pos[1] y
	cornerpos=( $(echo "$xwininfo" | awk '$1=="Corners:"{print $2}' | tr '+-' '  ') )
	width="$(echo "$xwininfo" | awk '$1=="Width:"{print $2}')"
	height="$(echo "$xwininfo" | awk '$1=="Height:"{print $2}')"

	eval "$(xdotool getmouselocation --shell)" # now X, Y contain the mouse location

	# check if mouse is outside of the newly focused window
	# (so the mouse isn't "warped" when the window was selected by mouse movement)
	if (( X < cornerpos[0] )) || (( X > cornerpos[0] + width)) \
	|| (( $Y < ${cornerpos[1]} )) || (( $Y > ${cornerpos[1]} + $height)); then
		(( centerX = ${cornerpos[0]} + ($width/2) ))
		(( centerY = ${cornerpos[1]} + ($height/2) ))
		xdotool mousemove $centerX $centerY
	fi
done < <(herbstclient --idle '(focus_changed|fullscreen|focus_moved)') # focus_moved is a custom hook
