#import "@preview/plotst:0.2.0": *

= Asymptotic Runtime Complexity

Data Structures are the fundamentals of algorithms: How efficient an algorithm is depends on how the data is organized. 
Think about your workspace: If you know exactly where everything is, you can get to it much faster than if everything is piled up randomly.
Data structures are the same: If we organize data in a way that meets the need of an algorithm, the algorithm will run much faster (remember the array vs linked list comparison from earlier)?

Since the point of knowing data structures is to make your algorithms faster, one of the things we'll need to talk about is how fast the data structure (and algorithm) is for specific tasks.
Unfortunately, "how fast" is a bit of a nuanced comparison.
I could time how long algorithms *A* and *B* take to run, but what makes a fair comparison depends on a lot of factors:
- How big is the data that the algorithm is running on? 
   - *A* might be faster on small inputs, while *B* might be faster on big inputs.
- What computer is running the algorithm?
   - *A* might be much faster on one computer, *B* might be much faster on a network of computers.
   - *A* might be especially tailored to Intel x86 CPUs, while *B* might be tailored to the non-uniform memory latencies of AMD x86 CPUs.
- How optimized is the code?
   - Hand-coded optimizations can account for multiple orders of magnitude in algorithm performance.

In short, comparing two algorithms requires a lot of careful analysis and experimentation.
This is important, but as computer scientists, it can also help to take a more abstract view.
We would like to have a shorthand that we can use to quickly convey the 50,000-ft view of "how fast" the algorithm is going to be.
That shorthand is asymptotic runtime complexity.

== Some examples of asymptotic runtime complexity

Look at the documentation for data structures in your favorite language's standard library.
You'll see things like:
- The cost of appending to a Linked List is $O(1)$
- The cost of finding an element in a Linked List is $O(N)$
- The cost of appending to an Array List is $O(N)$, but amortized $O(1)$
- The cost of inserting into a Tree Set is $O(log N)$
- The cost of inserting into a Hash Map is Expected $O(1)$, but worst case $O(N)$
- The cost of retrieving an element from a Cuckoo Hash is always $O(1)$

These are all examples of asymptotic runtimes, and they give you a quick at-a-glance idea of how well the data structure handles specific operations.
Knowing these facts about the data structures involved can help you plan out the algorithms you're writing, and avoid picking a data structure that tanks the performance of your algorithm.

== Asymptotic Analysis in General

Although our focus in this book is mainly on asymptotic *runtime* complexity, asymptotic analysis is a general tool that can be used to discuss all sorts of properties of code and algorithms.  For example:
- How fast is an algorithm?
- How much space does an algorithm need?
- How much data does an algorithm read from disk?
- How much network bandwidth will an algorithm use?
- How many CPUs will a parallel algorithm need?

== Runtime Growth Functions

Let's start by talking about *Runtime Growth Functions*.  A runtime growth function looks like this:

#align(center,[
  $$T(N)$$
])


Here, $T$ is the name of the function (We usually use $T$ for runtime growth functions, and $N$ is the _size_ of the input.  

You can think of this function as telling us "For an input of size $N$, this algorithm will take $T(N)$ seconds to run"
This is a little bit of an inexact statement, since the actual number of seconds it takes depends on the type of computer, implementation details, and more.  
We'll eventually generalize, but for now, you can assume that we're talking about a specific implementation, on a specific computer (like e.g., your computer).

We call this a growth function because it generally has to follow a few rules:

- For all $N >= 0$, it must be the case that $T(N) >= 0$
   - The algorithm can't take negative time to run.
- For all $N >= N'$, it must be the case that $T(N) >= T(N')$
   - It shouldn't be the case that the algorithm runs faster on a bigger input #footnote[
     In practice, this is not actually the case.
     We'll see a few examples of functions who's runtime can sometimes be faster on a bigger input. 
     Still, for now, it's a useful simplification.
   ].


== Complexity Classes

Before we define the idea of asymptotic runtimes precisely, let's start with an intuitive idea.
We're going to take algorithms (including algorithms that perform specific operations on a data structure), and group them into what we call *Complexity Classes*#footnote[
  To be pedantic, what we'll be describing is called "simple complexity classes", but throughout this book, we'll refer to them as just complexity classes.
].

@linlog_plot shows three different runtime growth functions: Green (dashed), Red (solid), and Blue (dash-dotted).  
For an input of size $N = 2$, the green dashed function appears to be the best, while the blue dash-dotted function appears the worst.  
By the time we get to $N = 10$, the roles have reversed, and the blue dash-dotted function is the best.

#{
  let lin1 = (
    (0, 1), (68, 20)
  )
  let lin2 = (
    (0, 0.5), (50, 20)
  )
  let log1 = (
    (0, 0.5), (1, 1.5), (4, 2.5), (9, 3.5), (16,4.5), (25,5.5), (36, 6.5), (49, 7.5), (64, 8.5), (81, 9.5)
  )
  let x_axis = axis(min: 0, max: 80, step: 5, location: "bottom", title: [Size of Input ($N$)])
  let y_axis = axis(min: 0, max: 21, step: 2, location: "left", title: [Runtime ($T(N)$)])
  let pl_lin_1 = graph_plot(
    plot(data: lin1, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: red, thickness: 2pt),
    markings: [],
    caption: "Different types of growth functions"
  )
  let pl_lin_2 = graph_plot(
    plot(data: lin2, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: green, thickness: 2pt, dash: "dashed"),
    markings: []
  )
  let pl_log_1 = graph_plot(
    plot(data: log1, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: blue, thickness: 2pt, dash: "dash-dotted"),
    markings: []
  )
  overlay(
    (pl_lin_1, pl_lin_2, pl_log_1), (70%, 25%),
  )
} <linlog_plot>

// https://raw.githubusercontent.com/johannes-wolf/cetz/master/manual.pdf

