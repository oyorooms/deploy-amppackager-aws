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
The `bin/amppkg` binary is the actual executable which will start the server. `scripts/amppkg.sh` is a helper shell script for various operations in this project. The following command will **g**et, **b**uild a fresh binary and **r**un the server:
```
./scripts/amppkg.sh -g -b -r
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
Since this is just a deployment helper, it fetches the amppackager tool itself from it's own GitHub repo on each deployment.
**This should be done to get the updates, but must be tested for compatibity whenever upgraded!**
```
./scripts/amppkg.sh -g
```

## Details of the `amppkg.sh` script
The script is made for local use. It has various flags that help from running the binary to even fetching the fresh amppackager version from it's GitHub repo.

**Usage:** `./scripts/amppkg.sh -flag`

**Possible flags:**
```
 -g Get and build latest amppackager (use only when updated package needed)
 -b Build amppackager binary to "bin/amppkg"
 -r Run amppackager binary
 -d Run amppackager binary in development mode
```

## The amppackager server
The server listens on port `8080`. It serves the signed exchange on URLs of this format:
```
localhost:8080/priv/doc/<Document's URL>
```

For example, `localhost:8080/priv/doc/https://www.example.com/awesome-amp-page/` will serve the signed exchange for a `https://www.example.com/awesome-amp-page/` AMP Page.

It serves other resources like certificate information on the URL's of this format:
```
localhost:8080/amppkg/<Path to Resource>
```

## Checking activity logs on Elastic Beanstalk instances
Helpful sample commands for checking EC2 logs:

Go server logs:
```
sudo tail -f -n 300 /var/log/web-1.error.log
sudo tail -f -n 300 /var/log/web-1.log ## <-- not used in current amppackager
```
EB activity logs:
```
sudo tail -f -n 300 /var/log/eb-activity.log
```
Nginx logs:
```
sudo tail -f -n 300 /var/log/nginx/error.log
```

## More on Elastic Beanstalk
Accessing env vars and other configs:
```
sudo /opt/elasticbeanstalk/bin/get-config optionsettings ## (all config options)
sudo /opt/elasticbeanstalk/bin/get-config environment ## (env vars as json)
sudo /opt/elasticbeanstalk/bin/get-config environment -k GOPATH ## (particular env var value, here "GOPATH")
```

Refer hooks dir on EC2:
```
/opt/elasticbeanstalk/hooks/
```

## Generating ECDSA key and CSR (refer [this article](https://www.ericlight.com/using-ecdsa-certificates-with-lets-encrypt))
If new key and certificate are needed, the following procedure should come in handy:

Generate a new EC P-256 private key:
```
openssl ecparam -genkey -name secp256r1 | openssl ec -out privkey.pem
```

Generate a Certificate Signing Request (CSR) using the key:
```
openssl req -new -sha256 -key privkey.pem -nodes -out ec.csr -outform pem
```

Now the generated CSR can be submitted to the CA for signing.
At the time of writing this, only DigiCert provides certificates with [CanSignHttpExchanges extension](https://www.digicert.com/account/ietf/http-signed-exchange.php).

Other options are self-signed certificates (issue: OCSP issues) or free Let'sEncrypt certificates (issue: no CanSignHttpExchanges extension, so they work in development mode only).
