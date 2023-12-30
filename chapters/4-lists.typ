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

This `interface` states that any class that implements `Moof` must provide `foo`, `bar`, and `baz` methods, with arguments and return values as listed above.
This is not especially helpful, since it doesn't give us any idea of what these methods are supposed to do.
Contrast `Moof` with the following interface:
```java
public interface MutableSequence<T>
{
  public void update(T value, int index);
  public T get(int index);
  public int size();
}
```
`Sequence` is semantically identical to `Narf`, but far more helpful.
Just by reading the names of these methods, you get some idea of what each method does, and how it interacts with the state represented by a `Sequence`. 
You can build a mental model of what a Sequence is from these names.

An Abstract Data Type is:
1. A mental model of some sort of data (a data type)
2. One or more operations for accessing or modifying that state (an interface)
3. Any other rules for the state (constraints)

For most ADTs discussed in this book, the state modeled by the ADT is some sort of collection of elements.

A data structure is a *specific* strategy for organizing data.  We say that the data structure implements (or conforms to) an ADT if:
1. The data structure stores the same type of data as the ADT
2. Each of the operations required by the ADT can be implemented on the data structure
3. The operation implementations are guaranteed to respect the rules for the state.

== The Sequence ADT

A very common example of an ADT is a sequence.  Examples include: 

- The English alphabet ('A', 'B', ..., 'Z')
- The Fibbonacci Sequence (1, 1, 2, 3, 5, 8, ...)
- An arbitrary collection of numbers (42, 19, 86, 23, 19)

What are some commonalities in these examples?

- Every sequence is a collection of elements of some type `T` (integer, character, etc...)
- The same element may appear multiple times.
- Every sequence has a size $N$ (which may be infinite).
- Every element (or occurrence of an element) is assigned to an index: $0 <= "index" < N$.
- Every index in the range $0 <= "index" < N$ has exactly one element assigned to it.

What kind of operations can we do on a sequence#footnote[
  Note: Although several of the ADTs and data structures we'll present throughout this book correspond to actual Java interfaces and classes, `Sequence` is *not* one of them.  However, it serves as a useful introduction to the `List` interface that we'll encounter later on.
]?
```java
public interface Sequence<T>
{
  /** Retrieve the element at a specific index */
  public T get(int index);
  /** Obtain the size of the sequence */
  public int size();
}
```

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

=== Arbitrary Sequences

Often, however, we want to represent an sequence of *arbitrary* elements.
We won't have simple rule we can use to translate the index into a value.
Instead, we need to store the elements somewhere if we want to be able to retrieve them.  
We need an *array*.

Let's take a brief diversion into the guts of a computer.  
Most computers store data in a component called RAM#footnote[
  This is a pretty blatant lie... but a useful simplification for now.  We'll walk the lie back slightly later in the book.
].  
You can think of RAM as being a ginormous sequence of bits (0/1 values).  
We've set up some rules for how bits can be used to encode other information.
The details of how that works are not immediately relevant to us, but two things are useful to know:
1. Most basic data values (integers, decimals, characters, dates) can be represented using a fixed number of bits (e.g., 8 bits per character#[
  This is another blatant lie.  Characters can sometimes take 16 bits, and for special characters like emoji, they can consist of a semi-random group of 16-bit sequences.  String encodings are a real mess.  Similarly, integers and decimals are only representable up to a fixed upper bound/precision.  Don't get us started on dates.  For most purposes though, this is a reasonable assumption.
])
2. The number of bits required in most cases are multiples of 8, so we usually talk about] the number of bytes required (1 byte = 8 bits).

For example, the ASCII character encoding forms the basis for most character representations we use today, and assigns each of the letters of the English alphabet (upper and lower case, and a few other symbols) to a particular sequence of 8 bits (one byte).
Let's say we wanted to store the sequence 'H', 'e', 'l', 'l', 'o'.  
The ASCII code for 'H' is hexadecimal 0x48, or binary 01001000.
We would store that byte at one position in RAM, then the ASCII encoding of 'e' at the next byte, and then the encoding of 'l' at the next byte, and so forth.

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
If the array has a thousand, or a million, or a trillion elements, we can still obtain the $i$th element with one multiplication and one addition.  
In other words, the cost of retrieving an element is constant (i.e., $Theta(1)$)#footnote[
  The attentive reader might note that we still need to retrieve $E$ bytes, and so technically the cost of an array access is $Theta(E)$.  However, we're mainly interested in how runtime scales with the size of the collection, as $E$ is fixed upfront, and usually very small.  So, more precisely, *with respect to $N$*, the cost of retrieving an element from an array is $Theta(1)$.
  The even more attentive reader might be aware of things like caches, which we're going to ignore until much later in the book.
].

==== Arrays In Java

Java provides a convenient shorthand for creating and accessing arrays using square brackets.  To instantiate an array, use `new`:
```java
int[] myArray = new int[100];
```
Note that the type of an integer array is `int[]`#footnote[
  Java sort of allows you to store variable size objects in an array.  For example, `String[]` is a valid array type.  The trick to this is that Java allocates the actual string _somewhere else in RAM_.  What it stores in the actual array is the address of the string (also called a pointer).
], and the number of elements in the array must be specified upfront (`100` in the example above).  To access an element of an array use `[index]`.
```java
myArray[10] = 29;
int myValue = myArray[10];
assert(myValue == 29);
```

Java arrays are *bounds-checked*.  
That is, Java stores the size of the array as part of the array itself (the first 4 bytes of the array stores the number of elements).
Whenever you access an array element, Java checks to make sure that the index is greater than or equal to zero and less than the size.
If not, it throws an `IndexOutOfBounds` exception otherwise.
As a convenient benefit, bounds checking means we can get the array size from Java.
```java
int size = myArray.size
assert(size == 100)
```

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

