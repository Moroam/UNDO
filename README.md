# UNDO
Backup / copy full rows to JSON in MySql

# Problem
There is a problem saving the history of data changes in the database .
Similarly, there is a problem of restoring the original information (changed or deleted in the process).

However, there may be a large number of tables with different structures. 

Creating a separate procedure for each table is not a good idea. 

# Idea
We need to use a universal structure for storing data about changes. 
This format is the well-known JSON.

# Concept of proof
