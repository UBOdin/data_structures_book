#import "@preview/cetz:0.2.2"

= The Sequence and List ADTs

Now that we have the right language to talk about algorithm runtimes (asymptotic complexity), we can start talking about actual data structures that these algorithms can use.
Since the choice of data structure can have a huge impact on the complexity of an algorithm, it's often useful to group specific data structures together by the roles that they can fulfill in an algorithm.
We refer to such a grouping as an *abstract data type* or ADT.  

== What is an ADT?

An ADT is, informally, a contract that states what we can expect from a data structure. 
Take, for example, a Java `interface` like the following:

```java
public interface Narf<T>
{
  public void foo(T poit, int zort);
  public T bar(int zort);
  public int baz();
}
```

This `interface` states that any class that implements `Narf` must provide `foo`, `bar`, and `baz` methods, with arguments and return values as listed above.
This is not especially helpful, since it doesn't give us any idea of what these methods are supposed to do.
Contrast `Narf` with the following interface:
```java
public interface MutableSequence<T>
{
  public void set(int index, T element);
  public T get(int index);
  public int size();
}
```
`Sequence` is semantically identical to `Narf`, but far more helpful.
Just by reading the names of these methods, you get some idea of what each method does, and how it interacts with the state represented by a `Sequence`. 
You can build a mental model of what a Sequence is from these names.

An Abstract Data Type is defined in three parts:
1. Formal rules for the type of data being stored (a data type).
2. One or more operations for accessing or modifying that state (an interface).
3. Any other rules for the state (constraints).

For most ADTs discussed in this book, the ADT models sort of collection of elements.  The difference between them is how you're allowed to interact with the data.

A data structure is a *specific* strategy for organizing the data modeled by an ADT.  We say that the data structure implements (or conforms to) an ADT if:
1. The data structure stores the same type of data as the ADT
2. Each of the operations required by the ADT can be implemented on the data structure
3. We can prove that the operation implementation is guaranteed to respect the rules for the ADT's state.

== The Sequence ADT

A very common example of an ADT is a sequence.  Examples include: 

- The English alphabet ('A', 'B', ..., 'Z')
- The Fibonacci Sequence (1, 1, 2, 3, 5, 8, ...)
- An arbitrary collection of numbers (42, 19, 86, 23, 19)

What are some commonalities in these examples?

- Every sequence is a collection of elements of some type `T` (integer, character, etc...)
- The same element may appear multiple times.
- Every sequence has a size (that may be infinite).  We often write $N$ to represent this size.
- Every element (or occurrence of an element) is assigned to an index: $0 <= "index" < N$.
- Every index in the range $0 <= "index" < N$ has exactly one element assigned to it.

What kind of operations can we do on a sequence#footnote[
  Note: Although several of the ADTs and data structures we'll present throughout this book correspond to interfaces and classes from the Java standard library, `Sequence` is *not* one of them.  However, it serves as a useful simplification of the `List` interface from the Java standard library that we *will* encounter later on.
]?
```java
public interface Sequence<T>
{
  /** Retrieve the element at a specific index or throw an IndexOutOfBounds exception if index < 0 or index >= size() */
  public T get(int index);
  /** Obtain the size of the sequence */
  public int size();
}
```

To recap, we have a mental model, and a series of rules:
- A sequence contains $N$ elements.
- Every index $i$ from $0 <= i < N$ identifies exactly one element (no more, no less).

The `get` method returns the element identified by `index`, and the `size` method returns $N$.

=== Sequences by Rule
For some of the example sequences listed above, we can implement this interface directly.  For example, for the English alphabet:
```java
public class Alphabet implements Sequence<Character>
{
  /** Retrieve the element at a specific index */
  public Character get(int index)
  {
    if(index == 0){ return 'A'; }
    if(index == 1){ return 'B'; }
    /* ... */
    if(index == 25){ return 'Z'; }
    throw IndexOutOfBoundsException("No character at index "+index)
  }
  /** Obtain the size of the sequence */
  public int size() 
  { return 26; }
}
```

Is `Alphabet` a sequence?  Yes!  It implements the two operations of a sequence:
- `size`: There are $N = 26$ elements.
- `get`: Every element from $0 <= i < 26$ is assigned exactly one value.

Similarly, we can implement the Fibonacci sequence according to the Fibonacci rule $"Fib"(x) = "Fib"(x-1) + "Fib"(x-2)$:
```java
public class Fibonacci implements Sequence<Int>
{
  /** Retrieve the element at a specific index */
  public Int get(int index)
  {
    if(index < 0){ 
      throw IndexOutOfBoundsException("Invalid index: "+index)
    }
    if(index == 0){ return 0; }
    if(index == 1){ return 1; }
    return get(index-1) + get(index-2);
  }
  /** Obtain the size of the sequence */
  public int size() 
  { return INFINITY; }
}
```
Is `Fibonacci` a sequence?  Yes!  It implements the two operations of a sequence:
- `size`: There are $N = infinity$ elements.
- `get`: Every element from $0 <= i < infinity$ is assigned exactly one value derived from the value of preceding elements of the sequence as $"Fib"(i-1) + "Fib"(i-2)$#footnote[
  If you're paying attention, you might notice that we're waving our hands a bit with this proof.  Specifically, how do we convince ourselves that there is *exactly* one value at index $i$, and not zero (can $"Fib"(i)$ return `IndexOutOfBoundsException` for $i >= 0$), or more than 1 (will $"Fib"(i)$ always return the same value)?  Proving either of these will require a technique called *induction* that we'll come back to later in the book.
].

=== Arbitrary Sequences

Often, however, we want to represent an sequence of *arbitrary* elements.
We won't have simple rule we can use to translate the index into a value.
Instead, we need to store the elements somewhere if we want to be able to retrieve them.  
The easiest way to store a sequence, when we know the size of the sequence up front is called an *array*.

Let's take a brief diversion into the guts of a computer.  
Most computers store data in a component called RAM#footnote[
  What you're about to read is called the RAM model of computing.  It is a blatant lie: The way computers store and access data involves multiple levels of caches, disks, and networked storage.  However, the RAM model is quite useful as a starting point.  We'll walk the lie back when we introduce the External Memory model towards the end of the book.
].  
You can think of RAM as being a ginormous sequence of bits (0s and 1s).  
Folks who work on computers have, over the course of many years, come to agree on some common guidelines for how to represent other types of information in bit sequences.  
The details of most of these guidelines (e.g., Little- vs Big-endian, Floating-point encodings, Characters and strings, etc...) are usually covered in a computer organization or computer architecture class.  However, there's a few details that are really helpful for us to review.

First, we group every 8 bits into a 'byte'.  A byte can take on $2^8 = 256$ different possible values.  It turns out that this is enough to represent most simple printable characters.  Similarly, bytes can be grouped together into 2, 4, or 8 bytes, allowing us to represent more complex data like emoji, larger integers, negative numbers, or floating point numbers.  Strings are a special case that we'll come back to in a moment.

For example, the ASCII character encoding#footnote[
  The American Standard Code for Information Interchange forms the basis for most modern character 'encodings'.  More recent encodings (e.g. UTF-8, UTF-16) extend the ASCII code, and sometimes require more than one byte per printable character.
] forms the basis for most character representations we use today, and assigns each of the letters of the English alphabet (upper and lower case, and a few other symbols) to a particular sequence of 8 bits (one byte).

Most modern computers are 'byte-addressable', meaning that every byte is given its own address.  The first byte is at address 0000, followed by address 0001, then address 0002, and so forth.  If we want to represent a value that takes up multiple bytes (e.g., a 4-byte integer), we typically point at the address of the first byte of the value.

=== Arrays

Let's say we have a series of values we want to store.  For example, let's say we wanted to store the sequence 'H', 'e', 'l', 'l', 'o'.  
The ASCII code for 'H' is hexadecimal 0x48, or binary 01001000.  We could store that value at one specific address in RAM.  The value takes up one byte of space, so we could put the second value in the sequence 'e' (hexadecimal 0x65, or binary 10101001) in the byte right after it.  We then similarly store the remaining three elements of the sequence, each in the byte after the previous one.
#figure(
  image("graphics/lists-memory-array.svg", width: 50%),
  caption: [
    RAM (1) can be viewed as a sequence of bits (2).  We can break these bits up into fixed size chunks (3).  Each fixed size chunk can be used to identify some value, like for example a character (4).  Thus a sequence of characters can be stored somewhere in RAM (5).
  ]
)

This arrangement, where we just concatenate elements side by side in memory is really useful, _if each element always uses up the same number of bytes_.
Specifically, if we want to retrieve the $i$th element of the sequence, we need only two things: 
1. The position of the 0th element in RAM (Let's call this $S$)
2. The number of bytes that each element takes up (Let's call this $E$).

The the $i$th element's $E$ bytes will always start at byte $S + i dot E$ (with 0 being the first element).

==== Array Runtime Analysis

In order to retrieve the $i$'th element of an array, we need one multiplication, and one addition.  
This is true regardless of how big the array is.  
If the array has a thousand, or a million, or a trillion elements, we can still obtain the address of the $i$th element with one multiplication and one addition.  Given the address, we can then obtain the value in a single access to memory.
In other words, the cost of retrieving an element from an array is constant (i.e., $Theta(1)$)#footnote[
  If you're paying close attention, you might note that we still need to retrieve $E$ bytes, and so technically the cost of an array access is $Theta(E)$.  However, we're mainly interested in how runtime scales with the size of the collection, as $E$ is fixed upfront, and usually very small.  So, more precisely, *with respect to $N$*, the cost of retrieving an element from an array is $Theta(1)$.
  The even more attentive reader might be aware of things like caches, which as previously mentioned, we're going to ignore for now.
].

==== Side Note: Memory Allocation

Most operating systems provide a way to allocate contiguous regions of memory (in C, this operation is called `malloc`, in Java it is called `new`). 
Eventually, when the data is no longer necessary (C's `free` operation, or based on Java's automatic 'garbage collector'), the allocated memory is returned to the general pool of 'free' memory.
We will assume that both allocating and freeing memory are constant-time ($Theta(1)$) operations#footnote[
  Again, this is a lie.  Depending on the operating system's implementation (e.g., if it allocates pages lazily or not), allocating memory may require linear time in the size of the allocation, or non-constant (e.g., logarithmic or linear) time in the number of preceding allocations.  Nevertheless, for the rest of the book, we'll treat it as being constant
]

It's important to note that once memory is allocated, it has a fixed size.  
It is not generally possible to simply resize a previously allocated chunk of memory, since that memory is located at a specific position in RAM, and it is possible that the space immediately following the array may already be in-use#footnote[
  C provides a `realloc` operation that opportunistically _tries_ to extend an allocated chunk of memory if space exists for it.  However, if this is not possible, the entire allocation will be copied byte-for-byte to a new position in memory where space does exist.  As we'll emphasize shortly, copying an array is a linear ($Theta(N)$) operation.
].

==== Arrays In Java

