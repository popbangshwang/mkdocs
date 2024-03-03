FROM nginx:alpine

# install python and pip3 needed for installation of mkdocs
RUN apk add --no-cache \
    python3 \
    py3-pip \
    nodejs \
    git \
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

# Copy in nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-certificate.crt /etc/nginx/certificate/nginx-certificate.crt
COPY nginx.key /etc/nginx/certificate/nginx.key
COPY .htpasswd /etc/nginx/.htpasswd

# Copy in webhook and startup script
COPY webhook.js /opt/webhook/webhook.js
COPY mkdocs.sh /docker-entrypoint.d/40-mkdocs.sh
RUN chmod +x /docker-entrypoint.d/40-mkdocs.sh