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
*remark - is assumed that the tables have a key autoincrement field*
1. table_product.sql - creating table with trigger, copying row befor update to json
2. script.sql - scripts for backuping to json and restore values

# Extension of the idea
Сommit all changes during the transaction execution.
And after it is completed, we can save the previous state of the data and roll back to it.