So let's talk about these lines and what we can say about them.
First, in this book, we're going to ignore what happens for "small" inputs.  
This isn't always the right thing to do, but we're taking the 50,000 ft view of algorithm performance.
From this perspective, the blue dot-dashed line is the "best".

But why is it better?
If we look closely, both the green dashed and the red solid line are straight lines.  
The blue dot-dashed line starts going up faster than both the other two lines, but bends downward.
In short, the blue dot-dashed line draws a function of the form $a log(N) + b$, while the other two lines draw functions of the form .
For "big enough" values of $N$, any function of the form $a log(N) + b$ will always be smaller than any function of the form $a · N + b$.  
On the other hand, the value of any two functions of the form $a · N + b$ will always "look" the same.  No matter how far we zoom out, those functions will always be a constant factor different.

Our 50,000 foot view of the runtime of a function (in terms of $N$, the size of its input) will be to look at the "shape" of the curve as we plot it against $N$.

=== Example

Try the following code in python:
```python
from random import randrange
from datetime import datetime
N = 10000
TRIALS = 1000

#### BEGIN INITIALIZE data
data = []
for x in range(N):
    data += [x]
data = list(data)
#### END INITIALIZE data

contained = 0
start_time = datetime.now()
for x in range(TRIALS):
    if randrange(N) in data:
        contained += 1
end_time = datetime.now()

time = (end_time - start_time).total_seconds() / TRIALS

print(f"For N = {N}, that took {time} seconds per lookup")
```

This code creates a list of `N` elements, and then does `TRIALS` checks to see if a randomly selected value is somewhere in the list.  This is a toy example, but see what happens as you  increase the value of `N`.  In most versions of python, you'll find that every time you multiply `N` by a factor of, for example 10, the total time taken per lookup grows by the same amount.

Now try something else.  Modify the code so that the `data` variable is initialized as:
```python
#### BEGIN INITIALIZE data
data = []
for x in range(N):
    data += [x]
data = set(data)
#### END INITIALIZE data
```

You'll find that now, as you increase `N`, the time taken *per lookup* grows at a much smaller rate.  Depending on the implementation of python you're using, this will either grow as $log N$ or only a tiny bit.  The `set` data structure is much faster at checking whether an element is present than the `list` data structure.

Complexity classes are a language that we can use to capture this intuition.  We might say that `set`'s implementation of the `in` operator belongs to the *logarithmic* complexity class, while `list`'s implementation of the operator belongs to the *linear* complexity class.  Just saying this one fact about the two implementations makes it clear that, in general, `set`'s version of `in` is much better than `list`'s.  

== Formal Notation

Sometimes it's convenient to have a shorthand for writing down that a runtime belongs in a complexity class.  We write:

$g(N) in Theta(f(n))$

... to mean that the mathematical function $g(N)$ belongs to the same *asymptotic complexity class* as $f(N)$.  You may also see this written as an equality.  For example

$T(N) = Theta(N)$

... means that the runtime function $T(N)$ belongs to the *linear* complexity class.  Continuing the example above, we would use our new shorthand to describe the two implementations of Python's `in` operator as:

- $T_"set" in Theta(log N)$
- $T_"list" in Theta(N)$

*Formalism:* A little more formally, $Theta(f(N))$ is the *set* of all mathematical functions $g(N)$ that belong to the same complexity class as $f(N)$.  So, writing $g(N) in Theta(f(N))$ is saying that $g(N)$ is in ($in$) the set of all mathematical functions in the same complexity class as $f(N)$#footnote[
  We are sweeping something under the rug here: We haven't precisely defined what it means for two functions to be in the same complexity class yet.  We'll get to that shortly, after we introduce the concept of complexity bounds.
].


Here are some of the more common complexity classes that we'll encounter throughout the book:
- *Constant*: $Theta (1)$
- *Logarithmic*: $Theta (log N)$
- *Linear*: $Theta (N)$
- *Loglinear*: $Theta (N log N)$
- *Quadratic*: $Theta (N^2)$
- *Cubic*: $Theta (N^3)$
- *Exponential* $Theta (2^N)$

#figure(
  image("graphics/complexity-overview.svg", width: 50%),
  caption: [
    $Theta(f(N))$ is the set of all mathematical functions including $f(N)$ and everything that has the same "shape", represented in the chart above as a highlighted region around each line.
  ]
)

Complexity classes are given in order.  The later they appear in the list, the faster they grow.  
Any function that has a *linear* shape, will always be smaller (for big enough values of $N$) than a function with a *loglinear* shape.

=== Polynomials and Dominant Terms

What complexity class does $10N + N^2$ fall into?  Let's plot it and see:

#{
  let lin_pts = (
    (0, 0), (20, 200)
  )
  let quad_pts = (
    (0,0), (1,1), (2,4), (3,9), (4,16), (5,25), (6,36), (7,49), (8,64), (9,81), (10,100), (11,121), (12,144), (13,169), (14,196), (15,225), (16,256), (17,289), (18,324), (19,361), (20,400)
  )
  let target_pts = (
    (0,0), (1,11), (2,24), (3,39), (4,56), (5,75), (6,96), (7,119), (8,144), (9,171), (10,200), (11,231), (12,264), (13,299), (14,336), (15,375), (16,416), (17,459), (18,504), (19,551), (20,600)
  )
  let x_axis = axis(min: 0, max: 20, step: 1, location: "bottom", title: [Size of Input ($N$)])
  let y_axis = axis(min: 0, max: 600, step: 40, location: "left", title: [Runtime ($T(N)$)])
  let lin_plt = graph_plot(
    plot(data: lin_pts, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: red, thickness: 2pt),
    markings: [],
    caption: [Comparing $N$ (solid red), $N^2$ (dashed green), and $10N+N^2$ (dash-dotted blue)]
  )
  let quad_plt = graph_plot(
    plot(data: quad_pts, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: green, thickness: 2pt, dash: "dashed"),
    markings: []
  )
  let target_plt = graph_plot(
    plot(data: target_pts, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: blue, thickness: 2pt, dash: "dash-dotted"),
    markings: []
  )
  overlay(
    (lin_plt, quad_plt, target_plt), (70%, 25%),
  )
} <poly_plot>

