Param(
    [string]
    [parameter(Mandatory = $true, Position = 0)]
    $Script,

    [Amazon.Runtime.AWSCredentials]
    $Credential = (Get-AWSCredential)
)

if ($Credential -eq $null) {
    throw "You must provide credentials using the '-Credential' parameter or use Set-AWSCredential in your PowerShell session."
}

$cred = $Credential.GetCredentials()

$params = @(
    "-var", "aws_access_key=$($cred.AccessKey)",
    "-var", "aws_secret_key=$($cred.SecretKey)"
)

if ($cred.UseToken) {
    $params += @("-var", "aws_session_token=$($cred.Token)")
}

packer build $params $Script