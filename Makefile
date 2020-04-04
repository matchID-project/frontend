##############################################
# WARNING : THIS FILE SHOULDN'T BE TOUCHED   #
#    FOR ENVIRONNEMENT CONFIGURATION         #
# CONFIGURABLE VARIABLES SHOULD BE OVERRIDED #
# IN THE 'artifacts' FILE, AS NOT COMMITTED  #
##############################################

SHELL=/bin/bash
export DEBIAN_FRONTEND=noninteractive
export USE_TTY := $(shell test -t 1 && USE_TTY="-t")
#matchID default exposition port
export APP_GROUP=matchID
export APP=frontend
export APP_PATH=$(shell pwd)
export APP_NAME=${APP_GROUP}
export API_PATH=/${APP_NAME}/api/v0
export API_USER_LIMIT_RATE=1r/s
export API_DOWNLOAD_LIMIT_RATE=30r/m
export API_USER_BURST=20 nodelay
export API_USER_SCOPE=http_x_forwarded_for
export API_GLOBAL_LIMIT_RATE=20r/s
export API_GLOBAL_BURST=200 nodelay
export PORT=8081
export BACKEND_HOST=backend
export BACKEND_PORT=8081
export TIMEOUT=30

#matchID default paths
export FRONTEND := $(shell pwd)
export NGINX=${FRONTEND}/nginx
export NGINX_TIMEOUT=15
export DOCKER_USERNAME=$(shell echo ${APP_GROUP} | tr '[:upper:]' '[:lower:]')
export DC_DIR=${FRONTEND}
export DC_FILE=${DC_DIR}/docker-compose
export DC_PREFIX := $(shell echo ${APP_GROUP} | tr '[:upper:]' '[:lower:]')
export DC_IMAGE_NAME=${DC_PREFIX}-${APP}
export DC_NETWORK=${DC_PREFIX}
export DC_NETWORK_OPT=
export DC_BUILD_ARGS = --pull --no-cache
export DC_IMAGE_NAME=${DC_PREFIX}-${APP}
export GIT_ROOT=https://github.com/matchid-project
export GIT_ORIGIN=origin
export GIT_BRANCH=dev
export GIT_TOOLS=tools
export GIT_BACKEND=backend
export GIT_BACKEND_BRANCH=dev

export BACKEND=${FRONTEND}/../${GIT_BACKEND}
export BACKEND_DC_IMAGE_NAME=${DC_PREFIX}-${GIT_BACKEND}

dummy		    := $(shell touch artifacts)
include ./artifacts

tag                 := $(shell git describe --tags | sed 's/-.*//')
version 			:= $(shell cat tagfiles.version | xargs -I '{}' find {} -type f -not -name '*.tar.gz'  | sort | xargs cat | sha1sum - | sed 's/\(......\).*/\1/')
export APP_VERSION =  ${tag}-${version}