@poly_plot compares these three functions.  Observe that the dash-dotted blue line starts off very similar to the solid red line.  However, as $N$ grows, its shape soon starts resembling the dashed green $N^2$ more than the solid red $10N$.  

This is a general pattern.  In any polynomial (a sum of mathematical expressions), for really big values of $N$, the complexity class of the "biggest" term starts to win out once we get to really big values of $N$.  

In general, for any sum of mathematical functions:

$g(N) = f_1(N) + f_2(N) + ... + f_k(N)$

The complexity class of $g(N)$ is the greatest complexity class of any $f_i(N)$

For example:
- $10N + N^2 in Theta(N^2)$
- $2^N + 4N in Theta(2^N)$
- $1000 · N log(N) + 5N in Theta(N log(N))$


=== $Theta$ in mathematical formulas

Sometimes we'll write $Theta(g(N))$ in regular mathematical formulas.  For example, we could write: 

$Theta(N) + 5N$

You should interpret this as meaning any function that has the form:

$f(N) + 5N$

... where $f(N) in Theta(N)$.  


== Code Complexity

Let's see a few examples of how we can figure out the runtime complexity class of a piece of code.

```python
def userFullName(users: List[User], id: int) -> str:
    user = users[id]
    fullName = user.firstName + " " + user.lastName
    return fullName
```

The `userFullName` function takes a list of users, and retrieves the `id`th element of the list and generates a full name from the user's first and last names.  
For now, we'll assume that looking up any element of any array (`users[id]`), string concatenation (`user.firstName + " " + user.lastName`), assignment (`user = ...`, and `fullName`), and returns are all constant-time operations#footnote[
  Array lookups being constant-time is a huge simplification, called the RAM model, that we'll roll back at the end of the book.  
].  

Under these assumptions, the first, second, and third lines can each be evaluated in constant time $Theta(1)$.
The total runtime of the function is the time required to run each line, one at a time, or:

$T_"userFullName" (N) = Theta(1) + Theta(1) + Theta(1)$

Recall above, that $Theta(1)$ in the middle of an arithmetic expression can be interpreted as $f(N)$ where $f(N) in Theta(1)$ (it is a constant).  That is, $f(N) = c$.  So, the above expression can be rewritten as#footnote[
  There's another simplification here.  Technically, $f(N)$ is always within a bounded factor of a constant $c_1$, and likewise for $g(N)$, but we'll clarify this when we get to complexity bounds below.
]:

$T_"userFullName" (N) = c_1 + c_2 + c_3$

Adding three constant values together (even without knowing what they are, exactly) always gets us another constant value.
So, we can say that $T_"userFullName" (N) in Theta(1)$.


```python
def updateUsers(users: List[User]) -> None:
    x = 1
    for user in users:
        user.id = x
        x += 1
```

The `updateUsers` function takes a list of users and assigns each user a unique id.  
For now, we'll assume that the assignment operations (`x = 1` and `user.id`), and the increment operation (`x += 1`) all take constant ($Theta(1)$) time.
So, we can model the total time taken by the function as:

$T_"updateUsers" (N) = O(1) + sum_"user" (O(1) + O(1))$

Simplifying as above, we get

$T_"updateUsers" (N) = c_1 + sum_"user" (c_2 + c_3)$

Recalling the rule for summation of a constant, using $N$ as the total number of users, and then the rule for sums of terms, we get:

$T_"updateUsers" (N) = c_1 + N · (c_2 + c_3) = Theta(N)$


//////////////////////////////////////////////////////////////////////////

== Complexity Bounds

Not every mathematical function fits neatly into a single complexity class.  
Let's go to our python code example above.  
The `in` operator tests to see whether a particular value is present in our data.
If `data` is a `list`, then the implementation checks every position in the list, in order.
Internally, Python implements the expression `target in data` with something like:

```python
def __in__(data, target):
    N = len(data)
    for i in range(N):
        if data[i] == target:
            return True
    return False
```

In the best case, the value we're looking for happens to be at the first position `data[0]`, and the code returns after a single check.
In the worst case, the value we're looking for is at the last position `data[N-1]` or is not in the list at all, and we have to check every one of the `N` positions.
Put another way, the *best case* behavior of the function is constant (exactly one check), while the *worst case* behavior is linear ($N$ checks).  We can write the resulting runtime using a case distinction:

$T_"in" (N) = cases(
  a · 1 + b & bold("if") mono("data[0]" = "target"),
  a · 2 + b & bold("if") mono("data[1]" = "target"),
  "...",
  a · (N-1) + b & bold("if") mono("data[N-2]" = "target"),
  a · N + b & bold("if") mono("data[N-1]" = "target")
)$

We don't know the runtime exactly, as it is based on the computer and version of python we are using.  
However, we can model it, in general in terms of some upfront cost $b$ (e.g., for computing `N = len(data)`), and some additional cost $a$ for every time we go through the loop (e.g., for computing `data[i] == target`).
Since we don't know where the target is, exactly, 

Let's do a quick experiment.  
The code below is like our example above, but measures the time for one lookup at a time.  
Each point it prints out is the runtime of a single lookup as the `list` gets bigger and bigger.

```python
from random import randrange
from datetime import datetime

N = 100000
TRIALS = 400
STEP = int(N/TRIALS)

data = list()

for i in range(TRIALS):
    # Increase the list size by STEP
    for j in range(STEP):
        data += [i * STEP + j]
    start = datetime.now()
    # Measure how long it takes to look up a random element
    if randrange(i * STEP + STEP) in data:
        pass
    end = datetime.now()
    # Print out the total time in microseconds
    microseconds = (end - start).total_seconds() * 1000000
    print(f"{i}, {microseconds}")
```

