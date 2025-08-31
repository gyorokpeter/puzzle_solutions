d21:{t:{`$([]ing:" "vs/:x[;0];al:", "vs/:-1_/:x[;1])}" (contains "vs/:x;
    poss:raze exec ing{`ing`al!(x;y)}/:'al from t;
    poss2:select inter/[ing] by al from poss;
    (t;poss2)};
d21p1:{r:d21 x;t:r 0;poss2:r 1;
    count raze[t`ing] except (exec raze ing from poss2)};
d21p2:{r:d21 x; poss2:r 1;
    ingm:([al:`$()]ing:`$());
    while[0<count poss2;
        ingm,:select al, first each ing from poss2 where 1=count each ing;
        poss2:key[ingm]_poss2;
        poss2:update ing:ing except\:(exec ing from ingm) from poss2;
    ];
    exec ","sv string ing from`al xasc ingm};

/
x:();
x,:enlist"mxmxvkd kfcds sqjhc nhms (contains dairy, fish)";
x,:enlist"trh fvjkl sbzzf mxmxvkd (contains dairy)";
x,:enlist"sqjhc fvjkl (contains soy)";
x,:enlist"sqjhc mxmxvkd sbzzf (contains fish)";

d21p1 x //5
d21p2 x //"mxmxvkd,sqjhc,fvjkl"
