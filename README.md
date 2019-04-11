# deploy-amppackager-aws

A build/deploy wrapper around [amppackager](https://github.com/ampproject/amppackager).

> AMP Packager is a tool to [improve AMP URLs](https://www.ampproject.org/latest/blog/developer-preview-of-better-amp-urls-in-google-search) by signing the request-response pair (see [Signed Exchange](https://developers.google.com/web/updates/2018/11/signed-exchanges)).
> The packager is an HTTP server that sits behind a frontend server; it fetches and signs AMP documents as requested by the AMP Cache.
> By running it in a proper configuration, web publishers may have origin URLs appear in AMP search results.

This is a setup for fetching, building, running and deploying the AMP Packager (a Golang server) on AWS Elastic Beanstalk.

## Getting Started
Basic instructions required to run locally or to deploy on AWS.

### Prerequisites
- Golang v1.10 or higher
- `privkey.pem` and `fullchain.pem` must be present at directory `/.certs`
- The key must be ECDSA, curve secp256r1

### Running locally
The `bin/amppkg` binary is the actual executable which will start the server. `scripts/amppkg.sh` is a helper shell script for various operations in this project. The following command will **b**uild a fresh binary and **r**un the server:
```
./scripts/amppkg.sh -b -r
```
Or, for running in **d**evelopment mode:
```
./scripts/amppkg.sh -b -d
```

(By default, the `amppkg.toml` file will be used for configuration.)

### Deployment on AWS
The `Buildfile` and `Procfile` lead the building and spawning of the server process respectively on an AWS EB with Golang environment ([relevant AWS doc](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_go.html)).
Deploy via Jenkins on staging or prod environments.

During deployment, the certificate and private key are downloaded securely via the AWS S3 bucket created by EB, and placed in the /.certs folder on the instance(s). The download path is mentioned in an `.ebextensions` config file.

Change this according to your setup: `https://s3-ap-southeast-1.amazonaws.com/path/to/certs/fullchain.pem`

### Updating the amppackager from it's GitHub repo
Since this is just a deployment helper, the amppackager tool itself must be updated from it's own GitHub repo.
**This should be done to get the updates, but must be tested for compatibity whenever upgraded!**
```
./scripts/amppkg.sh -g
```