#{
  let lin_pts = (
    (0, 4.0), (1, 4.0), (2, 1.0), (3, 5.0), (4, 3.0), (5, 9.0), (6, 12.0), (7, 2.0), (8, 5.0), (9, 15.0), (10, 2.0), (11, 12.0), (12, 22.0), (13, 3.0), (14, 19.0), (15, 24.0), (16, 28.0), (17, 14.0), (18, 10.0), (19, 7.0), (20, 4.0), (21, 24.0), (22, 11.0), (23, 34.0), (24, 43.0), (25, 35.0), (26, 5.0), (27, 30.0), (28, 44.0), (29, 22.0), (30, 51.0), (31, 49.0), (32, 14.0), (33, 48.0), (34, 23.0), (35, 3.0), (36, 39.0), (37, 3.0), (38, 50.0), (39, 17.0), (40, 37.0), (41, 26.0), (42, 24.0), (43, 47.0), (44, 71.0), (45, 52.0), (46, 55.0), (47, 33.0), (48, 50.0), (49, 87.0), (50, 7.0), (51, 67.0), (52, 67.0), (53, 5.0), (54, 41.0), (55, 8.0), (56, 92.0), (57, 53.0), (58, 9.0), (59, 55.0), (60, 92.0), (61, 27.0), (62, 104.0), (63, 81.0), (64, 63.0), (65, 18.0), (66, 108.0), (67, 113.0), (68, 10.0), (69, 31.0), (70, 34.0), (71, 4.0), (72, 127.0), (73, 25.0), (74, 10.0), (75, 75.0), (76, 115.0), (77, 125.0), (78, 83.0), (79, 46.0), (80, 5.0), (81, 135.0), (82, 26.0), (83, 70.0), (84, 91.0), (85, 74.0), (86, 115.0), (87, 47.0), (88, 4.0), (89, 81.0), (90, 71.0), (91, 75.0), (92, 115.0), (93, 23.0), (94, 9.0), (95, 51.0), (96, 70.0), (97, 97.0), (98, 4.0), (99, 32.0), (100, 111.0), (101, 93.0), (102, 98.0), (103, 177.0), (104, 4.0), (105, 79.0), (106, 5.0), (107, 111.0), (108, 18.0), (109, 81.0), (110, 121.0), (111, 82.0), (112, 63.0), (113, 45.0), (114, 101.0), (115, 75.0), (116, 49.0), (117, 128.0), (118, 79.0), (119, 93.0), (120, 100.0), (121, 43.0), (122, 10.0), (123, 87.0), (124, 46.0), (125, 77.0), (126, 152.0), (127, 47.0), (128, 220.0), (129, 35.0), (130, 198.0), (131, 100.0), (132, 265.0), (133, 195.0), (134, 104.0), (135, 177.0), (136, 70.0), (137, 130.0), (138, 219.0), (139, 40.0), (140, 81.0), (141, 42.0), (142, 113.0), (143, 20.0), (144, 164.0), (145, 228.0), (146, 49.0), (147, 62.0), (148, 196.0), (149, 157.0), (150, 139.0), (151, 226.0), (152, 56.0), (153, 49.0), (154, 252.0), (155, 78.0), (156, 40.0), (157, 170.0), (158, 142.0), (159, 73.0), (160, 86.0), (161, 6.0), (162, 256.0), (163, 278.0), (164, 256.0), (165, 19.0), (166, 43.0), (167, 17.0), (168, 269.0), (169, 200.0), (170, 245.0), (171, 259.0), (172, 154.0), (173, 173.0), (174, 86.0), (175, 50.0), (176, 268.0), (177, 293.0), (178, 178.0), (179, 13.0), (180, 257.0), (181, 262.0), (182, 265.0), (183, 253.00000000000003), (184, 51.0), (185, 285.0), (186, 87.0), (187, 241.0), (188, 91.0), (189, 55.0), (190, 149.0), (191, 352.0), (192, 2.0), (193, 235.0), (194, 152.0), (195, 294.0), (196, 106.0), (197, 14.0), (198, 131.0), (199, 221.0), (200, 127.0), (201, 340.0), (202, 369.0), (203, 170.0), (204, 376.0), (205, 69.0), (206, 131.0), (207, 62.0), (208, 96.0), (209, 257.0), (210, 55.0), (211, 98.0), (212, 344.0), (213, 360.0), (214, 305.0), (215, 45.0), (216, 290.0), (217, 150.0), (218, 183.0), (219, 198.0), (220, 184.0), (221, 141.0), (222, 64.0), (223, 355.0), (224, 283.0), (225, 2.0), (226, 55.0), (227, 62.0), (228, 247.0), (229, 117.0), (230, 147.0), (231, 358.0), (232, 194.0), (233, 358.0), (234, 248.0), (235, 331.0), (236, 413.0), (237, 86.0), (238, 213.0), (239, 338.0), (240, 365.0), (241, 387.0), (242, 115.0), (243, 40.0), (244, 153.0), (245, 412.0), (246, 292.0), (247, 245.0), (248, 86.0), (249, 317.0), (250, 125.0), (251, 367.0), (252, 323.0), (253, 62.0), (254, 41.0), (255, 351.0), (256, 123.00000000000001), (257, 68.0), (258, 318.0), (259, 394.0), (260, 427.0), (261, 262.0), (262, 22.0), (263, 283.0), (264, 229.0), (265, 428.0), (266, 344.0), (267, 157.0), (268, 459.0), (269, 433.0), (270, 46.0), (271, 360.0), (272, 295.0), (273, 308.0), (274, 367.0), (275, 46.0), (276, 155.0), (277, 54.0), (278, 454.0), (279, 474.0), (280, 424.0), (281, 367.0), (282, 363.0), (283, 406.0), (284, 353.0), (285, 240.0), (286, 3.0), (287, 350.0), (288, 76.0), (289, 144.0), (290, 342.0), (291, 298.0), (292, 242.0), (293, 98.0), (294, 157.0), (295, 154.0), (296, 112.0), (297, 376.0), (298, 189.0), (299, 510.00000000000006), (300, 354.0), (301, 328.0), (302, 160.0), (303, 277.0), (304, 3.0), (305, 522.0), (306, 172.0), (307, 501.99999999999994), (308, 29.0), (309, 92.0), (310, 506.00000000000006), (311, 400.0), (312, 535.0), (313, 64.0), (314, 492.99999999999994), (315, 154.0), (316, 37.0), (317, 385.0), (318, 433.0), (319, 200.0), (320, 455.0), (321, 506.99999999999994), (322, 67.0), (323, 117.0), (324, 352.0), (325, 33.0), (326, 13.0), (327, 358.0), (328, 416.0), (329, 274.0), (330, 292.0), (331, 171.0), (332, 479.0), (333, 16.0), (334, 422.0), (335, 446.0), (336, 382.0), (337, 112.0), (338, 111.0), (339, 210.0), (340, 510.99999999999994), (341, 578.0), (342, 258.0), (343, 264.0), (344, 545.0), (345, 348.0), (346, 72.0), (347, 106.0), (348, 607.0), (349, 606.0), (350, 370.0), (351, 225.0), (352, 213.0), (353, 216.0), (354, 418.0), (355, 508.0), (356, 157.0), (357, 380.0), (358, 503.0), (359, 364.0), (360, 54.0), (361, 193.0), (362, 410.0), (363, 477.0), (364, 18.0), (365, 606.0), (366, 565.0), (367, 643.0), (368, 266.0), (369, 54.0), (370, 80.0), (371, 445.0), (372, 54.0), (373, 441.0), (374, 260.0), (375, 185.0), (376, 200.0), (377, 227.0), (378, 52.0), (379, 403.0), (380, 540.0), (381, 423.0), (382, 194.0), (383, 163.0), (384, 402.0), (385, 3.0), (386, 75.0), (387, 368.0), (388, 29.0), (389, 594.0), (390, 69.0), (391, 450.0), (392, 628.0), (393, 653.0), (394, 44.0), (395, 669.0), (396, 451.0), (397, 218.0), (398, 35.0), (399, 506.00000000000006), 
  )
  let x_axis = axis(min: 0, max: 400, step: 40, location: "bottom", title: [Size of Input ($N$)])
  let y_axis = axis(min: 0, max: 1000, step: 100, location: "left", title: [Runtime ($T(N)$)])
  let lin_plt = graph_plot(
    plot(data: lin_pts, axes: (x_axis, y_axis)),
    (100%, 25%),
    stroke: (paint: red, thickness: 2pt),
    markings: [],
    caption: [Scaling the `list` lookup.]
  )
  lin_plt
} <list_lookup>

