#!/bin/bash
<< comment
read -p "Enter a number: " num

while [ $num -gt 0 ]
do
    echo "The number is $num"
    ((num--))
done
comment
<< Comment
read -p "Enter a number: " num

if (( num % 2 == 0 ))
then
    echo "The number is even"
else
    echo "The number is odd"
fi
Comment

count=1
until [ $count -gt 100 ]; do
  echo "Count is $count"
  ((count++))
done