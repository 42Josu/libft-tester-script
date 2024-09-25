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
    echo -e "\nso:\n\tgcc -nostartfiles -fPIC -Wall -Wextra -Werror \
ft_memset.c ft_bzero.c ft_strlen.c ft_atoi.c ft_isdigit.c ft_isalpha.c\
ft_isprint.c ft_isascii.c ft_isalnum.c ft_memchr.c ft_memcpy.c\
ft_memcmp.c ft_memmove.c ft_strchr.c ft_strdup.c ft_strlcat.c ft_strlcpy.c\
ft_strncmp.c ft_toupper.c ft_tolower.c ft_strnstr.c ft_strrchr.c ft_calloc.c\
ft_putchar_fd.c ft_putstr_fd.c ft_putnbr_fd.c ft_putendl_fd.c ft_substr.c\
ft_strjoin.c ft_strtrim.c ft_strmapi.c ft_itoa.c ft_split.c \
ft_lstnew_bonus.c ft_lstadd_front_bonus.c ft_lstsize_bonus.c\
ft_lstlast_bonus.c ft_lstadd_back_bonus.c ft_lstdelone_bonus.c\
ft_lstclear_bonus.c ft_lstiter_bonus.c ft_lstmap_bonus.c\
\n\tgcc -nostartfiles -shared -o libft.so \
ft_memset.o ft_bzero.o ft_strlen.o ft_atoi.o ft_isdigit.o ft_isalpha.o\
ft_isprint.o ft_isascii.o ft_isalnum.o ft_memchr.o ft_memcpy.o\
ft_memcmp.o ft_memmove.o ft_strchr.o ft_strdup.o ft_strlcat.o ft_strlcpy.o\
ft_strncmp.o ft_toupper.o ft_tolower.o ft_strnstr.o ft_strrchr.o ft_calloc.o\
ft_putchar_fd.o ft_putstr_fd.o ft_putnbr_fd.o ft_putendl_fd.o ft_substr.o\
ft_strjoin.o ft_strtrim.o ft_strmapi.o ft_itoa.o ft_split.o \
ft_lstnew_bonus.o ft_lstadd_front_bonus.o ft_lstsize_bonus.o\
ft_lstlast_bonus.o ft_lstadd_back_bonus.o ft_lstdelone_bonus.o\
ft_lstclear_bonus.o ft_lstiter_bonus.o ft_lstmap_bonus.o" >> "$MAKEFILE"
    echo "Se han añadido nuevas reglas al Makefile."
else
    echo "Error: No se encontró el Makefile en $RENAMED_DIR."
    exit 1
fi

# Conectar a SFTP y realizar las operaciones
sftp -P $PORT $USER@$SERVER <<EOF
rm -rf $REMOTE_DIR/libft || true  # Eliminar la carpeta remota si existe, ignorar errores si no existe
mkdir $REMOTE_DIR  # Crear el directorio remoto si no existe
put -r $RENAMED_DIR $REMOTE_DIR  # Subir la carpeta
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
