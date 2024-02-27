FROM nginx:alpine

# install python and pip3 needed for installation of mkdocs
RUN apk add --no-cache \
    python3 \
    py3-pip \
# Install Build dependencies (for some mkdocs requirements)
  && apk add --no-cache --virtual .build-deps \
#      build-base \
#      curl \
#      wget \
#      make \
#      python3-dev \
#  && pip3 install \
#      wheel \
  && pip3 install \
      mkdocs-material \
  && rm -rf "$HOME/.cache" \
  && apk del .build-deps

# set the workdir for creation of the mkdocs environment
WORKDIR /app

# copy in files from the host
COPY ./mkdocs/mkdocs.yml /app/mkdocs/mkdocs.yml
COPY ./mkdocs/docs/* /app/mkdocs/docs/
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-certificate.crt /etc/nginx/certificate/nginx-certificate.crt
COPY ./nginx.key /etc/nginx/certificate/nginx.key
COPY ./.htpasswd /etc/nginx/.htpasswd

# change workdir for the mkdocs build process
WORKDIR /app/mkdocs

RUN mkdocs build