#! /bin/bash
lineNo=0
cat $1 | while read line
do
[[ -z $line ]] && continue
 lineNo=$(( $lineNo+1 ))
#   echo "${lineNo}"
  if [[ ${line} == *'-------'* ]] 
   then 
    continue
  fi
  #echo "|${line} |"
  if [[ ${lineNo} == 1 ]] 
   then  
    str= echo "| ${line} |" | sed -e "s/|/||/g"
   else
    str= echo "| ${line} |"
  fi
#  echo ${str}
done
