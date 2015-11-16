# CoreImageAreaFilterTest
This is an application that tests the Core Image filter CIAreaMinimum to see if a bug exists in Mac OS X 10.11 (El Capitan).

The application creates an image from a list of float values read from a file, creates a CIImage, then applies the CIAreaMinimum filter to it. The last line of code - reading the value back out from the 1x1 resulting image - is not correct. If anyone knows how to do this I'd appreciate letting me know!
