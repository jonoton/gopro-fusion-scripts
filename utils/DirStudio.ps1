
$fusionFilename = "FusionStudio_x64.exe"

function Get-ProgramFiles-FullPath {
	param($filename)
	$filePath = dir -Path "C:\\Program Files\\" -Filter $filename -Recurse -ErrorAction SilentlyContinue -Force | % { $_.FullName }
	return $filePath
}

$dirStudioExe = Get-ProgramFiles-FullPath -filename $fusionFilename
write-host "Fusion Studio: $dirStudioExe"

function Human-Readable-Size {
	param ([int]$size)
	if ($size -gt 1TB) { return [string]::Format("{0:0.00} TB", $size / 1TB) }
	elseif ($size -gt 1GB) { return [string]::Format("{0:0.00} GB", $size / 1GB) }
	elseif ($size -gt 1MB) { return [string]::Format("{0:0.00} MB", $size / 1MB) }
	elseif ($size -gt 1KB) { return [string]::Format("{0:0.00} kB", $size / 1KB) }
	elseif ($size -gt 0) { return [string]::Format("{0:0.00} B", $size) }
	else { return "" }
}

function Pretty-Print-Directory {
	param($path)
	$files = dir $path
	if ($files -and $files.length -ne 0) {
		write-host $path
		$totalLength = 0
		foreach ($file in $files) {
			$totalLength = $totalLength + $file.length
			$filename = $file.name
			$hsize = Human-Readable-Size -size $file.length
			write-host "`t$filename`t$hsize"
		}
		$htotal = Human-Readable-Size -size $totalLength
		write-host "Total $htotal"
	}
}

function Print-Separator {
	$separator = "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	write-host $separator
}

$processDate = (Get-Date).ToString("yyyy-MM-dd")
write-host "Process Date: $processDate"

$frontDir = "Front"
$backDir = "Back"
$frontFilePre = "GPFR"
$backFilePre = "GPBK"

$useGpu = "--iq 3"
$useCpu = "--iq 2"
$hw = $useGpu
$askHw = read-host "Choose HW:`n`t1. GPU`n`t2. CPU`n?(1)"
if ($askHw -eq 2) {
	$hw = $useCpu
}

$dWarp = "--pc 1"
$multiBandBlending = "--blending 0"
$equirectangularProjection = "--projection 0"
$fullStabilization = "--stabilization 2"
$styling = "--flatMode 0 --globalContrast 128 --sharpness 128 --temperature 128 --tint 128"

$3k = "--width 3072 --videoCodec 0" # h.264
$4k = "--width 3840 --videoCodec 0" # h.264
$5k = "--width 5120 --videoCodec 1" # cineform
$resolution = $3k
$askRes = read-host "Choose resolution:`n`t1. 3k h.264`n`t2. 4k h.264`n`t3. 5k cineform`n?(1)"
if ($askRes -eq 2) {
	$resolution = $4k
}
elseif ($askRes -eq 3) {
	$resolution = $5k
}

$globalSettings = "$resolution $dWarp $multiBandBlending $equirectangularProjection $fullStabilization $hw $styling"

$srcDir = $args[0]
$destDir = $args[1].ToString() + "\$processDate"
write-host "Destination Folder: $destDir"
if (!(test-path $destDir)) {
	mkdir $destDir > $null
}

$subName = ".tmp"
$destDirSub = "$destDir\$subName"
write-host "Destination Sub Folder: $destDirSub"
if (!(test-path $destDirSub)) {
	mkdir $destDirSub > $null
}
Pretty-Print-Directory -path $destDir

$files = dir $srcDir\$frontDir\*.mp4
$stopWatch = new-object system.diagnostics.stopwatch
$stopWatch.Start()
$countVideos = 0
foreach ($file in $files) {
	$filename = $file.ToString()
	$len = $filename.length
	$videoNum = $filename.Substring($len - 8, 4)
	Print-Separator
	write-host "Processing Video $videoNum"
	cp $srcDir\$frontDir\$frontFilePre$videoNum.* $destDirSub
	cp $srcDir\$backDir\$backFilePre$videoNum.* $destDirSub
	Pretty-Print-Directory -path $destDirSub
	$studioParamsStr = "-d `"$destDirSub`" --wave `"$destDirSub\$backFilePre$videoNum.wav`" --amb 1 $globalSettings -o `"$destDirSub`""
	$studioParams = $studioParamsStr.split(" ")
	write-host $dirStudioExe $studioParams
	."$dirStudioExe" $studioParams | Out-Null # Wait with Out-Null
	rm $destDirSub\*
	move "$destDir\_shot000$subName" "$destDir\Video$videoNum.mp4"
	write-host "Resulting Output is $destDir\Video$videoNum.mp4"
	Print-Separator
	write-host ""
	$countVideos++
}
$stopWatch.Stop()
$elapsedSeconds = $stopWatch.Elapsed.TotalSeconds
$elapsedMinutes = $stopWatch.Elapsed.TotalMinutes
$elapsedHours = $stopWatch.Elapsed.TotalHours

write-host ""
Print-Separator
if ($elapsedSeconds -lt 60) {
	write-host "Total of $countVideos Videos took $elapsedSeconds seconds"
}
elseif ($elapsedMinutes -lt 60) {
	write-host "Total of $countVideos Videos took $elapsedMinutes minutes"
}
else {
	write-host "Total of $countVideos Videos took $elapsedHours hours"
}
Print-Separator
write-host ""

if (test-path $destDirSub) {
	rm $destDirSub
}

Pretty-Print-Directory -path $destDir
