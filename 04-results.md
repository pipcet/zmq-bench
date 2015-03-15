### Results ###

#### 2015-03-12 ####

 - lazy branch at https://github.com/pipcet/FFI-Platypus/tree/180246074f910b8fae4e6dcfd1b6191243d905ed
 - gist at TBD

```
		       Rate method xsub(hash) method (2) method (3) TinyCC method xsub TinyCC method (2) TinyCC method (3) Inline method   XS Inline method (2) Inline method (3) Inline xsub TinyCC xsub
method            1811594/s     --        -1%        -9%        -9%          -10% -15%              -18%              -18%          -22% -27%              -29%              -32%        -36%        -36%
xsub(hash)        1831502/s     1%         --        -8%        -8%           -9% -14%              -17%              -17%          -21% -27%              -28%              -31%        -35%        -36%
method (2)        1996008/s    10%         9%         --        -0%           -1%  -7%              -10%              -10%          -14% -20%              -22%              -25%        -29%        -30%
method (3)        2000000/s    10%         9%         0%         --           -1%  -6%               -9%              -10%          -14% -20%              -21%              -25%        -29%        -30%
TinyCC method     2012072/s    11%        10%         1%         1%            --  -6%               -9%               -9%          -14% -19%              -21%              -25%        -29%        -29%
xsub              2136752/s    18%        17%         7%         7%            6%   --               -3%               -4%           -8% -14%              -16%              -20%        -24%        -25%
TinyCC method (2) 2207506/s    22%        21%        11%        10%           10%   3%                --               -0%           -5% -11%              -13%              -17%        -22%        -23%
TinyCC method (3) 2217295/s    22%        21%        11%        11%           10%   4%                0%                --           -5% -11%              -13%              -17%        -21%        -22%
Inline method     2331002/s    29%        27%        17%        17%           16%   9%                6%                5%            --  -7%               -8%              -13%        -17%        -18%
XS                2493766/s    38%        36%        25%        25%           24%  17%               13%               12%            7%   --               -2%               -6%        -11%        -12%
Inline method (2) 2544529/s    40%        39%        27%        27%           26%  19%               15%               15%            9%   2%                --               -5%        -10%        -11%
Inline method (3) 2666667/s    47%        46%        34%        33%           33%  25%               21%               20%           14%   7%                5%                --         -5%         -6%
Inline xsub       2816901/s    55%        54%        41%        41%           40%  32%               28%               27%           21%  13%               11%                6%          --         -1%
TinyCC xsub       2849003/s    57%        56%        43%        42%           42%  33%               29%               28%           22%  14%               12%                7%          1%          --
```

Comments:
 - `method` is what I'd actually use today. It uses the attach_method feature to cache a raw pointer for a Perl object without going through its hash, and it's nearly as fast as using an XSUB and going through a hash lookup (`xsub(hash)`). `method (2)` and `method (3)` are variants that don't go through Perl's method resolution mechanism.
 - `TinyCC method` is what we would get if we JIT-compiled C code. It's quite a bit faster than `method`, and I believe can be said to be faster than `xsub` based on variant `(3)`.
 - `Inline method` is the same thing with Inline::C *and very aggressive optimization*. I think the gain is not worth it in this case, because Inline has a huge run-time overhead and caches results based only on the C code, not the compiler options or machine type; thus, it is very easy to end up with an _Inline directory that doesn't run on the machine it's on.
 - `XS` is the vanilla LibZMQ3 XS code. It's not been optimized further, which reflects reality.
 - `TinyCC xsub` is a JIT-generated C XSUB compiled with TinyCC. Going through Inline and enabling aggressive optimization turns out not to make a difference for this very short piece of code.

#### 2015-03-15 ####

