d8p1:{
    a:" "vs/:/:" | "vs/:"\n"vs ssr[x;"|\n";"| "];
    sum sum(count each/:a[;1])in 2 3 4 7};
d8p2:{
    a:" "vs/:/:" | "vs/:"\n"vs ssr[x;"|\n";"| "];
    f:{
        //x:a[0]
        c:x[0] iasc count each x[0];  //2 3 4 5 5 5 6 6 6 7
                                      //1 7 4 [235] [069] 8
        top:first c[1]except c[0];
        right:c[1]except top;
        r2:asc count each group raze[c 6 7 8] inter right;
        topRight:first key r2;
        bottomRight:last key r2;
        tlm:c[2]except c[1];
        tlm2:asc count each group raze[c 6 7 8] inter tlm;
        middle:first key tlm2;
        topLeft:last key tlm2;
        bl:asc count each group raze[c 3 4 5] except raze[c 1 2];
        bottomLeft:first key bl;
        bottom:last key bl;
        map:(top;topLeft;topRight;middle;bottomLeft;bottomRight;bottom)!"abcdefg";
        map2:("abcefg";"cf";"acdeg";"acdfg";"bcdf";"abdfg";"abdefg";"acf";"abcdefg";"abcdfg")!til 10;
        10 sv map2 asc each map x[1]};
    sum f each a};

/
x:"be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe\n"
x,:"edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc\n"
x,:"fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg\n"
x,:"fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb\n"
x,:"aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea\n"
x,:"fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb\n"
x,:"dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe\n"
x,:"bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef\n"
x,:"egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb\n"
x,:"gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"
d8p1 x
d8p2 x
