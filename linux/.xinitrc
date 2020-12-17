setxkbmap -layout "uni_fork(us_universal),uni_fork(ru_universal)" -option "" -option "grp:win_space_toggle,grp_led:scroll" -print | xkbcomp -I"$HOME/.config/xkb" - "${DISPLAY%%.*}"
