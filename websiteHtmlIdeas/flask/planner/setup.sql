-- run this file by typing sqlite3 -cmd ".read setup.sql" from your terminal
.open planner.db
.mode box
-- drop the tables
drop table if exists users;
drop table if exists tasks;
-- create your tables
create table if not exists users(
    userID integer primary key,
    username text not null unique,
    password text
);
create table if not exists tasks(
    taskID integer primary key,
    userID integer not null,
    taskName text not null,
    date date not null,
    description text,
    priority integer default 0,
    done integer default 0,
    check(done==0 or done==1),
    check(priority>=-5),
    check(priority<=5),
    foreign key (userID) references users (userID)
        on update cascade
        on delete cascade
);
-- add some starter data to your tables using INPUT statemtns
insert into users
    (username,password)
    values
    ("admin","admin");
insert into tasks
    (userID,taskName,date,description,priority,done)
    values
    (1,"clean dishes","2025-05-20","banananananana",2,1),
    (1,"clean bedroom","2025-04-20","whonfaef",-5,0);
insert into users(username)values("idiot");
insert into tasks
    (userID,taskName,date)
    values
    (2,"hw","2025-04-28");
-- show all the starter data
select * from users;
select * from tasks;
select * from tasks
    inner join users on tasks.userID=users.userID;
