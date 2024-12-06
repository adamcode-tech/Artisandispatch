#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [GMSServices provideAPIKey:@"AIzaSyCOb94Dftq8IkFGeYZi2F0Aj2C5LcCxMCA"];
  // ... reste du code
}
@end 