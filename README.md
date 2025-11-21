# ❄️ nix-gaming-setup

🇬🇧 My amateur attempt at making nixos somewhat gaming-ready distro for my desktop PC.  
So far no flakes and no home-manager. Maybe I will learn it in the future.  

If You want to use it on your own PC:  
As admin, Copy all files except for hardware-configuration.nix to your /etc/nixos  
Open configuration.nix and replace rabbit with your user account  
open services.nix and replace rabbit with your user account  
  
then sudo nixos-rebuild boot  
  
You use config on your own, I won't help.   
Remember to change it to your likings, remove stuff You don't need.  
  
______________________________________________________________________________________  
  
🇵🇱 Moja amatorska próba zamiany nixos w dystrybucję gamingową pod mój komputer.  
Na ten moment bez użycia technologii flake i home-manager. Może w przyszłości się tego nauczę.  
  
Jeżeli chcesz wgrać mój config do siebie to:  
Jako admin, skopiuj wszystkie pliki za wyjątkiem hardware-configuration.nix do folderu /etc/nixos  
Otwórz edytorem tekstu configuration.nix i podmień słowo 'rabbit' twoim kontem użytkownika  
Otwórz edytorem tekstu services.nix i podmień słowo 'rabbit' twoim kontem użytkownika  
  
Później wywołaj w terminalu  
sudo nixos-rebuild boot  
  
Config używasz na własną odpowiedzialność, nie oferuję pomocy.  
Pamiętaj by dokonać zmian wedle swojego uznania, usuń czego nie potrzebujesz.  
