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


-- create table createModify (
--     -- created is for creation of database item
--     -- modified is for modification of database information in a row, ie id's or
--     -- copy the below
--
--     -- creation and modification data
--     created_by_id int not null,
--     created_on datetime not null,
--     modified_by_id int not null,
--     modified_on datetime not null,
--     constraint created_by_id_fk
--         foreign key (created_by_id)
--         references users (user_id),
--     constraint modified_by_id_fk
--         foreign key (modified_by_id)
--         references users (user_id),
--     constraint modified_after_creation_ck check
--         (created_on <= modified_on)
-- );

-- .box

-- enum tables
-- table for scopes enum
create table enum_scopes (
    enum_id int,
    name varchar(255) not null,
    constraint enum_scopes_enum_id_pk primary key (enum_id)
);

-- table for permission_flags enum
create table enum_permission_flags (
    enum_id int,
    name varchar(255) not null,
    constraint enum_permission_flags_enum_id_pk primary key (enum_id)
);

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

-- table for audit_reference_type enum
create table enum_audit_reference_types (
    enum_id int,
    name varchar(255) not null,
    constraint enum_audit_reference_types_enum_id_pk primary key (enum_id)
    -- this table is used to uniquely identify each table in the database
);

-- table for audit_reasons enum
create table enum_audit_reasons (
    enum_id int,
    name varchar(255) not null,
    constraint enum_audit_reasons_enum_id_pk primary key (enum_id)
    -- this is for telling which audit reason happened, and includes a description of it
);

-- commit;

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
    constraint users_email_uk unique (email),
    -- may add checks for last_login being less than created
    -- may need to add triggers to prevent data from being deleted,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint users_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint users_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint users_modified_after_creation_ck check
        (created_on <= modified_on)
);
-- -- outside of table creation because they cause errors otherwise
-- alter table users add column created_by_id int not null;
-- alter table users add column created_on datetime not null;
-- alter table users add column modified_by_id int not null;
-- alter table users add column modified_on datetime not null;
-- alter table users add constraint users_created_by_id_fk
--         foreign key (created_by_id)
--         references users (user_id);
-- alter table users add constraint users_modified_by_id_fk
--         foreign key (modified_by_id)
--         references users (user_id);
-- alter table users add constraint users_modified_after_creation_ck check
--         (created_on <= modified_on);

