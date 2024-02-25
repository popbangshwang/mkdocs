# docker-nginx-mkdocs-material

Pulls raw mkdocs, builds, then serves with nginx

## Usage

Set up a git repository that can be cloned. This will house your mkdocs raw markdown and configuration ([Github hosted example](https://github.com/nwesterhausen/public-wiki)).

This container uses the default nxinx:alpine as a base, so the final documentation site is run on port 80 in the container.

To run the container exposing the mkdocs site on localhost:8900:

```
docker run \
  --env "DOC_REPO=github.com/nwesterhausen/docker-nginx-mkdocs-material" \
  --publish 172.0.0.1:8900:80 \
  nwesterhausen/static-mkdocs-material
```

### Private repositories

To use with a private repository, set the ACCESS_TOKEN variable with a personal access token that has private repo access.

## Environment Variables

| Name         | Usage                                                                                                                            |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| DOC_REPO     | Web URL for repository. 'https://' will be prepended to this value                                                               |
| ACCESS_TOKEN | For private repository, include a personal access token which gets inserted before DOC_REPO like 'https://ACCESS_TOKEN@DOC_REPO' |