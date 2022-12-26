# Breakdown
Example input:
```q
x:"\n"vs"$ cd /\n$ ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n$ cd a\n$ ls\ndir e\n29116 f\n2557 g\n62596 h.lst\n$ cd e\n$ ls\n584 i\n$ cd ..\n$ cd ..\n$ cd d\n$ ls\n4060174 j\n8033020 d.log\n5626152 d.ext\n7214296 k";
```

## Common
We start by cutting the lines on spaces:
```q
q)a:" "vs/:x
q)a
(,"$";"cd";,"/")
(,"$";"ls")
("dir";,"a")
("14848514";"b.txt")
("8504156";"c.dat")
...
```
Then we generate the current working directory for each line using an iterated function. The path will contain one element for each directory on the path AND it will also contain the full path, so for example `/a/e` will be represented as `("";"/a";"/a/e")` (the empty string stands for the root directory).

The directory is updated in a branch statement:
```q
$[not y[0]~enlist"$";x;
```
If the first element is not `$`, we don't do anything because that is not a directory change.
```q
y[1]~"ls";x;
```
If the second element is `ls`, we also don't do anything.
```q
y[2]~enlist"/";enlist"";
```
If we are switching to the root directory, update our representation accordingly, by replacing it with a list containing an empty string.
```q
y[2]~"..";-1_x;
```
If we are moving one level up, that's done by dropping the last element of our directory list.
```q
x,enlist last[x],"/",y 2]
```
The default case is that we are moving to a new directory, so we add a new element to the list that is created by adding a separator and the new directory name to the last element.

```q
pwd:{...}\[enlist"";a]
```
We call this function with a list containing an empty string, and pass in the commands in turn. We use the `\` _scan_ iterator as we are interested in the intermediate values.
```q
q)pwd

..
("";"/a")
("";"/a")
..
("";"/a";"/a/e")
("";"/a";"/a/e")
..
```
The other info we need is the file sizes, so we convert the first word of every line into an integer, not caring that some are invalid:
```q
q)fs
0N 0N 0N 14848514 8504156 0N 0N 0N 0N 29116 2557 62596 0N 0N 584 0N 0N 0N 0N 4060174 8033020 5626152 7214296
```
The reason for including every intermediate directory as a separate item in the list is that this makes it easier to count the same file into the size of every enclosing directory, not just the innermost one. So we create a small table containing the full paths and the file sizes:
```q
q)([]pwd;fs)
pwd              fs
-------------------------
..
("";"/a")        29116
("";"/a")        2557
("";"/a")        62596
("";"/a";"/a/e")
("";"/a";"/a/e")
("";"/a";"/a/e") 584
..
```
Then by the magic of the `ungroup` function we duplicate the sizes to each of the subdirectories:
```q
q)ungroup ([]pwd;fs)
pwd    fs
---------------
..
""     29116
"/a"   29116
""     2557
"/a"   2557
""     62596
"/a"   62596
..
```
Then we can group in the other direction, summing up the sizes for each directory:
```q
q)t:exec sum fs by pwd from ungroup ([]pwd;fs)
q)t
""    | 48381165
"/a"  | 94853
"/a/e"| 584
"/d"  | 24933642
```

## Part 1
After finding the size of each directory, we can compare it to 100000 to find which are smaller:
```q
q)t<=100000
""    | 0
"/a"  | 1
"/a/e"| 1
"/d"  | 0
q)where t<=100000
"/a"
"/a/e"
```
And use this index to the original dictionary to find the actual sizes, and finally sum them:
```q
q)t where t<=100000
94853 584
q)sum t where t<=100000
95437
```

## Part 2
The entry for `""` contains the total size:
```q
q)t[""]
48381165
```
We subtract this from 70000000 to find the free space:
```q
q)70000000-t[""]
21618835
```
We add this result to the sizes to find how much space will be free if we delete that particular directory:
```q
q)t+70000000-t[""]
""    | 70000000
"/a"  | 21713688
"/a/e"| 21619419
"/d"  | 46552477
```
We filter to find which is greater than 30000000:
```q
q)t where 30000000<=t+70000000-t[""]
48381165 24933642
```
The answer is the minimum of these:
```q
q)min t where 30000000<=t+70000000-t[""]
24933642
```

## Note
The command in the story, `system-update --please --pretty-please-with-sugar-on-top`, references having to provide various parameters to make commands work and other steps you need to take, such as running with `sudo`, or suppressing prompts to overwrite files and confirm the extra disk space used. The error message in the title text, `E099 PROGRAMMER IS OVERLY POLITE`, is a reference to [INTERCAL](https://en.wikipedia.org/wiki/INTERCAL), a programming language whose compiler could reject the program for being too polite due to "PLEASE" appearing too often.
