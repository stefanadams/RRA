#!/bin/bash

year=$(date +%Y)
./items.pl ../dataimport/items.$year.txt 
echo Add more info: for i in 12 34 56\; do ./moreinfo.pl $i \(jpg\|pdf\)\; done
