#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function helpPanel() {
  echo -e "Uso del script: timer -t 'Nº MINUTOS + FORMATO(s,m,h,d)' "
  echo -e "\t\ttimer -c 'HORA'"
  echo -e "\nEjemplo uso script: timer -t 3m"
  echo -e "\t\t    timer -c 14:00"
}

function ctrl_c() {
  echo -e "\n${redColour}[!]Saliendo...\n${endColour}"
  tput cnorm && exit 1
  exit 1
}

#Ctrl+C
trap ctrl_c INT

function alarm() {
  timeToCount="$1"

  echo -e "\nSe va a esperar $timeToCount"

  sleep $timeToCount && notify-send -u low -i "$HOME/.config/swaync/images/bell.png" "Time out!(TimeSpend: $timeToCount)"
  echo -e "\n${yellowColour}[ALARM]Sonando${endColour}"
  cvlc --repeat "$HOME/Documentos/Scripts/alarm/alarmSound.mp3"


}

function hourTimer() {
  timeDesire="$1"

  echo -e "\nSe va ha esperar hasta $timeDesire"

  currentHour="$(date +"%H")"
  currentMinute="$(date +"%M")"

  #Solo el valor de la hora cuando introducida por consola
  hoursInDesire="$(echo "$timeDesire" | awk '{print $1}' | cut -c 1-2)"
  #El valor de los minutos introducidos por consola
  minutesInDesire="$(echo "$timeDesire" | awk '{print $1}' | cut -c 4-5)"

  if [ $hoursInDesire -eq $currentHour ]; then
    if [ $currentMinute -gt $minutesInDesire ]; then
      esperaMinutos="$(echo "$currentMinute - $minutesInDesire" | bc)"
    fi
    if [ $currentMinute -lt $minutesInDesire ]; then
      esperaMinutos="$(echo "$minutesInDesire - $currentMinute" | bc)"
    fi
  fi

  if [ $hoursInDesire -gt $currentHour ]; then

    mirarSiHoraMayor="$(echo "$hoursInDesire - $currentHour" | bc)"

    if [ $mirarSiHoraMayor -gt 1 ]; then
      horasEsperar="$(echo "60 * $mirarSiHoraMayor" | bc)"
      currentMinuteMinusHour="$(echo "60 - $currentMinute " | bc)"
      esperaMinutos="$(echo "$currentMinuteMinusHour + $minutesInDesire + $horasEsperar" | bc)"
    else
      currentMinuteMinusHour="$(echo "60 - $currentMinute " | bc)"
      esperaMinutos="$(echo "$currentMinuteMinusHour + $minutesInDesire" | bc)"
    fi
  fi

  fixesperaMinutos="$(echo "$esperaMinutos m" | tr -d ' ')"

  echo "Tiempo: $fixesperaMinutos"

  sleep $fixesperaMinutos && notify-send -u low -i "$HOME/.config/swaync/images/bell.png" "Time out!(TimeSpend: $fixesperaMinutos)"
  echo -e "\n${yellowColour}[ALARM]Sonando${endColour}"
  cvlc --repeat "$HOME/Documentos/Scripts/\[01\]\ Kur/alarm/alarmSound.mp3" 2>/dev/null
}

# Indicators
declare -i parameter_counter=0

while getopts "t:c:h" arg; do
  case $arg in
  t)
    timeToCount="$OPTARG"
    let parameter_counter+=1
    ;;
  c)
    timeDesire="$OPTARG"
    let parameter_counter+=2
    ;;

  h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  alarm $timeToCount
elif [ $parameter_counter -eq 2 ]; then
  hourTimer $timeDesire
else
  helpPanel
fi
