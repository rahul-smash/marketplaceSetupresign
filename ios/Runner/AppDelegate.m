#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
// Add the following import.
#import "GoogleMaps/GoogleMaps.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  // Add the following line, with your API key
    //AIzaSyCwKXvgsBElyhqwj03ro9e-Lnu3fmRmpJI
    [GMSServices provideAPIKey: @"AIzaSyDwWsP2a9qP7PA-aojp81sOGE_bJrSw6AM"];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
