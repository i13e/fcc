#!/bin/bash

# Database connection details
DB_USER="freecodecamp"
DB_NAME="postgres"

# Function to execute SQL queries
run_sql() {
    psql -X --username="$DB_USER" --dbname="$DB_NAME" -t -c "$1"
}

echo "Enter your username:"
read USERNAME

GAMES_PLAYED=$(run_sql "SELECT games_played FROM users WHERE username='$USERNAME';")
BEST_GAME=$(run_sql "SELECT best_game FROM users WHERE username='$USERNAME';")
GAMES_PLAYED_FORMATTED=$(echo "$GAMES_PLAYED" | tr -d " ")
BEST_GAME_FORMATTED=$(echo "$BEST_GAME" | tr -d " ")


if [[ -z "$GAMES_PLAYED" || -z "$BEST_GAME" ]]; then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED_FORMATTED games, and your best game took $BEST_GAME_FORMATTED guesses."
fi

i=1
secret_number=$((1 + RANDOM % 1000))
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ GUESS -lt secret_number ]]; then
    echo -e "\nIt's higher than that, guess again:"
  elif [[ GUESS -gt secret_number ]]; then
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nYou guessed it in $i tries. The secret number was $secret_number. Nice job!"
    break
  fi
  ((i++))
done

if [[ -z "$GAMES_PLAYED" || -z "$BEST_GAME" ]]; then
  INSERTED=$(run_sql "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 1, $i);")
else
  INSERTED=$(run_sql "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME';")
fi

if [[ "$i" -lt "$BEST_GAME" ]]; then
  INSERTED=$(run_sql "UPDATE users SET best_game=$i WHERE username='$USERNAME';")
fi
