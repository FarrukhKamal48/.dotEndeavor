#!/bin/sh

grim -g "$(slurp)"  "/home/$USER/stuff/Media/Snips/tesseract" && tesseract "/home/$USER/stuff/Media/Snips/tesseract" stdout | wl-copy
