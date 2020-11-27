#!/bin/bash
# plot 2019 Ridgecrest earthquake sequence

gmt begin Ridgecrest-eqs png
# find Ridgecrest earthquake sequence
awk '{if($8>35.5 && $8<36 && $9>-118 && $9<-117.3) {print $1,$2,$3,$4,$5,$6,$8,$9,$10,$11}}' sc-catalog-201907.dat > Ridgecrest-eqs.dat

# plot Ridgecrest earthquake sequence
awk '{print $8,$7}' Ridgecrest-eqs.dat | gmt plot -JM7c -R-118/-117.25/35.5/36 -Bxa0.25 -Bya0.25 -BWSne -Sp0.03c -Gblack

# plot three selected events
awk '{print $8,$7}' events-selected.dat | gmt plot -Sa0.5c -Gred
gmt end show

rm Ridgecrest-eqs.dat
