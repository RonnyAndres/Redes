cut -d: -f1 /etc/passwd | grep -v "^server$" > /tmp/users.txt
for user in $(cat /tmp/users.txt); do sudo deluser --remove-home $user; done
sudo rm /tmp/users.txt
