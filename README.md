# MATLAB Image Cartoonization

MATLAB Digital Image Processing Term Project – Image Cartoonization

## Overview

This project implements an image cartoonization system in MATLAB. The application provides a simple graphical user interface (GUI) that allows users to load an image and control the cartoonization level using a slider.

The main purpose of the project is to transform a standard image into a cartoon-like image by combining color quantization, bilateral filtering, and edge detection techniques.

## Features

- Graphical User Interface (GUI)
- Image loading from JPG, JPEG, PNG, and BMP formats
- Adjustable cartoonization level
- Color quantization
- Bilateral filtering
- Grayscale conversion
- Canny-based edge detection
- Real-time image update through the GUI

## Image Processing Pipeline

The cartoonization process consists of several main stages:

1. **Image Loading**
   - The user selects an input image through the GUI.

2. **Color Quantization**
   - The number of available color levels is reduced to create a simplified, cartoon-like color appearance.

3. **Bilateral Filtering**
   - Spatial and intensity-based weights are used to smooth the image while preserving important edges.

4. **Grayscale Conversion**
   - The filtered image is converted to grayscale for edge detection.

5. **Canny Edge Detection**
   - Edge information is obtained using Gaussian filtering, gradient calculation, non-maximum suppression, double thresholding, and hysteresis.

6. **Final Image**
   - The processed image is displayed as the cartoonized output.

## GUI

The application provides:

- **Load Image** button for selecting an image
- **Cartoonization Level** slider with values from 0 to 10
- Image display area for the processed result

## Requirements

- MATLAB
- Image Processing Toolbox

## How to Run

1. Download or clone this repository.
2. Open MATLAB.
3. Navigate to the project folder.
4. Open `manualcartoon.m`.
5. Run the program.
6. Click **Load Image** and select an image.
7. Adjust the **Cartoonization Level** slider to change the effect.

## Project Structure

```text
MATLAB-Image-Cartoonization/
│
├── README.md
└── manualcartoon.m
