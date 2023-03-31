# Stable Diffusion-UI : l’IA auto-hébergée pour créer des images
# https://www.matronix.fr/stable-diffusion-ui-lia-auto-hebergee-pour-creer-des-images/#comment-83134
# https://upandclear.org/2023/01/25/stable-diffusion-lai-auto-hebergee-pour-creer-des-images/

git clone https://github.com/AbdBarho/stable-diffusion-webui-docker.git # Entrer dans le dosseir et lancer la création du Docker d'installation
cd stable-diffusion-webui-docker/
docker compose --profile download up --build # Ce qui demandera du temps...# Une fois terminé on peut lancer le projet
UI=auto-cpu #UI=auto #UI=invoke #UI=sygil
docker compose --profile $UI up --build

