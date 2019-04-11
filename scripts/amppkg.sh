#!/usr/bin/env bash


# Usage:
# scriptname -flag
#
# Possible flags:
# -g Get and build latest amppackager (use only when updated package needed)
# -b Build amppackager binary to "bin/amppkg"
# -r Run amppackager binary
# -d Run amppackager binary in development mode


# Stops the process if something fails
set -e

# Set $GOPATH to current directory (project's root directory)
export GOPATH=`pwd`

# Parse arguments
while getopts "gbrd" option
do
  echo 'Running with argument:' -$option;
  case "${option}"
  in

    g)
      # ARG_GET=${OPTARG}

      echo 'Getting and building latest amppackager'
      # remove the obsolete amppackager folder
      rm -rf src/github.com/ampproject/amppackager
      # fetch and build the latest amppackager
      go get -u github.com/ampproject/amppackager/cmd/amppkg
      # remove it's ".git" folder
      # it should not be a redundant git repo
      # within this projects's own git repo
      rm -rf src/github.com/ampproject/amppackager/.git
      ;;

    b)
      # ARG_BUILD=${OPTARG}

      echo 'Building amppackager binary to "bin/amppkg"'
      # Build amppackager binary to "bin/amppkg"
      go build -o bin/amppkg src/github.com/ampproject/amppackager/cmd/amppkg/main.go
      ;;

    r)
      # ARG_RUN=${OPTARG}

      echo 'Running amppackager binary'
      # Execute the binary in prod mode
      # with config amppkg.toml (default config filename)
      ./bin/amppkg
      ;;

    d)
      # ARG_DEVRUN=${OPTARG}

      echo 'Running amppackager binary in development mode'
      # Execute the binary in dev mode
      # with config amppkg.toml (default config filename)
      ./bin/amppkg -development
      ;;
  esac
done
