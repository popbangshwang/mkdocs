# Mkdocs-material custom container

The repo should be structured this way:

```
Repo-root
--docs
  -mdffiles go here
-docker-compose.yml
-Dockerfile
-nginx.conf
-.htpasswd
-run.sh
-README.md
```


Clone the repo (replace the repo with your own copy)

```
sudo git clone https://github.com/Xyic0re/mkdocs.git && cd mkdocs
```

Basic authentication is configured for nginx - this allows for password protecting the static content

Install apache2-utils and openssl to generate the .htpasswd file and self signed ssl certificate:

```
sudo apt update
sudo apt install apache2-utils openssl
```

To generate the an encrypted .htpasswd file

```
sudo htpasswd -c .htpasswd username
```

To add additional users, leave out the `-c`

```
sudo htpasswd .htpasswd another_user
```

Generate self signed certificate with openssl for use with nginx (CN is important - must be the host IP or FQDN)

```
sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx-certificate.crt -keyout nginx.key -subj "/C=AU/ST=QLD/L=Brisbane/O=Global Security/OU=IT Department/CN=192.168.8.211"
```

Make `run.sh` executable

```
sudo chmod +x run.sh
```

To run the container

```
sudo ./run.sh
```