PROJECT_NAME?=project

DOCKER_CC?=clang
DOCKER_CXX?=clang++

DOCKER_DEPS_REPO?=${PROJECT_NAME}/
DOCKER_DEPS_IMAGE?=${PROJECT_NAME}_deps
DOCKER_DEPS_VERSION?=latest
DOCKER_DEPS_CONTAINER?=${DOCKER_DEPS_IMAGE}
DOCKER_DEPS_FILE?=DockerfileBuildEnv

DOCKER_PREPEND_MAKEFILES?=
DOCKER_APPEND_MAKEFILES?=

DOCKER_CMAKE_FLAGS?=

DOCKER_SHELL?="bash"
LOCAL_SRC_PATH?=${CURDIR}
DOCKER_SOURCE_PATH?=/${PROJECT_NAME}
DOCKER_BUILD_DIR?="build"
DOCKER_CTEST_TIMEOUT?="5000"

DOCKER_TEST_CORE_DIR?="cores"

ADDITIONAL_RUN_PARAMS?=

BASIC_RUN_PARAMS?=-it --init --rm --privileged=true \
					  --memory-swap=-1 \
					  --ulimit core=-1 \
					  --name="${DOCKER_DEPS_CONTAINER}" \
					  --workdir=${DOCKER_SOURCE_PATH} \
					  --mount type=bind,source=${LOCAL_SRC_PATH},target=${DOCKER_SOURCE_PATH} \
					  ${ADDITIONAL_RUN_PARAMS} \
					  ${DOCKER_DEPS_REPO}${DOCKER_DEPS_IMAGE}:${DOCKER_DEPS_VERSION}

IF_CONTAINER_RUNS=$(shell docker container inspect -f '{{.State.Running}}' ${DOCKER_DEPS_CONTAINER} 2>/dev/null)

.DEFAULT_GOAL:=build

-include ${DOCKER_PREPEND_MAKEFILES}

.PHONY: help
help: ##
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: gen_cmake
gen_cmake: ## Generate cmake files, used internally
	docker run ${BASIC_RUN_PARAMS} \
		${DOCKER_SHELL} -c \
		"mkdir -p ${DOCKER_SOURCE_PATH}/${DOCKER_BUILD_DIR} && \
		cd ${DOCKER_BUILD_DIR} && \
		CC=${DOCKER_CC} CXX=${DOCKER_CXX} \
		cmake ${DOCKER_CMAKE_FLAGS} .."
	@echo
	@echo "CMake finished."

.PHONY: build
build: gen_cmake ## Build source. In order to build a specific target run: make TARGET=<target name>.
	docker run ${BASIC_RUN_PARAMS} \
		${DOCKER_SHELL} -c \
		"cd ${DOCKER_BUILD_DIR} && \
		make -j $$(nproc) ${TARGET}"
	@echo
	@echo "Build finished. The binaries are in ${CURDIR}/${DOCKER_BUILD_DIR}"

.PHONY: test
test: ## Run all tests
	docker run ${BASIC_RUN_PARAMS} \
		${DOCKER_SHELL} -c \
		"mkdir -p ${DOCKER_TEST_CORE_DIR} && \
		cd ${DOCKER_BUILD_DIR} && \
		ctest --timeout ${DOCKER_CTEST_TIMEOUT} --output-on-failure"

.PHONY: clean
clean: ## Clean build directory
	docker run ${BASIC_RUN_PARAMS} \
		${DOCKER_SHELL} -c \
		"rm -rf ${DOCKER_BUILD_DIR}"

.PHONY: login
login: ## Login to the container. Note: if the container is already running, login into existing one
	@if [ "${IF_CONTAINER_RUNS}" != "true" ]; then \
		docker run ${BASIC_RUN_PARAMS} \
			${DOCKER_SHELL}; \
	else \
		docker exec -it ${DOCKER_DEPS_CONTAINER} \
			${DOCKER_SHELL}; \
	fi

.PHONY: build-docker-deps-image
build-docker-deps-image: ## Build the deps image. Note: without caching
	docker build -t ${DOCKER_DEPS_REPO}${DOCKER_DEPS_IMAGE}:latest \
		-f ./${DOCKER_DEPS_FILE} .
	@echo
	@echo "Build finished. Docker image name: \"${DOCKER_DEPS_REPO}${DOCKER_DEPS_IMAGE}:latest\"."
	@echo "Before you push it to Docker Hub, please tag it(DOCKER_DEPS_VERSION + 1)."
	@echo "If you want the image to be the default, please update the following variables:"
	@echo "${CURDIR}/Makefile: DOCKER_DEPS_VERSION"

-include ${DOCKER_APPEND_MAKEFILES}
