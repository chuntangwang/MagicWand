//
//  Canvas.m
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Canvas.h"
#import "SelectionBuilder.h"

@interface Canvas (Private)

- (NSBitmapImageRep *) createImageRep:(NSSize)size;

@end

@implementation Canvas

- (id) initWithSize:(NSSize)size
{
	self = [super init];
	
	if ( self ) {
		// Create an image rep that we can use as the backing store for the canvas.
		//	To keep things simple we'll use a 32-bit RGBA bitmap image.
		mImageRep = [self createImageRep:size];
	}
	
	return self;
}

- (void) dealloc
{
	// Free up our bitmap image rep
	[mImageRep release];
	
	[super dealloc];
}

- (void) setImage:(NSImage *)image
{
	// This method will resize the image rep to the size of the image
	//	then render the passed in image into it.
	
	// First resize the image rep, by killing the old one and creating
	//	a new one.
	[mImageRep release];
	mImageRep = nil;
	
	NSSize size = [image size];
	mImageRep = [self createImageRep:size];
	
	// We want to render the image into our bitmap image rep, so create a
	//	NSGraphicsContext from it.
	NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:mImageRep];
	
	// "Focus" our image rep so the NSImage will use it to draw into
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	// Draw the image, with no scaling
	[image drawAtPoint:NSMakePoint(0, 0) fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositeSourceOver fraction:1.0];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawRect:(NSRect)rect inContext:(NSGraphicsContext*)context
{
	// Here we simply want to render our bitmap image rep into the view's
	//	context. It's going to be a straight forward bit blit. 
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:context];

	[mImageRep drawAtPoint: NSMakePoint(0, 0)];
	
	[NSGraphicsContext restoreGraphicsState];	
}

- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(float)tolerance
{
	// Building up a selection mask is pretty involved, so we're going to pass
	//	the task to a helper class that can build up temporary state.
	SelectionBuilder* builder = [[[SelectionBuilder alloc] initWithBitmapImageRep:mImageRep point:point tolerance:tolerance] autorelease];
	
	return [builder mask];
}

- (NSSize) size
{
	// Return the size of the canvas, based on the calculated size of the image rep
	return NSMakeSize([mImageRep pixelsWide], [mImageRep pixelsHigh]);
}


@end

@implementation Canvas (Private)

- (NSBitmapImageRep *) createImageRep:(NSSize)size
{
	// Create an image rep that we can use as the backing store for the canvas.
	//	To keep things simple we'll use a 32-bit RGBA bitmap image.
	int rowBytes = ((int)(ceil(size.width)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned is good
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
														pixelsWide:size.width 
														pixelsHigh:size.height 
													 bitsPerSample:8 
												   samplesPerPixel:4 
														  hasAlpha:YES 
														  isPlanar:NO 
													colorSpaceName:NSCalibratedRGBColorSpace 
													  bitmapFormat:NSAlphaNonpremultipliedBitmapFormat 
													   bytesPerRow:rowBytes 
													  bitsPerPixel:32];
	
	
	// Paint on a white background so the user has something to start with.
	NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	
	// "Focus" our image rep so the NSImage will use it to draw into
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect: NSMakeRect(0, 0, size.width, size.height)];
	
	[NSGraphicsContext restoreGraphicsState];	
	
	return imageRep;
}


@end

