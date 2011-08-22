//
//  LiveSearchViewController.m
//  Viva
//
//  Created by Daniel Kennett on 6/9/11.
//  Copyright 2011 Spotify. All rights reserved.
//

#import "LiveSearchViewController.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "LiveSearch.h"

@implementation LiveSearchViewController
@synthesize tableView;
@synthesize gutterView;
@synthesize popover;

-(id)init {
	if ((self = [super initWithNibName:@"LiveSearchViewController" bundle:nil])) {
		[self addObserver:self
			   forKeyPath:@"representedObject.latestSearch.searchInProgress"
				  options:0
				  context:nil];
	}
	return self;
}

-(void)awakeFromNib {
	self.gutterView.backgroundImage = [NSImage imageNamed:@"livesearch-gutter"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath hasPrefix:@"representedObject."]) {
		
		LiveSearch *search = self.representedObject;
		if (search.latestSearch.searchInProgress)
			return;
		
		[self.tableView reloadData];
		
		CGFloat tableHeight = tableView.numberOfRows * 30.0;
		
		NSUInteger numberOfDividers = 3 + (search.topHit == nil ? 0 : 1);
		tableHeight -= (numberOfDividers * 30.0);
		tableHeight += (numberOfDividers * 20.0);
		tableHeight += 3.0; // Yay magic numbers
		
		if (self.popover.contentSize.height != tableHeight)
			self.popover.contentSize = NSMakeSize(self.tableView.frame.size.width, tableHeight);
		
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	
	LiveSearch *search = self.representedObject;
	
	NSUInteger rowCount = search.topTracks.count + search.topAlbums.count + search.topArtists.count;
	rowCount += 4; // Dividers and "show all";
	if (search.topHit != nil) rowCount += 2;
	
	if (search.topTracks.count == 0)
		rowCount++; // "No Matches"
	
	if (search.topAlbums.count == 0)
		rowCount++; // "No Matches"
	
	if (search.topArtists.count == 0)
		rowCount++; // "No Matches"
	
	return rowCount;
}

-(CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)row {
	return [self tableView:aTableView isGroupRow:row] ? 10.0 : 30.0;
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)row {
	return ![self tableView:aTableView isGroupRow:row];
}

