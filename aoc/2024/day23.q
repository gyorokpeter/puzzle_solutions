d23p1:{a:asc each`$"-"vs/:x;
    b:flip`s`t!flip a,reverse each a;
    c:exec t by s from b;
    d:c c;
    e:distinct asc each raze key[c],/:'raze each c,/:''d@''where each/:d in'c;
    sum any each e like\:"t*"};
d23p2:{a:asc each`$"-"vs/:x;
    b:exec t by s from flip`s`t!flip a,reverse each a;
    queue:enlist each key b;
    while[count queue;
        prevQueue:queue;
        nxts:raze ([]p:queue),/:'flip each([]ext:b last each queue);
        nxts:delete from nxts where ext<=last each p;
        nxts:update ext2:b ext from nxts;
        nxts:delete from nxts where not all each p in'ext2;
        queue:exec (p,'ext) from nxts;
    ];
    ","sv string first prevQueue};

/

x:"\n"vs"kh-tc\nqp-kh\nde-cg\nka-co\nyn-aq\nqp-ub\ncg-tb\nvc-aq\ntb-ka\nwh-tc\nyn-cg\nkh-ub\nta-co";
x,:"\n"vs"de-co\ntc-td\ntb-wq\nwh-td\nta-ka\ntd-qp\naq-cg\nwq-ub\nub-vc\nde-ta\nwq-aq\nwq-vc";
x,:"\n"vs"wh-yn\nka-de\nkh-ta\nco-tc\nwh-qp\ntb-vc\ntd-yn";

d23p1 x //7
d23p2 x //"co,de,ka,ta"
