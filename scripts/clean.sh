#!/bin/sh

echo "Cleaning general stuff"
if [ -x "$(command -v bleachbit)" ]; then
   bleachbit -c --preset > /dev/null
else
   echo "bleachbit not found, skipping it"
fi

echo "Cleaning package cache"
if [ -x "$(command -v yay)" ]; then
   yay -Sc --noconfirm > /dev/null
else
   echo "yay not found, using pacman"
   pacman -Sc --noconfirm > /dev/null
fi


