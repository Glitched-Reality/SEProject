-- Written by James Willmore
-- For Software Engineering SE-353-01-FA-2026
-- Class Taught By Professor Khadka

-- Notes:
-- id is a unique identifier for something, exclusively for primary keys
-- num is a subtype of id used for link tables
    -- num counts up for every new item linked to the main table of the link
    -- As an example, table link_tasks_users_roles_teams
    -- would use task_link_num along with task_id as the primary key
    -- when indexing all the different items linked to a task

-- Do not use enums within a primary key at all
-- Whenever you reference an enum at all, you do not include an '_id' postfix to it

-- all tables are
    -- users
    -- projects
    -- tasks
    -- roles
    -- statuses
    -- task_comments
    -- teams
    -- role_permissions
    -- link tables

-- TODO
    -- add triggers which check for any conflicting scopes when setting up permissions
    -- add views to do things such as show what teams a user is in or a manager of
        -- see what permissions a role has
        -- see what roles a user has
        -- make the data stored in link tables more readable
    -- add check constraints where nessicary
    -- get the createModify items into every table
-- drop table if exists role

-- drop database if exists seproject;
-- create database seproject;
-- use seproject;


create table createModify (
    -- created is for creation of database item
    -- modified is for modification of database information in a row, ie id's or
    created_by_id int not null,
    created_on datetime not null,
    modified_by_id int not null,
    modified_on datetime not null
);

-- enum tables
-- table for scopes enum
create table enum_scopes (
    enum_id int,
    name varchar(255) not null,
    constraint enum_scopes_enum_id_pk primary key (enum_id)
);
insert into enum_scopes (enum_id, name) values
    (0, 'undefined'), -- DO NOT CHANGE
    (1, 'global'), -- DO NOT CHANGE
    (2, 'project'),
    (3, 'task'),
    (4, 'team'),
    (5, 'user'),
    (6, 'comment');

-- table for permission_flags enum
create table enum_permission_flags (
    enum_id int,
    name varchar(255) not null,
    constraint enum_permission_flags_enum_id_pk primary key (enum_id)
);
insert into enum_permission_flags (enum_id, name) values
    (0, 'undefined'), -- DO NOT CHANGE
    (1, 'disabled'),
    (2, 'enabled'),
    (3, 'none'),
    (4, 'read'),
    (5, 'write');

-- table for list_permissions enum
create table enum_list_permissions (
    enum_id int,
    scope int not null,
    name varchar(255) not null,
    constraint enum_list_permissions_enum_id_pk primary key (enum_id),
    constraint enum_list_permissions_scope_fk
        foreign key (scope)
        references enum_scopes (enum_id)
);
insert into enum_list_permissions (enum_id, name, scope) values
    (0, 'undefined', 0), -- DO NOT CHANGE
    (1, 'undefined global', 1); -- DO NOT CHANGE

-- table for audit_reference_type enum
create table enum_audit_reference_types (
    enum_id int,
    name varchar(255) not null,
    constraint enum_audit_reference_types_enum_id_pk primary key (enum_id)
    -- this table is used to uniquely identify each table in the database
);
insert into enum_audit_reference_types (enum_id, name) values
    (0, 'undefined'); -- DO NOT CHANGE

-- table for audit_reasons enum
create table enum_audit_reasons (
    enum_id int,
    name varchar(255) not null,
    constraint enum_audit_reasons_enum_id_pk primary key (enum_id)
    -- this is for telling which audit reason happened, and includes a description of it
);
insert into enum_audit_reasons (enum_id, name) values
    (0, 'undefined'); -- DO NOT CHANGE

-- primary tables

create table users (
    user_id int,
    is_superuser int not null default 0,
    email varchar(255) not null,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    password varchar(255) not null default 'passwordDefault',
    last_login datetime,
    constraint users_user_id_pk primary key (user_id),
    constraint users_email_uk unique (email)
    -- may add checks for last_login being less than created
    -- may need to add triggers to prevent data from being deleted
);

create table projects (
    project_id int,
    name varchar(255) not null,
    description varchar(255),
    deadline datetime not null,
    constraint projects_project_id_pk primary key (project_id)

);

create table tasks (
    task_id int,
    project_id int not null,
    parent_id int,
    name varchar(255) not null,
    description varchar(255),
    deadline datetime not null,
    constraint tasks_task_id_pk primary key (task_id, project_id),
    constraint tasks_project_id_fk
        foreign key (project_id)
        references projects (project_id),
    constraint tasks_parent_id_fk
        foreign key (parent_id, project_id)
        references tasks (task_id, project_id)

);

create table task_comments (
    comment_id int,
    task_id int,
    project_id int,
    reply_of_id int,
    message varchar(1024),
    constraint task_comments_comment_id_pk primary key (comment_id, task_id, project_id),
    constraint task_comments_task_id_fk foreign key (task_id, project_id) references tasks (task_id, project_id),
    constraint task_comments_reply_of_id_fk
        foreign key (reply_of_id, task_id, project_id)
        references task_comments (comment_id, task_id, project_id)

);

create table roles (
    role_id int,
    project_id int,
    name varchar(255) not null,
    scope int not null default 0, -- assumes 1 references 'undefined'
    constraint roles_role_id_pk primary key (role_id),
    constraint roles_project_id_fk
        foreign key (project_id)
        references projects (project_id),
    constraint roles_scope_fk
        foreign key (scope)
        references enum_scopes (enum_id)
    -- may need a trigger to make scope to default to the enum_id of some specific name you have
);

create table statuses (
    status_id int,
    project_id int,
    name varchar(255) not null,
    scope int not null default 0, -- assumes 0 references 'undefined'
    description varchar(255),
    constraint statuses_status_id_pk primary key (status_id),
    constraint statuses_project_id_fk
        foreign key (project_id)
        references projects (project_id),
    constraint statuses_scope_fk
        foreign key (scope)
        references enum_scopes (enum_id)
    -- may need a trigger to set scope to some enum_id based on a string
);

create table teams (
    team_id int,
    manager_id int not null,
    name varchar(255) not null,
    description varchar(255),
    constraint teams_team_id_pk primary key (team_id),
    constraint teams_manager_id_fk
        foreign key (manager_id)
        references users (user_id)

);

create table role_permissions (
    permission_num int,
    role_id int,
    name int not null default 0, -- enum referencing enum_list_permissions
    flag int not null default 0, -- enum referencing enum_permission_flags
    constraint role_permissions_permission_num_pk primary key (permission_num, role_id),
    constraint role_permissions_role_id_fk
        foreign key (role_id)
        references roles (role_id),
    constraint role_permissions_name_fk
        foreign key (name)
        references enum_list_permissions (enum_id),
    constraint role_permissions_flag_fk
        foreign key (flag)
        references enum_permission_flags (enum_id)

);

create table audit_log (
    time_logged datetime,
    user_id int,
    audit_reason int not null default 0, -- enum referencing enum_audit_reasons
    constraint audit_log_time_logged_pk primary key (time_logged, user_id),
    constraint audit_log_user_id_fk
        foreign key (user_id)
        references users (user_id),
    constraint audit_log_audit_reason_fk
        foreign key (audit_reason)
        references enum_audit_reasons (enum_id)

);

