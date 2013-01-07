//
//  CanvasView.m
//  MagicWand
//
//  Created by Andy Finnell on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CanvasView.h"
#import "Canvas.h"
#import "MagicWand.h"
#import "PathBuilder.h"

#define kPhaseLength	4.0

@interface CanvasView (Private)

- (NSBezierPath *) selectionPath;
- (void) onSelectionTimer:(NSTimer*)timer;

@end

@implementation CanvasView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create both the canvas and the magic wand tool. Create the canvas
		//	the same size as our initial size. Note that the canvas will not
		//	resize along with us.
		mCanvas = [[Canvas alloc] initWithSize:frame.size];
		mMagicWand = [[MagicWand alloc] init];
		
		// The following members are only used when we have a selection.
		mSelection = nil;
		mCachedPath = nil;
		mPhase = 0.0;
    }
    return self;
}

- (void) dealloc
{
	// Clean up our canvas, magic wand, and selection
	[mCanvas release];
	[mMagicWand release];
	CGImageRelease(mSelection);
	[mCachedPath release];
	
	[super dealloc];
}

- (void) setImage:(NSImage *)image
{
	// Give the canvas the image. This will cause the canvas to be
	//	resized and render the image.
	[mCanvas setImage:image];
	
	// Resize this view so that we're the same as the image (and canvas)
	[self setFrameSize: [image size]];
	
	// We just changed what we the canvas draws, so invalidate the entire view
	[self setNeedsDisplay:YES];
}

- (void) setSelection:(CGImageRef)mask
{
	// First free up the old selection, which includes the mask and the
	//	path feedback.
	CGImageRelease(mSelection);
	mSelection = nil;
	[mCachedPath release];
	mCachedPath = nil;
	
	// If the caller gave us a new selection, retain it
	if ( mask != nil )
		mSelection = CGImageRetain(mask);
	
	// We render selection feedback, so we need to invalidate the view so it
	//	is rendered.
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	// Simply ask the canvas to draw into the current context, given the
	//	rectangle specified. A more sophisticated view might draw a border
	//	around the canvas, or a pasteboard in the case that the view was
	//	bigger than the canvas.
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	
	[mCanvas drawRect:rect inContext:context];	
	
	// Since the selection is a property of the view, we need to render it here.
	//	First ask for the selection path. If we don't have one, then we don't
	//	have a selection and can bail.
	NSBezierPath *path = [self selectionPath];
	if ( path == nil )
		return;
	
	// We don't want anti-aliasing since we're drawing 1 pixel lines around
	//	the selection
	[context setShouldAntialias:NO];

	// First, layer on a 1 pixel line of white. We do this because the line
	//	dash alternates between black and transparent, so the white shows
	//	up where the line dash draws transparent. We set a line dash pattern
	//	here to clear the one we set below, the last time we drew.
	float fullPattern[] = { 1.0, 0.0 };
	[path setLineDash:fullPattern count:2 phase:0];
	[[NSColor whiteColor] set];
	[path stroke];

	// Next draw a 1 pixel line that alternates between black and transparent
	//	every four pixels. This gives the selection marching ants around it.
	float lengths[] = { kPhaseLength, kPhaseLength };
	[path setLineDash:lengths count:sizeof(lengths)/sizeof(lengths[0]) phase:mPhase];
	[[NSColor blackColor] set];
	[path stroke];
		
	// The marching ants need to animate, so fire off a timer half a second later.
	//	It will update the mPhase member and then invalidate the view so
	//	it will redraw.
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onSelectionTimer:) userInfo:nil repeats:NO];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	// Simply pass the mouse down to the magic wand. Also give it the canvas to
	//	work on, and a reference to ourselves, so it can translate the mouse
	//	locations.
	[mMagicWand mouseDown:theEvent inView:self onCanvas:mCanvas];
}

- (IBAction) copy:(id)sender
{
	// If we don't have a selection then we don't have anything to copy
	if ( mSelection == nil )
		return;
	
	// We're going to render the canvas into an NSImage that we can then hand
	//	off to the pasteboard. So create an NSImage the same size as our canvas.
	NSSize canvasSize = [mCanvas size];
	NSImage *image = [[[NSImage alloc] initWithSize: canvasSize] autorelease];
	
	[image lockFocus];
	
	// Before we ask the canvas to draw itself into our image, we want to clip
	//	it. So drop down into CoreGraphics and clip the context with our image
	//	mask.
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	CGContextRef cgContext = [context graphicsPort];
	CGContextSaveGState(cgContext);

	CGContextClipToMask(cgContext, CGRectMake(0, 0, canvasSize.width, canvasSize.height), mSelection);
	
	// Ask the canvas to draw itself in its entirety. 
	[mCanvas drawRect:NSMakeRect(0, 0, canvasSize.width, canvasSize.height) inContext:context];	
	
	CGContextRestoreGState(cgContext);

	[image unlockFocus];
	
	// Now that we have the selection drawn into an NSImage, give it to the
	//	pasteboard as a TIFF.
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects:NSTIFFPboardType, nil];
	[pasteboard declareTypes:types owner:self];
	[pasteboard setData:[image TIFFRepresentation] forType:NSTIFFPboardType];
}

- (BOOL)acceptsFirstResponder
{
	// If we want to get something other than mouseDown: events (like copy: events)
	//	we have to be able to be a first responder.
	return YES;
}


@end

@implementation CanvasView (Private)

- (NSBezierPath *) selectionPath
{
	// This method will lazily generate a bounding path around the image mask
	//	and cache it for later use.
	
	// If no selection, then there's no path around it
	if ( mSelection == nil )
		return nil;
	
	// If we've already created the selection path, then just return it
	if ( mCachedPath != nil )
		return mCachedPath;
	
	// OK, we have to build a path from the selection. Create a PathBuilder object
	//	and pass it our selection. Ask for a path back.
	PathBuilder* builder = [[[PathBuilder alloc] initWithMask:mSelection] autorelease];
	mCachedPath = [[builder path] retain];
	
	return mCachedPath;
}

- (void) onSelectionTimer:(NSTimer*)timer
{
	// This timer is set from inside of drawRect: if it rendered the marching
	//	ants. It advances the phase then marks the view for a redraw.
	
	// Increase the the phase so the ants appear to march. Let the phase wrap
	//	around when we reach the end of the phase.
	mPhase = mPhase + 1.0;
	if ( mPhase > (2 * kPhaseLength - 1.0) )
		mPhase = 0.0;
	
	// It would be more efficient to take the bounds of the selection path (mCachedPath)
	//	and only invalidate that.
	[self setNeedsDisplay:YES];
}

@end
