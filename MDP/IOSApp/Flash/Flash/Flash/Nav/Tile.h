//
//  Tile.h
//  Flash
//
//  Created by Sam Bohnett on 9/19/22.
//

#ifndef Tile_h
#define Tile_h
#import <Foundation/Foundation.h>

@interface Tile : NSObject {
    // Nothing lol
}
@property char value;
@property char reachedByGoing;
@property char directionToCar;
@property bool discovered;
@end

@interface Coord : NSObject {
    // Nothing lol
}
@property int z;
@property int x;
@property int y;
@end

#endif /* Tile_h */