@list_lookup shows the output of one run of the code above.  
You can see that it looks a lot like a triangle.  
The *worst case* (top of the triangle) looks a lot like the *linear* complexity class ($Theta(N)$, or an angled line), but the *best case* (bottom of the triangle) looks a lot more like a flat line, or the *constant* complexity class ($Theta(1)$, or a flat line).  
The runtime is _at least_ constant, and _at most_ linear: We can *bound* the runtime of the function between two complexity classes.

== Big-$O$ and Big-$Omega$

We capture this intuition of bounded runtime by introducing two new concepts: Worst-case (upper, or Big-$O$) and Best-case (lower, or Big-$Omega$) bounds.   
To see these in practice, let's take the linear complexity class as an example:
#figure[
  #image("graphics/complexity-theta.svg", width:50%)
] 

We write $O(N)$ to mean the set of all mathematical functions that are *no worse than $Theta(N)$*.  This includes:
- all mathematical functions in $Theta(N)$ itself
- all mathematical functions in lesser (slower-growing) complexity classes (e.g., $Theta(1)$)
- any mathematical function that never grows faster than $O(N)$ (e.g., the runtime of each individual lookup in our Python example above)

The figure below illustrates $Theta(N)$ (the dotted region) and all lesser complexity classes.  Note the similarity to @list_lookup.

#figure[
  #image("graphics/complexity-bigo.svg", width:50%)
]

Similarly, we write $Omega(N)$ to mean the set of all mathematical functions that are *no better than $Theta(N)$*.  This includes:
- all functions in $Theta(N)$ itself
- all greater (faster-growing) complexity classes (e.g., $Theta(N^2)$), and anything in between.

#figure[
  #image("graphics/complexity-omega.svg", width:50%)
]

To summarize, we write:
- $f(N) in O(g(N))$ to say that $f(N)$ is in $Theta(g(N))$ or a lesser complexity class.
- $f(N) in Omega(g(N))$ to say that $f(N)$ is in $Theta(g(N))$ or a greater complexity class.

== Formalizing Big-$O$

Before we formalize our bounds, let's first figure out what we want out of that formalism.  

Let's start with the basic premise we outlined above: For a function $f(N)$ to be in the set $O(g(N))$, we want there to be some function in $Theta(g(N))$ that is always bigger than $f(N)$.

The first problem we run into with this formalism is that we haven't really defined what exactly $Theta(g(N))$ is yet, so we need to pin down something first.  Let's start with the same assumption we made earlier: we can scale $g(N)$ by any constant value without changing its complexity class.  Formally:

Formally: $forall c : c dot g(N) in Theta(g(N))$

That is, for any constant $c$ ($forall$ means 'for all'), the product $c dot g(N)$ is in $Theta(g(N))$ (remember that $in$ means is in).  This isn't meant to be all-inclusive: There are many more functions in $Theta(g(N))$, but this gives us a pretty good range of functions that, at least intuitively, belong in $g(N)$'s complexity class.

