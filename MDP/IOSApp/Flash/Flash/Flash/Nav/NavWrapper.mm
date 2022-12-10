//
//  NavWrapper.mm
//  Flash
//
//  Created by Sam Bohnett on 6/20/22.
//

#import "NavWrapper.h"
#import "testNav.hpp"
#import "Tile.h"
struct CPPMembers {
    Nav testGarage;
};

@implementation NavWrapper
- (id)init
{
    self = [super init];
    if (self) {
        //Allocate storage for members
        cppMembers = new CPPMembers;
        
    }

    return self;
}
- (void)dealloc
{
    //Free members even if ARC.
    delete cppMembers;

    //If not ARC uncomment the following line
    //[super dealloc];
}
- (void) initMap:(int)floors :(int)rows :(int)columns {
    cppMembers->testGarage.initMap(floors, rows, columns);
}
- (void) setMapRange:(int)z :(int)xMin : (int)xMax : (int)yMin : (int)yMax : (char)val {
    cppMembers->testGarage.setMapRange(z, xMin, xMax, yMin, yMax, val);
}
- (void) setMapPoint:(int)z :(int)x :(int)y :(char) val {
    cppMembers->testGarage.setMapPoint(z, x, y, val);
}
- (void) navigateRegular {
    cppMembers->testGarage.navigateRegular();
}
- (void) printNavOutput {
    cppMembers->testGarage.printNavOutput();
}
- (void) printNavMap {
    cppMembers->testGarage.printNavMap();
}


- (NSMutableArray<NSMutableArray<NSMutableArray<Tile *>*> *> *) returnGarage {
    
    
    auto garage = cppMembers->testGarage.returnGarage();
    NSMutableArray<NSMutableArray<NSMutableArray<Tile *>*> *> *newGarage = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < garage.size(); i++) {
        NSMutableArray<NSMutableArray<Tile *> * > *temp = [[NSMutableArray alloc] init];
        
        [newGarage addObject:temp];
        for (int j = 0; j < garage[i].size(); j++) {
            
            NSMutableArray<Tile *> *temp = [[NSMutableArray alloc] init];
            [newGarage[i] addObject:temp];
            for (int k = 0; k < garage[i][j].size(); k++) {
                Tile *temp = [[Tile alloc] init];
                auto currentTile = garage[i][j][k];
                
                
                temp.value = currentTile.value;
                temp.reachedByGoing = currentTile.reachedByGoing;
                temp.directionToCar = currentTile.directionToCar;
                temp.discovered = currentTile.discovered;
                
                
                [newGarage[i][j] addObject:temp];
                
                //printf("%lu", (unsigned long)newGarage[i][j].count);
                
            }
        }
    }
    
    return newGarage;
}

- (NSMutableArray<Coord*>*) returnOutput {
    auto output = cppMembers->testGarage.returnOutput();
    NSMutableArray<Coord*>* newOutput = [[NSMutableArray alloc] init];
    for (int i = 0; i < output.size(); i++) {
        Coord *temp = [[Coord alloc] init];
        auto currOutput = output[i];
        
        temp.x = currOutput.x;
        temp.y = currOutput.y;
        temp.z = currOutput.z;
        [newOutput addObject:temp];
    }
    
    return newOutput;
}
 
 
@end

