# Mkdocs-material custom container with nginx/basic auth/ssl - self signed

The repo should be structured this way:

```
.
├── docs/
│  └── index.md
├── mkdocs.yml
├── docker-compose.yml
├── Dockerfile
├── nginx.conf
├── .htpasswd
├── run.sh
├── README.md
```

Clone the repo - replace PAT, username and repo (https://github.com/Xyic0re/mkdocs.git)
 - 'PAT' with personal access token
 - 'username' with your repo username
 - 'repo' with the repositories name

```
git clone https://<PAT>@github.com/username/repo.git && cd mkdocs
```

**This container requires apache2-utils and openssl to generate the .htpasswd file and self signed ssl certificate:** - run.sh can use apt install to install these

## Running and setup

Setup
```
chmod +x run.sh && ./run.sh
```

Running
```
./run.sh
```