Now we have a basis for formalizing Big-$O$: We can say that $f(N) in O(g(N))$ if there is *some* multiple of $g(N)$ that is always bigger than $f(N)$.  Formally:

$exists c > 0, forall N : f(N) <= c dot g(N)$

That is, there exists ($exists$ means there exists) some positive constant $c$, such that for each value of $N$, the value of $f(N)$ is smaller than the corresponding value of $c dot g(N)$.

Let's look at some examples:

*Example:* $f(N) = 2N$ vs $g(N) = N$

Can we find a $c$ and show that for this $c$, for all values of $N$, the Big-$O$ inequality holds for $f$ and $g$?

- $f(N) <= c dot g(N)$
- $2N <= c dot N$
- $2 <= c$

We start with the basic inequality, substitute in the values of $f(N)$ and $g(N)$, and then divide both sides by $N$.
So, the inequality is always true for any value of $c >= 2$.  

*Example:* $f(N) = 100N^2$ vs $g(N) = N^2$

Can we find a $c$ and show that for this $c$, for all values of $N$, the Big-$O$ inequality holds for $f$ and $g$?

- $f(N) <= c dot g(N)$
- $100N^2 <= c dot N^2$
- $100 <= c$

We start with the basic inequality, substitute in the values of $f(N)$ and $g(N)$, and then divide both sides by $N$.
So, the inequality is always true for any value of $c >= 100$.  

*Example:* $f(N) = N$ vs $g(N) = N^2$

Can we find a $c$ and show that for this $c$, for all values of $N$, the Big-$O$ inequality holds for $f$ and $g$?

- $f(N) <= c dot g(N)$
- $N <= c dot N^2$
- $1 <= c dot N$

*Uh-oh!*  For $N = 0$, there is no possible value of $c$ that we can plug into that inequality to make it true ($0 dot c$ is never bigger than $1$ for any $c$).  

*Attempt 2*: So what went wrong?  Well, we mainly care about how $f(N)$ behaves for really big values of $N$.  In fact, for the example, for any $N >= 1$ (and $c >= 1$), the inequality is satisfied!  It's just that pesky $N = 0$!#footnote[
  Recall that we're only allowing non-negative input sizes (i.e., $N >= 0$), so negative values of $N$ aren't a problem. 
].

So, we need to add one more thing to the formalism: the idea that we only care about "big" values of N.  Of course, that leaves the question of how big is "big"?  Now, we could pick specific cutoff values, but any specific cutoff we picked would be entirely arbitrary.  So, instead, we just make the cutoff definition part of the proof: When proving that $f(N) in O(g(N))$, we just need to show that *some* cutoff exists, beyond which $f(N) <= c dot g(N)$.  *The formal definition of Big-$O$ is*:

$f(N) in O(g(N)) <=> exists c > 0, N_0 >= 0: forall N >= N_0 : f(N) <= c dot g(N)$

This is the same as our first attempt, with only one thing added: $N_0$.  In other words, $f(N) in O(g(N))$ if we can pick some cutoff value ($exists N_0 >= 0$) so that for every bigger value of $N$ ($N >= N_0$), $f(N)$ is smaller than $c dot g(N)$.

=== Proving a function has a specific Big-$O$ bound

To show that a mathematical function is *in* $O(g(N))$, we need to find a $c$ and an $N_0$ for which we can prove the Big-$O$ inequality.  A generally useful strategy is:

1. Write out the Big-O inequality
2. "plug in" the values of $f(N)$ and $g(N)$
3. "Solve for" $c$, putting it on one side of the inequality, with everything else on the other side.
4. Try a safe default of $N_0 = 1$.  
5. Use the $A <= B$ and $B <= C$ imply $A <= C$ trick (transitivity of inequality) to replace any term involving $N$ with $N_0$
5. Use the resulting inequality to find a lower bound on $c$

Continuing the above example:

- $f(N) <= c dot g(N)$
- $N <= c dot N^2$
- $1/N <= c$

For that last step, we have $N_0 <= N$, or $1 <= N$, so dividing both sides by $N$, we get $1/N <= 1$.  So, if we pick $1 <= c$, then $1/N <= 1 <= c$, and $1/N <= c$.

=== Proving a function does not have a specific Big-$O$ bound

To show that a mathematical function is *not in* $O(g(N))$, we need to prove that there can be *no* $c$ or $N_0$ for which we can prove the Big-$O$ inequality.  A generally useful strategy is:

1. Write out the Big-O inequality
2. "plug in" the values of $f(N)$ and $g(N)$
3. "Solve for" $c$, putting it on one side of the inequality, with everything else on the other side.
4. Simplify the equation on the opposite side and show that it is strictly growing.  Generally, this means that the right-hand-side is in a complexity class at least $N$.

Flipping the above example:

- $f(N) <= c dot g(N)$
- $N^2 <= c dot N$
- $N <= c$

$N$ is strictly growing: for bigger values of $N$, it gets bigger.  There is no constant that can upper bound the mathematical function $N$.  

/////////////////////////////////////////////
== Formalizing Big-$Omega$

Now that we've formalized Big-$O$ (the upper bound), we can formalize Big-$Omega$ (the lower bound) in exactly the same way: 

$f(N) in O(g(N)) <=> exists c > 0, N_0 >= 0: forall N >= N_0 : f(N) >= c dot g(N)$

The only difference is the direction of the inequality: To prove that a function exists in Big-$Omega$, we need to show that $f(N)$ is bigger than some constant multiple of $g(N)$.  


/////////////////////////////////////////////
== Formalizing Big-$Theta$

Although we started with an intuition for Big-$Theta$, we haven't yet formalized it.  To understand why, let's take a look at the following runtime:

$T(N) = 10N + "rand"(10)$

