d13common:{[part;x]
    cartPos:raze til[count x],/:'where each x in "^v><";
    cartDir:x ./:cartPos;
    carts:([]pos:cartPos;dir:cartDir;turn:-1);
    map:x^("^v><"!"||--")x;
    while[1b;
        cart:0;
        carts:`pos xasc carts;
        while[cart<count carts;
            newPos:carts[cart;`pos]+("^v><"!(-1 0;1 0;0 1;0 -1))carts[cart;`dir];
            cont:1b;
            if[0<count ni:exec i from carts where pos~\:newPos;
                if[part=1; :","sv string reverse newPos];
                cont:0b;
                carts:delete from carts where i in (ni,cart);
                if[cart>first ni; cart-:1];
            ];
            if[cont;
                carts[cart;`pos]:newPos;
                tile:map . newPos;
                dir:carts[cart;`dir];
                carts[cart;`dir]:$[
                    tile in "-|"; dir;
                    tile="\\"; ("^>v<"!"<v>^")dir;
                    tile="/"; ("^>v<"!">^<v")dir;
                    tile="+"; [t:carts[cart;`turn]:(carts[cart;`turn]+1)mod 3;
                        (("^>v<"!"<^>v");::;("^>v<"!">v<^"))[t]dir
                    ];
                    '"unknown tile: ",tile
                ];
                cart+:1;
            ];
        ];
        if[2>count carts;
            :","sv string reverse exec first pos from carts;
        ];
    ];
    };
d13p1:{d13common[1;x]};
d13p2:{d13common[2;x]};

/
x:"\n"vs"/->-\\\n|   |  /----\\\n| /-+--+-\\  |\n| | |  | v  |\n\\-+-/  \\-+--/\n  \\------/   ";
x2:"\n"vs"/>-<\\  \n|   |  \n| /<+-\\\n| | | v\n\\>+</ |\n  |   ^\n  \\<->/";

d13p1 x //"7,3"
//d13p2 x
d13p2 x2    //"6,4"
