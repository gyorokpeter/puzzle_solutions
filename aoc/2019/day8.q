ocr:enlist[""]!enlist" ";
ocr[" **  *  * *  * **** *  * *  * "]:"A";
ocr["***  *  * ***  *  * *  * ***  "]:"B";
ocr[" **  *  * *    *    *  *  **  "]:"C";
ocr["**** *    ***  *    *    **** "]:"E";
ocr["**** *    ***  *    *    *    "]:"F";
ocr[" **  *  * *    * ** *  *  *** "]:"G";
ocr["*  * *  * **** *  * *  * *  * "]:"H";
ocr["  **    *    *    * *  *  **  "]:"J";
ocr["*  * * *  **   * *  * *  *  * "]:"K";
ocr["*    *    *    *    *    **** "]:"L";
ocr["***  *  * *  * ***  *    *    "]:"P";
ocr["***  *  * *  * ***  * *  *  * "]:"R";
ocr["*  * *  * *  * *  * *  *  **  "]:"U";
ocr["*   **   * * *   *    *    *  "]:"Y";
ocr["****    *   *   *   *    **** "]:"Z";

d8p1:{[w;h;img]
    layers:(w*h) cut "J"$/:raze img;
    minz:first{where x=min x}sum each 0=layers;
    {sum[x=1]*sum[x=2]}layers[minz]};
d8p2:{[w;h;img]
    img2:" *"w cut (^/)reverse(w*h) cut 0 1"J"$/:raze img;
    ocr raze each flip 5 cut/:img2};

/
x:enlist"123456789012"

d8p1[3;2;x] //1
//d8p1[25;6;x]
//d8p2[25;6;x]
