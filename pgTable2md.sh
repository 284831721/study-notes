#! /bin/bash
cat $1 | while read line
do
[[ -z $line ]] && continue
  if [[ ${line} == *'-------'* ]] 
   then 
     echo "| ${line} |" | sed -e "s/+/|/g"
   else
     echo "| ${line} |"
  fi
done
