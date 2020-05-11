# Shell Special Folder Constants: https://docs.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants
# Shell Folder Methods: https://docs.microsoft.com/en-us/windows/win32/shell/folder

param([switch]$copyAll,[switch]$moveAll,[switch]$deleteAll,[string]$deviceName,[string]$sourceFolder,[string]$targetFolder,[string]$filter='(.jpg)|(.mp4)$')
 
function Ask-Sure-N
{
	$askConfirm = "Are you sure? y/N"
	$confirm = read-host $askConfirm
	if (!($confirm -eq "y" -or $confirm -like "yes"))
	{
		write-host "Aborted."
		exit
	}
}

function Ask-Sure-Y
{
	$askConfirm = "Are you sure? Y/n"
	$confirm = read-host $askConfirm
	if (!($confirm -eq "y" -or $confirm -like "yes" -or $confirm -eq ""))
	{
		write-host "Aborted."
		exit
	}
}

function Get-ShellProxy
{
    if( -not $global:ShellProxy)
    {
        $global:ShellProxy = new-object -com Shell.Application
    }
    $global:ShellProxy
}

function Get-Shell-Folder
{
	param($path)
	$shell = Get-ShellProxy
	$shellItem = $shell.Namespace($path).self
	return $shellItem.GetFolder
}

function Get-RecyclingBin-Folder
{
	$recyclingBin = Get-Shell-Folder 10
	return $recyclingBin
}

function Get-MyComputer-Folder
{
	$myComputer = Get-Shell-Folder 17
	return $myComputer
}

function Get-Temp-Path
{
	return [System.IO.Path]::GetTempPath()
}

function Get-Temp-Folder
{
	$tempPath = Get-Temp-Path
	$temp = Get-Shell-Folder $tempPath
	return $temp
}

function Get-Device
{
    param($deviceName)
    $myComputer = Get-MyComputer-Folder
    $device = $myComputer.items() | where { $_.name -eq $deviceName }
    return $device
}
 
function Get-SubFolder
{
    param($parent,[string]$path)
    $pathParts = @( $path.Split([system.io.path]::DirectorySeparatorChar) )
    $current = $parent
    foreach ($pathPart in $pathParts)
    {
        if ($pathPart)
        {
            $current = $current.GetFolder.items() | where { $_.name -eq $pathPart }
        }
    }
    return $current.GetFolder
}

function Copy-Files
{
	param([switch]$move, $deviceName, $device, $deviceFolderPath, $destinationFolderPath, $filter)
	if ($move)
	{
		write-host "Confirm moving files from $deviceName"
		Ask-Sure-Y
	}
	$deviceSubFolder = Get-SubFolder -parent $device -path $deviceFolderPath
	$items = $deviceSubFolder.items() | where { $_.name -match $filter }
	if (!$items -or $items.count -eq 0)
	{
		write-host "No files found matching filter: $filter"
		return
	}
	if (-not (test-path $destinationFolderPath))
	{
		new-item -itemtype directory -path $destinationFolderPath > $null
	}
	$destinationFolder = Get-Shell-Folder $destinationFolderPath
	foreach ($item in $items)
	{
		$filename = $item.name
		$targetFilePath = join-path -path $destinationFolderPath -childPath $filename
		if (test-path -path $targetFilePath)
		{
			write-host "Destination file exists - file not saved:`n`t$targetFilePath"
		}
		else
		{
			if ($move)
			{
				$destinationFolder.MoveHere($item) > $null
			}
			else
			{
				$destinationFolder.CopyHere($item) > $null
			}
			if (test-path -path $targetFilePath)
			{
				write-host "Successfully saved: $targetFilePath"
			}
			else
			{
				write-host "Failed to save file: $targetFilePath"
			}
		}
	}
}

function Delete-Files
{
	param($deviceName, $device, $deviceFolderPath, $filter)
	write-host "Confirm deleting all files from $deviceName"
	Ask-Sure-N
	$deviceSubFolder = Get-SubFolder -parent $device -path $deviceFolderPath
	$items = $deviceSubFolder.items() | where { $_.name -match $filter }
	if (!$items -or $items.count -eq 0)
	{
		write-host "No files found matching filter: $filter"
		return
	}
	$tempFolder = Get-Temp-Folder
	foreach ($item in $items)
	{
		$filename = $item.name
		$tempPath = Get-Temp-Path
		$targetFilePath = join-path -path $tempPath -childPath $filename
		$tempFolder.MoveHere($item) > $null
		if (test-path -path $targetFilePath)
		{
			remove-item -path $targetFilePath > $null
			if (test-path -path $targetFilePath)
			{
				write-host "Failed to delete file: $filename"
			}
			else
			{
				write-host "Successfully deleted: $filename"
			}
		}
		else
		{
			write-host "Failed to delete file: $filename"
		}
	}
}

function Main
{
	$device = Get-Device -deviceName $deviceName
	if (!$device)
	{
		write-host "Cannot find device: $deviceName"
		exit
	}

	if ($copyAll)
	{
		Copy-Files -deviceName $deviceName -device $device -deviceFolderPath $sourceFolder -destinationFolderPath $targetFolder -filter $filter
	}
	elseif ($moveAll)
	{
		Copy-Files -move -deviceName $deviceName -device $device -deviceFolderPath $sourceFolder -destinationFolderPath $targetFolder -filter $filter
	}
	elseif ($deleteAll)
	{
		Delete-Files -deviceName $deviceName -device $device -deviceFolderPath $sourceFolder -filter $filter
	}
}

Main
