&"choco" install gh --yes --no-progress

if (${Env:PATH}.EndsWith(';')) {
    $path = "${Env:PATH}${Env:ProgramFiles(x86)}\GitHub CLI\"
}
else {
    $path = "${Env:PATH};${Env:ProgramFiles(x86)}\GitHub CLI\"
}

setx /M PATH $path
