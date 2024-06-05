param(
    [string] $folderPath,
    [string] $inputFile,
    [string] $cleanedFile,
    [string] $uploadFile)

$inputFilePath = Join-Path -Path $folderPath -ChildPath $inputFile
$cleanedFilePath = Join-Path -Path $folderPath -ChildPath $cleanedFile
$uploadFilePath = Join-Path -Path $folderPath -ChildPath $uploadFile

Write-Host "$inputFilePath is inputFile"
Write-Host "$cleanedFilePath is cleanedFile"
Write-Host "$uploadFilePath is uploadFile"

if (Test-Path -Path $inputFilePath) {
    $content = Get-Content -Path $inputFilePath
    if ($content -eq $null -or $content.Length -eq 0) {
        Write-Host "The file is empty."
    } else {
    Import-Csv -Path $inputFilePath |
        ConvertTo-Csv -Delimiter '|' | 
        ForEach-Object { $_ -replace '"',[String]::Empty } |
        Out-File -Encoding utf8 -FilePath $cleanedFilePath

    Get-Content -Path $cleanedFilePath | Select-Object -Skip 1 | Set-Content $uploadFilePath -Encoding utf8
    }
} else {
    Write-Host "The file does not exist."
}