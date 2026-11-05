.open dogbox.db
.mode box

drop table if exists dogs;
drop table if exists subscriptions;
drop table if exists owners;
drop table if exists plans;
drop view if exists dogOwners;
drop view if exists ownerSubscriptions;

create table if not exists owners(
    ownerID integer primary key,
    firstName text not null,
    lastName text not null,
    email text not null unique
);

create table if not exists dogs(
    dogID integer primary key,
    name text not null,
    breed text,
    gender text,
    age integer,
    ownerID integer,
    check(gender=="F" or gender=="M"),
    foreign key (ownerID) references owners (ownerID)
        on update cascade
        on delete cascade
);

create table if not exists plans(
    planID integer primary key,
    planName text not null,
    price real,
    numToys integer
);

create table if not exists subscriptions(
    subID integer primary key,
    ownerID integer,
    planID integer,
    foreign key (ownerID) references owners (ownerID)
        on update cascade on delete cascade,
    foreign key (planID) references plans (planID)
        on update cascade on delete cascade
);

--vreate the views, like saved select statements
create view if not exists dogOwners as
    select * from owners natural join dogs;
create view if not exists ownerSubscriptions as
    select * from owners natural join plans natural join subscriptions;

insert into owners (firstName,lastName,email) values
    ("Melissa","Fishel","test@test.com"),
    ("Tom","Darling","abc@xyz.com"),
    ("Becky","Smith","go@stay.com");

insert into dogs (name,breed,gender,age,ownerID) values
    ("Ruby","Golden","F",4,1),
    ("Zuko","Huskie","M",4,2),
    ("Flora","Huskie","F",3,2);

insert into plans (planName,price,numToys) values
    ("Basic",14.99,3),
    ("Gold",19.99,5),
    ("Platinum",24.95,8),
    ("Trial",0,1);

insert into subscriptions (ownerID,planID) values
    (1,2),(2,1),(2,3);

select * from owners
    inner join dogs on dogs.ownerID=owners.ownerID;
