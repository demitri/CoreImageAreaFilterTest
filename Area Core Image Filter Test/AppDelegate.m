//
//  AppDelegate.m
//  Area Core Image Filter Test
//
//  Created by Demitri Muna on 10/27/15.
//  Copyright © 2015 Demitri Muna. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

// This takes a float array and normalizes it to [0,1]
//
void normalizeFloatArray01MinMax(float *a, unsigned long nelements, float min, float max)
{
	float delta = max - min;
	for (int i=0; i < nelements; i++) {
		a[i] = (a[i] - min) / delta;
	}
}

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	// Create the CIFilter
	CIFilter *areaMinFilter = [CIFilter filterWithName:@"CIAreaMinimum"];
	[areaMinFilter setDefaults];
	[areaMinFilter setValue:self.image forKey:@"inputImage"];
	[areaMinFilter setValue:self.imageExtent forKey:kCIInputExtentKey]; // <-- leaving this out may break filter on El Capitan?
	
	CIImage* minPixelImage = [areaMinFilter valueForKey:@"outputImage"];
	
	NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithCIImage:minPixelImage];
	//unsigned char btimapData = bitmap.bitmapData;
	unsigned char* data = bitmap.bitmapData; // pointer to pixel data
	
	// print out pixel value ... I don't know how to do this...
	NSLog(@"Value of minimum pixel after CIImage: %f", data[0]);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (CIImage*)image
{
	// Create CIImage from a binary file of float data.
	// This is not an RGB, only a list of floats (i.e. monoscale intensity).
	
	if (_image == nil) {
		
		// dimensions
		const size_t width = 242;
		const size_t height = 242;
		const size_t bytesPerRow = width * sizeof(float);
		NSUInteger n = width * height;
		NSUInteger dataLength = sizeof(float) * n;

		self.imageExtent = [CIVector vectorWithX:0 Y:0 Z:width W:height];
		
		// read the data
		float* data = malloc(dataLength);
		NSString *dataFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.bin"];
		FILE *rawDataFile = fopen(dataFilePath.UTF8String, "r");
		fread(data, sizeof(float), width*height, rawDataFile);
		fclose(rawDataFile);
		
		// print the min, max values calculated by hand
		float min = data[0];
		float max = data[0];
		for (unsigned int i=1; i < n; i++) {
			if (data[i] < min)
				min = data[i];
			if (data[i] > max)
				max = data[i];
		}
		NSLog(@"Minimum value in original array: %f", min);
		NSLog(@"Maximum value in original array: %f", max);
		
		normalizeFloatArray01MinMax(data, n, min, max);

		// create the image
		NSData *nsData = [NSData dataWithBytesNoCopy:data length:dataLength freeWhenDone:YES];
		CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)nsData);
		CGBitmapInfo bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrder32Host | kCGBitmapFloatComponents;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);

		CGImageRef cgImage = CGImageCreate(width,			// size_t width
										   height,			// size_t height
										   32,				// size_t bitsPerComponent (float=32)
										   32,				// size_t bitsPerPixel == bitsPerComponent for float
										   bytesPerRow,		// size_t bytesPerRow
										   colorSpace,		// CGColorSpaceRef
										   bitmapInfo,		// CGBitmapInfo
										   dataProvider,	// CGDataProviderRef
										   NULL,			// const CGFloat decode[] - NULL = do not want to allow
															//   remapping of the image’s color values
										   NO,				// shouldInterpolate
										   kCGRenderingIntentDefault); // CGColorRenderingIntent

		NSAssert(cgImage != nil, @"could not create image");
		
		_image = [CIImage imageWithCGImage:cgImage options:@{kCIImageColorSpace: [NSNull null]}];
		
		// clean up
		CGDataProviderRelease(dataProvider);
		CGColorSpaceRelease(colorSpace);
		CGImageRelease(cgImage);
	}
	return _image;
}

@end
