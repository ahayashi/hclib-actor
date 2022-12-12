Our framework focuses on improving the performance and programmability of distributed applications where each PE sends/receives a massive number of fine-grain messages to/from random remote locations. Such applications are typically categorized as irregular applications such as graph analytics, sparse matrix linear algebra operations, and so on.

The key features of our framework include:

- Asynchronous messaging with our actor/selector library (`hclib-actor`).
- SPMD-style programming with OpenSHMEM.
- Runtime automatic message aggregation backed by Bale. 

More details on SPMD, OpenSHMEM, Bale, Actor model can be found in the Background section.

### Step 1: Create an empty hclib-actor program

To take a first step, let's first write an empty program that 1) initializes and finializes SHMEM, and 2) launches an empty HClib program:

```c++ linenums="1"
#include <shmem.h>
#include "selector.h"
// SPMD
int main(int argc, char * argv[]) {
  // Initialize SHMEM
  shmem_init();

  const char *deps[] = { "system", "actor" };
  hclib::launch(deps, 2, [=] {
    // do nothing
  });
  // Finalize SHMEM
  shmem_finalize();  
  return 0;
}
```

As the names imply, `shmem_init()` initializes and `shmem_finalize()` finalizes SHMEM. Also, `hclib::launch` launches an HClib program expressed as a C++ lambda expression (`[=] {}`). The first two arguments indicate that it loads two plugins stored in the array `deps` (`libhclib_system.so` and `libhclib_actor.so`).

### Step 2: Allocate memory and initialize it

Then, let's allocate memory using `shmem_malloc()` and initialize it:

```c++ linenums="1"
#include <shmem.h>
#include "selector.h"

void print_array(int *larray, const int N) {
   for (int i = 0; i < N; i++) {
     printf("[PE%d] larray[%d] = %d\n", shmem_my_pe(), i, larray[i]);
   }
}

// SPMD
int main(int argc, char * argv[]) {
  // Initialize SHMEM
  shmem_init();

  const char *deps[] = { "system", "actor" };
  hclib::launch(deps, 2, [=] {
    // allocate memory
    const int N = 10;
    int* larray = (int*)shmem_malloc(sizeof(int)*N);
    for (int i = 0; i < N; i++) {
        larray[i] = N * shmem_my_pe() + i;
    }
    print_array(larray, N);
    shmem_barrier_all();
    shmem_free(larray);
  });
  // Finalize SHMEM
  shmem_finalize();  
  return 0;
}
```

Here each PE allocates an integer array with N elements and initializes it. Notice that now we have `print_array` function that prints the content of the array on the current PE. Here is an example output with 2PEs:

```
[PE0] larray[0] = 0
[PE0] larray[1] = 1
[PE0] larray[2] = 2
[PE0] larray[3] = 3
[PE0] larray[4] = 4
[PE0] larray[5] = 5
[PE0] larray[6] = 6
[PE0] larray[7] = 7
[PE0] larray[8] = 8
[PE0] larray[9] = 9
[PE1] larray[0] = 10
[PE1] larray[1] = 11
[PE1] larray[2] = 12
[PE1] larray[3] = 13
[PE1] larray[4] = 14
[PE1] larray[5] = 15
[PE1] larray[6] = 16
[PE1] larray[7] = 17
[PE1] larray[8] = 18
[PE1] larray[9] = 19
```

### Step 3: Write an actor program

Now let us create an actor program in which each PE sends asynchronous messages that increment the content of `larray` by one on the receiver side. Like conventional actor programs, let us define an actor class with 1) a local state (`larray`) and 2) a message handler (`process()`):

``` c++ linenums="1"
class MyActor: public hclib::Selector<1, int> {
    int *larray;
    void process(int idx, int sender_rank) {
        larray[idx] += 1;
    }
public:
    MyActor(int *larray) : larray(larray) {
        mb[0].process = [this](int idx, int sender_rank) { this->process(idx, sender_rank);};
    }
};
```

Then, let us use the actor class from the main program:

``` c++ linenums="1"
MyActor* actor_ptr = new MyActor(larray);
hclib::finish([=]() {
    actor_ptr->start();
    for (int i = 0; i < N; i++) {
        int pe = (shmem_my_pe() + 1) % shmem_n_pes();
        actor_ptr->send(i, pe);
    }
    actor_ptr->done(0);
});
```

In this example, each PE starts the actor class and sends `N` messages to the next PE (the last PE sends messages to PE0). (Add more)

### Step 4: Putting it altogether

Here is a final program:

``` c++ linenums="1"
#include <shmem.h>
#include "selector.h"

void print_array(int *larray, const int N) {
   for (int i = 0; i < N; i++) {
     printf("[PE%d] larray[%d] = %d\n", shmem_my_pe(), i, larray[i]);
   }
}

class MyActor: public hclib::Selector<1, int> {
    int *larray;
    void process(int idx, int sender_rank) {
        larray[idx] += 1;
    }
public:
    MyActor(int *larray) : larray(larray) {
        mb[0].process = [this](int idx, int sender_rank) { this->process(idx, sender_rank);};
    }
};

// SPMD
int main(int argc, char * argv[]) {
  // Initialize SHMEM
  shmem_init();

  const char *deps[] = { "system", "actor" };
  hclib::launch(deps, 2, [=] {
    // allocate memory
    const int N = 10;
    int* larray = (int*)shmem_malloc(sizeof(int)*N);
    for (int i = 0; i < N; i++) {
      larray[i] = N * shmem_my_pe() + i;
    }
    print_array(larray, N);
    MyActor* actor_ptr = new MyActor(larray);
    hclib::finish([=]() {
	    actor_ptr->start();
    	for (int i = 0; i < N; i++) {
        int pe = (shmem_my_pe() + 1) % shmem_n_pes();
        actor_ptr->send(i, pe);
	    }
      actor_ptr->done(0);
    });
    shmem_barrier_all();
    print_array(larray, N);
    shmem_barrier_all();
    shmem_free(larray);
  });
  // Finalize SHMEM
  shmem_finalize();
  return 0;
}
```

```
[PE0] larray[0] = 0
[PE0] larray[1] = 1
[PE0] larray[2] = 2
[PE0] larray[3] = 3
[PE0] larray[4] = 4
[PE0] larray[5] = 5
[PE0] larray[6] = 6
[PE0] larray[7] = 7
[PE0] larray[8] = 8
[PE0] larray[9] = 9
[PE1] larray[0] = 10
[PE1] larray[1] = 11
[PE1] larray[2] = 12
[PE1] larray[3] = 13
[PE1] larray[4] = 14
[PE1] larray[5] = 15
[PE1] larray[6] = 16
[PE1] larray[7] = 17
[PE1] larray[8] = 18
[PE1] larray[9] = 19
[PE0] larray[0] = 1
[PE0] larray[1] = 2
[PE0] larray[2] = 3
[PE0] larray[3] = 4
[PE0] larray[4] = 5
[PE0] larray[5] = 6
[PE0] larray[6] = 7
[PE0] larray[7] = 8
[PE0] larray[8] = 9
[PE0] larray[9] = 10
[PE1] larray[0] = 11
[PE1] larray[1] = 12
[PE1] larray[2] = 13
[PE1] larray[3] = 14
[PE1] larray[4] = 15
[PE1] larray[5] = 16
[PE1] larray[6] = 17
[PE1] larray[7] = 18
[PE1] larray[8] = 19
[PE1] larray[9] = 20
```