create table projects (
    project_id int,
    name varchar(255) not null,
    description varchar(255),
    deadline datetime not null,
    constraint projects_project_id_pk primary key (project_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint projects_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint projects_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint projects_modified_after_creation_ck check
        (created_on <= modified_on)
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
        references tasks (task_id, project_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint tasks_reated_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint tasks_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint tasks_modified_after_creation_ck
        check (created_on <= modified_on)

);

create table task_comments (
    comment_id int,
    task_id int,
    project_id int,
    reply_of_id int,
    message varchar(1024),
    constraint task_comments_comment_id_pk primary key (comment_id, task_id, project_id),
    constraint task_comments_task_id_fk
        foreign key (task_id, project_id)
        references tasks (task_id, project_id),
    constraint task_comments_reply_of_id_fk
        foreign key (reply_of_id, task_id, project_id)
        references task_comments (comment_id, task_id, project_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint task_comments_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint task_comments_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint task_comments_modified_after_creation_ck
        check (created_on <= modified_on)

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
        references enum_scopes (enum_id),
    -- may need a trigger to make scope to default to the enum_id of some specific name you have
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint roles_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint roles_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint roles_modified_after_creation_ck
        check (created_on <= modified_on)
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
        references enum_scopes (enum_id),
    -- may need a trigger to set scope to some enum_id based on a string
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint statuses_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint statuses_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint statuses_modified_after_creation_ck
        check (created_on <= modified_on)
);

create table teams (
    team_id int,
    manager_id int not null,
    name varchar(255) not null,
    description varchar(255),
    constraint teams_team_id_pk primary key (team_id),
    constraint teams_manager_id_fk
        foreign key (manager_id)
        references users (user_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint teams_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint teams_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint teams_modified_after_creation_ck
        check (created_on <= modified_on)

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
        references enum_permission_flags (enum_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint role_permissions_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint role_permissions_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint role_permissions_modified_after_creation_ck
        check (created_on <= modified_on)

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

-- link tables

create table link_users_roles (
    user_id int,
    role_id int,
    constraint link_users_roles_user_id_pk primary key (user_id, role_id),
    constraint link_users_roles_user_id_fk
        foreign key (user_id)
        references users (user_id),
    constraint link_users_roles_role_id_fk
        foreign key (role_id)
        references roles (role_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint link_users_roles_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint link_users_roles_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint link_users_roles_modified_after_creation_ck
        check (created_on <= modified_on)
);

create table link_users_statuses (
    user_id int,
    status_id int,
    constraint link_users_statuses_user_id_pk primary key (user_id, status_id),
    constraint link_users_statuses_user_id_fk
        foreign key (user_id)
        references users (user_id),
    constraint link_users_statuses_status_id_fk
        foreign key (status_id)
        references statuses (status_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint link_users_statuses_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint link_users_statuses_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint link_users_statuses_modified_after_creation_ck
        check (created_on <= modified_on)
);

create table link_teams_roles (
    team_id int,
    role_id int,
    constraint link_teams_roles_team_id_pk primary key (team_id, role_id),
    constraint link_teams_roles_team_id_fk
        foreign key (team_id)
        references teams (team_id),
    constraint link_teams_roles_role_id_fk
        foreign key (role_id)
        references roles (role_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint link_teams_roles_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint link_teams_roles_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint link_teams_roles_modified_after_creation_ck
        check (created_on <= modified_on)
);

create table link_teams_users (
    team_id int,
    user_id int,
    constraint link_teams_users_team_id_pk primary key (team_id, user_id),
    constraint link_teams_users_team_id_fk
        foreign key (team_id)
        references teams (team_id),
    constraint link_teams_users_user_id_fk
        foreign key (user_id)
        references users (user_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint link_teams_users_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint link_teams_users_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint link_teams_users_modified_after_creation_ck
        check (created_on <= modified_on)
);

create table link_tasks_users_roles_teams (
    task_link_num int,
    task_id int,
    project_id int,
    user_id int,
    role_id int,
    team_id int,
    constraint link_tasks_users_roles_teams_task_link_num_pk primary key (task_link_num, task_id, project_id),
    constraint link_tasks_users_roles_teams_task_id_fk
        foreign key (task_id, project_id)
        references tasks (task_id, project_id),
    constraint link_tasks_users_roles_teams_project_id_fk
        foreign key (project_id)
        references projects (project_id),
    constraint link_tasks_users_roles_teams_user_id_fk
        foreign key (user_id)
        references users (user_id),
    constraint link_tasks_users_roles_teams_role_id_fk
        foreign key (role_id)
        references roles (role_id),
    constraint link_tasks_users_roles_teams_team_id_fk
        foreign key (team_id)
        references teams (team_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint link_tasks_users_roles_teams_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint link_tasks_users_roles_teams_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint link_tasks_users_roles_teams_modified_after_creation_ck
        check (created_on <= modified_on)
);

create table link_tasks_statuses (
    task_id int,
    status_id int,
    constraint link_tasks_statuses_task_id_pk primary key (task_id, status_id),
    constraint link_tasks_statuses_task_id_fk
        foreign key (task_id)
        references tasks (task_id),
    constraint link_tasks_statuses_status_id_fk
        foreign key (status_id)
        references statuses (status_id),
    -- creation and modification data,
    created_by_id int not null,
    created_on datetime not null default  current_timestamp,
    modified_by_id int not null,
    modified_on datetime not null default current_timestamp,
    constraint link_tasks_statuses_created_by_id_fk
        foreign key (created_by_id)
        references users (user_id),
    constraint link_tasks_statuses_modified_by_id_fk
        foreign key (modified_by_id)
        references users (user_id),
    constraint link_tasks_statuses_modified_after_creation_ck
        check (created_on <= modified_on)
);
