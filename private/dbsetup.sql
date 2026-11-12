--create if not exists table

--all tables are
    --users
    --projects
    --tasks
    --roles
    --statuses
    --task_comments
    --groups

--ADD STATUS LATER

create table createModify (
    --created is for creation of database item
    --modified is for modification of database information in a row, ie id's or
    created_by_id int
        constraint created_by_id_nn not null,
    created_on datetime
        constraint created_on_nn not null,
    modified_by_id int
        constraint modified_by_id_nn not null,
    modified_on datetime
        constraint modified_on_nn not null
);

--enum tables
--table for use_types enum
create table enum_use_types (
    enum_id int,
    name varchar(255)
        constraint enum_use_types_name_nn not null,
    constraint enum_use_types_enum_id_pk primary key (enum_id)
);
insert into enum_use_types (enum_id, name) values
    (0, 'undefined'),
    (1, 'global'),
    (2, 'project'),
    (3, 'task');


--primary tables

create table users (
    user_id int,
    is_superuser int
        constraint users_is_superuser_nn not null
        constraint users_is_superuser_df default 0,
    email varchar(255)
        constraint users_email_nn not null,
    first_name varchar(100)
        constraint users_first_name_nn not null,
    last_name varchar(100)
        constraint users_last_name_nn not null,
    password varchar(255)
        constraint users_password_nn not null
        constraint users_password_df default 'passwordDefault',
    last_login datetime,
    constraint users_user_id_pk primary key (user_id),
    constraint users_email_uk unique
    --may add checks for last_login being less than created
    --may need to add triggers to prevent data from being deleted
);

create table projects (
    project_id int,
    name varchar(255)
        constraint projects_name_nn not null,
    description varchar(255),
    deadline datetime
        constraint projects_deadline_nn not null,
    constraint projects_project_id_pk primary key (project_id)

);

create table tasks (
    task_id int,
    project_id int
        constraint tasks_project_id_nn not null,
    parent_id int,
    name varchar(255)
        constraint tasks_name_nn not null,
    description varchar(255),
    deadline datetime
        constraint tasks_deadline_nn not null,
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
    name varchar(255)
        constraint roles_name_nn not null,
    use_type int
        constraint roles_use_type_nn not null
        constraint roles_use_type_df default 1, --assumes 1 references 'global'
    constraint roles_role_id_pk primary key (role_id),
    constraint roles_project_id_fk
        foreign key (project_id)
        references projects (project_id),
    constraint roles_use_type_fk
        foreign key (use_type)
        references enum_use_types (enum_id)
    --may need a trigger to make use_type to default to the enum_id of some specific name you have
);

create table statuses (
    status_id int,
    project_id int,
    name varchar(255)
        constraint statuses_name_nn not null,
    use_type int
        constraint statuses_use_type_nn not null
        constraint statuses_use_type_df default 1, --assumes 1 references 'global'
    description varchar(255),
    constraint statuses_status_id_pk primary key (status_id),
    constraint statuses_project_id_fk
        foreign key (project_id)
        references projects (project_id),
    constraint statuses_use_type_fk
        foreign key (use_type)
        references enum_use_types (enum_id)
    --may need a trigger to set use_type to some enum_id based on a string
);

create table groups (
    group_id int,
    manager_id int
        constraint groups_manager_id_nn not null,
    name varchar(255)
        constraint groups_name_nn not null,
    description varchar(255),
    constraint groups_group_id_pk primary key (group_id),
    constraint groups_manager_id_fk
        foreign key (manager_id)
        references users (user_id)

);
