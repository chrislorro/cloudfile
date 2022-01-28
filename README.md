# cloudfile

Welcome to your new module. A short overview of the generated parts can be found in the PDK documentation at https://puppet.com/pdk/latest/pdk_generating_modules.html .

#### Table of Contents

- [cloudfile](#cloudfile)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [What cloudfile affects](#what-cloudfile-affects)
    - [Setup Requirements **OPTIONAL**](#setup-requirements-optional)
    - [Beginning with cloudfile](#beginning-with-cloudfile)
  - [Usage](#usage)
      - [Examples](#examples)
        - [retrieve an application call invader from s3 storage to linux](#retrieve-an-application-call-invader-from-s3-storage-to-linux)
        - [retrieve an application call invader from s3 storage and install the application](#retrieve-an-application-call-invader-from-s3-storage-and-install-the-application)
  - [Limitations](#limitations)
  - [Development](#development)
  - [Release Notes/Contributors/Etc. **Optional**](#release-notescontributorsetc-optional)
- [cloudfile](#cloudfile-1)

## Description

Download archived packages from various locations and optionally install locally

## Setup

This module is dependant on the archive module and also almost does the same, it has additional functionality for AWS CLI on windows platforms, and optional will use a package resource with optional install parameters

### What cloudfile affects

If using this module with AWS S3 bucket infrastructure the AWSCLI is automatically downloaded and install, for AZ filestore a token can be passed.
### Setup Requirements **OPTIONAL**

Include `puppet/archive` and any dependencies

### Beginning with cloudfile
## Usage
#### Examples
##### retrieve an application call invader from s3 storage to linux

```puppet
class cloudfile {
  app_name       => 'invader',
  package_file   => 'invader.tar.gz',
  package_uri    => 's3://chrislorro',
  extract        => true,
  cloud_download => standard,
  aws_region     => eu-west-2,
}
```
##### retrieve an application call invader from s3 storage and install the application

```puppet
class cloudfile {
  app_name        => 'mcafee',
  package_file    => 'McAfee.zip',
  package_uri     => 'https://chrislorro.blob.core.windows.net/puppet,
  extract         => true,
  cloud_download  => 'secure',
  token           => 'sp=rwd&st=2022-01-27T11:46[…]sig=2ytxxRcpND1Khs4UgUL1tfMxOwHsZMMit'
  package_name    => McAfee.exe,
  install_options => [ '/SILENT', '/INSTALL=AGENT']
}
```
## Limitations

This is a beta version and is under development its been tested for downloading from AWS and Azure on Redhat, Centos, Windows 2016/2019. 

This package install is in the early stages and will be improved during the next release

## Development

If you run into an issue with this module, or if you would like to request a feature, you can fork the repo and submit a PR, raise a bug or new feature request.

## Release Notes/Contributors/Etc. **Optional**

Coming soon
# cloudfile

