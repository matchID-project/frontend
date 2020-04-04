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
export PORT=8081
export BACKEND_PORT=8081
export TIMEOUT=30

#matchID default paths
export FRONTEND := $(shell pwd)
export DOCKER_USERNAME=$(shell echo ${APP_GROUP} | tr '[:upper:]' '[:lower:]')
export DC_DIR=${FRONTEND}
export DC_FILE=${DC_DIR}/docker-compose
export DC_PREFIX := $(shell echo ${APP_GROUP} | tr '[:upper:]' '[:lower:]')
export DC_IMAGE_NAME=${DC_PREFIX}-${APP}
export DC_NETWORK=${DC_PREFIX}
export DC_NETWORK_OPT=
export DC_BUILD_ARGS = --pull --no-cache
export GIT_ROOT=https://github.com/matchid-project
export GIT_ORIGIN=origin
export GIT_BRANCH=dev
export GIT_TOOLS=tools
export GIT_BACKEND=backend
export GIT_BACKEND_BRANCH=dev

export BACKEND=${FRONTEND}/../${GIT_BACKEND}
export BACKEND_DC_IMAGE_NAME=${DC_PREFIX}-${FRONTEND}

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

export BUILD_DIR=${FRONTEND}/dist
export DC_BUILD_FRONTEND=${DC_FILE}-build.yml

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
	@rm -rf tools aws configure

docker-clean: stop
	docker container rm matchid-build-front matchid-nginx

clean: frontend-clean config-clean

network-stop:
	docker network rm ${DC_NETWORK}

network: configure
	@docker network create ${DC_NETWORK_OPT} ${DC_NETWORK} 2> /dev/null; true

backend-stop:
	${DC} down

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

backend-dev:
	@echo please use backend repo for full development mode && exit 1

backend: network
	@if [ -f docker-compose-local.yml ];then\
		DC_LOCAL="-f docker-compose-local.yml";\
	fi;\
	export BACKEND_ENV=production;\
	${DC} -f docker-compose.yml $$DC_LOCAL up -d

backend-docker-check:
	@BACKEND_APP_VERSION=$(make -C ${FRONTEND} version | awk '{print $$NF}');\
	make -C ${APP_PATH}/${GIT_TOOLS} docker-push DC_IMAGE_NAME=${BACKEND_DC_IMAGE_NAME} APP_VERSION=${BACKEND_APP_VERSION} ${MAKEOVERRIDES}


frontend-clean: frontend-build-dir-clean


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
		matchIdConfig \
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
	@sudo rm -rf ${BUILD_DIR}

$(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION): frontend-build-dir
	${DC} -f $(DC_BUILD_FRONTEND) run -T --rm frontend-build tar czf - $$(basename /$(APP)/public) -C $$(dirname /$(APP)/public) > $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION)
	  cp $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION)
	if [ -f $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) ]; then ls -alsrt  $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) && sha1sum $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION) ; fi
	if [ -f $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION) ]; then ls -alsrt  $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION) && sha1sum $(BUILD_DIR)/$(FILE_FRONTEND_DIST_LATEST_VERSION) ; fi

frontend-build: frontend-build-dist $(BUILD_DIR)/$(FILE_FRONTEND_DIST_APP_VERSION)


frontend-stop:
	${DC} -f ${DC_FILE}.yml down

frontend: frontend-build
	@echo docker-compose up matchID frontend
	${DC} -f ${DC_FILE}.yml up -d

stop: backend-stop
	@echo all components stopped

build: frontend-build

start: backend frontend

up: start

down: stop

restart: down up
