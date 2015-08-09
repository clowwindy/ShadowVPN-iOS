/*  ChinaDNS
 Copyright (C) 2015 clowwindy
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef chinadns_h
#define chinadns_h

#import <Foundation/Foundation.h>

// a hack
// caller set it to 1 when Reachability changes
// will be reset to 0 when the changes is handled by ChinaDNS
extern int remote_recreate_required;

// ChinaDNS main
// should be called from a background thread
int chinadns_main(int argc, char **argv);

#endif /* chinadns_h */
