#!/bin/bash
# set first_run=0 to run setup
first_run=0

if [ $first_run -eq 0 ]; then
  if [ $(grep -c 'git clone' ./mkdocs.sh) -eq 1 ]; then
    printf '(skipped) - mkdocs.sh already contains repo information - edit manually and remove line 13\n'
  else
    printf 'Injecting repository info into ./mkdocs.sh\n'
    read -rp 'Enter your repository clone address - eg: https://<PAT>@github.com/username/repo.git : ' git_address
    sed -i "13 s#^#git clone \""$git_address"\" /opt/mkdocs\n#" ./mkdocs.sh
    printf 'done\n'
  fi

  if [ $(grep -c 'const webhook_secret' ./webhook.js) -eq 1 ]; then
    printf '(skipped) - webhook.js already contains secret - edit manually and remove line 2\n'
  else
    printf 'Injecting secret into ./webhook.js\n'
    read -rp 'Enter your webhook secret ' secret
    sed -i "2 s#^#const webhook_secret = \""$secret"\";\n#" ./webhook.js
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

  read -rp 'add an additional user(s)? (y/N): ' more_users
  while [[ "$more_users" =~ ^([yY][eE][sS]|[yY])$ ]]; do
    read -rp 'Enter your user: ' add_user
    htpasswd ./.htpasswd $add_user
    printf "Added user $add_user to .htpasswd\n"
    read -rp 'add an additional user(s)? (y/N): ' more_users
  done

  printf 'Config done... building image\n'
  docker stop mkdocs
  docker container remove mkdocs
  docker image remove mkdocs
  docker build -t mkdocs .
  printf 'Image built - mkdocs\n'
fi

read -rp "Do you want to run the container now? (y/N): " runit
if [[ "$runit" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  docker run -d --name mkdocs --mount type=volume,target=/opt/mkdocs --publish 443:443/tcp --publish 80:80/tcp --publish 8080:8080/tcp mkdocs
else
  printf 'You can run the container with this script or using docker run with: \n docker run -d --name mkdocs --mount type=volume,target=/opt/mkdocs --publish 443:443/tcp --publish 80:80/tcp --publish 8080:8080/tcp mkdocs\n'
fi
# Set first_run to 1 - subsequent runs will not perform setup tasks
 printf "Setup complete - setting 'first_run=1' reset this to zero to rerun setup\n"
 printf 'You can run the container with this script or using docker run with: \n docker run -d --name mkdocs --mount type=volume,target=/opt/mkdocs --publish 443:443/tcp --publish 80:80/tcp --publish 8080:8080/tcp mkdocs\n'
 sed -i "3 s#first_run=0#first_run=1#" ./run.sh