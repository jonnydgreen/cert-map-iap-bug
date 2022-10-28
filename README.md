# Certificate Map with IAP LB BE Services issue repro

## Quick start

Create tfvars file:

```terraform
project_id           = "<gcp_project_id>"
name                 = "hello"
oauth2_client_id     = "GCP OAuth 2.0 Client ID"
oauth2_client_secret = "GCP OAuth 2.0 Client Secret"
accessors            = ["<email>"]
enable_iap           = true
```

Plan:

```sh
make plan
```

If happy, apply:

```sh
make apply
```

Wait for certs to provision (~20mins):

```sh
gcloud alpha certificate-manager certificates list
```

Check endpoints in the browser:

- https://hello1.domain
- https://hello2.domain

You should see the following behaviour:

## Hello1

Response in browser:

```
There was a problem with your request. Please reference https://cloud.google.com/iap/docs/faq#error_codes. Error code 52
```

## Hello2

Response as expected in browser
