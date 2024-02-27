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

Create a directory to house the container

```
sudo mkdir /opt/mkdocs & cd /opt/mkdocs
```

Clone the repo (replace the repo with your own copy)

```
sudo git clone https://github.com/Xyic0re/mkdocs.git
```

Basic authentication is configured for nginx - this allows for password protecting the static content

Install apache2-utils to generate the .htpasswd file:

```
sudo apt update
sudo apt install apache2-utils
```

To generate the an encrypted .htpasswd file

```
sudo htpasswd -c .htpasswd username
```

To add additional users, leave out the `-c`

```
sudo htpasswd .htpasswd another_user
```

Make `run.sh` executable

```
sudo chmod +x run.sh
```

To run the container

```
sudo ./run.sh
```