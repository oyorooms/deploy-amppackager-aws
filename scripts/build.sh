#!/usr/bin/env bash

# Stops the process if something fails
set -xe

# Set $GOPATH to current directory (project's root directory)
export GOPATH=`pwd`

# Build amppackager binary to "bin/amppkg"
go build -o bin/amppkg src/github.com/ampproject/amppackager/cmd/amppkg/main.go

# (Just for reference) Build a Linux-architecture amppackager binary to "bin/amppkg" :
# GOARCH=amd64 GOOS=linux go build -o bin/amppkg src/github.com/ampproject/amppackager/cmd/amppkg/main.go
