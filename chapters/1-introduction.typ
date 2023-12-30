= Introduction

Data Structures classes often have a mixed reception.
One of the most common things I hear from students is that it's hard to see how the concepts they learn get deployed into practice: We don't solve specific problems.
Although we will try to map many of the ideas we discuss to specific problems that you'll encounter as a computer scientist, it's also important to think about the content you learn in this class in a more general sense: as a set of tools for your toolbox.

This class will introduce you to the hammers, wrenches, and screwdrivers of computer science.
We'll show you how to decide whether a phillips-head or a flathead screwdriver is better for your use case; when to use a socket wrench or a crescent wrench.

A bit less metaphorically, this class will present a set of organizational strategies (data structures) suitable for different use cases (abstract data types).
We'll also introduce asymptotic complexity, a way to quickly summarize the performance characteristics of data structures (and a tool for thinking about algorithms).

== What to get out of this Data Structures class?

=== An intuition for data structures

We'll talk about the material at a precise, formal level, but we honestly hope that you learn the material to a point where you internalize it.  
If, after this class, you never again consciously think about the fact that prepending to a linked list is $O(1)$, that's fine.
What we care about is that you develop the intuition
- ... that you develop an instinct for which data structure is right for a given situation.
- ... that you get a little cringe in the back of your brain when you see in the documentation that a method you need to call repeatedly is $O(N)$.
- ... that you get a little cringe in the back of your brain when you see a doubly nested loop, or another piece of $O(N^2)$ or worse code.

=== Practice with formal proofs and recursion

By the time you take this class, you should have already taken a discrete math class and gotten your first exposure to proofs and recursive thinking.
This class is intended to develop those same skills:
- We'll review an assortment of proofs regarding algorithm runtimes using specific data structures. 
- We'll discuss specific strategies you can use while proving things.
- We'll review recursion and discuss approaches to identifying problems that can be solved through recursion and how to use recursion as a problem solving technique.

== What this class is not.

In contrast to many data structures classes, which introduce C programming, memory management, and other related concepts, UB's 250 is intended as a concepts/theory-style class.
To be clear, we will use code.  
Example code will be given in Java (or some cases Python), and we'll make extensive use of Java's class inheritance model.
We will use code  code to reinforce and motivate concepts that you will learn throughout the class.
However, the primary focus of this class is on understanding asymptotic analysis and adding the standard suite of data structures to your toolbox.

== A word on Lies and Trickery

"All models are wrong, but some are useful"

This is an introductory text.
As such, you should expect that many of the things we say are simplified for the purposes of presentation.
Some assertions (e.g., array accesses are constant-time) will be outright lies with respect to code running on modern computers.
Nevertheless, these simplifications are here for a reason.
It will be far easier to first grok the simpler model of code and data organization, before delving into the more nuanced details and special cases.

In general, we highlight some of the more blatant lies with footnotes that also hint at some of the nuanced details.
In a few cases (e.g., constant time array accesses), we'll peel back the lies later on in the book.  

That being said, these footnotes are primarily here for the pedants and excessively curious among you.  
You should still be able to understand the rest of the book even if you ignore every single footnote in the text.

