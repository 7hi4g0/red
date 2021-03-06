Red [
	Title:   "Red/System char! datatype test script"
	Author:  "Nenad Rakocevic & Peter W A Wood"
	File: 	 %char-test.red
	Version: "0.1.0"
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2013 Nenad Rakocevic & Peter W A Wood. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

#include  %../../../quick-test/quick-test.red

~~~start-file~~~ "char"

===start-group=== "+ tests"
	--test-- "char+1"
	--assert #"^(01)" + #"^(00)" 	 = #"^(01)"
	--assert #"^(01)" + #"^(10FFFF)" = #"^(00)"
===end-group===
  
===start-group=== "- tests"
===end-group===

===start-group=== "* tests"
===end-group===
  
===start-group=== "/ tests"
===end-group===

===start-group=== "mod tests"
===end-group===

===start-group=== "even?"
	--test-- "even1" --assert true	= even? #"^(00)"
	--test-- "even2" --assert false = even? #"^(01)"
	--test-- "even3" --assert false	= even? #"^(10FFFF)"
	--test-- "even4" --assert true	= even? #"^(FE)"
===end-group===

===start-group=== "odd?"
	--test-- "odd1" --assert false	= odd? #"^(00)"
	--test-- "odd2" --assert true	= odd? #"^(01)"
	--test-- "odd3" --assert true	= odd? #"^(10FFFF)"
	--test-- "odd4" --assert false	= odd? #"^(FE)"
===end-group===

===start-group=== "min/max"
	--test-- "max1" --assert #"b" = max #"a" #"b"
	--test-- "min1" --assert #"a" = min #"a" #"大"
===end-group===

~~~end-file~~~
