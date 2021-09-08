[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Dockerized C++ Build Environment

This repository contains a single highly customizable Makefile helping to build C+ projects in a docker container.

## Usage
* Add this repository as a git submodule to your project, for example as directory build_tools:<br>
`git submodule add  https://github.com/f-squirrel/dockerized_cpp.git build_tools/`
* Create a Makefile in the root of your project's source tree
* Override the variables from the [list](#list-of-variables) in the Makefile
* Include the Makefile from this repository in your new Makefile: `include build_tools/Makefile`

In order to see availabe commands including user-defined, run `make help`:

```plain
$ make help
gen_cmake                      Generate cmake files, used internally
build                          Build source. In order to build a specific target run: make TARGET=<target name>.
test                           Run all tests
clean                          Clean build directory
login                          Login to the container. Note: if the container is already running, login into existing one
build-docker-deps-image        Build the deps image.
```

## Example
An example of usage can be found in the repository ["Dockerized C++ Build Example"](https://github.com/f-squirrel/dockerized_cpp_build_example).

## List of variables

| Variable name                 | Default value             | Description |
| -------------                 | -------------             | ----------- |
| PROJECT_NAME                  | project                   | Name of the project, by default used in multiple places |
| DOCKER_CC                     | clang                     | C copmiler used in the project |
| DOCKER_CXX                    | clang++                   | C++ copmiler used in the project |
| DOCKER_DEPS_REPO              | ${PROJECT_NAME}/          | Docker repository where the build image is stored |
| DOCKER_DEPS_IMAGE             | ${PROJECT_NAME}_build      | The name of the build image |
| DOCKER_DEPS_VERSION            | latest | Docker image     version |
| DOCKER_DEPS_CONTAINER         | ${DOCKER_DEPS_IMAGE}      | The name of build's docker container |
| DOCKER_DEPS_FILE              | DockerfileBuildEnv        | Dockerfile used for building the build image |
| DOCKER_DEPS_IMAGE_BUILD_FLAGS | --no-cache=true           | Flags used for building the image, note with this flag on, docker rebuilds from scratch the whole image |
| DOCKER_PREPEND_MAKEFILES      | empty                     | The list of space-separated custom Makefiles to be included before default targets |
| DOCKER_APPEND_MAKEFILES       | empty                     | The list of space-separated ustom Makefiles to be included after default targets |
| DOCKER_CMAKE_FLAGS            | empty                     | Project specific CMake flags |
| DOCKER_SHELL                  | bash                      | Shell used in the container |
| LOCAL_SOURCE_PATH             | Current directory         | The path to the source files |
| DOCKER_SOURCE_PATH            | /${PROJECT_NAME}          | Path where source files are mounted in the container |
| DOCKER_BUILD_DIR              | build                     | Cmake build directory |
| DOCKER_CTEST_TIMEOUT          | 5000                      | CMake test timeout |
| DOCKER_TEST_CORE_DIR          | ${DOCKER_BUILD_DIR}/cores | Path to the core files. For more information on configuring core dumps in docker please refer [here](https://ddanilov.me/how-to-configure-core-dump-in-docker-container) |
| DOCKER_ADDITIONAL_RUN_PARAMS  | empty                     | Additional docker run commands |
| DOCKER_BASIC_RUN_PARAMS       | [link to the code](https://github.com/f-squirrel/dockerized_cpp/blob/master/Makefile#L29) | Default commands used for running the build container |

