#Consertar permissoes .ssh
chmod u+rwx,go-rwx ~/.ssh
ssh-add ~/.ssh/id_ed25519
#Instalar NordVPN
sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)

sudo usermod -aG nordvpn $USER
