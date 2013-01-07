//
//  SelectionBuilder.h
//  MagicWand
//
//  Created by Andy Finnell on 8/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Max would be CYMKA
#define kMaxSamples	5

@interface SelectionBuilder : NSObject {
	// The source image that we're using to build up a mask from
	NSBitmapImageRep	*mImageRep;
	
	// The width and height of the source image, the resulting image mask,
	//	and the intermediate mVisited table
	size_t			mWidth;
	size_t			mHeight;

	// The raw data for the resulting image mask
	unsigned char	*mMaskData;
	size_t			mMaskRowBytes;
	
	// An intermediate table we use when examining the source image to determine
	//	if we have visited a specific pixel location. It is mWidth by mHeight
	//	in size.
	BOOL			*mVisited;

	// Information about the pixel the user clicked on, including its coordinates
	//	and its pixel components.
	NSPoint			mPickedPoint;
	unsigned int	mPickedPixel[kMaxSamples];
	
	// The tolerance scaled to the range used by the pixel components in the
	//	source image.
	unsigned int	mTolerance;
		
	// The stack of line segments we still need to process. When it goes empty
	//	we're done.
	NSMutableArray*	mStack;
}

- (id) initWithBitmapImageRep:(NSBitmapImageRep *)imageRep point:(NSPoint)point tolerance:(float)tolerance;

- (CGImageRef) mask;

@end
