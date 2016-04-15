#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi


[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# disable speaker beep
xset -b

# notification
dunst -config ~/.i3/dunstrc &

# NetworkManager applet
>> /dev/null which nm-applet && nm-applet &

# make it easy on the eyes
redshift -O 3200 -l 17:78 -t 4500:3500 -g 0.95:1.0:0.90 &

# change caps lock to ESC
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape' &

# add font tamsyn
xset fp+ /usr/share/fonts/local
xset +fp /usr/share/fonts/ttf
xset fp rehash

export QT_STYLE_OVERRIDE=GTK+

xsetroot -cursor_name left_ptr &

i3
