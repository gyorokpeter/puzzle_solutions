d4p1:{sum{all 1=count each group" "vs x}each x};
d4p2:{sum{all 1=count each group asc each" "vs x}each x};

/
d4p1 "aa bb cc dd ee"   //1
d4p1 "aa bb cc dd aa"   //0
d4p1 "aa bb cc dd aaa"  //1

d4p2 "abcde fghij"  //1
d4p2 "abcde xyz ecdab"  //0
d4p2 "a ab abc abd abf abj" //1
d4p2 "iiii oiii ooii oooi oooo" //1
d4p2 "oiii ioii iioi iiio"  //0
