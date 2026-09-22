#!/bin/bash


read -p "Enter the marks: " marks

if [[ $marks -ge 90 ]];
then
	echo "S Grade"
elif [[ $marks -lt 90 && $marks -ge 80 ]];
then
	echo "A grade"
elif [[ $marks -lt 80 && $marks -ge 70 ]]; then
	echo "B grade"
elif  [[ $marks -lt 70 && $marks -ge 60 ]]; then
	echo "C grade"
elif  [[ $marks -lt 60 && $marks -ge 50 ]]; then
	echo "D grade"
elif  [[ $marks -lt 50 && $marks -ge 40 ]]; then
	echo "E grade"
else
	echo "F grade"
fi
