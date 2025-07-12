#!/usr/bin/bash

if test -s /tmp/curtheme 
then
    curtheme=$(cat /tmp/curtheme)
    rm $HOME/.config/waybar/colors/color.css;
    if [ "$curtheme" == "dark" ]
    then
        ln -s $HOME/.config/waybar/colors/primary.css $HOME/.config/waybar/colors/color.css
        echo "primary" > /tmp/curtheme
    else
        ln -s $HOME/.config/waybar/colors/dark.css $HOME/.config/waybar/colors/color.css
        echo "dark" > /tmp/curtheme
    fi
else
    echo "primary" > /tmp/curtheme
    ln -s $HOME/.config/waybar/colors/primary.css $HOME/.config/waybar/colors/color.css
fi
    
pkill waybar && waybar &
