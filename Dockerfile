FROM node:18.18.1-alpine3.17 as base
ARG proxy

ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG npm_registry
ARG sass_registry
ARG NPM_FIX
ARG NPM_LATEST
ARG NPM_VERBOSE
ARG NPM_AUDIT_IGNORE
ARG app_path
ARG app_name
ARG api_path
ARG app_ver
ENV APP ${APP}
ENV APP_VERSION ${app_ver}

WORKDIR /$app_path

# use proxy & private npm registry
RUN if [ ! -z "$http_proxy" ] ; then \
        npm config delete proxy; \
        npm config set proxy $http_proxy; \
        npm config set https-proxy $https_proxy ; \
        npm config set no-proxy $no_proxy; \
   fi ; \
   [ -z "${npm_registry}" ] || npm config set registry=$npm_registry; \
   [ -z "${sass_registry}" ] || npm config set sass_binary_site=$sass_registry;

RUN [ -z "${NPM_LATEST}" ] || npm i npm@latest -g

COPY package.json ./

RUN npm --no-git-tag-version version ${APP_VERSION}
RUN if [ -z "${NPM_VERBOSE}" ]; then\
      npm install;  \
    else \
      npm install --verbose; \
    fi

RUN if [ -z "${NPM_AUDIT_IGNORE}" ]; then\
      if [ ! -z "${NPM_AUDIT_LEVEL}" ]; then\
        npm config set audit-level ${NPM_AUDIT_LEVEL};\
      fi;\
      if [ -z "${NPM_FIX}" ]; then \
        npm audit --registry=https://registry.npmjs.org || npm audit --production --registry=https://registry.npmjs.org; \
      else \
        npm audit fix --registry=https://registry.npmjs.org || npm audit --production --registry=https://registry.npmjs.org; \
      fi;\
    fi
################################
# Step 2: "development" target #
################################
FROM base as development
ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG npm_registry
ARG sass_registry
ARG MIRROR_DEBIAN
ARG app_path
ARG app_name
ARG app_ver
ARG PORT

EXPOSE ${PORT}

CMD ["npm", "run", "dev"]

################################
# Step 3:   "build" target     #
################################
FROM base as build
ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG npm_registry
ARG sass_registry

ARG app_path
ARG app_name
ARG app_ver
ARG app_pkg
ENV APP ${app_name}
ENV APP_PKG ${app_pkg}
ENV APP_VERSION ${app_ver}
ENV APP_NAME ${app_name}

# VOLUME /$app_path/build

COPY ${app_pkg}-${APP_VERSION}.tar.gz .

RUN  set -ex ; tar -zxvf ${APP_PKG}-${APP_VERSION}.tar.gz  && \
     npm run build 2>&1 | tee npm.log; egrep -E '(ERROR|error)' npm.log && exit 1 ; rm -f npm.log \
     rm -rf ${APP_PKG}-${APP_VERSION}.tar.gz

CMD ["npm", "run", "build"]

