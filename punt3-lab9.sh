#!/bin/bash

# Instalar vsftpd
#sudo apt-get install vsftpd

# Crear nuevo usuario y establecer su contraseña
read -p "Ingrese el nombre del nuevo usuario: " nombre_usuario

# Verificar que el usuario no exista
if id "$nombre_usuario" >/dev/null 2>&1; then
    echo "El usuario $nombre_usuario ya existe."
    exit 1
fi

# Crear el usuario con su nombre como contraseña
sudo useradd -m -p $(openssl passwd -1 $nombre_usuario) $nombre_usuario

echo "El usuario $nombre_usuario se ha creado correctamente con su nombre como contraseña."

# Crear lista de usuarios permitidos
echo "Usuarios disponibles:"
compgen -u | grep -v '^ftp$\|^guest\|^nobody\|root'
usuarios_permitidos=()
while true; do
    read -p "Ingrese el nombre de usuario permitido (dejar en blanco para terminar): " usuario
    if [[ -z $usuario ]]; then
        break
    elif [[ ${usuarios_permitidos[*]} =~ $usuario ]]; then
        echo "El usuario ya ha sido agregado."
    elif compgen -u | grep -q "^$usuario$"; then
        usuarios_permitidos+=($usuario)
        echo "Usuarios agregados hasta el momento: ${usuarios_permitidos[*]}"
        echo "Usuarios disponibles:"
        comm -23 <(compgen -u | grep -v '^ftp$\|^guest\|^nobody\|root' | sort) <(echo "${usuarios_permitidos[*]}" | tr ' ' '\n' | sort)
    else
        echo "El usuario no existe."
    fi
done
echo "${usuarios_permitidos[*]}" | tr ' ' '\n' | sudo tee /etc/vsftpd.user_list

read -p "¿Desea editar el archivo de configuración de vsftpd? (1=Si, 2=No): " opcion
if [ $opcion -eq 1 ]; then
    sudo sed -i '$a userlist_enable=YES' /etc/vsftpd.conf
    sudo sed -i '$a userlist_file=/etc/vsftpd.user_list' /etc/vsftpd.conf
    sudo sed -i '$a userlist_deny=NO' /etc/vsftpd.conf
    sudo sed -i '$a chroot_local_user=YES' /etc/vsftpd.conf
    sudo sed -i '$a chroot_list_enable=YES' /etc/vsftpd.conf
    sudo sed -i '$a chroot_list_file=/etc/vsftpd.chroot_list' /etc/vsftpd.conf
    sudo sed -i '$a write_enable=YES' /etc/vsftpd.conf
fi

# Crear archivo chroot_list
echo $nombre_usuario | sudo tee /etc/vsftpd.chroot_list

# Reiniciar vsftpd
sudo service vsftpd restart

echo "El servidor FTP ha sido configurado exitosamente!"
