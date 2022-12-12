## `hclib`'s Actor

| API                  | Description |
| :-                   | :-   |
| `launch()`           | Create an hclib context. |
| `finish()`           | Wait until 1) all outgoing messages are sent, and 2) all incoming messages are processed on the current PE. |
| `send()`             | Send an asyncornous message to a remote PE.  |
| `done()`             | Tell the runtime that the current PE will not send any messages to a specific mailbox. |
| `yield()`            | Explicitly occur a context-swtiching to make progress in communication. |
