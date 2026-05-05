#!/bin/bash

# 0. Minimizar todas las ventanas (Simular Super+D)
wmctrl -k on
sleep 1

URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"
NUM_INICIAL=7
declare -a HANDLES

# Función para abrir ventanas y capturar sus IDs
abrir_rick() {
    for i in $(seq 1 $1); do
        # Abrir en una ventana nueva de Firefox (común en Mint) o Chrome
        firefox --new-window "$URL" & 
        sleep 2
        # Capturar el ID de la ventana más reciente de Firefox
        ID=$(xdotool search --onlyvisible --name "YouTube" | tail -1)
        if [[ ! " ${HANDLES[@]} " =~ " ${ID} " ]]; then
            HANDLES+=($ID)
        fi
    done
}

# Inicializar
abrir_rick $NUM_INICIAL

# Obtener dimensiones de la pantalla
WIDTH=$(xwininfo -root | grep 'Width:' | awk '{print $2}')
HEIGHT=$(xwininfo -root | grep 'Height:' | awk '{print $2}')
W_VENTANA=500
H_VENTANA=400

echo "PROTOCOLO HYDRA LINUX ACTIVADO"

while true; do
    for i in "${!HANDLES[@]}"; do
        ID=${HANDLES[$i]}

        # Verificar si la ventana aún existe
        if ! xdotool getwindowname "$ID" >/dev/null 2>&1; then
            echo "¡Ventana cerrada! Clonando..."
            unset 'HANDLES[$i]'
            abrir_rick 2
            continue
        fi

        # Quitar maximizado por si acaso
        wmctrl -ir "$ID" -b remove,maximized_vert,maximized_horz

        # Movimiento aleatorio
        POS_X=$(( RANDOM % (WIDTH - W_VENTANA) ))
        POS_Y=$(( RANDOM % (HEIGHT - H_VENTANA) ))
        
        xdotool windowmove "$ID" $POS_X $POS_Y
        xdotool windowsize "$ID" $W_VENTANA $H_VENTANA
    done
    sleep 0.05
done