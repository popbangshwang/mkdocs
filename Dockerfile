FROM nginx:alpine

# Install base system
RUN apk add --no-cache \
    python3 \
    py3-pip \
    openssl \
    git \
# Install build dependencies
  && apk add --no-cache --virtual .build-deps \
  && pip3 install \
      flask \
  && pip3 install \
      fastapi \
  && pip3 install \
      waitress \
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
COPY webhook.py /opt/webhook/webhook.py
COPY mkdocs.sh /docker-entrypoint.d/40-mkdocs.sh
RUN chmod +x /docker-entrypoint.d/40-mkdocs.sh