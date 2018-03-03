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
.\Pack.ps1 .\amis\windows\windows-msbuild2017.json
```

3. Watch the magic happen!


## Setup AWS Credentials (Courtesy of David Jackson)

1. Login to AWS Console and Create an Access Key / Secret Key for your account

2. Open Powershell for AWS

3. Enter the following commands, replacing the Access Key and Secret Key combo from above:
```powershell
Set-AWSCredential -AccessKey YourAccessKeyFromStep1 -SecretKey YourSecretKeyFromStep1 -StoreAs myCredentials
```
```powershell
Set-AWSCredential -SourceProfile myCredentials -RoleArn arn:aws:iam::097130181434:role/PowerUser -MfaSerial arn:aws:iam::yourmfaserialnumber -StoreAs myRoleProfile
```
```powershell
Set-WSCredential myRoleProfile
```

4. Verify Setup with:
```powershell
Get-EC2Instance -Region us-east-1
```

5. (Optional) Set Default Region
```powershell
Set-DefaultAWSRegion -Region us-east-1
```

## Packer Crashes!

NOTE: If Packer crashes during the creation of an AMI, it may be necessary to log directly into AWS to cleanup any temporary artifacts created by Packer during the creation process.

Check the following in AWS:
1. EC2
2. Security Groups
3. Access Keys

Filtering on the keyword 'Packer' in the areas listed above should reveal any values that need to be manually cleaned up (deleted / unregistered / etc).