Java provides a convenient shorthand for creating and accessing arrays using square brackets.  To instantiate an array, use `new`:
```java
int[] myArray = new int[100];
```
Note that the type of an integer array is `int[]`#footnote[
  Java sort of allows you to store variable size objects in an array.  For example, `String[]` is a valid array type.  The trick to this is that Java allocates the actual string _somewhere else in RAM_ called the heap.  What it stores in the actual array is the address of the string (also called a pointer).
], and the number of elements in the array must be specified upfront (`100` in the example above).  To access an element of an array use `array[index]`.
```java
myArray[10] = 29;
int myValue = myArray[10];
assert(myValue == 29);
```

Java arrays are *bounds-checked*.  
That is, Java stores the size of the array as part of the array itself. 
The array actually starts 4 bytes after the official address of the array; these bytes are used to store the size of the array.
Whenever you access an array element, Java checks to make sure that the index is greater than or equal to zero and less than the size.
If not, it throws an `IndexOutOfBounds` exception otherwise.
As a convenient benefit, bounds checking means we can get the array size from Java.  
```java
int size = myArray.size
assert(size == 100)
```
Since the size is stored at a known location, we can always retrieve it in constant ($O(1)$) time.

To prove to ourselves that the `Array` implements the `Sequence` ADT, we can implement its methods:
```java
public class ArraySequence<T> implements Sequence<T>
{
  T[] data;

  public ArraySequence(T[] data){ this.data = data; }
  public T get(int index) { return data[index]; }
  public int size() { return data.size; }
}
```

The `ArraySequence`, initialized by an array, follows the rules for a `Sequence`:
- `size`: There are $N = $`data.size` elements in the array
- `get`: The `i`th element of the sequence is `data[i]`.  


=== Mutable Sequences

The Fibonacci sequence and the English alphabet are examples of *immutable* sequences.  
Immutable sequences are pre-defined and can not be changed; We can't arbitrarily decide that the 10th Fibonacci number should instead be 3.
However, if the sequence is given explicitly (e.g., as an array), then it's physically possible to just modify the bytes in the array to a new value.  
To accommodate such edits, we can make our `Sequence` ADT a little more general by adding a way to modify its contents.  
We'll call the resulting ADT a `MutableSequence`#footnote[
  Note: Like `Sequence`, the `MutableSequence` is not a native part of Java.  Its role is subsumed by `List`, which we'll discuss shortly.
].

```java
public interface MutableSequence<T> extends Sequence<T>
{
  public void set(int index, T element)
}
```

The `extends` keyword in java can be used to indicate that an interface takes in all of the methods of the extended interface, and potentially adds more of its own.  In this case `MutableSequence` has all of the methods of `Sequence`, plus its own `set` method.

A Mutable Sequence introduces one new rule:
- After we call `set(i, value)` with a valid index (i.e., $0 <= i < N$), every following call to `get(i)` for the same index will return the `value` passed to set (until the next time index `i` is set).

==== Mutable Array

To prove to ourselves that the array implements the `MutableSequence` ADT, we can implement its methods:
```java
public class MutableArraySequence<T> implements MutableSequence<T>
{
  T[] data;

  public ArraySequence(int size){ this.data = new T[size]; }
  public void set(int index, T element) { data[index] = value; }
  public T get(int index) { return data[index]; }
  public int size() { return data.size; }
}
```

As before, we can show that the array satisfies the rules on `get` and `size`, leaving the new rule:
- `set`: Calling set overwrites the array element at `data[index]` with value, which is the value returned by `get(index)`.

=== Array Summary

Observe that each of the three `MutableSequence` methods are implemented in a single, primitive operation.  Thus:

- `get`: Retrieving an element of an Array (i.e., `array[index]`) is $Theta(1)$
- `set`: Updating an element of an array (i.e., `array[index] = ...`) is $Theta(1)$
- `size`: Retrieving the array's size (i.e., `array.size`) is $Theta(1)$

Recall that `size` accesses a pre-computed value, stored with the array in Java.

////////////////////////////////////////////
== The List ADT

Although we can change the individual elements of an array, once it's allocated, the size of the array is fixed.  
This is reflected in the `MutableSequence` ADT, which does not provide a way to change the sequence's size.
Let's design our next ADT by considering how we might want to change an array's size:

- Inserting a new element at a specific position
- Removing an existing element at a specific position 

It's also useful to treat inserting at/removing from the front and end of the sequence as special cases, since these are both particularly common operations.

We can summarize these operations in the `List` ADT#footnote[
  See Java's #link("https://docs.oracle.com/javase/8/docs/api/java/util/List.html")[List interface] for the full list of operations supported on `List`s.  Most of these operations are so-called syntactic sugar on top of these basic operations, offering cleaner code, but no new functionality.
]:

```java
public interface List<T> extends MutableSequence<T>
{
  /** Append an element to the end of a list */
  public void add(T element);
  /** Insert an element at an arbitrary position */
  public void add(int index, T element);
  /** Remove an element at a specific index */
  public void remove(int index);
  
  // ... and more operations that are not relevant to us for now.
}
```

`List` brings with it a new set of rules:
- After calling `add(index, element)` with a valid $0 <= "index" <= N$ (note that $N$ is an allowable index):
    - Every element previously at an index $i >= "index"$ will be moved to index $i+1$
    - The value `element` will be the new element at index $"index"$,
    - `size()` will increase by 1.
- After calling `remove(index)` with a valid $0 <= "index" < N$:
    - Every element previously at an index $i > "index"$ will be moved to index $i-1$
    - The value previously at index $"index"$ will be removed
    - `size()` will decrease by 1.

Note that calling `add(element)` is the same as calling `add(element, size())`.


=== A simple Array as a List

We can still use `Array`s to implement the `List` ADT.
However, recall that it's not (generally) possible to resize a chunk of memory once it's been allocated.
Since we can't change the size of an `Array` once it's allocated#footnote[
  Again, the C language has a method called `realloc` that can *sometimes* change the size of an array... if you're lucky and the allocator happens to have some free space right after the array.
  However, in this book we try to avoid relying purely on unconstrained luck.
], we'll need to allocate an entirely new array to store the updated list.
Once we allocate the new array, we'll need to copy over everything in our original array to the new array.

```java
public class SimpleArrayAsList<T> extends MutableArraySequence implements List<T>
{
  // data, get, set, size() inherited from MutableArraySequence

  public void add(T element){ add(size(), element); }
  public void add(int index, T element)
  {
    // Skipped: Check that index is in-bounds.
    T[] newData = new data[size() + 1];
    for(i = 0; i < newData.length; i++){
      if(i < index){ newData[i] = data[i]; }
      else if(i == index){ newData[i] = element; }
      else { newData[i] = data[i-1]; }
    }
    data = newData;
  }
  public void remove(int index)
  {
    // Skipped: Check that index is in-bounds.
    T[] newData = new data[size() - 1];
    for(i = 0; i < newData.length; i++){
      if(i < index){ newData[i] = data[i]; }
      else { newData[i] = data[i+1]; }
    }
  }
}
```

Does this satisfy our rules?
- `add`: `newData` is one larger, elements at positions `index` and above are shifted right by one position, and `element` is inserted at position `index`.
- `remove`: `newData` is one smaller, and elements at positions `index` and above are shifted left by one position. 


Let's look at the runtime of the `add` method:
- We'll assume that memory allocation is constant-time ($Theta(1)$)#footnote[
  Lies!  Lies and trickery!  Memory allocation may require zeroing pages, multiple calls into the kernel, page faults, and a whole mess of other nonsense that scale with the size of the memory allocated.  Still, especially for our purposes here, it's usually safe to assume that the runtime of memory allocation is a bounded constant.
].
- We already said that array changes and math operations are constant-time ($Theta(1)$)

So, we can view the the `add` method as
```java
public void add(int index, T element)
{
  /* Theta(1) */
  for(i = 0; i < newData.size; i++)
  {
    if(/* Theta(1) */){ /* Theta(1) */ }
    else if(/* Theta(1) */){ /* Theta(1) */ }
    else { /* Theta(1) */ }
  }
}
```

Since every branch of the `if` inside the loop is the same, we can simplify the loop body to just $Theta(1)$.

Recalling how we use $Theta$ bounds in an arithmetic expression, we can rewrite the runtime and simplify it as:

- $T_"add"(N) = Theta(1) + sum_(i = 0)^"newData.size" Theta(1)$
- $ = Theta(1) + sum_(i = 0)^(N+1) Theta(1)$ (`newData` is one bigger than the original $N$)
- $ = Theta(1) + (N+2) dot Theta(1)$ (Plugging in the formula for summation of a constant)
- $ = Theta(1+N+2)$ (Merging $Theta$s)
- $ = Theta(N)$ (Dominant term)

If you analyze the runtime of the `remove` method similarly, you'll likewise get $Theta(N)$.

== Linked Lists

$Theta(N)$ is not a particularly good runtime for simple "building block" operations like `add` and `remove`.  
Since these will be called in loops, the `Array` data structure is not ideal for situations where a `List` is required.

The main difficulty with the `Array` is that the entire list is stored in the same memory allocation.  A single chunk of memory holds all elements in the list.
So, instead of allocating one chunk for the entire list, we can go to the opposite extreme and give each element its own chunk.

Giving each element its own chunk of memory means that we can allocate (or free) space for new elements without having to copy existing elements around.
However, it also means that the elements of the list are scattered throughout RAM.
If we want to be able to find the $i$th element of the list (which we need to do to implement `get`), we need some way to keep track of where the elements are stored.
One approach would be to keep a list of all $N$ addresses somewhere, but this brings us back to our original problem: we need to be able to store a variable-size list of $N$ elements.

Another approach is to use the chunks of memory as part of our lookup strategy: We can have each chunk of memory that we allocate store the address of (i.e., a pointer to) the *next* element in the list.  
That way, we only need to keep track of a single address: the position of the *first* element of the list (also called the list head).
The resulting data structure is called a linked list.
@linked_list_vs_array contrasts the linked list approach with an `Array`.

#figure(
  image("graphics/lists-memory-linkedlist.svg", width: 50%),
  caption: [
    Instead of allocating a fixed unit of memory like an array, a linked list consists of chunks of memory scattered throughout RAM.  Each element gets one chunk that has a pointer to the next (and/or previous) element in the sequence.
  ]
) <linked_list_vs_array>

=== Side Note: How Java uses Memory

Java represents chunks of memory as classes, so we can implement a linked list by defining a new class that contains a value, and a reference to the next node on the list.

It's important here to take a step back and think about how Java represents chunks of memory.  Specifically, primitive values (`int`, `long`, `float`, `double`, `byte`, and `char`) are stored *by value*.  This means that if you have a variable with type `long`, that variable directly stores a number.  
If you assign the value to a new variable, the new variable stores a *copy* of the number.
```java
long x = 12;
long y = x;
x = x + 5;
System.out.println(x); // prints 17
System.out.println(y); // prints 12
```

On the other hand, objects (anything that extends `Object`) and arrays are stored *by reference*.  
This means that what you're storing is the _address_ of the actual object value (aka a pointer).  
When you assign the object to a new variable, what you're _really_ doing is copying the address of the object or array; both variables will now point to the *same* object.
```java
int[] x = new [1, 2, 3, 4, 5];
int[] y = x;
x[2] = 10;
System.out.println(y[1]); // prints 2
System.out.println(y[2]); // prints 10
System.out.println(y[3]); // prints 4
```

