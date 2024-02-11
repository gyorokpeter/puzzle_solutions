**NOTE: I originally wrote this for reddit but due to their draconian moderation policies they took it down.**

When faced with a problem it's a good idea to choose the right tool for the problem. The numerous posts (and especially memes) about the difficulty of input parsing is an indicator that mainstream programming languages might not be the best tool to use.

If your favorite language supports regexes then that is a huge help. However in this post I would like to demonstrate how I do input parsing in my favorite language which is **q**. It has no regex support, but it does have a few simple but powerful operations that can be composed:

* `vs`: Cut a string based on a delimiter (which can be a character or string)
* `/:`: Apply the preceding operation one level deeper on the right (so `" "vs/:x` would cut each string in a list of strings on spaces)
* `$`: The cast operator. The most useful feature is to turn strings into integers which is written as `"J"$`. Note that this *does not* require `/:` to work on a list *except* if we want to parse individual digits as individual integers.

Also one more thing to remember is that expressions are always evaluated *right to left* and there is no precedence between the operators.

The examples below also contain some other operators from **q** but I will try to explain them as they come up.

Here I will demonstrate the input parsing for all problems from 2021 and those released until now from 2022 (Day 6). In each code sample, it is assumed that the variable `x` is a list of strings containing the input (that can be obtained by using `read0` on the downloaded input file) except if the input is not in a separate file but embedded in the puzzle text in which case it's a single string or even an integer - I will mention those if they come up.

The days are ordered by how complex they are, measured by the code size.

Let me know if you would like any more days to be added or any changes to the format.

# 2021-10, 2022-3

No parsing required as a list of strings is the best way to process them.

# 2021-1

    "J"$x

Cast the list of strings to integers.

# 2022-6

    first x

The input is a *list* of strings and we only want the first one. I prefer to follow the convention than break it just to say "no parsing required".

# 2021-24

    " "vs/:x

Split every line on spaces. Note that depending on the instruction, further cast to integer is required.

# 2021-3

    "B"$/:/:x

Cast the list of list of characters into booleans.

# 2021-9, 2021-11, 2021-15

    "J"$/:/:x

Cast the list of list of characters into integers. In this and the previous example, there are two uses of `/:` because we need to go two levels deep, as we want to parse individual characters and not the whole strings.

# 2021-12

    `$"-"vs/:x

Split every line on dashes. I also cast every element into *symbols* because there is a small number of possibilities and symbols are easier to compare.

# 2021-18

    .j.k each x

Use the built-in JSON parser. In my published solution I actually don't do this to the entire input but rather parse bits of it on the fly on different levels of my code.

# 2021-13

    "J"$","vs/:x

Split every line on commas, then cast everything to integers.

# 2021-6, 2021-7

    "J"$","vs first x

Split the first line on commas, then cast everything to integers. This is another one-line input therefore the `first`.

# 2021-16

    "X"$2 cut first x

Cut the first line (one-line input) into strings of length 2, then parse each string as a byte (type `X`, which is displayed/parsed as 2 hexadecimal digits in **q**).

# 2021-8

    " "vs/:/:" | "vs/:x

Split every line on the delimiter `" | "`, then split every resulting substring on spaces.

# 2021-25

    ssr[;".";" "]each x

Replace every dot with a space. This might not be necessary depending on the code, but I found it easier to do it this way as the space character counts as `null` in **q** while the dot doesn't, and some operators have specific behavior to ignore `null`s.

# 2021-21

    "J"$last each" "vs/:x

Split every line on spaces, take the last element of each line, and cast the resulting strings into integers.

# 2022-4

    "J"$"-"vs/:/:","vs/:x

Split every line on commas, split every resulting substring on dashes, then cast everything to integers.

# 2022-2

    x[;0 2]

Take the characters at index 0 and 2 from each line. However one that makes subsequent processing easier is

    (`int$x[;0 2])-\:65 88

so cast the result of the indexing to integers and then subtract the list `65 88`, i.e. subtract 65 from every first element and 88 from every second element, so ABC becomes 012 and XYZ also becomes 012. There are also other ways to do this conversion such as mapping with a dictionary.

# 2021-5

    "J"$","vs/:/:" -> "vs/:x

Split every line on the delimiter `" -> "`, split every resulting substring on commas, then cast everything to integers.

# 2022-1

    "J"$"\n"vs/:"\n\n"vs"\n"sv x

Join the list with newlines, then split on double-newlines. This will be a common pattern for any input which has two consecutive newlines separating sections, so I will call this operation **split into sections**. Split each section on newlines and convert everything into integers.

Alternatively:

    {(0,where null x)cut x}"J"$x

