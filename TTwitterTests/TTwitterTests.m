//
//  TTwitterTests.m
//  TTwitterTests
//
//  Created by Iryna Didkovska on 6/17/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TTNetworkManager.h"


@interface TTwitterTests : XCTestCase

@end

@implementation TTwitterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGetToken {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetToken"];
    [[TTNetworkManager sharedManager] getTempTokenWithCompletionHandler:^(NSString *token, NSString *error) {
        
        XCTAssertGreaterThan(token.length, 0);
        [expectation fulfill];
        
    }];
    
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"testGetToken timeout error: %@", error);
        }
    }];
    
}

- (void)testGetListTweets
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"getListOfTweetsWithPage"];
    [[TTNetworkManager sharedManager] getListOfTweetsWithPage:1 compleationHendler:^(BOOL willLoadNewContent, NSString *error) {
        
        XCTAssertGreaterThan(error.length, 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"testGetListTweets timeout error: %@", error);
        }
    }];
}

@end
