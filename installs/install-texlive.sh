#!/bin/bash

sudo apt update && sudo apt install texlive-full -y

# Updating the packages
sudo tlmgr update --self && sudo tlmgr update --all