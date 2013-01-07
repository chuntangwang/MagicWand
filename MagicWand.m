//
//  MagicWand.m
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MagicWand.h"
#import "CanvasView.h"
#import "Canvas.h"

@interface MagicWand (Private)

- (NSPoint) canvasLocation:(NSEvent *)theEvent view:(CanvasView *)view;

@end

@implementation MagicWand

- (id) init
{
	self = [super init];
	
	if ( self ) {
		// By default our tolerance is 0.125, which means we'll select pixels
		//	that are less 12.5% "different" from the pixel the user picks.
		mTolerance = 0.125;
	}
	
	return self;
}

- (void) mouseDown:(NSEvent *)theEvent inView:(CanvasView *)view onCanvas:(Canvas *)canvas
{
	// Translate the event point location into a canvas point
	NSPoint currentPoint = [self canvasLocation:theEvent view:view];
	
	// Ask the canvas to generate an image mask that selects the pixels around
	//	the point the user clicked on, that are within the tolerance specified.
	CGImageRef mask = [canvas floodFillSelect:currentPoint tolerance:mTolerance];
	
	// The selection is really a property of the view, so give the mask to the
	//	view
	[view setSelection:mask];
	
	// We're done with the selection mask, so free it up
	CGImageRelease(mask);	
}

@end

@implementation MagicWand (Private)

- (NSPoint) canvasLocation:(NSEvent *)theEvent view:(CanvasView *)view
{
	// Currently we assume that the NSView here is a CanvasView, which means
	//	that the view is not scaled or offset. i.e. There is a one to one
	//	correlation between the view coordinates and the canvas coordinates.
	NSPoint eventLocation = [theEvent locationInWindow];
	return [view convertPoint:eventLocation fromView:nil];
}

@end