#set page(width: 8.5in, height: 11in)
#set heading(numbering: "1.")
#show figure.caption: strong
#show heading: set text(navy)
#show heading.where(level: 1): it => [
  #set text(navy)
  #set align(center)
  #pagebreak() 
  #underline[
    Chapter #counter(heading).display() #emph(it.body) 
  ]
]
#set document(title: "CSE 250: Data Structures")

#align(center + horizon)[
  #text(size: 40pt)[CSE 250: Data Structures]

  #text(size: 20pt)[Course Reference]
]

#outline()

#include "chapters/1-introduction.typ"
#include "chapters/2-math.typ"
#include "chapters/3-asymptotic.typ"
#include "chapters/4-lists.typ"
#include "chapters/5-recursion.typ"
// Chapter 6: The Stacks and Queue ADTs
// Chapter 7: The Graph ADT and Graph Traversal
// Chapter 7: The Priority Queue ADT
// Chapter 8: Binary Search Trees
// Chapter 9: Hash Tables
// Chapter 10: Spatial Indexing
// Chapter 11: On-Disk Data Structures