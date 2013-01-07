//
//  MagicWand.h
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Canvas;
@class CanvasView;

@interface MagicWand : NSObject {
	// The only parameter for the magic wand is the tolerance setting. It has
	//	a range of 0.0 to 1.0, where 0.0 matches only the exact same color,
	//	and 1.0 matches any color.
	float		mTolerance;
}

// The magic wand only needs to know about mouse downs
- (void) mouseDown:(NSEvent *)theEvent inView:(CanvasView *)view onCanvas:(Canvas *)canvas;

@end
