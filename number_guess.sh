#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

# username
echo -e "\nEnter your username:"
read USERNAME

USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_DB ]]
then 
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  INSERT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=0 WHERE username='$USERNAME'")
  USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME_DB! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# give the number
SECRET_NUMBER=$((1 + $RANDOM % 1000))

echo "Guess the secret number between 1 and 1000:"
read USER_NUMBER

until [[ $USER_NUMBER =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read USER_NUMBER
done

# guessing the number loop
NUMBER_OF_GUESSES=0

until [[ $USER_NUMBER -eq $SECRET_NUMBER ]]
do
  if [[ $USER_NUMBER -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    read USER_NUMBER
    if [[ $USER_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES++ ))
    fi
  fi
  if [[ $USER_NUMBER -lt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read USER_NUMBER
    if [[ $USER_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES++ ))
    fi
  fi 
done

# best game 
REAL_GUESS_NUMBER=$(($NUMBER_OF_GUESSES+1))
USER_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER_BEST_GAME ]]
then
  INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game=$REAL_GUESS_NUMBER WHERE username='$USERNAME'")
else
  if [[ $REAL_GUESS_NUMBER -lt $USER_BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$REAL_GUESS_NUMBER WHERE username='$USERNAME'")
  fi
fi

# games played
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$(($GAMES_PLAYED + 1)) WHERE username='$USERNAME'")

# number guessed
if [[ $USER_NUMBER -eq $SECRET_NUMBER ]]
then
  echo -e "\nYou guessed it in $REAL_GUESS_NUMBER tries. The secret number was $SECRET_NUMBER. Nice job!"
fi