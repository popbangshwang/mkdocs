# Mkdocs-material custom container with nginx/basic auth/ssl - self signed/webhook for pushes and auto mkdocs rebuild

**The repo should be structured this way:**

```
.
├── docs/
│  └── index.md
|  └── <additional docs go here>
├── mkdocs.yml
├── mkdocs.sh
├── webhook.js
├── Dockerfile
├── nginx.conf
├── run.sh
├── README.md
```

***Some/all of these commands may require 'sudo' depending on your environment***

Clone the repo - replace 'PAT', 'username' and 'repo' to match (https://GEdsfasds38212fda@github.com/Xyic0re/mkdocs.git)
 - 'PAT' with personal access token
 - 'username' with your repo username
 - 'repo' with the repositories name

```
git clone https://<PAT>@github.com/<username>/<repo>.git && cd mkdocs
```
Public repo
```
git clone https://github.com/<username>/<repo>.git && cd mkdocs
```

**This container requires apache2-utils and openssl to generate the .htpasswd file and self signed ssl certificate:** - run.sh can use apt install to install these

## Running and setup

**Setup**
```
chmod +x run.sh && ./run.sh
```

**Running**
```
./run.sh
```
