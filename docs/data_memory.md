# Data memory

Because some io's are memory mapped, the quartus 1-port ram block is not sufficient.
Therefore this block will be wrapped in another module as shown below.

Note that the byte enable input of each block is appears to unconnected, this is only for readability purposes. In reality the byte enable is determined based on a `mem_mode` (which is byte, word or halfword) and the least significant bits of the address.

![Data memory wrapper](./res/data_memory.svg)