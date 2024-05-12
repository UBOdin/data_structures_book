= Introduction

Data Structures classes often have a mixed reception.
Students frequently say that it's hard to see how concepts from data structures get deployed into practice.  
They complain that the class doesn't teach them to solve specific problems.
To some extent, that's true.  
This class is less about learning how to build the next AI, data management system, or website.
Instead, this class is about giving you a set of simple tools that you'll be able to reach for, no matter what great things you end up doing.
In short, this class will introduce you to the hammers, wrenches, and screwdrivers of computer science.
We'll show you how to decide whether a phillips-head or a flathead screwdriver is better for your use case; when to use a socket wrench or a crescent wrench.

A bit less metaphorically, this class will teach you to think about different data management use cases (called abstract data types), and give you a set of data organization strategies (called data structures) suitable for each.
We'll also introduce asymptotic complexity, a way to quickly summarize the performance characteristics of data structures (and a tool for thinking about algorithms).
Finally, we'll nudge you to start thinking about code a bit more formally, less as a sequence of instructions, and more in terms of the goals those instructions are trying to achieve.

== What should you get out of this Data Structures class?

=== An intuition for data structures

Throughout the book (and class), we'll try to be precise and formal when talking about course material.
That said, we're less interested in you learning the precise formalism, and more interested in you developing an intuition about what the formalism represents.
It's possible (even likely) that after leaving this class, you will never again consciously think about the fact that prepending to a linked list is $O(1)$.
If so, that's fine.  What we care about is ...
- ... that you develop an instinct for which data structure is right for a given situation.
- ... that you get a little cringe in the back of your brain when you see a method with an $O(N)$ complexity.
- ... that you get a little cringe in the back of your brain when you see a doubly nested loop, or another piece of $O(N^2)$ or worse code.

=== Practice with formal proofs and recursion

By the time you take this class, you should have already taken a discrete math class and gotten your first exposure to proofs and recursive thinking.
This class is intended to develop those same skills further:
- We'll review an assortment of proofs regarding algorithm runtimes using specific data structures. 
- We'll discuss specific strategies you can use while proving things.
- We'll review recursion and discuss approaches to identifying problems that can be solved through recursion and how to use recursion as a problem solving technique.

Apart from preparing you for subsequent theory-oriented classes, our goal here is to give you some tools that you can use to think critically about code that you write, and that you need to debug.
If, in five years, you completely forget how to prove that quick sort is Expected-$O(N log N)$, it'll make us sad, but we'll understand.
Instead, we hope that you'll walk away from the class with the instinct to write down invariants for code that you're trying to write or debug.

== What this class is not.

In contrast to many data structures classes, which introduce C programming, memory management, and other related concepts, UB's 250 is intended as a concepts/theory-style class.
We will use code.  
We will spend some time talking about the mechanics of how a computer runs that code.

We'll provide lots of example code in Java (or some cases Python), and we'll make extensive use of Java's class inheritance model.
These examples are there to motivate concepts that you will learn throughout the class, or to make the concepts a bit more precise and concrete.
However, we assume that you already know how to program in a major object-oriented language (like Java or Python).
This is not a class to learn to program; We're here to teach you asymptotic analysis, data structures (ignoring language details where possible), and proof techniques.

== A word on Lies and Trickery

"All models are wrong, but some are useful"

This is an introductory text.
You should expect that many of the things we say are simplified for the purposes of presentation.
Some things we say and write (e.g., all array accesses are constant-time) will be outright lies (at least for modern computers).
However, we make these simplifications intentionally, because it's far easier to grok the simpler model of code and data organization, and because the simpler model is a reasonable approximation (up to a point).

We'll add footnotes that highlight some of the more blatant lies, and hint at some of the nuanced details.
In a few cases (e.g., constant time array accesses), we'll also walk back the approximation a bit later in the book.
That said, these footnotes are primarily present for the pedantic and the curious.
You should still be able to understand the rest of the book even if you ignore every single footnote in the text.

