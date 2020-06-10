# gopro-fusion-scripts
GoPro Fusion Scripts

Automate copying/moving files from the camera and rendering/stitching them into videos.

[![Gift!](https://img.shields.io/badge/Gift!-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=RLF3ZHK79YL3W&currency_code=USD&source=url)

## Copy
```
gopro-fusion-scripts\copyCam.bat Sources\Cam
```
Copy all camera files front and back to `Sources\Cam` directory.

*Note: Prompt with default `Yes`.*

## Move
```
gopro-fusion-scripts\moveCam.bat Sources\Cam
```
Move all camera files front and back to `Sources\Cam` directory.

*Note: Prompt with default `No`.*

## Render/Stitch
```
gopro-fusion-scripts\render.bat Sources\Cam Rendered
```
Render/Stitch all local files in `Sources\Cam` directory and output to `Rendered` directory.

*Note: Prompts for options. Creates a sub directory with current date as the name in `Rendered` directory.*

## Clear
```
gopro-fusion-scripts\clearCam.bat
```
Clears all files on the camera.

*Note: Prompt with default `No`.*
