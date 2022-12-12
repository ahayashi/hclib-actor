`hclib::yield()` defines a yield point for enabling context-switching between a main program and the selector runtime. While the `yield` operation is not always required, in some cases, the user has to explicitly call the operation to do the context-switching. Specifically, the `yield` operation may be required when a variable is shared by both the main program and the process method. 

First, consider the following selector class:

``` c++ linenums="1"
class MyActor: public hclib::Selector<1, int> {
    int *larray;
    int *lreceived;
    void process(int idx, int sender_rank) {
        larray[idx] += 1;
        *lreceived = *lreceived + 1;
    }
public:
    MyActor(int *larray, int *lreceived) : larray(larray), lreceived(lreceived) {
        mb[0].process = [this](int idx, int sender_rank) { this->process(idx, sender_rank);};
    }
};
```

Notice that `*lreceived` is incremented by one in the process method. Also, here is the main program:

``` c++ linenums="1"
int *received = (int*)calloc(1, sizeof(int));
MyActor* actor_ptr = new MyActor(larray, received);
hclib::finish([=]() {
  actor_ptr->start();
  for (int i = 0; i < N; i++) {
    int pe = (shmem_my_pe() + 1) % shmem_n_pes();
    actor_ptr->send(i, pe);
  }
  // while (*received != N) { }
  while (*received != N) { hclib::yield(); }
  actor_ptr->done(0);
});
assert(*received == N);
```

On Line 9, there is an inactive while loop that loops until `*received == N`. Note that, if you comment in the line, the program will never be terminated due to the following reasons:

First, recall that the main program and the process method are executed concurrently by the same PE in an interleaved fashion. Second, recall that the `send` API is non-blocking and it is not guaranteed that the operation is completed on the receiver side when `send` returns, which simultaneously means there is no guarantee that the process method is called `N` times when the execution reaches Line 9. 

Thus, on Line 9, if the while loop is commented in, the PE executing the while loop is blocked, which prevents the PE from exeucting the process method, which eventually prevents `lreceived` from getting updated. In most cases, we strongly recommend using `finish`, which ensures that all the send and process operations are completed. However, if there is a strong motivation for keeping track of `lreceived` in the finish scope, it is required to invoke `yield` in the while loop (Line 10) to let the runtime make progress on communications.
