# Breakdown
Example input:
```q
x:()
x,:enlist"Step C must be finished before step A can begin."
x,:enlist"Step C must be finished before step F can begin."
x,:enlist"Step A must be finished before step B can begin."
x,:enlist"Step A must be finished before step D can begin."
x,:enlist"Step B must be finished before step E can begin."
x,:enlist"Step D must be finished before step E can begin."
x,:enlist"Step F must be finished before step E can begin."
```

## Part 1
Since the letters for the tasks appear at fixed positions in each string, we can index into the
strings at those positions to get the interesting info:
```q
q)e:flip`s`t!flip x[;5 36]
q)e
s t
---
C A
C F
A B
A D
B E
D E
F E
```
We initialize the list of completed tasks to empty:
```q
q)done:""
```
We find the list of tasks by taking the distinct values from the two lists:
```q
q)ts:asc distinct e[`t],e[`s]
q)ts
`s#"ABCDEF"
```
We perform an iteration as long as there are items left in the table:
```q
    while[0<count e;
        ...
    ];
```
In the iteration, we first find which tasks are not found in the `t` column of the table, which
indicates there are no tasks required before they can begin:
```q
q)ts except e[`t]
,"C"
```
We find the minimum of this list, which picks the alphabetically first one:
```q
q)nxt:min ts except e[`t]
q)nxt
"C"
```
We add this task to the list of done tasks:
```q
q)done,:nxt
q)done
,"C"
```
We update the table to remove any dependencies on this task:
```q
q)e:select from e where s<>nxt
q)e
s t
---
A B
A D
B E
D E
F E
```
We also remove the completed task from the full task list:
```q
q)ts:ts except nxt
q)ts
"ABDEF"
```
This is the end of the iteration code.

At the end of the iteration, the `done` list will contain all tasks in completion order:
```q
q)done
"CABDF"
```
There may still be tasks left to do in the `ts` list. Since that list was sorted in ascending order,
we can append it to the end to get the complete list.
```q
q)done,ts
"CABDFE"
```

## Part 2
The function for this part takes two additional parameters: the number of additional workers (2 for
the example and 5 for the real input) and the base time for each task (0 for the example and 60 for
the real input).
```q
q)workers:2
q)basetime:0
```
We create the dependency table as before:
```q
q)e:flip`s`t!flip x[;5 36]
```
We create a work table with the tasks in progress and the time left:
```q
q)work:([]task:"";timeLeft:`int$())
q)work
task timeLeft
-------------
```
Like in part 1, we create a variable for the incomplete tasks, but this time it will be a table such
that it can also hold the time required to finish each task. We use some ASCII code aritmhetic to
calculate the times - while characters can't participate in calculations, we can convert them to
integers which can.
```q
q)ts:update cost:basetime+1+(`int$task)-`int$"A" from ([]task:asc distinct e[`t],e[`s])
q)ts
task cost
---------
A    1
B    2
C    3
D    4
E    5
F    6
```
We also keep a list of done tasks:
```q
q)done:""
```
We store the "now" time (in seconds) that starts at zero:
```q
q)now:0
```
We perform an iteration as long as there are items in the pending task list and the work list:
```q
    while[(0<count ts) or 0<count work;
        ...
    ];
```
We find how much time has to pass before a task is completed by taking the minimum of the remaining
times of the tasks in the work table. We have to specifically handle the case when the table is
empty, because `min` on an empty list returns infinity, whereas the meaningful value in this case is
zero.
```q
q)timePassed:$[0<count work;exec min timeLeft from work;0]
q)timePassed
0
```
We add the elapsed time to the current time:
```q
q)now+:timePassed
q)now
0
```
We decrease the remaining time from any work items by the elapsed time:
```q
q)work:update timeLeft:timeLeft-timePassed from work
q)work
task timeLeft
-------------
```
If there are any tasks with 0 seconds left, we add them to the done list:
```q
q)done,:exec task from work where 0=timeLeft
q)done
""
```
We also remove the completed tasks from the work table:
```q
q)work:delete from work where 0=timeLeft
q)work
task timeLeft
-------------
```
We also remove the completed tasks from the dependency table:
```q
q)e:select from e where not s in done
q)e
s t
---
C A
C F
A B
A D
B E
D E
F E
```
We now try to fill in the work table to make sure all workers are busy. This is done in a nested
iteration while the work table has less elements than the worker count and there are still tasks
left to do:
```q
    while[(count[work]<workers) and 0<count ts;
        ...
    ];
```
In the sub-iteration, we pick an incomplete task that has no dependencies:
```q
q)nxt:first select from ts where not task in e[`t]
q)nxt
task| "C"
cost| 3
```
We append it to the work table:
```q
q)work,:`task`timeLeft!nxt[`task`cost]
q)work
task timeLeft
-------------
C    3
```
We delete this task from the pending task list:
```q
q)ts:select from ts where task<>nxt`task
q)ts
task cost
---------
A    1
B    2
D    4
E    5
F    6
```
This is the end of the code for the sub-iteration.

One aspect that is not obvious from the above is what happens if there are not enough tasks to
assign to each worker because all pending tasks have dependencies that are currently in progress or
pending. In this case the code will still run, and will pull out a null task from the table and
insert it into the work table. It is easier to implement it this way than to keep track of another
variable that indicates not being able to pull another task from the queue. All that is required is
deleting the null tasks from the work table:
```q
q)work:delete from work where task=" "
q)work
task timeLeft
-------------
C    3
```
This is the end of the code for the main iteration.

At the end of the iteration, the `now` variable contains the time taken:
```q
q)now
15
```