```
			     Rate method Python method (3) method (2) Perl exec, XS based Perl exec, FFI based xsub(hash) Inline(GCC) method TinyCC method Inline(GCC) method (3) Inline(GCC) method (2)   XS TinyCC method (3) TinyCC method (2) xsub TinyCC xsub Inline(GCC) xsub Inline(GCC) TinyCC
method                  1394700/s     --    -6%        -7%        -7%                -35%                 -38%       -39%               -40%          -43%                   -45%                   -47% -48%              -48%              -49% -50%        -51%             -54%        -87%   -87%
Python                  1483680/s     6%     --        -1%        -1%                -31%                 -34%       -35%               -36%          -39%                   -42%                   -43% -45%              -45%              -46% -47%        -47%             -51%        -86%   -86%
method (3)              1494768/s     7%     1%         --        -0%                -31%                 -33%       -35%               -35%          -39%                   -41%                   -43% -44%              -45%              -45% -47%        -47%             -51%        -86%   -86%
method (2)              1499250/s     7%     1%         0%         --                -30%                 -33%       -35%               -35%          -39%                   -41%                   -43% -44%              -44%              -45% -47%        -47%             -50%        -86%   -86%
Perl exec, XS based     2155172/s    55%    45%        44%        44%                  --                  -4%        -6%                -7%          -12%                   -16%                   -18% -19%              -20%              -21% -23%        -24%             -29%        -79%   -80%
Perl exec, FFI based    2247191/s    61%    51%        50%        50%                  4%                   --        -2%                -3%           -8%                   -12%                   -14% -16%              -17%              -18% -20%        -20%             -26%        -78%   -79%
xsub(hash)              2298851/s    65%    55%        54%        53%                  7%                   2%         --                -1%           -6%                   -10%                   -12% -14%              -15%              -16% -18%        -19%             -24%        -78%   -78%
Inline(GCC) method      2314815/s    66%    56%        55%        54%                  7%                   3%         1%                 --           -5%                    -9%                   -12% -13%              -14%              -15% -18%        -18%             -23%        -78%   -78%
TinyCC method           2444988/s    75%    65%        64%        63%                 13%                   9%         6%                 6%            --                    -4%                    -7%  -9%               -9%              -10% -13%        -13%             -19%        -77%   -77%
Inline(GCC) method (3)  2551020/s    83%    72%        71%        70%                 18%                  14%        11%                10%            4%                     --                    -3%  -5%               -5%               -6%  -9%        -10%             -16%        -76%   -76%
Inline(GCC) method (2)  2624672/s    88%    77%        76%        75%                 22%                  17%        14%                13%            7%                     3%                     --  -2%               -3%               -4%  -7%         -7%             -13%        -75%   -75%
XS                      2673797/s    92%    80%        79%        78%                 24%                  19%        16%                16%            9%                     5%                     2%   --               -1%               -2%  -5%         -5%             -11%        -74%   -75%
TinyCC method (3)       2695418/s    93%    82%        80%        80%                 25%                  20%        17%                16%           10%                     6%                     3%   1%                --               -1%  -4%         -5%             -11%        -74%   -74%
TinyCC method (2)       2724796/s    95%    84%        82%        82%                 26%                  21%        19%                18%           11%                     7%                     4%   2%                1%                --  -3%         -4%             -10%        -74%   -74%
xsub                    2816901/s   102%    90%        88%        88%                 31%                  25%        23%                22%           15%                    10%                     7%   5%                5%                3%   --         -0%              -7%        -73%   -73%
TinyCC xsub             2824859/s   103%    90%        89%        88%                 31%                  26%        23%                22%           16%                    11%                     8%   6%                5%                4%   0%          --              -6%        -73%   -73%
Inline(GCC) xsub        3021148/s   117%   104%       102%       102%                 40%                  34%        31%                31%           24%                    18%                    15%  13%               12%               11%   7%          7%               --        -71%   -71%
Inline(GCC)            10416667/s   647%   602%       597%       595%                383%                 364%       353%               350%          326%                   308%                   297% 290%              286%              282% 270%        269%             245%          --    -1%
TinyCC                 10526316/s   655%   609%       604%       602%                388%                 368%       358%               355%          331%                   313%                   301% 294%              291%              286% 274%        273%             248%          1%     --
```
