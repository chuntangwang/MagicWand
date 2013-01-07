//
//  CanvasView.h
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Canvas;
@class MagicWand;

@interface CanvasView : NSView {
	// The mCanvas we will render to the screen
	Canvas		*mCanvas;
	// The magic wand tool that we will pass events to
	MagicWand	*mMagicWand;
	
	// The selection as represented as an image mask. If there is no selection
	//	it is nil.
	CGImageRef	mSelection;
	
	// We draw the feedback of the selection here in the view. The easiest way
	//	to do that is to stroke a path. Since computing the bounding path of
	//	the image mask is expensive, cache it here.
	NSBezierPath *mCachedPath;
	
	// We animate the marching ants using a line pattern on the stroke of mCachedPath.
	//	To animate them we shift the phase each time we draw.
	float		mPhase;
}

- (void) setImage:(NSImage *)image;
- (void) setSelection:(CGImageRef)mask;

- (IBAction) copy:(id)sender;

@end
