#! /bin/bash

echo Hello World!

# VARIABLES
# Uppercase by convention
# Letters, numbers, underscores are only allowed

NAME="Bimbo"
# echo "My name is ${NAME}"

#USER INPUT

# read -p "Enter your name:" NAME
# echo "Hello ${NAME}" 

# CONDITIONALS

# if [ "$NAME" == "Wale" ]
# then
#     echo "Hello Wale"
# elif [ "$NAME" == "Jack" ]
# then
#     echo "Hello Jack"
# else
#     echo "Hello Stranger"
# fi

# COMPARISON OPERATORS -eq -ne -gt -ge -lt -le
NUM1=5
NUM2=8
if [ "$NUM1" -gt "$NUM2" ]
then
    echo "Number 1 is greater than Number 2"
elif [ "$NUM2" -ne "$NUM1" ]
then
    echo "Number 2 not equals Number 1"
fi

# FILE CONDITIONS

#######
# -d file True if the file is a directory
# -e file True if the file exists
# -f file True if the file is a regular file
# -g file True if the group id is set on a file
# -r file True if the file is readable
# -s file True if the file has a non-zero size
# -u file True if the user id is set on a file
# -w file True if the file is writable
# -x file True if the file is an executable
#######

# FILE="damn.txt"
# if [ -e "$FILE" ]
# then
#   echo "File exist"
# else 
#   echo "File does not exist"
# fi

# CASE STATEMENTS
# read -p "Are you 21 or over? Y/N " ANSWER
# case "$ANSWER" in
#   [yY] | [yY][eE][sS])
#     echo "You can have a beer :)"
#     ;;
#   [nN] | [nN][oO])
#     echo "Sorry, no drinking"
#     ;;
#   *)
#     echo "Please enter y/yes or n/no"
#     ;;
# esac    

# FOR LOOP
# Names="Brad Kevin Alice Mark"
# for NAME in $Names
# do
#   echo "Hello $NAME"
# done

# # FOR LOOP TO RENAME FILES
# FILES=$(ls *.txt)
# NEW="new"
# for FILE in $FILES
# do
#   echo "Renaming $FILE to new-$FILE"
#   mv $FILE $NEW-$FILE
# done

# WHILE LOOP - READ THROUGH A FILE LINE BY LINE
LINE=1
while read -r CURRENT_LINE
do
  echo "$LINE: $CURRENT_LINE"
  ((LINE++))
done < "./damn.txt"
