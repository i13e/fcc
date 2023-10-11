#!/bin/bash

# Check if the script is called without any arguments
if [ $# -eq 0 ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Database connection details
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to query the database and display element information
get_element_info() {
  local input="$1"
  # Check if the input is a valid integer
  if [[ $input =~ ^[0-9]+$ ]]; then
    condition="e.atomic_number = $input"
  else
    condition="e.name = '$input' OR e.symbol = '$input'"
  fi

  $PSQL \
    "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
     FROM public.elements e
     JOIN public.properties p ON e.atomic_number = p.atomic_number
     JOIN public.types t ON p.type_id = t.type_id
     WHERE $condition;"
}

# Get element information based on the input
element_info=$(get_element_info "$1")
# Check if the element was found in the database
if [ -z "$element_info" ]; then
  echo "I could not find that element in the database."
else
  # Parse and display the element information
  IFS="|"
  read -ra element_array <<< "$element_info"
  atomic_number="${element_array[0]}"
  element_name="${element_array[1]}"
  symbol="${element_array[2]}"
  element_type="${element_array[3]}"
  atomic_mass="${element_array[4]}"
  melting_point="${element_array[5]}"
  boiling_point="${element_array[6]}"
  echo "The element with atomic number $atomic_number is $element_name ($symbol). It's a $element_type, with a mass of $atomic_mass amu. $element_name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi
