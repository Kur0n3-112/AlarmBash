#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
green="\e[1;32m"
red="\e[1;31m"
blue="\e[1;34m"
yellow="\e[1;33m"
purple="\e[1;35m"
turquoise="\e[1;36m"
gray="\e[1;37m"
reset="\e[0m"

# Recursos
ALARM_SOUND="$SCRIPT_DIR/alarmSound.mp3"
BELL_ICON="$HOME/.config/swaync/images/bell.png"

helpPanel() {
  cat <<EOF
Uso del script:
  timer -t 'Nº MINUTOS + FORMATO(s,m,h,d)'   (p. ej. timer -t 3m)
  timer -c 'HORA'                            (p. ej. timer -c 14:00)
EOF
}

ctrl_c() {
  echo -e "\n${red}[!] Saliendo...\n${reset}"
  tput cnorm
  exit 0
}

# Cuenta regresiva: countDown <horas> <minutos> <segundos>
countDown() {
  local hours="${1:-0}" minutes="${2:-0}" seconds="${3:-0}"
  local total=$(( hours * 3600 + minutes * 60 + seconds ))

  while (( total > 0 )); do
    printf "\r%02d:%02d:%02d" $(( total / 3600 )) $(( (total / 60) % 60 )) $(( total % 60 ))
    (( total-- ))
    sleep 1
  done
  printf "\n"
}

ringAlarm() {
  local elapsed="$1"

  notify-send -u low -i "$BELL_ICON" "Time out! (TimeSpend: $elapsed)"
  echo -e "\n${yellow}[ALARM] Sonando${reset}"
  mpv "$ALARM_SOUND" --loop=yes
}

# Timer por duración: timer -t 3m
alarm() {
  local time_to_count="$1"
  local number unit

  if [[ ! "$time_to_count" =~ ^([0-9]+)([smhd])$ ]]; then
    echo -e "${red}[!] Formato inválido: '$time_to_count'${reset}" >&2
    helpPanel
    exit 1
  fi

  number="${BASH_REMATCH[1]}"
  unit="${BASH_REMATCH[2]}"

  echo -e "\nSe va a esperar $time_to_count"

  case "$unit" in
    s) countDown 0 0 "$number" ;;
    m) countDown 0 "$number" 0 ;;
    h) countDown "$number" 0 0 ;;
    d) countDown $(( number * 24 )) 0 0 ;;
  esac

  ringAlarm "$time_to_count"
}

# Timer por hora del día: timer -c 14:00
hourTimer() {
  local time_desire="$1"
  local desired_hour desired_minute now_total target_total minutes_to_wait

  if [[ ! "$time_desire" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
    echo -e "${red}[!] Hora inválida: '$time_desire'${reset}" >&2
    helpPanel
    exit 1
  fi

  desired_hour="${BASH_REMATCH[1]}"
  desired_minute="${BASH_REMATCH[2]}"

  echo -e "\nSe va a esperar hasta $time_desire"

  now_total=$(( 10#$(date +%H) * 60 + 10#$(date +%M) ))
  target_total=$(( 10#$desired_hour * 60 + 10#$desired_minute ))

  # Si la hora ya pasó, esperar hasta el día siguiente
  if (( target_total <= now_total )); then
    target_total=$(( target_total + 1440 ))
  fi

  minutes_to_wait=$(( target_total - now_total ))

  echo "Tiempo: ${minutes_to_wait}m"
  countDown 0 "$minutes_to_wait" 0
  ringAlarm "${minutes_to_wait}m"
}

main() {
  local mode=""
  local value=""

  while getopts "t:c:h" opt; do
    case "$opt" in
      t) mode="t"; value="$OPTARG" ;;
      c) mode="c"; value="$OPTARG" ;;
      h) helpPanel; exit 0 ;;
      *) helpPanel; exit 1 ;;
    esac
  done

  case "$mode" in
    t) alarm "$value" ;;
    c) hourTimer "$value" ;;
    *) helpPanel ;;
  esac
}

trap ctrl_c INT

main "$@"