Since there's no way to modify the array through the `Sequence` interface, the class initializer allows us to import a pre-constructed array.

=== Mutable Sequences

The Fibonacci sequence and the English alphabet are examples of *immutable* sequences: Sequences that are pre-defined and can not be changed.  
However, there's technically nothing stopping us from just modifying the bytes of an array's element.
We can make our `Sequence` ADT a little more general by adding a way to modify its contents.  
We call the resulting ADT a `MutableSequence`#footnote[
  Note: Like `Sequence`, the `MutableSequence` is not a thing in Java.  Its role is subsumed by `List`, which we'll discuss shortly.
].

```java
public interface MutableSequence<T> extends Sequence<T>
{
  public void update(T value, int index)
}
```

The `extends` keyword in java can be used to indicate that an interface takes in all of the methods of the extended interface, and potentially adds more of its own.  In this case `MutableSequence` has all of the methods of `Sequence`, plus its own `update` method.

To prove to ourselves that the `Array` implements the `MutaleSequence` ADT, we can implement its methods:
```java
public class MutableArraySequence<T> implements MutableSequence<T>
{
  T[] data;

  public ArraySequence(int size){ this.data = new T[size]; }
  public void update(T value, int index) { data[index] = value; }
  public T get(int index) { return data[index]; }
  public int size() { return data.size; }
}
```

Note how we initialize the `Array` to a specified size instead of bringing in an existing array.

=== Array Summary

- Retrieving an element of an Array (i.e., `array[index]`) is $Theta(1)$
- Updating an element of an array (i.e., `array[index] = ...`) is $Theta(1)$
- Retrieving the array's size (i.e., `array.size`) is $Theta(1)$

////////////////////////////////////////////
== The List ADT

Although we can change the individual elements of an array, once it's allocated, the size of the array is fixed.  
This is reflected in the `MutableSequence` ADT, which does not provide a way to change the sequence's size.
Let's design our next ADT by considering how we might want to change an array's size:

- Inserting a new element at a specific position
- Removing an existing element at a specific position 

It's sometimes convenient to treat inserting at/removing from the front and end of the sequence as special cases, since these are both particularly common operations.

We can summarize these operations in the `List` ADT#footnote[
  See Java's #link("https://docs.oracle.com/javase/8/docs/api/java/util/List.html")[List interface].
]:

```java
public interface List<T> extends MutableSequence<T>
{
  /** Append an element to the list */
  public void add(T element);
  /** Insert an element at an arbitrary position */
  public void add(int index, T element);
  /** Remove an element at a specific index */
  public void remove(int index);
  // ... and more operations that are not relevant to us at the moment.
}
```

=== A simple Array as a List

We can still use `Array`s to implement the `List` ADT, but doing so isn't cheap.  
Since we can't change the size of an `Array` once it's allocated#footnote[
  The "C" language has a method called `realloc` that can *sometimes* change the size of an array... if you're lucky and the allocator happens to have some free space right after the array.
  However, in this book we try to avoid relying purely on unconstrained luck.
], we'll need to allocate an entirely new array to store the updated list.
Once we allocate the new array, we'll need to copy over everything in our original array to the new array.

```java
public class SimpleArrayAsList<T> extends MutableArraySequence implements List<T>
{
  // data, get, update, size() inherited from MutableArraySequence

  public void add(T element){ add(size(), element); }
  public void add(int index, T element)
  {
    // Skipped: Check that index is in-bounds.
    T[] newData = new data[size() + 1];
    for(i = 0; i < newData.size; i++){
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
    for(i = 0; i < newData.size; i++){
      if(i < index){ newData[i] = data[i]; }
      else { newData[i] = data[i+1]; }
    }
  }
}
```

Let's look at the runtime of the `add` method:
- We'll assume that memory allocation is constant-time ($Theta(1)$)#footnote[
  Lies!  Lies and trickery!  Memory allocation may require zeroing pages, multiple calls into the kernel, page faults, and a whole mess of other nonsense that scale with the size of the memory allocated.  Still, especially for our purposes here, it's usually safe to assume that the runtime of memory allocation is a bounded constant.
].
- We already said that array updates and math operations are constant-time ($Theta(1)$)

So, we can view the the `add` method as
```java
public void add(int index, T element)
{
  /* Theta(1) */
  for(i = 0; i < newData.size; i++)
  {
    /* Theta(1) */
  }
}
```

Recalling how we use $Theta$ bounds in an arithmetic expression, we can rewrite the runtime and simplify it as:

- $T_"add"(N) = Theta(1) + sum_(i = 0)^"newData.size" Theta(1)$
- $ = Theta(1) + sum_(i = 0)^(N+1) Theta(1)$ (`newData` is one bigger than the original $N$)
- $ = Theta(1) + (N+2) dot Theta(1)$ (Plugging in the formula for summation of a constant)
- $ = Theta(1+N+2)$ (Merging $Theta$s)
- $ = Theta(N)$ (Dominant term)

The runtime of the `remove` method can similarly be computed as $Theta(N)$.

== Linked Lists

$Theta(N)$ is not a particularly good runtime for simple "building block" operations like `add` and `remove`.  
Since these will be called in loops, the `Array` data structure is not ideal for situations where a `List` is required.

The main difficulty with the `Array` is that memory allocation happens at the granularity of the entire list: A single _chunk_ of allocated memory holds all elements in the list.
So, instead of allocating one chunk for the entire list, we can go to the opposite extreme and give each element its own chunk.

Giving each element its own chunk of memory makes allocating space for new elements (or releasing space for removed elements) easy, since we can do so without copying anything.
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




=== Doubly Linked Lists