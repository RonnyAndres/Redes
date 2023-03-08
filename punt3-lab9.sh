#!/bin/bash

# Instalar vsftpd
#sudo apt-get install vsftpd

# Crear nuevo usuario y establecer su contraseña
read -p "Ingrese el nombre del nuevo usuario FTP: " nombre_usuario
sudo adduser $nombre_usuario
sudo passwd $nombre_usuario

# Crear lista de usuarios permitidos
echo "Usuarios disponibles:"
compgen -u | grep -v '^ftp$'
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
        comm -23 <(compgen -u | grep -v '^ftp$' | sort) <(echo "${usuarios_permitidos[*]}" | tr ' ' '\n' | sort)
    else
        echo "El usuario no existe."
    fi
done
echo "${usuarios_permitidos[*]}" | tr ' ' '\n' | sudo tee /etc/vsftpd.user_list

# Editar archivo de configuración de vsftpd
sudo sed -i '$a userlist_enable=YES' /etc/vsftpd.conf
sudo sed -i '$a userlist_file=/etc/vsftpd.user_list' /etc/vsftpd.conf
sudo sed -i '$a userlist_deny=NO' /etc/vsftpd.conf
sudo sed -i '$a chroot_local_user=YES' /etc/vsftpd.conf
sudo sed -i '$a chroot_list_enable=YES' /etc/vsftpd.conf
sudo sed -i '$a chroot_list_file=/etc/vsftpd.chroot_list' /etc/vsftpd.conf
sudo sed -i '$a write_enable=YES' /etc/vsftpd.conf

# Crear archivo chroot_list
echo $nombre_usuario | sudo tee /etc/vsftpd.chroot_list

# Reiniciar vsftpd
sudo service vsftpd restart

echo "El servidor FTP ha sido configurado exitosamente!"