=== A Linked List as a List

We refer to the chunk of memory that we allocate for each element of a linked list as a `Node`.
In java, we can allocate `Node` objects if we define them as a class, here storing the element represented by the `Node`, and a reference (pointer) to the next `Node`.
We use java's `Optional` type to represent situations where a `Node` is not present#footnote[
  An `Optional` extends existing types to indicate that the value may be present or absent (empty).  Although java already allows for object variables to take a `null` value, using `Optional` instead makes it easier for people writing code to know when it's necessary to explicitly check for a missing value (e.g., `value.isPresent()`).  Since `Optional` was added to java, it's been considered bad practice to use `null`.  As a further side note, `Optional` can actually be viewed as a `MutableSequence`.  Implementing this is left as an exercise for the reader.
]

A simple linked list, also known as a 'singly' linked list, is just a reference to a `head` node (which is empty if the list is empty).
The last element of the list has an empty `next`.

```java
public class SinglyLinkedList<T> implements List<T>
{
  class Node
  {
    T value;
    Optional<Node> next = Optional.empty();
    public this(T value) { this.value = value; }
  }
  /** The first element of the list, or None if empty */
  Optional<Node> head = Option.none();

  /* method implementations */
}
```

To help us convince ourselves that we're actually creating a list, let's state some rules for this structure we're building:
1. If the list is empty then `head.isEmpty()`.
2. If the list is non-empty, then `head` refers to the $0$th node.
3. The $x$th node stores the $x$th element of the list.
    - *Corrolary*: There are $N$ nodes.
4. If the $x$th node is the last node (i.e., $x = N-1$), then the node's `next.isEmpty()`.
5. If the $x$th node is not the last node, then the node's `next` points to the $x+1$th node.

Rules about how a data structure should behave are often called *invariants*.  When writing your own code and/or data structures, a great way to avoid bugs is to write down the invariants that you expect your code to follow, and then proving that your code follows the rules ("preserves the invariant").


==== Linked List `get`


#let mark_step = {
  import cetz.draw: *
  (where, what) => {
    content(where, text(blue, weight: "bold")[#what])
    circle(where, radius: 0.4, stroke: blue)
  }
}

#let linked_list_pointer = {
  import cetz.draw: *
  (from, to, color: black) => {
    let line_start = (rel: (1.5, 0.5), to: from)
    let line_end   = (rel: (0, 0.5), to: to)
    let mark_start = (line_end, 0.5, line_start)
    line(line_start, line_end, stroke: color)
    mark(mark_start, line_end,  symbol: ">", stroke: color, fill: color)
  }
}

#let linked_list_head = {
  import cetz.draw: *
  (at, to) => {
    content((rel: (0,0.5), to: at), [*HEAD*], name: "head")
    linked_list_pointer((0, 0), to)
  }
}

#let linked_list = {
  import cetz.draw: *
  (elems) => {
    for (position, letter, next) in elems {
      grid(position, (rel: (2, 1), to: position))
      content((rel: (0.5,0.5), to: position), letter)
      if next != none {
        linked_list_pointer(position, next)
      } else {
        // content((x+1.5, 0.5), $emptyset$)
      }
    }
  }
}


#figure(
  cetz.canvas({
    import cetz.draw: *
    scale(0.5)

    linked_list_head((0,0), (3,0))
    linked_list( (
      ((3,  0), "M", (6,  0)), 
      ((6,  0), "o", (9,  0)), 
      ((9,  0), "p", (12, 0)), 
      ((12, 0), ".", none)
    ) )

    for (idx) in (1, 2, 3) {
      let edge = (idx * 3, 0)
      arc((rel: (0, 1), to: edge), start: 45deg, stop: 135deg, radius: 2, stroke: blue)
      mark((rel: (-0.5, 1.5), to: edge), (rel: (0, 1), to: edge),  symbol: ">", stroke: blue, fill: blue)
      mark_step((rel: (-1, 2.2), to: edge), [#(idx - 1)])
    }

    line( (9.5, 0), (9.5, -1.5), stroke: blue)
    mark( (9.5, -1.0), (9.5, -1.5), symbol: ">", stroke: blue, fill: blue)
    mark_step((10.2, -0.8), [3])
  }),
  caption: "Retrieving the character at index 2 from a linked list representing the list ['M', 'o', 'p', '.']"
)


To retrieve a specific element $i$ of the list, we need to find the $i$th node.  
Since all we have to start is the $0$th node (the `head`; step ⓪), we can start there.
If that's the node we're looking for, great, we're done; Otherwise, the only other place we can go is the $1$st node (step ①). 
We repeat this process, moving from node to node until we get to the $i$th node (step ②), and return the corresponding value (step ③).

```java
  public T get(int index)
  {
    if(index < 0){ throw new IndexOutOfBoundsException() }
    Option<Node> currentNode = head;
    for(i = 0; i < index; i++){
      if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
      currentNode = currentNode.get().next;
    }
    if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
    return currentNode.get().value;
  }
```

Note that, if the rules we set for ourselves are being followed, we can prove to ourselves that this implementation is correct.  
Recall that we said `get(index)` is correct if it returns the $"index"$th element of the list.  

1. We start with `currentNode` assigned to `head`; By the rules we set for ourselves, this is the 0th node.  
2. The $i$th node has a pointer to the $(i+1)$th node, which we follow $i$ times.  
3. After $i$ steps, `currentNode` has been reassigned to the $0 + underbrace(1 + ... + 1, i "times") = 0 + sum_i 1 = i$th node.
4. It follows from step 4 and the fact that the loop iterates `index` times that after the loop, `currentNode` is the $"index"$th node.
5. It follows from step 5 and the rule that the $i$th node (if it exists) contains the $i$th element (if it exists), that the `value` in `currentNode` which `get` returns is the $"index"$th node
6. Since a correct `get` is one that returns the $"index"$th node, we can conclude that `get` is correct.

As usual, we can figure out the runtime of a snippet of code, starting by replacing every primitive operation with $Theta(1)$

```java
  public T get(int index)
  {
    if( /* Theta(1) */ ){ throw /* Theta(1) */ }
    /* Theta(1) */
    for(i = 0; i < index; i++){
      if( /* Theta(1) */ ){ throw /* Theta(1) */ }
      /* Theta(1) */
    }
    if( /* Theta(1) */ ){ throw /* Theta(1) */ }
    return /* Theta(1) */
  }
```

Before the `for` loop, we have only constant-time operations.  Similarly, we have only constant-time operations inside the body of the loop.  Both can be simplified to $Theta(1)$  Let's start by figuring out the runtime of what's inside the for loop.

$sum_(i=0)^("index"-1) Theta(1) = (("index"-1) - 0 + 1) dot Theta(1) = "index" dot Theta(1) = Theta("index")$

Since this is only the body of the for loop, we can add back the constant time operations before and after the loop to get the total runtime of `get`: 

$T_"get"("index") = Theta(1) + Theta("index") + Theta(1) = Theta("index")$.

The $Theta("index")$ runtime is a little unusual: With arrays, most costs were expressed in terms of the size of the array itself.  
That is, our asymptotic runtime complexity was given in terms of $N$, while here, it's given in terms of $"index"$. 
However, we know that $0 <= "index" < N$, and we we can use that fact to create an analogous bound on the runtime of `get`#footnote[
  The proof here is given only for _valid_ inputs.  For values of index less than zero, the function aborts immediately, and we can prove to ourselves (based on the rule that the last element in the list has an empty `next` node) that we will never go through the loop more than $N$ times.  Strictly speaking, the runtime should be, $Theta(min(N, "index"))$.  However, this added complexity makes no immediate impact on our discussion, and so we omit it.
].  

Since $"index" < N$, `get` is at worst linear in the size of the array, and so we get the upper bound: $T_"get"(N) = O(N)$

Similarly, since $"index" >= 0$, so `get` _could be_ constant time (e.g., `get(0)` requires only constant time), and we get the lower bound: $T_"get"(N) = Omega(1)$

==== Linked List `set`

