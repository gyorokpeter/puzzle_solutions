d4p1:{sum 7=count each(first each"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x)except\:`cid};
d4p2:{
    t:"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x;
    t2:(uj/) enlist each (!)./:t where 7=count each (first each t) except\:`cid;
    exec count i from t2 where
        ("J"$byr) within 1920 2002,
        ("J"$iyr) within 2010 2020,
        ("J"$eyr) within 2020 2030,
        ?[hgt like "*in";("J"$-2_/:hgt)within 59 76;
            ?[hgt like "*cm";("J"$-2_/:hgt)within 150 193;
            0b]],
        hcl like("#",raze 6#enlist"[0-9a-f]"),
        ecl in ("amb";"blu";"brn";"gry";"grn";"hzl";"oth"),
        pid like raze 9#enlist"[0-9]"};

/
x: enlist"ecl:gry pid:860033327 eyr:2020 hcl:#fffffd";
x,:enlist"byr:1937 iyr:2017 cid:147 hgt:183cm";
x,:enlist"";
x,:enlist"iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884";
x,:enlist"hcl:#cfa07d byr:1929";
x,:enlist"";
x,:enlist"hcl:#ae17e1 iyr:2013";
x,:enlist"eyr:2024";
x,:enlist"ecl:brn pid:760753108 byr:1931";
x,:enlist"hgt:179cm";
x,:enlist"";
x,:enlist"hcl:#cfa07d eyr:2025 pid:166559648";
x,:enlist"iyr:2011 ecl:brn hgt:59in";

x2: enlist"eyr:1972 cid:100";
x2,:enlist"hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926";
x2,:enlist"";
x2,:enlist"iyr:2019";
x2,:enlist"hcl:#602927 eyr:1967 hgt:170cm";
x2,:enlist"ecl:grn pid:012533040 byr:1946";
x2,:enlist"";
x2,:enlist"hcl:dab227 iyr:2012";
x2,:enlist"ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277";
x2,:enlist"";
x2,:enlist"hgt:59cm ecl:zzz";
x2,:enlist"eyr:2038 hcl:74454a iyr:2023";
x2,:enlist"pid:3556412378 byr:2007";
x2,:enlist"";
x2,:enlist"pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980";
x2,:enlist"hcl:#623a2f";
x2,:enlist"";
x2,:enlist"eyr:2029 ecl:blu cid:129 byr:1989";
x2,:enlist"iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm";
x2,:enlist"";
x2,:enlist"hcl:#888785";
x2,:enlist"hgt:164cm byr:2001 iyr:2015 cid:88";
x2,:enlist"pid:545766238 ecl:hzl";
x2,:enlist"eyr:2022";
x2,:enlist"";
x2,:enlist"iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719";

d4p1 x  //2
//d4p2 x
d4p2 x2 //4
