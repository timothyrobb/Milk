//
//  MilkAppDelegate.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "MilkAppDelegate.h"
#import "List.h"
#import "Product.h"

@implementation MilkAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[TestFlight takeOff:@"dc1ea7a7-e4b3-4dc6-b1e3-8fbd18f34028"];
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    List *testList1 = [List createEntity];
    testList1.title = @"Weekly";
    
    List *testList2 = [List createEntity];
    testList2.title = @"Party";
    
    Product *testProduct1 = [Product createEntity];
    testProduct1.name = @"Chocolate";
    testProduct1.value = @5.00;
    [testList1 addProductsObject:testProduct1];
    
    Product *testProduct2 = [Product createEntity];
    testProduct2.name = @"Macbook Pro 15\" 2.2GHz 720GB 8GB DDR3";
    testProduct2.value = @3502.23;
    [testList1 addProductsObject:testProduct2];
    
    Product *testProduct3 = [Product createEntity];
    testProduct3.name = @"Tomatoes";
    testProduct3.value = @1.72;
    [testList1 addProductsObject:testProduct3];
    
    Product *testProduct4 = [Product createEntity];
    testProduct4.name = @"Baked Beans";
    testProduct4.value = @0.71;
    [testList2 addProductsObject:testProduct4];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