#figure(
  cetz.canvas({
    import cetz.draw: *
    scale(0.5)

    linked_list_head((0,0), (3,0))
    linked_list( (
      ((3,  0), "M", (6,  0)), 
      ((6,  0), "o", (9,  0)), 
      ((9,  0), "p", (12, 0)), 
      ((12, 0), ".", none)
    ) )

    for (idx) in (1, 2, 3) {
      let edge = (idx * 3, 0)
      arc((rel: (0, 1), to: edge), start: 45deg, stop: 135deg, radius: 2, stroke: blue)
      mark((rel: (-0.5, 1.5), to: edge), (rel: (0, 1), to: edge),  symbol: ">", stroke: blue, fill: blue)
      mark_step((rel: (-1, 2.2), to: edge), [#(idx - 1)])
    }

    line( (9.5, 0), (9.5, -1.5), stroke: blue)
    mark( (9.5, -0.5), (9.5, 0), symbol: ">", stroke: blue, fill: blue)
    mark_step((10.2, -0.8), [3])
    content((9.5, -2), text(blue)['o'])
  }),
  caption: "Updating the character at index 2 to 'o', on the linked list representing the list ['M', 'o', 'p', '.'].  After the set, the linked list represents the list ['M', 'o', 'o', '.']"
)
To set the $i$th element of a linked list, just like `get`, we need to first find the $i$th element. 
As a result, the code for `set` is almost exactly the same as `get`, except for the very last line.

```java
  public void set(int index, T element)
  {
    if(index < 0){ throw new IndexOutOfBoundsException() }
    Option<Node> currentNode = head;
    for(i = 0; i < index; i++){
      if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
      currentNode = currentNode.get().next;
    }
    if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
    currentNode.get().value = element;
  }
```

Using our Linked List invariants, we can similarly prove that our implementation of set follows the rules that we set out for `List`'s `set` operation.
Remember that `set(index, element)` is supposed to change the linked list so that the next time we call `get(index)`, we get `element` instead of what was there before.

1. We start with `currentNode` assigned to `head`; By the rules we set for ourselves, this is the 0th node.  
2. The $i$th node has a pointer to the $(i+1)$th node, which we follow $i$ times.  
3. After $i$ steps, `currentNode` has been reassigned to the $0 + underbrace(1 + ... + 1, i "times") = 0 + sum_i 1 = i$th node.
4. It follows from step 4 and the fact that the loop iterates `index` times that after the loop, `currentNode` is the $"index"$th node.
5. It follows from step 5 and the rule that the $i$th node (if it exists) contains the $i$th element (if it exists), that the `value` in `currentNode` which `set` changes is the $"index"$th node
6. Since any subsequent calls to `get` will return the $"index"$th node, we can conclude that `set` is correct.

*Side Note*: Observe how the proof for `set` is almost exactly the same as the proof for `get`.  

As usual we can figure out the runtime by replacing every primitive operation with $Theta(1)$

```java
  public void set(int index, T element)
  {
    if( /* Theta(1) */ ){ throw /* Theta(1) */ }
    /* Theta(1) */
    for(i = 0; i < index; i++){
      if( /* Theta(1) */ ){ throw /* Theta(1) */ }
      /* Theta(1) */
    }
    if( /* Theta(1) */ ){ throw /* Theta(1) */ }
    /* Theta(1) */
  }
```

Once we replace all primitive operations with $Theta(1)$, `set` and `get` are exactly the same. 
Taking the same steps gets us to a runtime of $Theta("index")$, or $O(N)$.

==== Linked List `add`
#figure(
  cetz.canvas({
    import cetz.draw: *
    scale(0.5)

    linked_list_head((0,0), (3,0))
    linked_list( (
      ((3,  0), "M", (6,  0)), 
      ((6,  0), "o", (9,  0)), 
      ((9,  0), "o", none), 
      ((15, 0), ".", none)
    ) )
    linked_list( (
      ((12, 2), "f", none),
    ) )
    for (idx) in (1, 2, 3) {
      let edge = (idx * 3, 0)
      arc((rel: (0, 1), to: edge), start: 45deg, stop: 135deg, radius: 2, stroke: blue)
      mark((rel: (-0.5, 1.5), to: edge), (rel: (0, 1), to: edge),  symbol: ">", stroke: blue, fill: blue)
      mark_step((rel: (-1, 2.2), to: edge), [#(idx - 1)])
    }
    linked_list_pointer( (9, 0), (15, 0), color: gray)
    linked_list_pointer( (9, 0), (12, 2), color: blue)
    linked_list_pointer( (12, 2),(15, 0), color: blue)

    mark_step((13, 1.2), [3])
  }),
  caption: "Inserting the character 'f' at index 3, on the linked list representing the list ['M', 'o', 'o', '.'].  After the add, the linked list represents the list ['M', 'o', 'o', 'f', '.'] (the call of the noble dogcow)."
)


Unlike the array, where we manually need to copy over every element of the array to a new position, in a linked list, the position of each node is given relative to the previous node.
If we insert a new node by redirecting the `next` value of the previous node, we automatically shift every subsequent node by one position to the right.

```java
  public void add(int index, T element)
  {
    if(index < 0){ throw new IndexOutOfBoundsException() }
    Node newNode = new Node(element);
    if(head.isEmpty){                    /* Case 1: Initially empty list */
      head = Optional.of(newNode);
    } else if(index == 0){               /* Case 2: Insertion at head */
      newNode.next = head;
      head = Optional.of(newNode);
    } else {                             /* Case 3: Insertion elsewhere */
      Option<Node> currentNode = head;
      for(i = 0; i < index-1; i++){
        if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
        currentNode = currentNode.get().next;
      }
      if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
      newNode.next = currentNode.get().next;
      currentNode.get().next = Optional.of(newNode);
    }
  }
```

Let's prove to ourselves that this code is correct, and start by recalling our rules for how `add` is supposed to behave:
1. The size of the List grows by 1.
2. The value `element` will be the new element at index $"index"$.
3. Every element previously at an index $i >= "index"$ will be moved to index $i+1$.

#let oldlinkedlist = () => {$L_"old"$}
#let newlinkedlist = () => {$L_"new"$}
#let oldlinkedlistsize = () => {$N_"old"$}
#let newlinkedlistsize = () => {$N_"new"$}

Let's set aside the size rule for the moment and focus on the other two rules.  
We have our original list ($oldlinkedlist()$ of size $oldlinkedlistsize()$), and the list we get after calling `add` ($newlinkedlist()$ of size $newlinkedlistsize() = oldlinkedlistsize()+1$).  
Collectively, the latter two rules give us four cases for what will happen if we call $newlinkedlist()$.`get`($i$):
1. If $0 <= i <$ `index`: $newlinkedlist()$.`get`($i$) = $oldlinkedlist()$.`get`($i$)
2. If $i =$ `index`: $newlinkedlist()$.`get`($i$) = `element`
3. If $newlinkedlistsize() > i >$ `index`: $newlinkedlist()$.`get`($i$) = $oldlinkedlist()$.`get`($i-1$)
4. If $i >= newlinkedlistsize()$: $newlinkedlist()$.`get`($i$) throws an exception

We'll want to show that after calling `add`, any subsequent call to `get`($i$) will return the correct value.
We already proved that `get` is correct if the linked list follows the rules we set forth for ourselves, so we need to show that the new linked list is correct for the updated list.
In other words, we want to show that:
1. All nodes at position $0 <= i <$ `index` are left unchanged.
2. The newly created node (at position `index`) is pointed to by the node at position `index`$-1$, or by `head` if `index` $= 0$.
3. All nodes previously at positions `index` $ <= i < oldlinkedlistsize()$ are now at position $i+1$.
4. The node at position $newlinkedlistsize()-1$ has an empty `next`.

The code has three cases that we'll look at individually.

*Case 1: Initially empty list*: 
Going down the list of things we need to prove:
1. There are no other nodes, so nothing changes.
2. The newly created node is at position $0$, and so is correctly pointed to by `head` after the code runs.
3. There are no other nodes, so nothing needs to change.
4. Since $newlinkedlistsize() = 1$, we need the node at position $newlinkedlistsize() - 1 = 0$ to have an empty next.  Since this is the node we just created, this is true.

*Case 2: Insertion at head*:
Going down the list of things we need to prove:
1. Since `index` $=0$, there can be no nodes at positions before `index`, so nothing changes.
2. The newly created node is at position $0$, and so is correctly pointed to by `head` after the code runs.

For the remaining two rules, consider the fact that the (newly created) $0$th node's `next` field now points at the node that used to be the `head`.
- By our rules for linked lists, this means that the old $0$th element is now the $1$st element (correct).
- The new $1$st element is pointing at what used to be the $1$st element, but is now the $2$nd element (also correct).
- The new $2$nd element is pointing at what used to be the $2$nd element, but is now the $3$rd element (also correct).
- The new $3$rd element is pointing at what used to be the $3$rd element, but is now the $4$th element (also correct).
This pattern continues: The new $i$th element is pointing at what used to be the $i$th element, but is now the $i+1$th element (still correct), up until we get to the $newlinkedlistsize()-1$th element, which used to be the $oldlinkedlistsize()-1$th element, which still (correctly) has an empty `next`.

*Case 3: Insertion anywhere else*:
Going down the list of things we need to prove:
1. The code finds the node at position `index`$-1$, skipping over all preceding nodes.  These are unchanged.
2. The newly created node is pointed to by the node at position `index`$-1$, putting it at position `index`.

For the remaining two rules, we want to consider what happens to the node previously at position `index`, but also need to consider the possibility that there was no node at this index to begin with (if `index` $= oldlinkedlistsize()$).
If the node exists, then as in *Case 2*, the node at position `index` moves to position `index`$+1$, likewise repositioning every following node, including the final one.
If the node doesn't exist, then the newly created node's `next` field is assigned an empty value, (correctly) making it the last node in the list.


==== Aside: Invariants and Rule Preservation

It's worth taking a step back at this point and reviewing what we just did and why.
We defined the expected state of the linked list (in terms of the behavior of `get` and our rules for a correct linked list) _after_ the set, but we did so relatively to its state _before_ the set.
Specifically, we showed that, if the list was correct before we called `set`, it would still be correct (for the new list) after we called `set`, or in other words, we showed that `set` *preserves the invariants* we defined for the linked list.

Invariants are an extremely useful debugging technique for data structures (and other code).
If you can precisely define one or more rules (invariants) for your data structure, you can check to see whether your code follows the rules:
If you get a correct data structure as input to your function, is it always the case that you get a correct data structure as an output (keeping in mind that the function may change the definition of correctness).


==== Linked List `add` runtime

The runtime of `add` follows a pattern very similar to that of `set`:

```java
  public void add(int index, T element)
  {
    if( /* Theta(1) */ ){ /* Theta(1) */ }
    /* Theta(1) */
    if( /* Theta(1) */ ){                /* Case 1: Initially empty list */
      /* Theta(1) */
    } else if( /* Theta(1) */ ){         /* Case 2: Insertion at head */
      /* Theta(1) */
    } else {                             /* Case 3: Insertion elsewhere */
      /* Theta(1) */
      for(i = 0; i < index-1; i++){
        /* Theta(1) */
      }
      if( /* Theta(1) */ ){ /* Theta(1) */ }
      /* Theta(1) */
    }
  }
```

Based on the the outer if statement, we have three cases:

$T_("add")("index") = cases(
  Theta(1) "if case 1",
  Theta(1) "if case 2",
  Theta(1) + sum_(i=0)^("index"-1) ( Theta(1) ) "if case 3",
)$

Simplifying the third case, we get:
- $Theta(1) + sum_(i=0)^("index"-1) ( Theta(1) )$
- $Theta(1) + ("index" - 1 + 0 + 1) ( Theta(1) )$
- $Theta(1) + "index" dot Theta(1)$
- $Theta(1) + Theta("index")$
- $Theta("index")$

So...
$T_("add")("index") = cases(
  Theta(1) "if case 1",
  Theta(1) "if case 2",
  Theta("index") "if case 3",
)$

Since $"index" = 0$ in cases 1 and 2, we can further simplify to 

$T_("add")("index") = cases(
  Theta("index") "if case 1",
  Theta("index") "if case 2",
  Theta("index") "if case 3",
) = Theta("index")$

As before, $Theta("index") in O(N)$ and $Theta("index") in Omega(1)$

==== Linked List `remove`
#figure(
  cetz.canvas({
    import cetz.draw: *
    scale(0.5)

    linked_list_head((0,0), (3,0))
    linked_list( (
      ((3,  0), "M", (6,  0)), 
      ((6,  0), "o", none), 
      ((9,  0), "o", (12, 0)), 
      ((12, 0), "f", (15, 0)), 
      ((15, 0), ".", none)
    ) )
    for (idx) in (1, 2) {
      let edge = (idx * 3, 0)
      arc((rel: (0, 1), to: edge), start: 45deg, stop: 135deg, radius: 2, stroke: blue)
      mark((rel: (-0.5, 1.5), to: edge), (rel: (0, 1), to: edge),  symbol: ">", stroke: blue, fill: blue)
      mark_step((rel: (-1, 2.2), to: edge), [#(idx - 1)])
    }
    linked_list_pointer( (6, 0), (9, 0), color: gray)
    arc((12, 0), start: -45deg, stop: -147deg, radius: 2.9, stroke: blue)
    mark((11.5, -0.5), (12, 0),  symbol: ">", stroke: blue, fill: blue)
    mark_step((12.5, -0.75), 2)
  }),
  caption: "Removing the element at index 2 from the linked list representing the list ['M', 'o', 'o', 'f', '.'].  After removal, the linked list represents the list ['M', 'o', 'f', '.']"
)

As with `add`, we can benefit from the relative positioning of linked list nodes by simply moving a `next` reference to skip over the removed linked list node.

```java
  public void remove(int index)
  {
    if(index < 0){ throw new IndexOutOfBoundsException() }
    if(head.isEmpty){                    /* Case 1: Initially empty list */
      throw new IndexOutOfBoundsException();
    } else if(index == 0){               /* Case 2: Deletion from head */
      head = head.get().next;
    } else {                             /* Case 3: Deletion elsewhere */
      Option<Node> currentNode = head;
      for(i = 0; i < index-1; i++){
        if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
        currentNode = currentNode.get().next;
      }
      if(currentNode.isNone){ throw new IndexOutOfBoundsException() }
      currentNode.next = currentNode.get().next;
    }
  }
```

The proof of correctness and `remove`'s runtime of $Theta("index")$ are left as an exercise for the reader.

==== Linked List `size` (Take 1)

The size of the list is the number of elements.  Thinking back to our rules, the last node is the node with an empty `next` pointer, so we need to figure out where this node is located

```java
  public int size()
  {
    Option<Node> currentNode = head;
    int count = 0;
    while( ! currentNode.isEmpty() ){
      currentNode = currentNode.get().next
      count += 1
    }
    return count
  }
```

Let's see if we can prove that this code is correct.  This code is a bit harder to think about than `get` and `set`, since in both of those cases we had a nice handy `for` loop to keep track of how many 'steps' we take through the list.  
Here, the while loop just keeps going until `currentNode.isEmpty()`.   
When trying to tackle a tricky proof like this, it can often help to break down the proof into cases.  

Let's start with the simplest case: What happens if the list is empty ($N=0$)?
1. `count` starts off at 0.
2. If the list is empty, then by our rules for linked lists `head` is empty, so we start off with `currentNode` empty as well.
3. Since `currentNode` is empty from the start, we skip the `while` loop's body entirely.
4. `count` is never modified, and we correctly return 0.

Let's tackle the next simplest case next: What happens if the list only has 1 element ($N=1$)
1. `count` starts off at 0.
2. `head` points to the $0$th element of the list, so `currentNode` starts off pointing to the $0$th node.
3. Since `currentNode` is not empty, we enter the body of the while loop.
4. We increment `count` to $1$, and update `currentNode` from the $0$th node to its `next` reference.  
5. By our rules for linked lists, since the list has only 1 element, the $0$th node's `next` reference is empty, so `currentNode` is now empty and we exit the `while` loop.
6. We correctly return `count`$=1$, 

Moving on, let's see what happens if the list has 2 elements ($N=2$)
1. `count` starts off at 0.
2. `head` points to the $0$th element of the list, so `currentNode` starts off pointing to the $0$th node.
3. Since `currentNode` is not empty, we enter the body of the while loop, increment count, and update `currentNode` to its `next` reference.
4. We increment `count` to $1$, and update `currentNode` from the $0$th node to its `next` reference, the $1$st node.  
5. We increment `count` to $2$, and update `currentNode` from the $1$st node to its `next` reference.
6. By our rules for linked lists, since the list has only 2 elements, the $1$st node's `next` reference is empty, so `currentNode` is now empty and we exit the `while` loop.
7. We correctly return `count`$=2$, 

Moving on, let's try a list with 3 elements ($N=3$)
1. `count` starts off at 0.
2. `head` points to the $0$th element of the list, so `currentNode` starts off pointing to the $0$th node.
3. Since `currentNode` is not empty, we enter the body of the while loop, increment count, and update `currentNode` to its `next` reference.
4. We increment `count` to $1$, and update `currentNode` from the $0$th node to its `next` reference, the $1$st node.  
5. We increment `count` to $2$, and update `currentNode` from the $1$st node to its `next` reference, the $2$nd node.  
6. We increment `count` to $3$, and update `currentNode` from the $2$nd node to its `next` reference.
7. By our rules for linked lists, since the list has only 3 elements, the $2$st node's `next` reference is empty, so `currentNode` is now empty and we exit the `while` loop.
8. We correctly return `count`$=3$, 

Although the proof is different for each case, you might notice a pattern forming.  
For a list of _any_ size, we can come up with a similar proof by adding a bunch of lines into the middle, all from the template:

We increment `count` to $i$, and update `currentNode` from the $i-1$th node to its `next` reference, the $i$th node.  

In other words, it looks like the code ties the values of `count` and `currentNode` together.
We can use this intuition to define a rule for ourselves: If `currentNode` is not empty, it always points to the `count` node of the list.
This is true at the start of the loop, since `count`$=0$ and by our rules for linked lists, `currentNode` points at the $0$th node.
Now, if we know that `currentNode` (if non-empty) points to the `count` node of the linked list when we *start* the loop body, we can show that it's still true at the end of the loop body:
1. If `currentNode` points to the $i$th node of the list, by our rules for linked lists, its `next` element points to the $i+1$th node.
2. If `count` is $i$ to start, then incrementing it sets it to $i+1$
3. From lines 1 and 2, after the loop body, `count`$=i+1$ and `currentNode` is the $i+1$th node, and we're still following the rule.

Since the rule holds at the *start* of the loop, and since the loop body preserves the rule, we know that the rule is also followed at the *end* of the loop.
We call a rule that is satisfied at the start of a loop and preserved by the loop body, a *loop invariant*.

The loop ends at the very first point where `currentNode` becomes empty.  This happens in one of two cases:
- `head` is empty.
- The `next` element of `currentNode` is empty.
By our rules for linked lists, the first case happens only when the list is empty, and we've already shown that `size` is correct in this case.
Similarly, by our rules for linked lists, the second case happens only when `currentNode` points to the last (i.e., $N-1$th) node of the linked list.  
From that, and our loop invariant, it must be the case that `count` is $N-1$.
Since `count` gets incremented one last time on the 2nd line of the loop body, when the loop ends `count`$=N$, which is also correct.

==== Aside: Loop Invariants
Once again, let's take a quick moment to review what we just did, because it's very useful trick for debugging loops in your code#footnote[
  Although it's a bit too early to use the term in the main body of the text, loop invariants are a specific example of a proof trick called "induction".  We'll come back to induction as a more general technique next chapter, when we talk about recursion.
].
We started by trying to prove that our code was correct for a couple of simple example cases.
From those simple example cases, we found a pattern in the proof: a rule that our code seemed to obey throughout our proof.
We then set up a *loop invariant* based on that pattern and showed that (i) it held at the start of the loop, and (ii) each line of the loop preserved the rule.
Because we could show that the invariant held at the start of the loop, and each loop iteration preserved the invariant, we inferred that the invariant had to be true at the end of the loop as well.
We used the fact that the invariant was true at the end of the loop to prove that `size` was correct.

When debugging code with loops, try tracing through the loop manually for a few iterations.
You'll often start noticing patterns and relationships between elements of the code.
Try to pin down *exactly* what that pattern is (like `currentNode` always points to the `count` node in our example), and write down the loop invariant.
Then, try to prove to yourself that (i) the pattern holds at the start of the loop, (ii) the pattern is preserved by the loop body.

==== Linked List `size` (Take 1) runtime

As usual, we can replace all primitive operations with $Theta(1)$

```java
  public int size()
  {
    /* Theta(1) */
    while( /* Theta(1) */ ){
      /* Theta(1) */
    }
    return /* Theta(1) */
  }
```

Once again, the `while` loop makes our job a little harder.  
However, just as before, we can use the loop invariant to help ourselves out:
1. $"count"$ starts at 0.
2. Each loop iteration increments $"count"$ by 1.
3. The loop ends when $"count" = N$.
Combining these facts, we can definitively state that the loop goes through $N$ iterations.
So, we get: 

$Theta(1) + underbrace(Theta(1) + ... + Theta(1), N "times") + Theta(1) = (N+2) dot Theta(1) = Theta(N+2) = Theta(N)$



==== Linked List `size` (Take 2)

It's not great when a function has a $Theta(N)$ runtime, and it's really bad when it's something as fundamental as `size`.
Many algorithms need to know the size of a collection, so it would be useful to have a way to cut the runtime to something more practical.
In the case of `size`, there's one simple trick that lets us cut the runtime down to $Theta(1)$: Precomputing the size.
Let's add a `N` field to the linked list and modify the `size` method to just return it.

```java
public class SinglyLinkedList<T> implements List<T>
{
  class Node
  {
    T value;
    Optional<Node> next = Optional.empty();
    public this(T value) { this.value = value; }
  }
  /** The first element of the list, or None if empty */
  Optional<Node> head = Option.none();

  /** The precomputed size of the list */
  private int N = 0;

  public int size() { return this.N; }

  /* method implementations */
}
```

The list starts off empty ($N = 0$), so initially this method is correct.  
However, we need to make sure that it stays correct as we change the structure.  
There are two operations, `add` and `remove`, that modify the size of a list, incrementing and decrementing the list's size.
We need to modify these operations to properly maintain $N$:

```java
  public void add(int index, T element)
  {
    /* ... as before ... */
    this.N += 1;
  }
  public void remove(int index)
  {
    /* ... as before ... */
    this.N -= 1;
  }
```

Let's review the trade-off we just made:
Both changes add an additional $Theta(1)$ runtime cost to `add` and `remove`.
This doesn't change the overall code complexity of either ($Theta("index")$, or equivalently $O(N)$)#footnote[
  In practice, incrementing and decrementing an integer is a relatively inexpensive operation in most cases, so even outside of the magical land of asymptotics, this is usually a worthwhile trade.
  That said, there are _some_ exceptions, primarily when dealing with concurrency (synchronized integers are expensive) or with random memory access (we'll talk about this later in the book).
].
In exchange, the asymptotic runtime complexity of `size` drops from $Theta(N)$ to $Theta(1)$.
To summarize, the asymptotic runtime complexity of all the other operations stays the same, and `size`'s asymptotic runtime complexity drops massively.
This is almost always a worthwhile trade.

== The Iterator ADT

In the next section, we'll introduce a new type of abstract data type called the Iterator (sometimes called a 'Cursor').
Iterators are a little unique as far as this class goes, in that they represent something a bit different from a collection.
They represent a loop over the elements of a collection.
The ability to abstractly loop over the elements of a collection is really useful for keeping the abstraction layer around our other collection types, as we'll see shortly.
We'll start with a motivating example.

=== Motivation: Summing up Integers

Have a look at the following code, which takes a `List` of `Integer`s and computes their sum.  Before you read on, try to work out the code's runtime for yourself.

```java
  public int computeSum(List<Integer> list)
  {
    int sum = 0;
    for(i = 0; i < list.size(); i++)
    {
      sum += list.get(i);
    }
    return sum;
  }
```

Seriously, stop reading and figure out the code's runtime before you read on.

I mean it.  Did you figure it out yet?

Ok... if you read on without figuring it out for yourself, you're cheating yourself of a learning experience.  You've been warned thrice.

Using our normal technique of replacing primitive operations would lead you to a runtime of $Theta(N)$, but this is actually not correct.  
We're allowed to replace *primitive* operations with $Theta(1)$.  
However, this particular block of code relies on two non-primitive operations: the block of code invokes `list.size()` and `list.get()`.  
For these, instead of $Theta(1)$, we need to "plug in" the runtime complexities that we computed before.

But what is the runtime complexity of these operations?  
To answer that question, we need to know which `List` data structure we're using.
For arrays, which store the size explicitly, the `size` operation is $Theta(1)$.
For linked lists, our first attempt was a `size` operation that was $Theta(N)$, but then we came up with an optimization that got us down to $Theta(1)$.
So:

$T_("size")(N) = cases(
  Theta(1) "if using an array",
  Theta(1) "if using a linked list",
) = Theta(1)$

Since all cases are the same, it doesn't matter which structure we're using, `size` is always $Theta(1)$.
However, the same isn't true for `get`.  Recall that for the linked list, the cost of `get` depends on the index.

$T_("get")("index") = cases(
  Theta(1) "if using an array",
  Theta("index") "if using a linked list",
)$

Since there are two possibilities here, we can't define a simple theta bound for `get`, but we can provide upper and lower bounds $O("index")$ and $Omega(1)$.
Let's plug this all into our code and see what we get:

```java
  public int computeSum(List<Integer> list)
  {
    /* Theta(1) */
    for(i = 0; i < list.size(); i++)
    {
      /* Theta(1) + T_get(i) */
    }
    return /* Theta(1) */;
  }
```

Since we don't have a (simple) tight bound for $T_("get")(i)$, we can switch to using both upper and lower bounds.  Remember that wherever you see $Theta(f(N))$, it means that $f(N)$ is *both* an upper and a lower bound, so we can always replace $Theta(f(N))$ in an arithmetic expression, with $O(f(N))$ or $Omega(f(N))$.
Solving for the upper bound first, we get: 
- $T_("computeSum")(N) = O(1) + (sum_(i=0)^N O(1) + T_("get")(i)) + O(1)$
- $= O(1) + (sum_(i=0)^N O(1) + O(i)) + O(1)$
- $= O(1) + (sum_(i=0)^N O(i)) + O(1)$
- $= O(1) + (sum_(i=0)^N i dot O(1)) + O(1)$
- $= O(1) + O(1) dot (sum_(i=0)^N i) + O(1)$
- $= O(1) + O(1) dot (frac(N dot (N+1), 2)) + O(1)$
- $= O(1) + O(1) dot (N^2/2 + N/2) + O(1)$
- $= O(1) + O(N^2/2 + N/2) + O(1)$
- $= O(1) + O(N^2) + O(1)$
- $= O(N^2)$

And then for the lower bound:
- $T_("computeSum")(N) = Omega(1) + (sum_(i=0)^N Omega(1) + T_("get")(i)) + Omega(1)$
- $= Omega(1) + (sum_(i=0)^N Omega(1) + Omega(1)) + Omega(1)$
- $= Omega(1) + (sum_(i=0)^N Omega(1)) + Omega(1)$
- $= Omega(1) + Omega(1) dot (sum_(i=0)^N 1) + Omega(1)$
- $= Omega(1) + Omega(1) dot (N - 0 + 1) + Omega(1)$
- $= Omega(1) + Omega(N + 1) + Omega(1)$
- $= Omega(1) + Omega(N) + Omega(1)$
- $= Omega(N)$

So `computeSum` will take *at least* linear time, but could take as much as quadratic time!

If we work our way backwards through the summation, the limiting factor seems to be $T_"get"$.  
If $T_"get"$ were constant-time, for example if we were certain that `list` was an array, we could re-do the summations with $T_("get") = O(1)$.
Try it yourself, and you'll see that the upper bound on the runtime works out to $O(N)$.  
This is *much* better.  As we saw in the last chapter, for a sufficiently large list, quadratic to linear can be the difference between an algorithm that takes seconds, and one that takes hours.

So, how do we fix it?
One strategy might be to observe that you can loop over the elements of a linked list *much* faster if you have some insight into the list's structure.
Instead of using a loop variable `i`, you can use a pointer to the 'current' node:

```java
  public int computeSumOfLinkedList(LinkedList<Integer> list)
  {
    int sum = 0;
    for(list.Node currentNode = list.head;
        currentNode.isPresent();
        currentNode = currentNode.get().next)
    {
      sum += currentNode.get().value;
    }
    return sum;
  }
```

In this version of the algorithm, every operation is primitive.
Note that the algorithm looks almost identical to that of `size` (take 1).  
The proof that this this algorithm also runs $Theta(N)$ is similar, and is left as an exercise for the reader.
Most importantly, the $Theta(N)$ we get from this algorithm is much better than the $O(N^2)$ we got from the "generic" version of the algorithm that we saw at the start of the section.
However, this improved performance comes at a steep cost: The new algorithm is specialized to linked lists.
If we need to change to a different data structure (e.g., the Buffered Array that we'll introduce shortly), then we have to rewrite the summation algorithm from scratch.

=== Abstracting Loops

The motivating problem goes beyond just computing sums: *Any* loop over the elements of a linked list using `get` is going to have an $O(N^2)$ runtime. 
We can play a similar trick, looping over the linked list nodes instead of the index, for any loop.
However, doing so requires us to know that we're working with a linked list.
So let's dig a little deeper.

To move from one index to the next, the generic linked list loop simply increments $i$ to $i+1$ (a constant-time operation).
For the array, where the index is sufficient to find the value in constant time, the overall cost of stepping from one element of the list to the next is constant.
However, for a linked list, going from an index to a value is a linear-time operation, since we need to find the node corresponding to the index.
The 'trick' underlying the specialized linked list version of the loop, is that moving from a linked list *node* to the `next` node can be done in constant time.
The structure of the loop is the same, but instead of using an index $i$, we use a node reference.

Looking at the commonalities between `computeSum` and `computeSumOfLinkedList`, the following code structure is common to both:

```java
  public void computeSumV2(List<Integer> list)
  {
    int sum = 0;
    for( PositionType i = list.firstPosition();
         i.isNotAtEnd();
         i.moveToNext())
    {
      sum += i.getValue();
    }
  }
```

This code structure includes five placeholders: 
1. The type of the position reference (`PositionType`).
2. A way to initialize the position reference to the first element (`firstPosition`).
3. A way to test whether there are more positions left to visit (`isNotAtEnd`)
4. A way to move to the next position (`moveToNext`)
5. A way to get the value at the current position (`value`)


#table(
  columns: 3,
  inset: 10pt,
  align: horizon,
  stroke: none,
  table.header(
    [],
    table.vline(),
    `computeSum`,
    `computeSumOfLinkedList`,
  ),
  table.hline(),
  [`PositionType`],
    `int`,
    `list.Node`,
  [`firstPosition`],
    `0`,
    `list.head`,
  [`isNotAtEnd`],
    `i < N`,
    `i.isPresent()`,
  [`moveToNext`],
    `i += 1`,
    `i = i.get().next`,
  [`getValue`],
    `list.get(i)`,
    `i.get().value`,
)

=== The Iterator ADT

The `Iterator` abstract data type, abstractly models the position of a loop in a list, providing the five operations named above.
Iterators are implemented in each language slightly differently, but in Java, the main parts of the `Iterator` interface look like:

```java
public interface Iterator<E>
{
  /** 
   * Returns true if there are more values to retrieve
   * (The `isAtEnd` of our example above)
   */
  public boolean hasNext();
  /**
   * Retrieves the next element and advances the iterator
   * to the next position.
   * (Combines `moveToNext` and `getValue` from our example)
   */
  public E next();

  /* A few other methods that aren't relevant yet */
}
```

To initialize the iterator, the `List` interface defines an `iterator` method that returns an iterator pointing to the first position (`firstPosition` in our example).
Plugging this into our template pattern, we get:

```java
  public void computeSumWithIterators(List<Integer> list)
  {
    int sum = 0;
    for( Iterator<Integer> i = list.iterator();
         i.hasNext();
         /* next() automatically advances the iterator */)
    {
      sum += i.next();
    }
    return sum;
  }
```


==== Case Study: Array Iterator

To build an iterator, we can look at the table above and plug in the corresponding operations for `hasNext` and `next`. 
For the array, this means using the index. 

```java
public class SimpleArrayIterator<T> extends Iterator<T>
{
  SimpleArrayAsList<T> array;
  int i = 0;

  /** `firstPosition` */
  public this(SimpleArrayAsList<T> array) { this.array = array }
  /** `isNotAtEnd` */
  public boolean hasNext() { return i < array.size; }
  /** `getValue` and `moveToNext` */
  public T next() { 
    T currentValue = array.get(i);
    i += 1; 
    return currentValue; 
  }
}
```

==== Case Study: Linked List Iterator
For the linked list, this means using the linked list node.

```java
public class SinglyLinkedListIterator<T> extends Iterator<T>
{
  Optional<Node> currentNode;

  /** `firstPosition` */
  public this(SinglyLinkedList<T> list) { this.currentNode = list.head; }
  /** `isNotAtEnd` */
  public boolean hasNext() { return currentNode.isPresent(); }
  /** `getValue` and `moveToNext` */
  public T next() { 
    T currentValue = currentNode.get().value;
    currentNode = currentNode.get().next;
    return currentValue; 
  }
}
```

=== Summation Runtime with Iterators

Note that, each of these implementations use exclusively primitive operations.
As a result, both iterators' initialization, `hasNext` and `next` are constant-time.
Returning to the iterator-based implementation of `computeSum`, we can figure out the runtime:

```java
  public void computeSumWithIterators(List<Integer> list)
  {
    /* Theta(1) */
    for( /* Theta(1) */;
         /* Theta(1) */;
         /* 0 */)
    {
      /* Theta(1) */
    }
    return /* Theta(1) */
  }
```

This gives us a runtime of:

$T_("computeSumWithIterators")(N) = Theta(1) + (sum_{i = 0}^{N-1} Theta(1) ) + Theta(1) = Theta(N)$

Using iterators, we get the same $Theta(N)$ runtime for a loop over either list implementation, but we get the benefit *without having to specialize the loop implementation*.  

The resulting code is far more flexible, since we can freely swap in *any* other data structure implementation, without impacting the code's correctness (or, in this case, performance).

==== Java Iterator shorthand 

Looping over the elements of a collection with iterators is such a common pattern that Java adds a bit of syntax to make it easier to write.  Note the `for` syntax below.


```java
  public void computeSumWithIteratorsV2(List<Integer> list)
  {
    int sum = 0;
    for(Integer i : list)
    {
      sum += i.next();
    }
    return sum;
  }
```

`computeSumWithIterators` and `computeSumWithIteratorsV2` do exactly the same thing.  
```java
  for(T element : collection){ /* ... */ }
``` 
is simply a shorthand for:
```java
  for(Iterator<T> iter = collection.iterator(); iter.hasNext(); ){
    T element = iter.next();
    ...
  }
```

=== List Access by Reference

Iterators have another benefit.  They give us a highly efficient way to reference a *specific* element of a list.  

Remember that for Arrays, we can efficiently identify an element by its index.  
For any operation that we want to perform on specific elements of the Array, we can use the list index to identify the element we want to affect.  For example, let's talk about the following bit of code, which deletes every instance of an element in the list.

```java
  public void removeAll<T>(List<T> list, T element)
  {
    for(i = 0; i < list.length(); i++){
      if(list.get(i).equals(element)){
        list.remove(i);
        i -= 1;
      }
    }
  }
```

The code iterates through every element of the list, and then calls `remove` on the element being removed.  In the implementation above, we use the index (`i`) to refer to a specific element.  
However, remember that that this is exactly the type of loop that led us to come up with iterators, since it performs quadratically if `list` is a `LinkedList`.  Let's replace the code with an iterator#footnote[
  If you try running `removeAllWithIterator` for real, you'll notice that it actually won't work.  Because `remove` changes the list, it also 'invalidates' all iterators on the list.  Keep reading on for a way to implement this algorithm without breaking the iterator.
].

```java
  public void removeAllWithIterator<T>(List<T> list, T element)
  {
    int i = 0;
    for(Iterator<T> iter = list.iterator(); iter.hasNext();){
      if(iter.next().equals(element)){
        list.remove(i);
      } else {
        i++;
      }
    }
  }
```

Note that we can't get rid of the list index (`i`), since we need a way to tell `remove` which element to remove.
However, this has an unexpected consequence on performance: If `list` is a `LinkedList`, `remove` has a runtime complexity of $Theta(i)$.  
If we do a runtime analysis of removeAllWithIterator, plugging in the cost of `remove` on a `LinkedList`#footnote[
  The analysis is only slightly different if you plug in the $O(N)$ cost of `remove` for an `Array`. 
], we start with:

