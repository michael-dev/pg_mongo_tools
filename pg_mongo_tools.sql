CREATE OR REPLACE FUNCTION from_mongo(database_in text, collection_in text) RETURNS SETOF JSON AS $$
    import pymongo
    import json
    from pymongo import Connection
    from bson import json_util

    q = plpy.prepare("SELECT * FROM mongo_config where alias = $1", [ "text" ])
    rv = plpy.execute(q, [ database_in ])
    connection = Connection(rv[0]["host"],rv[0]["port"])
    db = connection[rv[0]["db"]]
    collection = db[collection_in]
    for product in collection.find():
        yield(json.dumps(product, default=json_util.default))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION from_mongo(database_in text, collection_In text, predicate text) RETURNS SETOF JSON AS $$
    import pymongo
    import json
    from pymongo import Connection
    from bson import json_util

    q = plpy.prepare("SELECT * FROM mongo_config where alias = $1", [ "text" ])
    rv = plpy.execute(q, [ database_in ])
    connection = Connection(rv[0]["host"],rv[0]["port"])
    db = connection[rv[0]["db"]]
    collection = db[collection_in]
    for product in collection.find( json.loads(predicate, object_hook=json_util.object_hook) ):
        yield(json.dumps(product, default=json_util.default))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION to_mongo(database_in text, collection_in text, dataset JSON) RETURNS JSON AS $$
    import pymongo
    import json
    from pymongo import Connection
    from bson import json_util

    q = plpy.prepare("SELECT * FROM mongo_config where alias = $1", [ "text" ])
    rv = plpy.execute(q, [ database_in ])
    connection = Connection(rv[0]["host"],rv[0]["port"])

    collection = db[collection_in];
    collection.insert( json.loads(dataset, object_hook=json_util.object_hook) )
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION mongo_configure( alias_in text, database_in text, hostname_in text, port_in int ) RETURNS BOOLEAN LANGUAGE plpgsql 
AS $$
BEGIN
	CREATE TABLE IF NOT EXISTS mongo_config( alias text, db text, host text, port int, CONSTRAINT pmc_pk PRIMARY KEY
(alias), UNIQUE(db, host) );
	INSERT into mongo_config values ( alias_in, database_in, hostname_in, port_in);
	RETURN true;
END
$$;

CREATE OR REPLACE FUNCTION mongo_configure( alias_in text, database_in text, hostname_in text ) RETURNS BOOLEAN LANGUAGE plpgsql 
AS $$
BEGIN
	PERFORM mongo_configure( alias_in, database_in, hostname_in, 27017 );
	RETURN true;
END
$$;

CREATE OR REPLACE FUNCTION mongo_configure( alias_in text, database_in text ) RETURNS BOOLEAN LANGUAGE plpgsql 
AS $$
BEGIN
	PERFORM mongo_configure( alias_in, database_in, 'localhost');
	RETURN true;
END
$$;
