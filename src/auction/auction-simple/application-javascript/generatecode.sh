#!/bin/bash

# Copy templatefiles to working directory
rsync -r templates/ ${PWD}

numOfOrgs=$1
#numOfOrgs=${numOfOrgs:="4"}

# For testing purpose
inputAPPUTIL=AppUtil-template.txt
inputBID=bid-template.txt
inputCLOSEAUCTION=closeAuction-template.txt
inputCREATEAUCTION=createAuction-template.txt
inputENDAUCTION=endAuction-template.txt
inputENROLLADMIN=enrollAdmin-template.txt
inputQUERYAUCTION=queryAuction-template.txt
inputQUERYBID=queryBid-template.txt
inputREGISTERENROLLUSER=registerEnrollUser-template.txt


# This creates a string for buildCCPOrgx with x orgs
function stringBuilder(){
    template=${1%?}
    #result=""
    for (( c=1; c<=$numOfOrgs; c++ ));do
       result+="${template}""${c}, "
    done
    result=${result%??}
    echo "$result"
}

function stringBuilder2(){
    template=$1
    #result=""
    for (( c=1; c<=$numOfOrgs; c++ ));do
       result+="${template}""${c}MSP', "
    done
    result=${result%??}
    echo "$result"
}


# This creates const mspOrg1 = 'Org1MSP' lines when correct input is given
function read_input_file_and_replace(){
  local input_file=$1
  local substring=$2
  local tmp_input_file=$(mktemp)
  local count=1
  local count2=2

  while read line; do
    echo "$line" >> "$tmp_input_file"
    if [[ $line == *"$substring"* ]]; then
      for ((i=1; i<$numOfOrgs; i++))
      do
        line=${line//$count/$count2}
        echo "$line" >> "$tmp_input_file"
        count=$((count + 1))
        count2=$((count2 + 1))
      done
    fi
  done < "$input_file"
  echo "read_input_file_and_replace"
  mv "$tmp_input_file" "$input_file"
}

# Updates a row, change x for y, combined with stringbuilder can fix const { buildCCPOrgx}
function update(){
  while IFS= read -r a; do
      echo "${a//$2/$3}"
  done < $1 > $1.t
  mv $1{.t,}
}

# Edits an entire file for x orgs
function addOrgs(){
  input=$1
  replacement=""
  while IFS= read -r line; do
    if [[ "$line" == *"buildCCPOrgx"* ]]; then
      replacement=$(stringBuilder "buildCCPOrgx")
      update "$input" buildCCPOrgx "$replacement"
      #line=${line//'buildCCPOrgx'/$replacement}
    elif [[ "$line" == *"const msp"* ]]; then
      read_input_file_and_replace "$input" "const mspOrg"
    elif [[ "$line" == *"Start copy here"* ]]; then
      read_input_file_and_copy_function "$input" "temporary.txt"
      duplicate_function "temporary.txt" "$input" "PutNewFunctionsHere"
      rm temporary.txt
    elif [[ "$line" == *"function main"* ]]; then
      complete_main "$input" "testingtesting.txt"
      update "testingtesting.txt" "if" "else if"
      duplicate_function "testingtesting.txt" "$input" "PutNewMainStuff"
      rm testingtesting.txt
    elif [[ "$line" == *"REPLACEME"* ]]; then
      array=$(stringBuilder2 "'Org")
      update "$input" REPLACEME "$array"
    fi
  done < $input > $input.t
  mv $input{.t,} 2>/dev/null
  
}

# Reads input and copies functions to a file
function read_input_file_and_copy_function(){
  input_file=$1
  output_file=$2
  local function_start=false

  while IFS= read -r line; do
    if [[ $line == *"function"* && $line == *"Org"* ]]; then
      function_start=true
      echo "$line" >> "$output_file"
    elif [[ $line == *"{"* ]] && [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
    elif [[ $line == *"}"* ]] && [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
      function_start=false
    elif [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
    fi
  done < "$input_file"

}

# Duplicates a function numOfOrgs times
function duplicate_function(){
  inputFunction=$1
  inputCodefile=$2
  linebreak=$3
  i=1
  while (( i++ < $numOfOrgs));do
    cp $inputFunction temp"$i".txt
    update temp"$i".txt "1" $i
    cat temp"$i".txt >> allFunc.txt
    rm temp"$i".txt
  done

  software_txt_top_half=$(sed "/$linebreak/q" $inputCodefile)
  software_txt_bottom_half=$(sed "1,/$linebreak/d" $inputCodefile)
  newFunctions=$(sed -n 'p' allFunc.txt)
  rm allFunc.txt

  # Insert user input into software.txt after specified line.
   cat << EOF > $inputCodefile
   $software_txt_top_half
   $newFunctions
   $software_txt_bottom_half
EOF

}

# Adds else if statements in main function
function complete_main(){
  input_file=$1
  output_file=$2
  local function_start=false

  while IFS= read -r line; do
    if [[ $line == *"if"* && $line == *"org1"* && $line == *"==="* && $line == *"||"* ]]; then
      function_start=true
      echo "$line" >> "$output_file"
    elif [[ $line == *"{"* ]] && [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
    elif [[ $line == *"}"* ]] && [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
      function_start=false
    elif [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
    fi
  done < "$input_file"
}

function copy_export_app_util(){
  input_file=$1
  output_file=$2
  local function_start=false
  while IFS= read -r line
  do
    if [[ $line == *"exports"* && $line == *"buildCCP"* && $line == *"Org"*  ]]; then
      function_start=true
      echo "$line" >> "$output_file"
    elif [[ $line == *"{"* ]] && [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
    elif [[ $line == *"};"* ]] && [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
      function_start=false
    elif [[ $function_start == true ]]; then
      echo "$line" >> "$output_file"
    fi
  done < "$input_file"
}

# Puting all the templatefiles through the meatgrinder
function loop_over_files(){
  for f in *template.txt; do
    addOrgs "$f"
    mv $f ${f%%\-*}.js
    done;
}


function main(){
  #copy_export_app_util $inputAPPUTIL result.txt
  #duplicate_function "result.txt" $inputAPPUTIL "PutNewFunctionsHere"
  copy_export_app_util $inputAPPUTIL "copiedFunc.txt"
  duplicate_function "copiedFunc.txt" $inputAPPUTIL "PutNewFunctionsHere"
  mv $inputAPPUTIL AppUtil.js
  rm copiedFunc.txt
  loop_over_files
  mv AppUtil.js ../../test-application/javascript

}

main