```java
  public void removeAllWithIterator<T>(List<T> list, T element)
  {
    /* O(1) */
    for(/* O(1) */){
      if( /* O(1) */){
        /* O(i) */
      } else {
        /* O(1) */
      }
    }
  }
```

The `for` loop visits every element of the list.  
Although `i` isn't incremented for *every* element of the list, we can use the number of elements we've visited as a _upper bound_ on `i`.  That is: $i in O(v)$ (where $v$ is the number of visited nodes.  Using this insight, we can compute the total runtime (with $N$ as the `length` of `list`) as:

$T_"removeAllWithIterator" (N) = O(1) + O(1) + sum_(v : 0)^N O(1) + cases(O(i), O(1))$

The cases block is upper-bounded by $O(i)$, and $O(i)+O(1) = O(i)$, so

$T_"removeAllWithIterator" (N) = O(1) + O(1) + sum_(v : 0)^N O(i)$

As we noted above, $i in O(v)$, so:

$T_"removeAllWithIterator" (N) = O(1) + O(1) + sum_(v : 0)^N O(v)$

Applying our summation rules, we can simplify the summation:

$T_"removeAllWithIterator" (N) = O(1) + O(1) + O(N^2)$

And one more simplification step gets us:

$T_"removeAllWithIterator" (N) = O(N^2)$

$O(N^2)$ isn't great, so let's take a step back and ask ourselves why that's the runtime complexity.
We need to do a loop over $N$ elements just to find the elements that don't fit, so it'll be difficult to get the runtime under $O(N)$#footnote[
  This is a tiny lie, but true for Arrays and Linked Lists.  We'll get to efficiently finding elements in the sections on Trees and Hash Tables.
].
However, in every iteration of the loop, we have the $O(i)$ call to `remove`.

