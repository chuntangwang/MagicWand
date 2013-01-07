//
//  MyDocument.h
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class CanvasView;

@interface MyDocument : NSDocument
{
	// The CanvasView that we'll load our image into
	IBOutlet CanvasView	*mCanvasView;
	// The image we load from disk. In the current implementation we don't
	//	update it after it is loaded and passed off to the CanvasView
	NSImage		*mImage;
}

@end