commit 				= ${APP_VERSION}
lastcommit          := $(shell touch .lastcommit && cat .lastcommit)
date                := $(shell date -I)
id                  := $(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

vm_max_count		:= $(shell cat /etc/sysctl.conf | egrep vm.max_map_count\s*=\s*262144 && echo true)

export FILE_FRONTEND_APP_VERSION = $(APP_GROUP)-$(APP)-$(APP_VERSION).tar.gz
export FILE_FRONTEND_DIST_APP_VERSION = $(APP_GROUP)-$(APP)-$(APP_VERSION)-dist.tar.gz
export FILE_FRONTEND_DIST_LATEST_VERSION = $(APP_GROUP)-$(APP)-latest-dist.tar.gz

export BUILD_DIR=${FRONTEND}/nginx/dist
export DC_BUILD_FRONTEND=${DC_FILE}-build.yml
export DC_RUN_NGINX_FRONTEND=${DC_FILE}.yml

#temp fix before updating
export NPM_FIX=true

DC := 'docker-compose'
include /etc/os-release

version:
	@echo ${APP_GROUP} ${APP} ${APP_VERSION}

configure:
	# this proc relies on matchid/tools and works both local and remote
	@sudo apt-get install make -yq
	@if [ -z "${TOOLS_PATH}" ];then\
		git clone ${GIT_ROOT}/${GIT_TOOLS};\
		make -C ${APP_PATH}/${GIT_TOOLS} config ${MAKEOVERRIDES};\
	else\
		ln -s ${TOOLS_PATH} ${APP_PATH}/${GIT_TOOLS};\
	fi
	cp artifacts ${APP_PATH}/${GIT_TOOLS}/
	@ln -s ${APP_PATH}/${GIT_TOOLS}/aws ${APP_PATH}/aws
	@touch configure

config-clean:
	@(rm -rf tools aws configure > /dev/null 2>&1 )|| exit 0;

docker-clean: stop
	docker container rm matchid-build-front matchid-nginx

clean: frontend-clean config-clean

network-stop:
	docker network rm ${DC_NETWORK}

network: configure
	@docker network create ${DC_NETWORK_OPT} ${DC_NETWORK} 2> /dev/null; true

backend-stop:
	make -C ${BACKEND} backend-stop

backend-prep:
ifeq ("$(wildcard ${UPLOAD})","")
	@sudo mkdir -p ${UPLOAD}
endif
ifeq ("$(wildcard ${PROJECTS})","")
	@sudo mkdir -p ${PROJECTS}
endif
ifeq ("$(wildcard ${MODELS})","")
	@sudo mkdir -p ${PROJECTS}
endif

backend-config:
	@if [ ! -d "${BACKEND}" ];then\
		git clone ${GIT_ROOT}/${GIT_BACKEND} ${BACKEND};\
		cd ${BACKEND};\
		git checkout ${GIT_BACKEND_BRANCH};\
	fi

backend-dev: network backend-config
	@make -C ${BACKEND} backend-dev ${MAKEOVERRIDES}

backend: network backend-config
	@make -C ${BACKEND} wait-backend ${MAKEOVERRIDES}

backend-docker-check: configure backend-config
	@make -C ${APP_PATH}/${GIT_TOOLS} docker-check \
		DC_IMAGE_NAME=${BACKEND_DC_IMAGE_NAME}\
		APP_VERSION=$(shell cd ${BACKEND} && make version | awk '{print $$NF}')

frontend-clean: frontend-build-dir-clean
	@(rm ${FRONTEND}/$(FILE_FRONTEND_APP_VERSION) > /dev/null 2>&1 )|| exit 0;

frontend-dev:
ifneq "$(commit)" "$(lastcommit)"
	@echo docker-compose up matchID frontend for dev after new commit
	${DC} -f ${DC_FILE}-dev.yml up --build -d
	@echo "${commit-frontend}" > ${FRONTEND}/.lastcommit
else
	@echo docker-compose up matchID frontend for dev
	${DC} -f  ${DC_FILE}-dev-frontend.yml up -d
endif

frontend-dev-stop:
	${DC} -f ${DC_FILE}-dev-frontend.yml down

dev: network frontend-stop backend elasticsearch postgres frontend-dev

dev-stop: backend-stop kibana-stop elasticsearch-stop postgres-stop frontend-dev-stop newtork-stop


${FRONTEND}/$(FILE_FRONTEND_APP_VERSION):
	( cd ${FRONTEND} && tar -zcvf $(FILE_FRONTEND_APP_VERSION) \
		index.html \
		package.json \
        src \
        static \
		.babelrc \
		.editorconfig \
		.eslintrc.js \
		.eslintignore \
		build \
		config \
		)

frontend-build-dist: ${FRONTEND}/$(FILE_FRONTEND_APP_VERSION) frontend-build-check
	@echo building ${APP_GROUP} ${APP} in ${FRONTEND}
	${DC} -f $(DC_BUILD_FRONTEND) build $(DC_BUILD_ARGS)

frontend-build-dir:
	@mkdir -p ${BUILD_DIR}

frontend-build-check:
	${DC} -f $(DC_BUILD_FRONTEND) config -q

frontend-build-dir-clean:
	@(rm -rf ${BUILD_DIR} > /dev/null 2>&1 )|| exit 0;

$(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION): frontend-build-dir
	${DC} -f $(DC_BUILD_FRONTEND) run -T --rm frontend-build tar czf - $$(basename /$(APP_GROUP)/dist) -C $$(dirname /$(APP_GROUP)/dist) > $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION)
	  cp $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION)
	if [ -f $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) ]; then ls -alsrt  $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) && sha1sum $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) ; fi
	if [ -f $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION) ]; then ls -alsrt  $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION) && sha1sum $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION) ; fi

frontend-package-dist: $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION)

frontend-build: frontend-build-dist frontend-package-dist

nginx-check-build:
	${DC} -f $(DC_RUN_NGINX_FRONTEND) config -q

nginx-build: $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) nginx-check-build
	@echo building ${APP_GROUP} static nginx ${APP}
	cp $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) ${NGINX}/
	${DC} -f $(DC_RUN_NGINX_FRONTEND) build $(DC_BUILD_ARGS)

frontend-stop:
	${DC} -f ${DC_FILE}.yml down

frontend-docker-check: configure
	@make -C ${APP_PATH}/${GIT_TOOLS} docker-check DC_IMAGE_NAME=${DC_IMAGE_NAME} APP_VERSION=${APP_VERSION} ${MAKEOVERRIDES}

docker-push:
	@make -C ${APP_PATH}/${GIT_TOOLS} docker-push DC_IMAGE_NAME=${DC_IMAGE_NAME} APP_VERSION=${APP_VERSION} ${MAKEOVERRIDES}

frontend: frontend-docker-check
	@echo docker-compose up matchID frontend
	${DC} -f ${DC_FILE}.yml up -d
	@timeout=${NGINX_TIMEOUT} ; ret=1 ; until [ "$$timeout" -le 0 -o "$$ret" -eq "0"  ] ; do (curl -s --fail -XGET localhost:${PORT} > /dev/null) ; ret=$$? ; if [ "$$ret" -ne "0" ] ; then echo "waiting for nginx to start $$timeout" ; fi ; ((timeout--)); sleep 1 ; done ; exit $$ret

stop: backend-stop frontend-stop
	@echo all components stopped

build: frontend-build nginx-build

start: backend frontend

up: start

down: stop

restart: down up
