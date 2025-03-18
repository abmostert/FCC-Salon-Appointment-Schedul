#! /bin/bash


PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

MAIN_MENU() {

  #Check for any input variables
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #Show the services list
 
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    #List the avialable services
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  PICK_SERVICE

}

PICK_SERVICE() {
  #User inputs their pick
  read SERVICE_ID_SELECTED
  
  #Searching database for the picked service
  SEARCH_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  echo $SEARCH_NAME
  if [[ -z $SEARCH_NAME  ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #Move to the function to enter appointment details
    ENTER_APPOINTMENT_DETAILS
  fi
  


}

ENTER_APPOINTMENT_DETAILS() {

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

#Here we check if the customer is already in the database
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  ADD_CUSTOMER
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME"
read SERVICE_TIME


NEW_APPOINTMENT_RECORD=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")

echo -e "I have put you down for a $SEARCH_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}

ADD_CUSTOMER() {
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  NEW_CUSTOMER_RECORD=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 

}



#Main programme runs from hereon
echo -e "\n~~~~~ MY SALON ~~~~~\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU
