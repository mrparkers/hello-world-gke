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
