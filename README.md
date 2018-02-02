# Jenkins.BuildAgents

Collection of [Packer](https://www.packer.io/intro/index.html) scripts to create new AMIs for build agents.  This makes it easy to apply new versions of build tools or create agents from up-to-date base AMIs with the latest security patches.

## Preparation

Install Packer using [Chocolatey](https://chocolatey.org/):

```powershell
choco install packer
```

Install [AWS Powershell Tools](https://www.powershellgallery.com/packages/AWSPowerShell):

```
Install-Module -Name AWSPowerShell
```

## Building a New AMI

1. Login to AWS using `Set-AWSCredential` or some other means of getting your credentials added to your PowerShell session.

2. Run `Pack.ps1`, supplying the path to the Packer script your wish to run:

```powershell
.\Pack.ps1 .\windows-msbuild2017.json
```

3. Watch the magic happen!