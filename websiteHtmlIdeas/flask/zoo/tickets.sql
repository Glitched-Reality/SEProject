--this file will create a new table to keep track of ticket orders

.open fishelzoo.db
.mode box

drop table if exists tickets;

create table if not exists tickets(
    orderNumber integer primary key,
    name text not null,
    contact text,
    visitDate date,
    numTickets integer,
    confirmation text not null unique,
    check (numTickets>0)
);


--add one row of test data
insert into tickets
    (name,contact,visitDate,numTickets,confirmation)
    values
    ("James","317-111-1111","2025-03-20",3,"9999");
