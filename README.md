# AlarmBash

Temporizador y alarma escrito en Bash. Muestra una cuenta regresiva en la terminal y, al terminar, lanza una notificación y reproduce un sonido de alarma.

## Requisitos

- Bash 4+
- [`mpv`](https://mpv.io/) para reproducir el sonido
- `notify-send` (paquete `libnotify`) para la notificación
- `tput` (paquete `ncurses`)
- Un servidor de notificaciones con el icono pegado a la ruta de `BELL_ICON` en el script (por defecto `~/.config/swaync/images/bell.png`, pensado para [SwayNC](https://github.com/ErikReider/SwayNotificationCenter))

## Instalación

```bash
./timer.sh -h
```

Opcionalmente, dale permisos de ejecución y añádelo a tu `PATH`:

```bash
chmod +x timer.sh
```

## Uso

```
Uso del script:
  timer -t 'Nº MINUTOS + FORMATO(s,m,h,d)'   (p. ej. timer -t 3m)
  timer -c 'HORA'                            (p. ej. timer -c 14:00)
```

### Temporizador por duración (`-t`)

Cuenta un tiempo a partir del valor introducido. El sufijo indica la unidad:

| Unidad | Descripción | Ejemplo |
|--------|-------------|---------|
| `s`     | segundos    | `timer -t 30s` |
| `m`     | minutos     | `timer -t 3m`  |
| `h`     | horas       | `timer -t 2h`  |
| `d`     | días        | `timer -t 1d`  |

### Alarma a una hora concreta (`-c`)

Espera hasta la hora indicada del día (formato `HH:MM`). Si la hora ya ha pasado, espera hasta la misma hora del día siguiente.

```bash
timer -c 14:00
timer -c 9:30
```

### Ayuda

```bash
timer -h
```

## Comportamiento

- Durante la cuenta regresiva se muestra el tiempo restante en formato `HH:MM:SS`, actualizado cada segundo.
- Al terminar se envía una notificación (`Time out!`) y se reproduce `alarmSound.mp3` en bucle hasta que interrumpas el script.
- Pulsa `Ctrl+C` para salir en cualquier momento.

## Configuración

Las rutas de los recursos están definidas como constantes al principio de `timer.sh`:

- `ALARM_SOUND`: ruta al archivo de sonido (por defecto, junto al script).
- `BELL_ICON`: ruta al icono usado en la notificación.

## Estructura

```
AlarmBash/
├── timer.sh        # Script principal
└── alarmSound.mp3  # Sonido de la alarma
```