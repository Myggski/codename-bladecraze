#!/bin/bash

packages="lua5.1 luarocks"

for package in $packages;
do
    sudo apt-get install -y $package
done

# Installing love stand-alone for busted
sudo add-apt-repository ppa:bartbes/love-stable
sudo apt update && apt upgrade
sudo apt install love geany

sudo luarocks make