That $O(i)$ factor is there because it takes us `i` steps to find the linked list node for the `i`th element. 
However, remember that *once we have the `i`th linked list node, actually removing the element is $O(1)$.*
To understand why that bit of information is useful, let's remember that the the `LinkedList` iterator works by storing a reference to the current linked list node.
The variable `iter` already stores a reference to the `i`th linked list node!
Meanwhile, here we are in this algorithm, repeatedly looking for an `i`th node that we already have.

To address this performance issue, `Java` iterators include a `remove` method that removes the element most recently returned by `next`.
Our algorithm changes only slightly:

```java
  public void removeAllWithIteratorV2<T>(List<T> list, T element)
  {
    for(Iterator<T> iter = list.iterator(); iter.hasNext();){
      if(iter.next().equals(element)){
        iter.remove();
      }
    }
  }
```

The implementation of `remove` for an Array-based `Iterator` remains $O(N)$ (since the array still needs to shift elements at indices above $i$ to the left).
However, for a `LinkedList`-based iterator, the `remove` method drops to $O(1)$, since the iterator already has a _reference_ to the linked list node.

Although `remove` is the only method that appears in an iterator, you can see that nearly every other operation on a `LinkedList` (`add`, `set`) is $O(i)$ for essentially the same reason: `List` uses the list position to identify elements, and it costs $O(i)$ to find the linked list node for the `i`th element.  
However, if we already have a reference to the `i`th element (technically the $i-1$th element), each of these operations can be performed in $O(1)$.