Here $"rand"(10)$ means a randomly generated number between 0 and 10 for each call.  
If the function were *just* $10N$, we'd be fine in using our intuitive definition of $Theta(N)$ being all multiples of $N$.  
However, this function still "behaves like" $g(N) = N$... just with a little random noise added in.  
For big values of $N$ (e.g., $10^10$), the random noise is barely perceptible.  
Although we can't say that $T(N)$ is *equal to* some multiple $c dot N$, we can say that it is *close to* that multiple (in fact, it's always between $10N$ and $10N + 10$).
In other words, we can bound it from both above and below!

Let's try proving this with the tricks we developed for Big-$O$ and Big-$Omega$:

- $T(N) <= c_"upper" dot N$
- $10N + "rand"(10) <= c_"upper" dot N$ (plug in $T(N)$)
- $10 + ("rand"(10))/N <= c_"upper"$ (divide by $N$)

Looking at this formula, we can make a few quick observations.  First, by definition $"rand"(10)$ is never bigger than $10$.  
Second, if $N_0 = 1$, $1/N$ can never be bigger than $1$.  
In other words, $("rand"(10))/N$ can not be bigger than 10.
Let's prove that to ourselves.

Taking the default $N_0 =1$ we get:
- $1 <= N$ (plug in $N_0$)
- $10 <= 10N$ (multiply by $10$)
- $"rand"(10) <= 10 <= 10N$ (transitivity with $"rand"(10) <= 10$)
- $("rand"(10))/N <= 10$ (divide by $N$)
- $10 + ("rand"(10))/N <= 10+10$ (add $10$)

So, if we pick $c_"upper" >= 20$, we can show (again, by transitivity):

$10 + ("rand"(10))/N <= c_"upper"$

Which gets us $T(N) <= c_"upper" dot N$ for all $N > N_0$.

Now let's try proving a lower (Big-$Omega$) bound:

- $T(N) >= c_"lower" dot N$
- $10N + "rand"(10) >= c_"lower" dot N$ (plug in $T(N)$)
- $10 + ("rand"(10))/N >= c_"lower"$ (divide by $N$)
- $10 >= c_"lower"$ (By transitivity: $10 >= 10 + ("rand"(10))/N$)

This inequality holds for any $10 >= c_"lower" > 0$ (recall that $c$ has to be strictly bigger than zero).

So, we've shown that $T(N) in O(N)$ *and* $T(N) in Omega(N)$.  
The new thing is that we've shown that the upper and lower bounds *are the same*.
That is, we've shown that $T(N) in O(g(N))$ and $T(N) in Omega(g(N))$ *for the same mathematical function $g$*.  
If we can prove that an upper and lower bound for some mathematical function $f(N)$ that is the same mathematical function $g(N)$, we say that $f(N)$ and $g(N)$ are in the same complexity class.  Formally, $f(N) in Theta(g(N))$ if and only if $f(N) in O(g(N))$ *and* $f(N) in Omega(g(N))$. 

== Tight Bounds

In the example above, we said that $"rand"(10) <= 10$.  
We could have just as easily said that $"rand"(10) <= 100$.  
The latter inequality is just as true, but somehow less satisfying; yes, the random number will always be less than 100, but we can come up with a "tighter" bound (i.e., $10$).

Similarly Big-$O$ and Big-$Omega$ are bounds.  
We can say that $N in O(N^2)$ (i.e., $N$ is no worse than $N^2$).  
On the other hand, this bound is just as unsatisfying as $"rand"(10) <= 100$, we can do better.

If it is not possible to obtain a better Big-$O$ or Big-$Omega$ bound, we say that the bound is *tight*.  For example:

- $10N^2 in O(N^2)$ and $10N^2 in Omega(N^2)$ are tight bounds.
- $10N^2 in O(2^N)$ is correct, but *not* a tight bound.
- $10N^2 in Omega(N)$ is correct, but *not* a tight bound.

Note that since we define Big-$Theta$ as the intersection of Big-$O$ and Big-$Omega$, all Big-$Theta$ bounds are, by definition tight.
As a result, we sometimes call Big-$Theta$ bounds "tight bounds".

== Which Variable?

We define asymptotic complexity bounds in terms of *some* variable, usually the size of the collection $N$.  However, it's also possible to use other bounds.  For example, consider the function, which computes factorial:
```java
public int factorial(int idx)
{
  if(idx <= 0){ return 0; }
  int result = 1;
  for(i = 1; i <= idx; i++) { result *= i; }
  return result
}
```
The runtime of this loop depends on the input parameter `idx`, performing one math operation for each integer between 1 and `idx`.
So, we could give the runtime as $Theta("idx")$.

When the choice of variable is implicit, it's customary to just use $N$, but this is not always the case.
For example, when we talk about sequences and lists, the size of the sequence/list is most frequently the variable of interest.
However, there might be other parameters of interest:
- If we're searching the list for a specific element, what position to we find the element at?
- If we're looking through a linked list for a specific element, what index are we looking for?
- If we have two or more lists (e.g., in an Edge List data structure), each list may have a different size.

In these cases, and others like them, it's important to be clear about which variable you're talking about.  

=== Related Variables

When using multiple variables, we can often bound one variable in terms of another.  Examples include:

- If we're looking through a linked list for the element at a specific index, the index must be somewhere in the range $[0, N)$, where $N$ is the size of the list.  As a result, we can can always replace $O("index")$ with $O(N)$ and $Omega("index")$ with $Omega(1)$, since `index` is bounded from above by a linear function of $N$ and from below by a constant. 

- The number of edges in a graph can not be more than the square of the number of vertices.  As a result, we can always replace $O("edges")$ with $O("vertices"^2)$ and $Omega("edges")$ with $Omega(1)$.

*Note*: Even though $O("index")$ in the first example may be a tighter bound than $O(N)$, the $O(N)$ bound is still tight *in terms of $N$*: We can not obtain a tighter bound that is a function only of $N$.

== Summary

We defined three ways of describing runtimes (or any other mathematical function):

