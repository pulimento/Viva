#include <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import <Carbon/Carbon.h>

#define SPSystemDefinedEventMediaKeys 8

@interface SPMediaKeyTap : NSObject {
	EventHandlerRef _app_switching_ref;
	EventHandlerRef _app_terminating_ref;
	CFMachPortRef _eventPort;
	CFRunLoopSourceRef _eventPortSource;
	CFRunLoopRef _tapThreadRL;
	BOOL _shouldInterceptMediaKeyEvents;
	id _delegate;
	// The app that is frontmost in this list owns media keys
	NSMutableArray *_mediaKeyAppList;
}
+ (NSArray*)defaultMediaKeyUserBundleIdentifiers;

-(id)initWithDelegate:(id)delegate;

+(BOOL)usesGlobalMediaKeyTap;
-(void)startWatchingMediaKeys;
-(void)stopWatchingMediaKeys;
@end

@interface NSObject (SPMediaKeyTapDelegate)
-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
@end
