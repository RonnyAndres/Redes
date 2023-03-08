#!/bin/bash

# Instalar vsftpd
#sudo apt-get install vsftpd

read -p "Desea crear un nuevo grupo? [1-Si] [2-No]: " crear_grupo

if [ $crear_grupo -eq 1 ]; then
  read -p "Escriba el nombre del nuevo grupo: " nombre_grupo
  
  # Verificar si el grupo ya existe
  if grep -q "^$nombre_grupo:" /etc/group; then
    echo "El grupo $nombre_grupo ya existe."
  else
    # Crear el grupo y agregar el usuario
    sudo groupadd $nombre_grupo
  fi
fi


# Crear nuevo usuario y establecer su contraseña
read -p "Ingrese el nombre del nuevo usuario: " nombre_usuario

# Verificar que el usuario no exista
if id "$nombre_usuario" >/dev/null 2>&1; then
    echo "El usuario $nombre_usuario ya existe."
else
    # Crear el usuario con su nombre como contraseña
    sudo useradd -m -p $(openssl passwd -1 $nombre_usuario) $nombre_usuario
    echo "El usuario $nombre_usuario se ha creado correctamente con su nombre como contraseña."
    if [ $crear_grupo -eq 2 ]; then
       # Crear arreglo de nombres de grupo
        groups=($(cut -d: -f1 /etc/group))

        # Presentar lista numerada de nombres de grupo
        select group_name in "${groups[@]}"; do
        # Guardar nombre seleccionado en una variable
          if [[ -n "$group_name" ]]; then
             selected_group="$group_name"
             break
          fi
        done
        echo "El grupo seleccionado es: $selected_group"
        sudo usermod -a -G $selected_group $usuario
    fi    
fi

# Crear lista de usuarios permitidos
echo "Usuarios disponibles:"
compgen -u | grep -v '^ftp$\|^guest\|^nobody\|root' | grep -vFf '/etc/vsftpd.chroot_list' | awk -F':' '{if (system("id -nG "$1" | grep -qw $nombre_grupo")) print $1}'

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
        compgen -u | grep -v '^ftp$\|^guest\|^nobody\|root' | grep -vFf '/etc/vsftpd.chroot_list' | awk -F':' '{if (system("id -nG "$1" | grep -qw $nombre_grupo")) print $1}'
        
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
echo $nombre_usuario | sudo tee -a /etc/vsftpd.chroot_list

# Reiniciar vsftpd
sudo service vsftpd restart

echo "El servidor FTP ha sido configurado exitosamente!"