- Big-$O$: The worst-case complexity: 
  - $T(N) in O(g(N))$ means that the runtime $T(N)$ scales *no worse than* the complexity class of $g(N)$
- Big-$Omega$: The best-case complexity
  - $T(N) in Omega(g(N))$ means that the runtime $T(N)$ scales *no better than* the complexity class of $g(N)$
- Big-$Theta$: The tight complexity
  - $T(N) in Theta(g(N))$ means that the runtime $T(N)$ scales *exactly as* the complexity class of $g(N)$

We'll introduce amortized and expected runtime bounds later on in the book; Since these bounds are given without qualifiers, and so are sometimes called the *Unqualified* runtimes.

=== Formal Definitions

For any two functions $f(N)$ and $g(N)$ we say that:

- $f(N) in O(g(N))$ if and only if $exists c > 0, N_0 >= 0 : forall N > N_0 : f(N) <= c dot g(N)$
- $f(N) in Omega(g(N))$ if and only if $exists c > 0, N_0 >= 0 : forall N > N_0 : f(N) >= c dot g(N)$
- $f(N) in Theta(g(N))$ if and only if $f(N) in O(g(N))$ and $f(N) in Omega(g(N))$ 

Note that a simple $Theta(g(N))$ may not exist for a given $f(N)$, specifically when the tight Big-$O$ and Big-$Omega$ bounds are different.

=== Interpreting Code

In general#footnote[
  All of these are lies.  The cost of basic arithmetic is often $O(log N)$, array access runtimes are affected by caching (we'll address that later in the book), and string operations are proportional to the length of the string.  However, these are all useful simplifications for now.
], we will assume that most simple operations: basic arithmetic, array accesses, variable access, string operations, and most other things that aren't function calls will all be $Theta(1)$.

Other operations are combined as follows...

*Sequences of instructions*
```java
{
  op1;
  op2;
  op3;
}
...
```
Sum up the runtimes.
$T(N) = T_("op1")(N) + T_("op2")(N) + T_("op3")(N) + ...$

*Loops*
```java
for(i = min; i < max; i++)
{
  block;
}
```
Sum up the runtimes for each iteration.  Make sure to consider the effect of the loop variable on the runtime of the inner block.
$T(N) = sum_(i="min")^"max" T_("block")(N, i)$

As a simple shorthand, if (i) the number of iterations is predictable (e.g., if the loop iterates $N$ times) and (ii) the complexity of the loop body is independent of which iteration the loop is on (i.e., $i$ does not appear in the loop body), you can just multiply the complexity of the loop by the number of iterations.

*Conditionals*
```java
if(condition){
  block1;
} else {
  block2;
}
```
The total runtime is the cost of either `block1` or `block2`, depending on the outcome of `condition`.  Make sure to add the cost of evaluating `condition`.

$T(N) = T_"condition"(N) + cases(
  T_("block1")(N) "if" "condition is true",
  T_("block2")(N) "otherwise"
)$

The use of a cases block is especially important here, since if $T_("block1")(N)$ and $T_("block2")(N)$ belong to different asymptotic complexity classes, the overall block of code belongs to multiple classes (and thus does not have a simple $Theta$ bound).


=== Simple Complexity Classes

We will refer to the following specific complexity classes:
- *Constant*: $Theta (1)$
- *Logarithmic*: $Theta (log N)$
- *Linear*: $Theta (N)$
- *Loglinear*: $Theta (N log N)$
- *Quadratic*: $Theta (N^2)$
- *Cubic*: $Theta (N^3)$
- *Exponential* $Theta (2^N)$

These complexity classes are listed in order.  

=== Dominant Terms

In general, any function that is a sum of simpler functions will be dominated by one of its terms.  That is, for a polynomial:

$f(N) = f_1(N) + f_2(N) + ... + f_k(N)$

The asymptotic complexity of $f(N)$ (i.e., its Big-$O$ and Big-$Omega$ bounds, and its Big-$Theta$ bound, if it exists) will be the *greatest* complexity of any individual term $f_i(N)$#footnote[
  Note that this is only true when $k$ is fixed.  If the number of polynomial terms depends on $N$, we need to consider the full summation.
].

*Remember*: If the dominant term in a polynomial belongs to a single simple complexity class, then the entire polynomial belongs to this complexity class, and the Big-$O$, Big-$Omega$, and Big-$Theta$ bounds are all the same.

=== Multiclass Asymptotics

A mathematical function may belong to multiple simple classes, depending on an unpredictable input or the state of a data structure.  
Generally, multiclass functions arise in one of two situations.
First, the branches of a conditional may have different complexity classes:

$T(N) = cases(
  T_(1)(N) "if" "a thing is true"
  T_(2)(N) "otherwise"
)$

If $T_(1)(N)$ and $T_(2)(N)$ belong to different complexity classes, then $T(N)$ as a whole belongs to *either* class. 
In this case, we can only bound the runtime $T(N)$.
Specifically, if $Theta(T_(1)(N)) > Theta(T_(2)(N))$, then:
- $T(N) in Omega(T_(2)(N))$
- $T(N) in O(T_(1)(N))$.

Second, the number of iterations of a loop may depend on an input that is bounded by multiple complexity classes.  For example, if $"idx" in [1, N]$ (`idx` is somewhere between $1$ and $N$, inclusive), then the following code does not belong to a single complexity class:
```java
for(i = 0; i < idx; i++){ do_a_thing(); }
```
In this case, we can bound the runtime based on `idx`.  Assuming `do_a_thing()` is $Theta(1)$, then $T(N) in Theta("idx")$.  However, since we can't bound `idx` in terms of $N$, then we can only provide weaker bounds with respect to $N$:
- $T(N) in Omega(1)$
- $T(N) in O(N)$

Remember that if we can not obtain identical, tight upper and lower bounds in terms of a given input variable, there is no simple $Theta$-bound in terms of that variable.