#!/bin/bash

function calc() {
    awk "BEGIN { print $*; }"    
}
 
out=$(calc $*)

echo $out
