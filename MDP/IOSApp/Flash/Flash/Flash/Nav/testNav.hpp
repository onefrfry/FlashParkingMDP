//
//  testNav.h
//  Flash
//
//  Created by Sam Bohnett on 6/20/22.
//
#include <iostream>
#include <algorithm>
#include <vector>
#include <utility>
#include <cmath>
#include <deque>
#include <string>

using namespace std;

#ifndef testNav_hpp
#define testNav_hpp
class Nav {
private:
    struct Coord {
        //has to be ZXY, each element in the outer Z vector must have a 2D map on it.
        int z; //floor
        int y; //row
        int x; //col
        friend bool operator== (const Coord& lhs, const Coord& rhs) {
            if (lhs.z == rhs.z && lhs.y == rhs.y && lhs.x == rhs.x) return true;
            else return false;
        };
    };
    struct Tile {
        char value;               // .SPECX
        char reachedByGoing;   // nesw
        char directionToCar; //nesw DUPLICATE OF reachedByGoing BC IM LAZY
        bool discovered;
    };
    
    int numRows;
    int numCols;
    Coord start = { -1, -1, -1 };
    Coord end = { -1, -1, -1 };
    vector<    vector<    vector<Tile> > > garage;
    
    //this is not necessary for checking whether you are in a vert zone -- just check the char
    //this is necessary for floyd warshall
    vector<Coord> vert;

    vector<Coord> output;
    //necessary for figuring out which floor a point is on
    vector< pair <int, int> >zRanges;
    
public:
    void initMap(int floors, int rows, int columns); //floors
    int getFloor(int z);
    double getDistance(Coord a, Coord b);
    void setMapRange(int z, int xMin, int xMax, int yMin, int yMax, char val);
    void setMapPoint(int z, int x, int y, char val);
    void printNavMap();
    void reset();
    vector<Coord> navigateRegular();
    void nav2d(Coord start, Coord end);
    void backTrace(Coord pos);
    Coord findBestVert();
    void printNavOutput();
    vector<Coord> navigateVecField();
    void fillVecField(Coord car, int nextFloor);
    void vecNav(Coord loc);
    void printVecField();
    
    // Testing sending the garage vector over
    vector<    vector<    vector<Tile> > >  returnGarage();
    vector<Coord> returnOutput();
    
};

#endif /* testNav_hpp */