Cast the lines into integers. Find where the integers are nulls (invalid integers, such as the empty lines, are parsed into nulls), and cut on these indices. Since `cut` starts cutting on the first index given which is where the first split is, it would normally drop the first section, so we prepend a 0 to the list of indices to cut on. The resulting lists still have the nulls in them but fortunately some functions like `sum` have built-in behavior to ignore nulls.

# 2021-19

    "J"$","vs/:/:1_/:"\n"vs/:"\n\n"vs"\n"sv x

Split into sections. In each section, split on newlines and drop the first element (`--- scanner # ---`), cut the remaining elements on commas, then cast everything to integers.

# 2021-17

    "J"$".."vs/:last each "="vs/:2_" "vs first[x] except","

Take the first line (one-line input), remove any commas from it (there is only one separating the x and y constraints), split it on spaces, drop the first two elements (`target area:`), split  on equals signs and take the last of each result (now we have `("AAA..BBB";"CCC..DDD")`), split  on the delimiter `".."` and cast everything to integers.

# 2021-20

    a:"\n\n"vs"\n"sv x
    prog:"#"=first a
    map:"#"="\n"vs last a

Now we are getting into multi-part parsing as the input contains multiple things that must be parsed differently. Split into sections. For the first section (program), convert to a list of booleans by comparing to `#`. For the second section (map), split in newlines and once again convert to booleans by comparing to `#`.

# 2021-14

    a:"\n\n"vs"\n"sv x
    polymer:first a
    rules:" -> "vs/:"\n"vs last a

Split into sections. The first section (polymer) doesn't need parsing. In the second section (rules), split on newlines, then split on the delimiter `" -> "`.

# 2021-22

    a:" "vs/:x
    op:a[;0]like"on"
    coord:"J"$".."vs/:/:2_/:/:","vs/:a[;1]

Split the lines on spaces. Take the first element of every line and compare it to the string `"on"` to get a list of booleans representing the operations. For the coordinates, take the second element of every line (index 1), split on commas, drop the first 2 characters of every element (the `x=` `y=` `z=` part), split again on `".."` then cast everything to integers.

# 2021-23

This one needs a variable `part` to be set to 1 or 2 as the input needs to be tweaked for part 2.

    enlist[x[2;3 5 7 9]],$[part=2;("DCBA";"DBAC");()],enlist x[3;3 5 7 9]

Take characters at indices 3, 5, 7, 9 from the lines at indices 2 and 3. These correspond to the useful info from the input, which we extract into two strings of length 4 each. For part 2, append "DCBA" and "DBAC" in the middle as instructed by the puzzle.

The `enlist`s are there because we want to append a list of strings (that only has one element) to another list of strings, as opposed to appending the characters inside the string. The middle section is a kind of if-then-else that returns a two-element list if the condition `part=2` is true, otherwise it returns an empty list.

# 2021-2

    a:" "vs/:x
    move:(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]
    amt:"J"$a[;1]

Split the lines on spaces. Map the first element of every line using a dictionary to the movement deltas. Convert the second elements to integers to get the movement amounts.

# 2021-4

    a:"\n\n"vs"\n"sv x
    nums:"J"$","vs first a
    cards:(raze each"J"$" "vs/:/:"\n"vs/:1_a)except\:0N

Split into sections. In the first section (nums), split on commas and convert everything to integers. In the remaining sections (cards), split on newlines, then on spaces, convert everything to integers, raze each list (so every card is flattened into a list of integers) and remove any nulls caused by the double spaces in the input.

# 2022-5

    a:"\n\n"vs"\n"sv x
    st:reverse each trim flip(4 cut/:-1_"\n"vs a 0)[;;1]
    ins:0 -1 -1+/:"J"$(" "vs/:"\n"vs a 1)[;1 3 5]

Split into sections. In the first section (stacks) split on newlines, drop the last line (the one that contains the stack numbers), cut the remaining lines into substrings of length 4, and index into the result such that we get the useful letter - this requires indexing with `[;;1]` which basically means "for every line (*blank first index*) and for every crate (*blank second index*) take the element at index 1 (*the index of the letter*)". For easier subsequent processing, flip the list (so rows become columns and vice versa) and `trim` the extra spaces (where there is no crate). I also `reverse` the lists so any modifications happen at the end of the list but it's possible to write the code without this reverse. In the second section (instructions), split on newlines, split again on spaces, then index into the result to get the numbers - in this case the correct index to use is `[;1 3 5]`. Cast the results to integers. For easier processing, subtract 1 from the second and third numbers which are to be interpreted as indices into a list as indexing starts from zero. This operation can be expressed as adding the list 0 -1 -1 to every list in the intructions, since it will leave the first number (the amount of crates) unchanged while adding -1 (i.e. subtracting 1) from the indices.
