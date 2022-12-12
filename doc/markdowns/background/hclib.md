## What is HClib?

Habanero C/C++ library (HClib) is a lightweight asynchronous many-task (AMT) programming model-based runtime. It uses a lightweight work-stealing scheduler to schedule the tasks. HClib uses a persistent thread pool called workers, on which tasks are scheduled and load balanced using lock-free concurrent deques. HClib exposes several programming constructs to the user, which in turn helps them to express parallelism easily and efficiently.

A brief summary of the relevant APIs is as follows:


* `launch`: Used for creating an HClib context.
* `async`: Used for creating asynchronous tasks dynamically.
* `finish`: Used for bulk task synchronization. It waits on all tasks spawned (including nested tasks) within the scope of the finish.
* `promise` and `future`: Used for point-to-point inter-task synchronization in C++11. A promise is a single-assignment thread-safe container, that is used to write some value and a future is a read-only handle for its value. Waiting on a future causes a task to suspend until the corresponding promise is satisfied by putting some value to the promise.

## An example HClib program

The following example creates an HClib context in which there is a `finish` scope that waits on a task created by `async`. Since the task assign 1 to `ran`, after the `finish` scope, the value of `ran` should be 1.

``` c++
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "hclib_cpp.h"

int ran = 0;

int main (int argc, char ** argv) {
    const char *deps[] = { "system" };
    hclib::launch(deps, 1, []() {
        hclib::finish([]() {
            printf("Hello\n");
            hclib::async([&](){ ran = 1; });
        });
    });
    assert(ran == 1);
    printf("Exiting...\n");
    return 0;
}
```

## Further Readings

- M. Grossman, V. Kumar, N. Vrvilo, Z. Budimlic and V. Sarkar, "A pluggable framework for composable HPC scheduling libraries," 2017 IEEE International Parallel and Distributed Processing Symposium Workshops (IPDPSW), 2017, pp. 723-732, doi:  <https://doi.org/10.1109/IPDPSW.2017.13>
