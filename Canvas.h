//
//  Canvas.h
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Canvas : NSObject {
	// The canvas is simply backed by a NSBitmapImageRep. A CGLayerRef would be
	//	better, but you have to know your destination context before you create
	//	it (which we don't).	
	NSBitmapImageRep	*mImageRep;	
}

// Constructor that creates a canvas at the specified size.
- (id) initWithSize:(NSSize)size;

// Resize the canvas to the size of the image and render the image onto the canvas
- (void) setImage:(NSImage *)image;

// Draws the contents of the canvas into the specified context. Handy for views
//	that host a canvas.
- (void)drawRect:(NSRect)rect inContext:(NSGraphicsContext*)context;

// Create an image mask that selects all the pixels around point that are
//	the same color, given the tolerance.
- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(float)tolerance;

// Returns the size of the canvas.
- (NSSize) size;

@end
