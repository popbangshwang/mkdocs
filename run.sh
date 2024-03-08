#!/bin/bash
# set first_run=0 to run setup
first_run=0


if ! [ -e ./.env ] ; then
   touch ./.env
fi
if ! [ -w ./.env ] ; then
   printf 'cannot write to %s\n' ./.env
   exit 1
fi

if [ $first_run -eq 0 ]; then

  if [ $(grep -c 'RAND_VAR=' ./.env) -eq 1 ]; then
    printf '(skipped) - .env already contains "RAND_VAR" - edit manually\n'
  else
    printf 'Injecting repository info into ./mkdocs.sh\n'
    rand_var=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 42; echo)
    echo "RAND_VAR=$rand_var" >> ./.env
    printf 'done\n'
  fi

  if [ $(grep -c 'CRYPT_GIT_REPO=' ./.env) -eq 1 ]; then
    printf '(skipped) - .env already contains "CRYPT_GIT_REPO" - edit manually\n'
  else
    printf 'Injecting repository info into ./mkdocs.sh\n'
    read -rp 'Enter your repository clone address - eg: https://<PAT>@github.com/username/repo.git : ' git_address
    crypt_git_address=$(echo $git_address | openssl enc -aes-256-ctr -A -pbkdf2 -a -k $rand_var)
    echo "CRYPT_GIT_REPO=$crypt_git_address" >> ./.env
    printf 'done\n'
  fi

  if [ $(grep -c 'CRYPT_SECRET=' ./.env) -eq 1 ]; then
    printf '(skipped) - .env already contains "CRYPT_SECRET" - edit manually\n'
  else
    printf 'Injecting secret into ./webhook.js\n'
    read -rp 'Enter your webhook secret ' secret
    crypt_secret=$(echo $secret | openssl enc -aes-256-ctr -A -pbkdf2 -a -k $rand_var)
    echo "CRYPT_SECRET=$crypt_secret" >> ./.env
    printf 'done\n'
  fi

  printf 'Setting up .htpasswd for nginx basic auth and self signed ssl cert\n'
  read -rp "Do you want this script to run 'sudo apt install apache2-utils openssl'? (y/N): " install_htpasswd
  if [[ "$install_htpasswd" =~ ^([yY][eE][sS]|[yY])$ ]]; then
     sudo apt install apache2-utils openssl
  else
     printf "skipping...\n"
  fi

  if [[ -f ./nginx-certificate.crt ]]; then
    read -rp 'nginx-certificate.crt already exists - do you wish to regenerate it? (y/N):' regenerate_cert
    if [[ "$regenerate_cert" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      printf 'Generating self signed ssl certificate\n'
      read -rp "Populating 'CN' field - enter your FQDN or host's IP: " CN_field
      openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx-certificate.crt -keyout nginx.key -subj "/C=AU/ST=QLD/L=Brisbane/O=Global Security/OU=IT Department/CN=$CN_field"
    fi
  else
    printf 'Generating self signed ssl certificate\n'
    read -rp "Populating 'CN' field - enter your FQDN or host's IP: " CN_field
    openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx-certificate.crt -keyout nginx.key -subj "/C=AU/ST=QLD/L=Brisbane/O=Global Security/OU=IT Department/CN=$CN_field"
  fi

  if [[ -f ./.htpasswd ]]; then
    read -rp '.htpasswd already exists - do you wish to regenerate it? (y/N):' regenerate_htpasswd
    if [[ "$regenerate_htpasswd" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      printf 'Configuring basic auth for nginx - generating .htpasswd\n'
      read -rp 'Enter your user: ' username
      htpasswd -c ./.htpasswd $username
      printf "Added user $username to .htpasswd\n To add additional user(s) run 'htpasswd ./.htpasswd <user> or edit the file directly\n"
    fi
  else
    printf 'Configuring basic auth for nginx - generating .htpasswd\n' 
    read -rp 'Enter your user: ' username
    htpasswd -c ./.htpasswd $username
    printf "Added user $username to .htpasswd\n To add additional user(s) run 'htpasswd ./.htpasswd <user> or edit the file directly\n"
  fi

  read -rp 'add additional user(s)? (y/N): ' more_users
  while [[ "$more_users" =~ ^([yY][eE][sS]|[yY])$ ]]; do
    read -rp 'Enter your user: ' add_user
    htpasswd ./.htpasswd $add_user
    printf "Added user $add_user to .htpasswd\n"
    read -rp 'add additional user(s)? (y/N): ' more_users
  done

  printf 'Config done... building image\n'
  docker stop mkdocs
  docker container remove mkdocs
  docker image remove mkdocs
  docker build -t mkdocs .
  printf 'Image built - mkdocs\n'
fi

read -rp "Run the container now? (y/N): " runit
if [[ "$runit" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  docker run -d --env-file=./.env --name mkdocs --mount type=volume,target=/opt/mkdocs --publish 443:443/tcp --publish 80:80/tcp --publish 8080:8080/tcp mkdocs
else
  printf '\n'
  printf 'Run the container with this script or using docker run with: \n docker run -d --env-file=./.env --name mkdocs --mount type=volume,target=/opt/mkdocs --publish 443:443/tcp --publish 80:80/tcp --publish 8080:8080/tcp mkdocs\n'
fi
# Set first_run to 1 - subsequent runs will not perform setup tasks
 printf '\n'
 printf "Setup complete - setting 'first_run=1' manually reset this to zero to rerun setup\n"
 printf 'Run the container with this script or using docker run with: \n docker run -d --env-file=./.env --name mkdocs --mount type=volume,target=/opt/mkdocs --publish 443:443/tcp --publish 80:80/tcp --publish 8080:8080/tcp mkdocs\n'
 sed -i "3 s#first_run=0#first_run=1#" ./run.sh