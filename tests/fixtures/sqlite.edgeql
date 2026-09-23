module default {
  type User {
    required property name -> str;
    property age -> int64;
    property active -> bool;
    required link manager -> User;
    multi link friends -> User;
    multi property tags -> str;
  }
  type Post {
    required property title -> str;
    required link author -> User;
  }
}

create type Audit {
  create required property action -> str;
};
