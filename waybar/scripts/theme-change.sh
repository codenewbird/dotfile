#!/usr/bin/bash

if test -s ./curtheme 
then
    curtheme=$(cat ./curtheme)
    rm $HOME/.config/waybar/colors/color.css;
    if [ "$curtheme" == "dark" ]
    then
        ln -s $HOME/.config/waybar/colors/primary.css $HOME/.config/waybar/colors/color.css
        echo "primary" > ./curtheme
    else
        ln -s $HOME/.config/waybar/colors/dark.css $HOME/.config/waybar/colors/color.css
        echo "dark" > ./curtheme
    fi
else
    echo "primary" > ./curtheme
    ln -s $HOME/.config/waybar/colors/primary.css $HOME/.config/waybar/colors/color.css
fi
    
pkill waybar && waybar &
