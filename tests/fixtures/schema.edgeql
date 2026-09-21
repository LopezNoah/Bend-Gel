# SDL-style module schema.  This lives in an .edgeql fixture so the IO path
# exercises the same source loading code used for query files.
module default {
  type User {
    required property name -> str;
    property age -> int64;
    multi link friends -> User;
  }
}

# DDL-style declaration.
create type Audit {
  create required property action -> str;
};

select User {
  name,
  age
}
filter .age = 21
order by .name asc;

insert User {
  name := 'Ada'
};
