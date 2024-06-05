param(
	[string] $folderPath,
    [string] $schemaName,
    [string] $tableName,
	[string] $uploadFile,
    [string] $createTableDDL)

$uploadFilePath = Join-Path -Path $folderPath -ChildPath $uploadFile
if (Test-Path -Path $uploadFilePath ) {
    $content = Get-Content -Path $uploadFilePath 
    if ($content -eq $null -or $content.Length -eq 0) {
        Write-Host "The file is empty."
    } else {
        $csvData = Import-CSV $uploadFilePath -Delimiter "|"
        $headers = $csvData[0].psobject.properties.name
        $ddl = "CREATE TABLE [$schemaName].[$tableName] (" + [Environment]::NewLine
            foreach ($columns in $headers) {
            $columns = $columns -replace '[\W]', '_'
            $ddl += "    [$columns] varchar(256) NULL," + [Environment]::NewLine
        }
        
        #remove trailing , and newline.
        $ddl = $ddl.TrimEnd([Environment]::NewLine)
        $ddl = $ddl.TrimEnd(",") 
        $ddl += [Environment]::NewLine + ") ON [PRIMARY]"

        $createTableDDLPath = Join-Path -Path $folderPath -ChildPath $createTableDDL
        $ddl | Out-File -FilePath $createTableDDLPath -NoClobber #NoClobber if Fixed schema is desired
    }
} else {
    Write-Host "The file does not exist."
}