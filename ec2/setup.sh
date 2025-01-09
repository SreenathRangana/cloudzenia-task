#!/bin/bash
sudo apt update
sudo apt install -y nginx docker.io
sudo systemctl enable nginx
