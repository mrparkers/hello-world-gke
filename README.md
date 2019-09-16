# hello-world-gke
Hello world application deployed to Google Cloud Kubernetes Engine

## Prerequisites

#### Google Cloud SDK

This demo application will be deployed to Google Cloud Platform. As
such, you will need a Google Cloud account in order to deploy this to
your own project.

You can click [here](https://cloud.google.com/free) to create a Google
Cloud account and receive $300 in promotional credits.

> Note: This demo exercise will cost money to run, so it is highly
> recommended to sign up for the $300 free credit. While Google Cloud
> does have an "always free" tier, this will not completely cover the
> resources used for this exercise.

After signing up, a billing account called "My Billing Account" with
$300 promotional credits should have been created for you. This account
will be used for the duration of this exercise.

The next step is to download the [Google Cloud SDK](https://cloud.google.com/sdk/).
This tool will allow you to obtain credentials for your Google account
that will be provided to the tools / scripts used to provision this
environment. It will also allow you to query for information about your
Google Cloud project(s) using a command line interface.

Once your `gcloud` CLI is set up, the following command can be used to
authenticate yourself with your Google account:

```bash
$ gcloud auth login
```

Optionally, you can also run the following command to authenticate any
applications that you run locally to use your Google account when
communicating to Google APIs:

```bash
gcloud auth application-default login
```

#### Docker

The only other prerequisite required for this exercise is Docker. While
this exercise takes advantage of several different tools to provision
infrastructure, such as Terraform, Helm, and the Kubernetes CLI, each of
these tools will be wrapped within a Docker image that can be built and
used locally.

## Deploying the exercise

The following command can be used to deploy this exercise:

```
$ make up
```

This command will build the image used for this exercise, and use it to
run `terraform`, `helm`, and `kubectl` to provision the environment for
you.

When you run this, you will be prompted to enter a value for your Google
Cloud Project ID. This is a string value that must be unique across all
of Google Cloud.

You will also be prompted to type the string `yes` during the `terraform
apply` step.

## Cleaning up

The following command can be used to clean up all resources deployed
within this exercise:

```
$ make down
```

You will be prompted to enter the string `yes` to confirm that you want
to destroy the resources provisioned during this exercise.

## Tools used

- [Terraform](https://www.terraform.io/) - used to provision and
  configure all of the Google Cloud infrastructure. The code for this
  can be found in the `tf` folder.
- [Helm](https://helm.sh/) - used to deploy the demo application and the
  [cert-manager](https://github.com/jetstack/cert-manager) and
  [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
  charts.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) -
  used to interact with the provisioned Kubernetes cluster
- [jq](https://stedolan.github.io/jq/) - used to parse JSON output from
  various commands
  
## Helm charts used

- [cert-manager](https://github.com/jetstack/cert-manager) - used to
  create a CA and SSL certificate to enable HTTPS communication with our
  app.
- [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
  \- used to enable ingress into our cluster using the `Ingress` API.
  This ingress controller consumes the certificate created by
  cert-manager and handles SSL termination for our application.

## Demo application

The application that will be deployed to your Kubernetes cluster during
this exercise is a Node.js based app that returns a JSON payload at `/`.
The source code can be found within the `app` folder. This code has
already been packaged into a Docker container that can be found at
[`mrparkers/hello-world-gke`](https://hub.docker.com/r/mrparkers/hello-world-gke).

The helm chart used for this application can be found within the
`k8s/app` folder.
