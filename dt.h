
#ifndef _DT_H_
#define _DT_H_
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>     // std::cout
#include <algorithm>    // std::max
// Geodesic Distance Transform:
//
// Compute distance map from a given seeds (in res) and a cost map.
// labels are propagated along with distance map, 
// for each pixel, we remember the closest seed)
//
float GDT(const float* cost, float* res, int* labels, int w, int h);

#endif //_DT_H_
