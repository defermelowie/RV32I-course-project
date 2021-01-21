# Memory mapped IO

## IO output bus

|HEX5     |HEX4     |HEX3     |HEX2     |HEX1     |HEX0     |LED    |
|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-----:|
|51 ... 45|44 ... 38|37 ... 31|30 ... 24|23 ... 17|16 ... 10|9 ... 0|

## IO input bus

|KEY      |SW     |
|:-------:|:-----:|
|13 ... 10|9 ... 0|

## Address space

The way an address is interpreted:

|Unused |Block address|Word address|Byte address|
|:-----:|:-----------:|:----------:|:----------:|
|[31:14]|[13:12]      |[11:2]      |[1:0]       |

The resulting memory map:

![Memory map](./res/memory_map.svg)