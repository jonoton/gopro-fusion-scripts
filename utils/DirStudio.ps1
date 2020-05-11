$processDate = (Get-Date).ToString("yyyy-MM-dd")
write-host "Process Date $processDate"

$frontDir = "Front"
$backDir = "Back"
$frontFilePre = "GPFR"
$backFilePre = "GPBK"

$3k = "3072"
$5k = "5760"

$dirStudioExe = "C:\Program Files\GoPro\Fusion Studio 1.3\FusionStudio_x64.exe"
$width = $3k

$srcDir = $args[0]
$destDir = $args[1].ToString() + "\$processDate"
write-host "Destination Folder is $destDir"
if (!(test-path $destDir))
{
	mkdir $destDir
	write-host ""
}

$subName = ".tmp"

$destDirSub = "$destDir\$subName"
write-host "Destination Sub Folder is $destDirSub"

if (!(test-path $destDirSub))
{
	mkdir $destDirSub
	write-host ""
}
write-host "$destDir contains"
dir $destDir
write-host ""

$files = dir $srcDir\$frontDir\*.mp4
$stopWatch = new-object system.diagnostics.stopwatch
$stopWatch.Start()
$countVideos = 0
foreach ($file in $files)
{
	$filename = $file.ToString()
	$len = $filename.length
	$videoNum = $filename.Substring($len-8, 4)
	write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	write-host "Processing Video $videoNum"
	cp $srcDir\$frontDir\$frontFilePre$videoNum.* $destDirSub
	cp $srcDir\$backDir\$backFilePre$videoNum.* $destDirSub
	dir $destDirSub
	."$dirStudioExe" -d $destDirSub --wave $destDirSub\$backFilePre$videoNum.wav --amb 1 --width $width --videoCodec 0 --pc 1 --blending 0 --projection 0 --stabilization 2 --iq 3 --flatMode 0 --globalContrast 128 --sharpness 128 --temperature 128 --tint 128 -o $destDirSub  | Out-Null
	rm $destDirSub\*
	move "$destDir\_shot000$subName" "$destDir\Video$videoNum.mp4"
	write-host "Resulting Output is $destDir\Video$videoNum.mp4"
	write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	write-host ""
	$countVideos++
}
$stopWatch.Stop()
$elapsedSeconds = $stopWatch.Elapsed.TotalSeconds
$elapsedMinutes = $stopWatch.Elapsed.TotalMinutes
$elapsedHours = $stopWatch.Elapsed.TotalHours

write-host ""
write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
if ($elapsedSeconds -lt 60)
{
	write-host "Total of $countVideos Videos took $elapsedSeconds seconds"
}
elseif ($elapsedMinutes -lt 60)
{
	write-host "Total of $countVideos Videos took $elapsedMinutes minutes"
}
else
{
	write-host "Total of $countVideos Videos took $elapsedHours hours"
}
write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
write-host ""

if (test-path $destDirSub)
{
	rm $destDirSub
}

dir $destDir
write-host ""
