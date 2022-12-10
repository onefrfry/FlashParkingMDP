//
//  NavWrapper.h
//  Flash
//
//  Created by Sam Bohnett on 6/21/22.
//

#ifndef NavWrapper_h
#define NavWrapper_h

#import <Foundation/Foundation.h>
#import "Tile.h"
@interface NavWrapper: NSObject {
    struct CPPMembers *cppMembers;
    
}
//@interface NavWrapper : NSObject
- (void) initMap:(int)floors :(int)rows :(int)columns;
- (void) setMapRange:(int)z :(int)xMin : (int)xMax : (int)yMin : (int)yMax : (char)val;
- (void) setMapPoint:(int)z :(int)x :(int)y :(char) val;
- (void) navigateRegular;
- (void) printNavOutput;
- (void) printNavMap;
- (NSMutableArray<NSMutableArray<NSMutableArray<Tile *>*> *> *) returnGarage;
- (NSMutableArray<Coord*>*) returnOutput;
//@end
 
@end



#endif /* NavWrapper_h */
