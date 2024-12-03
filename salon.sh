#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_SALON=$($PSQL "select * from services")

MENU_SERVICES(){
if [[ $1 ]]
then
  echo -e "\n$1"
fi

echo "$SERVICES_SALON" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
}

MENU_SERVICES

echo -e "\nIngrese el numero de servicio"
read SERVICE_ID_SELECTED

SERVICE_ID_SELECT=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_ID_SELECT ]]
then
  MENU_SERVICES "El numero ingresado no corresponde a algun servicio"
else
  echo -e "\nIngrese un numero de telefono"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nIngresa tu nombre"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  echo -e "\nIngrese el tiempo"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED" | sed 's/^[ \t]*//;s/[ \t]*$//')
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^[ \t]*//;s/[ \t]*$//')

  if [[ $INSERT_APPOINTMENT = "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi
