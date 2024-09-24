#!/bin/bash

# Verificar que se proporcionaron el directorio local como parámetro
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <directorio_local>"
    exit 1
fi

# Asignar el parámetro a una variable
LOCAL_DIR=$1
USER="jenbeita"
SERVER="eirenhost.com"
PORT=106
REMOTE_DIR="/home/jenbeita/libft_tester"  # Cambia esta ruta por la ruta deseada en el servidor
BUILD_DIR="/home/jenbeita/libft_tester/libft-unit-test-master/" #ruta del tester

# Verificar si la carpeta local existe
if [ ! -d "$LOCAL_DIR" ]; then
    echo "La carpeta local $LOCAL_DIR no existe."
    exit 1
fi

# Eliminar la subcarpeta .git si existe
if [ -d "$LOCAL_DIR/.git" ]; then
    echo "Eliminando la subcarpeta .git de $LOCAL_DIR"
    rm -rf "$LOCAL_DIR/.git"
fi

# Renombrar la carpeta local a libft
RENAMED_DIR="$(dirname "$LOCAL_DIR")/libft"
mv "$LOCAL_DIR" "$RENAMED_DIR"

# Añadir líneas al final del Makefile
MAKEFILE="$RENAMED_DIR/Makefile"
if [ -f "$MAKEFILE" ]; then
    echo -e "\nso:\n\t\$(CC) -nostartfiles -fPIC \$(CFLAGS) \$(SRC) \$(BONUSSRC)\n\tgcc -nostartfiles -shared -o libft.so \$(OBJ) \$(BONUSOBJ)" >> "$MAKEFILE"
    echo "Se han añadido nuevas reglas al Makefile."
else
    echo "Error: No se encontró el Makefile en $RENAMED_DIR."
    exit 1
fi

# Conectar a SFTP y realizar las operaciones
sftp -P $PORT $USER@$SERVER <<EOF
rm -rf $REMOTE_DIR/libft || true  # Eliminar la carpeta remota si existe, ignorar errores si no existe
mkdir $REMOTE_DIR  # Crear el directorio remoto si no existe
put -r $LOCAL_DIR $REMOTE_DIR  # Subir la carpeta
bye
EOF

echo "La carpeta ha sido subida correctamente al servidor."

# Ejecutar make en el servidor remoto
ssh -p $PORT $USER@$SERVER <<EOF
cd $BUILD_DIR || exit 1  # Cambiar al directorio de build, salir si falla
make f  # Ejecutar make
rm -rf $REMOTE_DIR/libft
EOF

if [ $? -eq 0 ]; then
    echo "La ejecución de make fue exitosa."
else
    echo "Ocurrió un error al ejecutar make."
fi
