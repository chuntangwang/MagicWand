//
//  MyDocument.m
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import "MyDocument.h"
#import "CanvasView.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
		mImage = nil; // The image we're going to load
    }
    return self;
}

- (void) dealloc
{
	[mImage release];
	
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	// If we managed to load an image, pass it off to the CanvasView
	if ( mImage )
		[mCanvasView setImage:mImage];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	return NO; // we dont' support saving for the sake of simplicity
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	// Just use NSImage to load up the image. We only declare gif/jpg/png in our
	//	Info.plist but NSImage can open more than that.
	mImage = [[NSImage alloc] initWithContentsOfURL:absoluteURL];
	
	return YES;
}

@end
