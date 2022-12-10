//
//  Tile.m
//  Flash
//
//  Created by Sam Bohnett on 9/19/22.
//

#import <Foundation/Foundation.h>
#import "Tile.h"
@implementation Tile
@synthesize value;
@synthesize reachedByGoing;
@synthesize directionToCar;
@synthesize discovered;

-(id)init
{
    self = [super init];
    if (self) {
        value = '.';
        reachedByGoing = '.';
        directionToCar = 'x';
        discovered = false;
    }
    return self;
}
@end

@implementation Coord
@synthesize z;
@synthesize x;
@synthesize y;

-(id)init
{
    self = [super init];
    if (self) {
        z = 0;
        x = 0;
        y = 0;
    }
    return self;
}
@end
