//
//  LiveSearchViewController.h
//  Viva
//
//  Created by Daniel Kennett on 6/9/11.
//  Copyright 2011 Spotify. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPBackgroundImageView.h"

@interface LiveSearchViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
	NSTableView *__weak tableView;
	SPBackgroundImageView *__weak gutterView;
	NSPopover *__weak popover;
}

@property (weak) NSPopover *popover;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet SPBackgroundImageView *gutterView;

@end