Because of this unusual behavior, we usually give *two* separate runtimes for `LinkedList` operations: One runtime for the operation applied to a given index (on the `List` itself) and one runtime for the operation applied to a reference (e.g., on the `Iterator`).  

1. `get(i)`
    - *By Index*: $O(i)$
    - *By Reference*: $O(1)$
2. `set(i, v)`
    - *By Index*: $O(i)$
    - *By Reference*: $O(1)$
3. `add(i, v)`
    - *By Index*: $O(i)$
    - *By Reference*: $O(1)$
4. `remove(i)`
    - *By Index*: $O(i)$
    - *By Reference*: $O(1)$

=== Doubly Linked Lists

In the simple `LinkedList` we've described so far, often called a *Singly* linked list, each node contains a pointer to the next node in the chain (or `null` if it's the last node).
This is convenient for moving _forwards_ through the list, but sometimes it's convenient to be able to go _backwards_ through the list as well.  For example, try implementing the `LinkedList` iterator's `remove` method with a singly linked list, and you'll find that you need to keep track of several of the preceding nodes.

In a *Doubly* linked list, each linked list node also keeps a pointer to the previous node, and the linked list itself usually keeps pointers to the first _and last_ nodes in the list.
Although the extra pointers require extra book-keeping, all of the extra work is constant time.
As a result, a doubly linked list's operations have asymptotic runtime complexities that are at least as good as a singly linked list.
In fact, the `add` (i.e., append) operation becomes $O(1)$, since we have a pointer to the last element in the list (and so can access it _by reference_).

Moving forward, *we will assume that every linked list is a Doubly Linked List*.

== Array List, take 2 (Buffered Arrays)

There are many situations where it's useful to be able to append to a list.
As we already discussed, Java implements append as a special case of `add` that omits the `index` argument.
For example, if we have a `List` of log entries, new log entries will always be added to the end.
Similarly, implementations of some ADTs like `Stack` and `Queue`, which we'll discuss later, involve putting new elements at the end of a `List`.

#figure(
  image("graphics/lists-array-add.svg", width: 50%),
  caption: [
    Adding an item to an array requires (1) allocating a new space for the array, (2) copying the contents of the old array to the new space, and (3) updating the data pointer to the new space.
  ]
)<array_add>

As we just discussed, we can append to a doubly linked list in $O(1)$, but let's come back to the humble array, for which the `add` operation is shown in @array_add.
Thinking back, remember that the cost of `add` comes from two general tasks:
1. Copying every element of the array to a new array with one extra space: $O(N)$
2. Shifting every element of the array to the right by one spot: $O(N-i)$

In the case of append, we're inserting at the end; In other words $i=N$, and the cost of second step is $O(N-N) = 0$.
Since we're inserting at the last element, nothing needs to be moved over to make space for the new element.
However, we can't directly benefit from this observation, since we still need to copy every element into a new array.
So let's think how we might be able to avoid that copy.

=== Buffered Arrays (Attempt 1: Fixed Increment)

#figure(
  image("graphics/lists-bufferedarray.svg", width: 50%),
  caption: [
    An `ArrayList` allocates extra space to efficiently support append operations.
    The example above shows an `ArrayList` with 5 elements in use, and 5 unused spaces.
    The structure keeps track of both how many elements in the array are in-use, and how big the allocated array is.
  ]
)<bufferedarray>

One idea might be to set aside a little bit of extra space in the array when we first allocate it.
Let's say that when we're asked to create an $N$ element array, we instead allocate space for $N+B$ elements (@bufferedarray).
The extra $B$ elements are held in reserve until `add` is called.
Now, the next $B$ calls to `add` are free, and even after that, we can still allocate another $B$ elements.
Here's a simplified version of this idea with the one argument `add` implemented:

```java
public class FixedIncrementArrayList<T> implements List<T>
{
  static int B = 10;
  T[] data = new T[0];
  int size = 0;

  /* Other methods omitted */

  public void add(T elem)
  {
    if(size >= data.length){
      T[] temp = new T[data.length + B];
      for(i = 0; i < data.length; i++){
        temp[i] = data[i];
      }
      data = temp;
    }
    data[size] = elem;
    size += 1;
  }
}
```

If we're out of space (`size >= data.length`), we allocate a new array (`temp`) that is $B$ elements bigger, and copy every element of `data` into it.
After we replace the old array with the new one, we have free space.
Regardless of whether we had to allocate more space or not, we put the new `elem` into the first free slot, and shift `size` over by one step.
It should be clear that, in the common case (which happens in $(B-1)/B$ calls to `add`), this data structure will be faster than `Array`.
But let's dig deeper and do a proper analysis.  
Tagging every step in the algorithm with the runtime, we get:

```java
  public void add(T elem)
  {
    if(/* O(1) */){
      /* O(1) */
      for(/* O(1), looping with i from 0 to N */){
        /* O(1) */
      }
      /* O(1) */
    }
    /* O(1) */
    /* O(1) */
  }
```

Summing this up, we get:

$( cases(O(1) + (sum_(i=0)^N O(1)) + O(1), O(1)) ) + O(1) + O(1)$

We can apply the summation rule for summation of a constant, and get rid of some of the redundant $O(1)$s

$( cases(O(N), O(1)) ) + O(1)$

Remembering that Big-$O$ is an _upper_ bound, we take the worse case

$O(N) + O(1) = O(N)$

So, from a worst-case perspective, it seems as though we haven't actually improved anything.
That makes sense: On *any* call to `add`, it's possible that we might trigger the worst case behavior, and have to pay the $O(N)$ cost.
On the other hand, $B-1$ out of every $B$ calls only have to pay $O(1)$, so while any *one* call to `add` might behave badly, maybe this leads to better performance on average?

=== Amortized Analysis

A large part of the reason that asymptotic runtime complexity is useful is that it allows us to plan out our algorithms.
Big-$O$, a.k.a. "worst-case" run-times are a safe bet for that planning process, since you know that it can't be any worse.
However, there are some cases where strictly using Big-$O$ ends up being too conservative, and you actually end up with an algorithm that has better performance than following the rules of worst-case analysis would lead you to believe.
On the other hand, just giving up and saying "well, the analysis says X, but it's usually faster" isn't helpful when you're trying to be precise.

In short, we still want to be able to make _some_ formal claim about the runtime of this new `add` function that will help us to understand its behavior, but Big-$O$ isn't the right language to use for that.
We need to define some new terms#footnote[
  Amortized complexity, which we discuss here, is one of two relaxations of simple, or "unqualified" asymptotic complexity.  We'll talk about Expected complexity in the next chapter, as we introduce Quick Sort.
].
Intuitively, even if every $B$'th call to `add` is slow, most calls to `add` are fast.
If we're trying to prove something, maybe we can show that these fast calls "average" out to a faster runtime if we call `add` repeatedly.
For example, let's take the following loop, which just appends $L$ elements to a list of some sort:

```java
  public void addLots(List<Integer> list, int L)
  {
    for(i = 0; i < L; i++)
    {
      list.add(i);
    }
  }
```

Let's start off by seeing what happens if we assume that `list` starts off as an empty `SimpleArrayAsList`.  

