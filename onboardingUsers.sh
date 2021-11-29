#! /bin/bash
#CREATE NEW USER FROM SHELL SCRIPT

FILE=./shell/names.csv
LINE=1
if [ -e $FILE ]
then
  while read -r CURRENT_LINE
  do 
    if id $CURRENT_LINE &>/dev/null; then
    ((LINE++))
    continue
    else
      HOME_DIR=/home/$CURRENT_LINE
      SSH_DIR=$HOME_DIR/.ssh
      sudo useradd -m -d $HOME_DIR $CURRENT_LINE
      sudo usermod -a -G developers $CURRENT_LINE
      sudo chmod 700 $HOME_DIR $HOME_DIR/.ssh
      sudo chown $CURRENT_LINE:developers $HOME_DIR -R
      if [ -d "$HOME_DIR" ]
      then
        echo "User's home directory already created"
      else
        sudo mkhomedir_helper $CURRENT_LINE
      fi
      if [ -d "$SSH_DIR" ]
      then
        echo "User's SSH folder already created"
      else
        sudo mkdir $SSH_DIR
        sudo chmod 700 $HOME_DIR $HOME_DIR/.ssh
      fi
      sudo touch $SSH_DIR/authorized_keys 
      sudo chmod 602 $SSH_DIR/authorized_keys 
      sudo chown $CURRENT_LINE:developers $SSH_DIR -R           
      sudo cat ./home/ubuntu/.ssh/authorized_keys > $SSH_DIR/authorized_keys #&& sudo chown $CURRENT_LINE:developers $SSH_DIR/authorized_keys
      sudo chmod 600 $SSH_DIR/authorized_keys 
      ((LINE++))
    fi
  done < $FILE  
else
  echo "File does not exist"
fi







# if [ -e $FILE ]
# then
#   while read -r CURRENT_LINE
#   do 
#     if [ $LINE -eq 1 ]
#     then
#       LINE=$((LINE+1))
#       continue
#     fi
#     IFS=',' read -r -a array <<< "$CURRENT_LINE"
#     USERNAME=${array[0]}
#     PASSWORD=${array[1]}
#     echo "Creating user $USERNAME"
#     useradd -m -p $PASSWORD $USERNAME
#     echo "$USERNAME:$PASSWORD" | chpasswd
#     LINE=$((LINE+1))
#   done < $FILE
# else
#   echo "File does not exist"
# fi