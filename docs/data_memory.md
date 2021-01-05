# Data memory

Because some io's are memory mapped, the quartus 1-port ram block is not sufficient.
Therefore this block will be wrapped in another module as shown below.

![Data memory wrapper](./res/data_memory.svg)