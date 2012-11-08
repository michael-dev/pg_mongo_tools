pg_mongo_tools
=============
Homepage: http://github.com/kerr23/pg_mongo_tools

A set of functions written in PL/Python to interact with a MongoDB from PostgreSQL

These functions are different from the Mongo Foreign Data Wrapper (http://pgxn.org/dist/mongo_fdw)
in that they utilize the JSON datatype which is new in PostgreSQL 9.2. 

FDWs require that you create a table that has the same structure of your MongoDB documents,
this is undesireable since one of the things that makes MongoDB so powerful is it's fluid schema.
(Not exactly schema-less, but close)

Prerequisites
=============

* The MongoDB Driver for Python must be installed on your server (https://github.com/mongodb/mongo-python-driver)
* PL/Python must be installed and created in your database

Installation
=============

   psql -f pg_mongo_tools.sql <database>


Setup
=============

To get started you need to run pg_mongo_configure, this creates a table called mongo_config that
holds connection info for MongoDB.

   pg_mongo_configure( ALIAS, DATABASE, HOST, PORT )

- ALIAS is the common name you'll use for your database @ this host
- DATABASE is the name of the MongoDB database
- HOST is the MongoDB hostname (defaults to localhost)
- PORT is the MongoDB port (defaults to 27017)


Usage
=============

Find all records from your collection, or it will send the JSON predicate for your query.

   from_mongo( DATABASE, COLLECTION, [ PREDICATE ] )

   Example:
   dkerr=# select from_mongo('pcat','products', '{"type": "phone"}');
                                                            from_mongo                                                            
   ----------------------------------------------------------------------------------------------------------------------------------
   {"available": true, "warranty_years": 1, "name": "AC3 Phone", "price": 200, "_id": "ac3", "type": "phone", "brand": "ACME"}
   {"available": false, "warranty_years": 1, "name": "AC7 Phone", "price": 320, "_id": "ac7", "type": "phone", "brand": "ACME"}
   {"available": true, "warranty_years": 0.25, "name": "AC9 Phone", "price": 333.0, "_id": "ac9", "type": "phone", "brand": "ACME"}
   (3 rows)

NOTE: I suspect this function may eat a lot of memory for a large number of records returned.


Insert a record into your collection.

   to_mongo( DATABASE, COLLECTION, DATASET )

   
