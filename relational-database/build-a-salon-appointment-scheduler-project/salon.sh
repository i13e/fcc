#!/bin/bash
# Database connection details
DB_USER="freecodecamp"
DB_NAME="salon"

# Function to execute SQL queries
run_sql() {
    psql -X --username="$DB_USER" --dbname="$DB_NAME" -t -c "$1"
}

# Welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Function to display the main menu
main_menu() {
  SERVICES=$(run_sql "SELECT service_id, name FROM services;")

  while read SERVICE_ID BAR NAME; do
      echo "$SERVICE_ID) $NAME"
  done <<< "$SERVICES"
}

# Loop until a valid service is selected
while true; do
  main_menu
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$(run_sql "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  [[ -n $SERVICE_NAME ]] && break

  echo -e "\nI could not find that service. What would you like today?"
done
SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | tr -d ' ')

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$(run_sql "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
if [[ -z $CUSTOMER_NAME ]] ; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERTED=$(run_sql "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
fi
CUST_ID=$(run_sql "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | tr -d " ")
CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | tr -d " ")
CUST_ID_FORMATTED=$(echo "$CUST_ID" | tr -d " ")

echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
read SERVICE_TIME
INSERTED=$(run_sql "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUST_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');") 

echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
