//
//  KarteTrackerTests.m
//  KarteTrackerTests
//
//  Created by Wataru Ikarashi on 08/30/2016.
//  Copyright (c) 2016 Wataru Ikarashi. All rights reserved.
//

// https://github.com/Specta/Specta

#import <Foundation/Foundation.h>
#import <KarteTracker/KarteTracker.h>
#import <KarteTracker/NSData+ZlibDeflate.h>

SpecBegin(InitialSpecs)

describe(@"these will fail", ^{

    it(@"can do maths", ^{
        expect(1).to.equal(2);
    });

    it(@"can read", ^{
        expect(@"number").to.equal(@"string");
    });
    
    it(@"will wait for 10 seconds and fail", ^{
        waitUntil(^(DoneCallback done) {
        
        });
    });
});

describe(@"these will pass", ^{
    
    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
    it(@"will wait and succeed", ^{
        waitUntil(^(DoneCallback done) {
            done();
        });
    });
  
  it(@"hoge", ^{
    printf("HERE hoge!!");
    [KarteTracker setupWithApiKey:@"62047b8feddfdf076202b56ee77f7d43"];
    [[KarteTracker sharedTracker] track:@"view_native_app" values:@{@"test_key":@"test_value"}];
  });
});

SpecEnd