```java
  public void addLots(List<Integer> list, int L)
  {
    for(/* O(1), looping with i from 0 to L */)
    {
      /* O(N) = O(i) */;
    }
  }
```

For a simple array, appending a new element is $O(N)$.
If we start off with an empty array, then on the `i`th insertion, $N = i$, so the add costs $O(i)$.
This gives us a total runtime of:

$T_"addLots1" (L) = O(1) + sum_(i = 0)^L (O(1) + O(i))$

Plugging in our standard summation formula and simplifying, we get:

$T_"addLots1" (L) = O(1) + O(L^2) = O(L^2)$

Now let's try the same thing with `FixedIncrementArrayList`.  If we do it naively, we get _exactly_ the same result, since `add` is $O(N) = O(i)$.  
However, this specific loop gives us a pattern we can benefit from: We know that every $B$ calls to `add` will be $O(N)$ and every other call will be $O(1)$.  The summation looks like this (assuming $L$ is divisible by $B$):

$T_"addLots2" (L) = underbrace(
  (overbrace(O(1) + ... + O(1), (B-1) "times") + O(B)) + ... +
  (overbrace(O(1) + ... + O(1), (B-1) "times") + O(L/B dot B)),
  L/B "times"
)$

Collapsing the $(B-1)$ times, we get:

$T_"addLots2" (L) = underbrace(
  (O(B-1) + O(B)) + (O(B-1) + O(2 dot B)) + ... + (O(B-1) + O(L/B dot B)),
  L/B "times"
)$

We can rearrange these terms to get:

$T_"addLots2" (L) = (underbrace(O(B-1) + ... + O(B-1), L/B "times")) + 
 (underbrace(O(1 dot B) + O(2 dot B) + O(3 dot B) + ... + O(L/B dot B), L/B "times"))$

And again, simplifying, we get:

$T_"addLots2" (L) = O(L/B dot (B-1)) + sum_(i = 1)^(L/B) O(i dot B) = O(L) + O(B) dot sum_(i = 1)^(L/B) O(i)$

Plugging in our summation formula and simplifying, we get

$T_"addLots2" (L) = O(L) + O(B) dot O(L^2 / B^2) = O(L) + O(L^2 / B) = O(L^2 / B)$

This should make intuitive sense: Since we're only paying the cost of an expensive copy on every $B$ insertions, the cost of $L$ appends into an empty `FixedIncrementArrayList` is $1/B$th of the cost of the same appends into a simple array list.
If we average the individual cost of each of the $L$ calls, each individual call "behaves" like its runtime is $O(L/B)$.

Put another way, in the worst possible case, `FixedIncrementArrayList.add` is $O(N)$.
However, if we're specifically analyzing the behavior of `add` when it is called in a loop, it's actually 100% safe to pretend like `add` is $O(N/B)$.

We want a way to talk about this sort of behavior, where an operation on a data structure has a better runtime when it's called in a loop: A way to distinguish the 'looping' runtime complexity from the normal runtime complexity.
The technical term for this better runtime is the "*amortized* runtime complexity" of the algorithm.

*Formally*, if the amortized runtime complexity of an operation is $O(f(N))$, then the normal, or "unqualified" runtime complexity#footnote[
  If the term "unqualified" seems a bit strange here, it's because the term "amortized" is a _qualifier_ that modifies the meaning of runtime complexity.  "un-qualified" doesn't mean that it's not good at anything, but just that we're talking about the runtime complexity without any qualifiers.  Next chapter, we'll introduce one more type of qualifier: "expected."
] of $N$ calls to the operation are guaranteed to be $O(N dot f(N))$.

For the running example, we would say that:
- The *unqualified* runtime complexity of `add` for `FixedIncrementArrayList` is $O(N)$
- The *amortized* runtime complexity of `add` for `FixedIncrementArrayList` is $O(N/B)$

Note that, it's possible to describe amortized complexity bounds as being "tight", if we know that we can't get a better bound.
It's worth noting that the *tight amortized runtime complexity is never worse than the tight unqualified runtime complexity* of an algorithm, since invoking an algorithm in a loop can not make it slower.
Formally, if the unqualified runtime is $O(f(N))$, then $N$ invocations is $sum_(i=0)^N O(f(N)) = O(N dot f(N))$, so by our definition above, the amortized runtime can not be worse than $O(f(N))$.


=== Buffered Arrays (Attempt 2: Exponential Increment)

*(Alternative title: Try this one neat trick to get your asymptotic runtime bound down to $O(1)$)*

The amortized runtime complexity of `add` for `FixedIncrementArrayList` is better than that of `SimpleArrayAsList`. 
However, in most cases $B$ is a constant, and so asymptotically $O(N)$ and $O(N/B)$ are the same.
Put another way, doubling $N$ still doubles the runtime, even under amortized analysis.
However, as it turns out, if we're a bit more clever about how we resize the array, we can actually push the asymptotic bound down to a lower complexity class: $O(1)$.
The trick here is that, instead of adding a fixed size to the array ($B$) whenever we resize it, we always double the size of the array instead.
This is the idea behind the `ArrayList` that is implemented in the Java standard library.

```java
public class ArrayList<T> implements List<T>
{
  T[] data = new T[1];
  int size = 0;

  /* Other methods omitted */

  public void add(T elem)
  {
    if(size >= data.length){
      T[] temp = new T[data.length * 2]; // Double the array size
      for(i = 0; i < data.length; i++){
        temp[i] = data[i];
      }
      data = temp;
    }
    data[size] = elem;
    size += 1;
  }
}
```

Analyzing the amortized runtime of this new version of `add` is a little trickier than the previous two instances of Array-based lists, but we can use the same strategy that worked with `FixedIncrementArrayList`: (i) Plug `ArrayList` into `addLots`, (ii) Rearrange terms to put the fast and slow cases together, (iii) Simplify.
Let's start by figuring out how 'slow' calls there are, where we need to copy.

- The first `add` call is $O(1)$ (array length 1).
- The 2nd `add` call requires a copy (array length 2).
- The 3rd `add` call requires a copy, and the next 1 call is $O(1)$ (array length 4).
- The 5th `add` call requires a copy, and the next 3 calls are $O(1)$ (array length 8).
- The 9th `add` call requires a copy, and the next 7 calls are $O(1)$ (array length 16).
- The 17th `add` call requires a copy, and the next 15 calls are $O(1)$ (array length 32).

The general pattern here is that the $i$th copy occurs on the $(2^(i)+1)$th call to `add`.
All the remaining calls are cheap.
Put another way, after $2^x$ calls to `add`, we will have resized the array $x-1$ times.
So, if we want to call `add` $N$ times, we can set up an equation to solve for $x$:

$N = 2^x$

Log is the inverse of exponent, so:

$log_2 N = log_2 2^x = x$

Plugging this back into our formula ($x-1$), we find that we will have resized the array $log_2 (N) - 1 = O(log_2(N))$ times.  
On the $i$th time we need to resize the array, the array will have $2^(i-1)$ elements in it.  So, we can figure out the total runtime of the calls to add as:

$T_"addLots3" (L) = 
  underbrace(
    O(1) + 2 O(1) + 4 O(1) + ... + (N-1) O(1),
    log_2 (N) - 1 "times"
  ) + 
  underbrace(
    O(1) + O(1) + ... + O(1),
    N - (log_2 (N) - 1) "times"
  )
)$

We can summarize this as:

$T_"addLots3" (L) = 
  (sum_(i = 0)^(log_2 (N) - 1) 2^(i) O(1))
  + 
  (sum_(i = 0)^(N - (log_2 (N) - 1)) O(1))
$

Factoring out the $O(1)$ terms and expanding out the summations, we get:

$T_"addLots3" (L) = 
  O(1) dot (2^(log_2 (N) - 1 + 1) - 1) 
  + 
  O(1) dot (N - log_2 (N) + 2)
$

Simplifying and noting that $2^(log_2 (N)) = N$, we get

$T_"addLots3" (L) = 
  (O(N) - O(1)) + (O(N) - O(log_2(N)) + O(1))
$

And since the dominant term here is $O(N)$, the whole thing reduces to

$T_"addLots3" (L) = O(N)$

Remember that `addLots` calls `add` $N$ times, so each individual call 'behaves' like it is $O(N) / N = O(1)$.
In other words, the *amortized* runtime complexity of `add` is $O(1)$!
It's left as an exercise for you to prove that the unqualified runtime complexity of `add` is still $O(N)$, so this might feel a bit weird: $N$ calls to an $O(N)$ operation should normally be $O(N^2)$, but in this specific case, it's actually $O(N)$, a substantially lower complexity class.
What is it about exponentially growing the array, doubling its size every time, that makes this possible?

The intuition here is that every time you double the size of the array from $N$ to $2N$ you're putting in $O(N)$ work to copy elements, but you can now do $N$ insertions before you need to copy again.
This is true, even as $N$ grows.  Each time, no matter how big $N$ gets, $O(N)$ work gets you another $N$ insertions.
The $O(N)$ work "amortizes" over the next $N$ insertions, and the ratio of cost to insertions stays the same.
Contrast this with the Fixed-Increment Array List, where increasing the size of the array from $N$ to $N+B$ took $N$ work, but only provided space for another $B$ insertions.  $N$ grows, while $B$ stays the same, and the ratio of cost to insertions keeps growing.

*Note:* It can be tempting to think that, if a data structure promises an $O(1)$ amortized runtime for an operation, you can safely treat the operation as $O(1)$ in all cases.
However, as exemplified in `ArrayList`, the cost of array resizing can actually get quite high.  Even though the cost amortizes over multiple calls, there are many use cases where `ArrayList` is not appropriate.
For example, let's say you're building a high-performance scientific data sensing application, which needs to be able to append sensor readings with sub-microsecond latencies.  
`ArrayList` would *not* be appropriate for such an application, because some sensor readings would have to block on the array list while it resizes, violating the quality of service guarantees.


== Recap

To summarize, we have introduced two ADTs: `Sequence` and the more general `List`; as well as three main data structures: The `Array`, the `LinkedList`, and the `ArrayList`. 
Overall asymptotic runtime bounds for these structures, assuming a Doubly-Linked list with a pointer to the last element, are as follows:


#table(
  columns: 5,
  inset: 10pt,
  align: horizon,
  stroke: none,
  table.header(
    [],
    table.vline(),
    `Array`,
    [`LinkedList` (by Idx)],
    [`LinkedList` (by Ref)],
    `ArrayList`
  ),
  table.hline(),
  [`get(i)`],
    $O(1)$,
    $O(i)$,
    $O(1)$,
    $O(1)$,
  [`set(i,v)`],
    $O(1)$,
    $O(i)$,
    $O(1)$,
    $O(1)$,
  [`add(i,v)`],
    $O(N)$,
    $O(i)$,
    $O(1)$,
    [$O(N-i)$ amortized, $O(N)$ unqualified],
  [`add(v)`],
    $O(N)$,
    $O(1)$,
    $O(1)$,
    [$O(1)$ amortized, $O(N)$ unqualified],
  [`remove(i)`],
    $O(N)$,
    $O(i)$,
    $O(1)$,
    $O(N-i)$,
)