- (BOOL)tableView:(NSTableView *)aTableView isGroupRow:(NSInteger)row {
	
	LiveSearch *search = self.representedObject;
	
	NSUInteger numberOfTopHitRows = search.topHit == nil ? 0 : 1;
	NSUInteger numberOfTrackRows = MAX(1, search.topTracks.count);
	NSUInteger numberOfArtistRows = MAX(1, search.topArtists.count);
	NSUInteger numberOfAlbumRows = MAX(1, search.topAlbums.count);
	
	NSUInteger groupOffsetModifier = search.topHit == nil ? 0 : 1;
	
	return (row == numberOfTopHitRows && search.topHit != nil) ||
	row == numberOfTopHitRows + numberOfTrackRows + groupOffsetModifier || 
	row == numberOfTopHitRows + numberOfTrackRows + numberOfArtistRows + 1 + groupOffsetModifier ||
	row == numberOfTopHitRows + numberOfTrackRows + numberOfArtistRows + numberOfAlbumRows + 2 + groupOffsetModifier;	
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	LiveSearch *search = self.representedObject;
	NSUInteger numberOfTopHitRows = search.topHit == nil ? 0 : 1;
	NSUInteger numberOfTrackRows = MAX(1, search.topTracks.count);
	NSUInteger numberOfArtistRows = MAX(1, search.topArtists.count);
	NSUInteger numberOfAlbumRows = MAX(1, search.topAlbums.count);
	
	NSUInteger groupOffsetModifier = search.topHit == nil ? 0 : 1;
	
	if ([[aTableColumn identifier] isEqualToString:@"HeaderColumn"]) {
		
		if (rowIndex == 0 && search.topHit != nil)
			return [NSImage imageNamed:@"livesearch-tophit"];
		else if (rowIndex == numberOfTopHitRows + groupOffsetModifier)
			return [NSImage imageNamed:@"livesearch-tracks"];
		else if  (rowIndex == numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows + 1)
			return [NSImage imageNamed:@"livesearch-artists"];
		else if (rowIndex == numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows + numberOfArtistRows + 2)
			return [NSImage imageNamed:@"livesearch-albums"];
		
		return [NSImage imageNamed:@"empty"];
	}
	
	NSMutableDictionary *objectValue = [NSMutableDictionary dictionaryWithCapacity:2];
	
	if (rowIndex == 0 && search.topHit != nil) {
		
		if ([search.topHit isKindOfClass:[SPTrack class]]) {
			[objectValue setValue:((SPTrack *)search.topHit).album.cover forKey:@"cover"];
			[objectValue setValue:((SPTrack *)search.topHit).name forKey:@"name"];
			
		} else if ([search.topHit isKindOfClass:[SPArtist class]]) {
			[objectValue setValue:[NSImage imageNamed:NSImageNameUser] forKey:@"cover.image"];
			[objectValue setValue:((SPArtist *)search.topHit).name forKey:@"name"];
			
		} else if ([search.topHit isKindOfClass:[SPAlbum class]]) {
			[objectValue setValue:((SPAlbum *)search.topHit).cover forKey:@"cover"];
			[objectValue setValue:((SPAlbum *)search.topHit).name forKey:@"name"];
		} 
		
	} else if (rowIndex >= numberOfTopHitRows + groupOffsetModifier && rowIndex < numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows) {
		
		if (search.topTracks.count == 0) {
			[objectValue setValue:@"No Matches" forKey:@"name"];
		} else {
			[objectValue setValue:((SPTrack *)[search.topTracks objectAtIndex:rowIndex - numberOfTopHitRows - groupOffsetModifier]).album.cover forKey:@"cover"];
			[objectValue setValue:((SPTrack *)[search.topTracks objectAtIndex:rowIndex - numberOfTopHitRows - groupOffsetModifier]).name forKey:@"name"];
		}
		
	} else if (rowIndex >= numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows + 1 && rowIndex < numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows + numberOfArtistRows + 1) {
		
		if (search.topArtists.count == 0) {
			[objectValue setValue:@"No Matches" forKey:@"name"];
		} else {
			[objectValue setValue:[NSImage imageNamed:@"NSUser"] forKey:@"cover.image"];
			[objectValue setValue:((SPArtist *)[search.topArtists objectAtIndex:rowIndex - numberOfTopHitRows - groupOffsetModifier - numberOfTrackRows - 1]).name forKey:@"name"];
		}
	} else if (rowIndex >= numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows + numberOfArtistRows + 2 && rowIndex < numberOfTopHitRows + groupOffsetModifier + numberOfTrackRows + numberOfArtistRows + numberOfAlbumRows + 2) {
		
		if (search.topAlbums.count == 0) {
			[objectValue setValue:@"No Matches" forKey:@"name"];
		} else {
			[objectValue setValue:((SPAlbum *)[search.topAlbums objectAtIndex:rowIndex - numberOfTopHitRows - groupOffsetModifier - numberOfTrackRows - numberOfArtistRows - 2]).cover forKey:@"cover"];
			[objectValue setValue:((SPAlbum *)[search.topAlbums objectAtIndex:rowIndex - numberOfTopHitRows - groupOffsetModifier - numberOfTrackRows - numberOfArtistRows - 2]).name forKey:@"name"];
		}
	} else {
		[objectValue setValue:@"Show All…" forKey:@"name"];
		[objectValue setValue:[NSImage imageNamed:@"livesearch-showAll"] forKey:@"cover.image"];
	}
	
	return objectValue;
}

-(void)dealloc {
	
	self.popover = nil;
	
	[self removeObserver:self
			  forKeyPath:@"representedObject.latestSearch.searchInProgress"];
	
	[super dealloc];
}

@end