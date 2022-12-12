<figure markdown>
  ![FA-BSP](../figs/fab.png){ width="450" }
  <figcaption>The FA-BSP Model</figcaption>
</figure>

Our proposal is to realize the FA-BSP (FABS) model by building on three ideas from past work in an integrated approach. 

The first idea is the actor model, which enables distributed asynchronous computations via fine-grained active messages while ensuring that all messages are processed atomically within a single-mailbox actor. For FABS, we extend classical actors with multiple symmetric mailboxes for scalability, and with automatic termination detection of messages initiated in a superstep. 

The second idea is message aggregation, which we believe should be performed automatically to ensure that the FABS model can be supported with performance portability across different systems with different preferences for message sizes at the hardware level due to the overheads involved. The third idea is to build on an asynchronous tasking runtime within each node, and to extend it with message aggregation and message handling capabilities.
