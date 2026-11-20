-- Written by James Willmore
-- For Software Engineering SE-353-01-FA-2026
-- Class Taught By Professor Khadka

-- this page is for the required insertions into the database
-- enum insertions here SHOULD NOT BE CHANGED AT ALL
-- if you have to, don't touch the ones labeled DO NOT CHANGE
-- the database expects those as defaults
-- there is also a default admin inserted into the database here as well

start transaction;

-- enum insertions

insert into enum_scopes (enum_id, name) values
    (0, 'undefined'), -- DO NOT CHANGE
    (1, 'global'), -- DO NOT CHANGE
    (2, 'project'),
    (3, 'task'),
    (4, 'team'),
    (5, 'user'),
    (6, 'comment');

insert into enum_permission_flags (enum_id, name) values
    (0, 'undefined'), -- DO NOT CHANGE
    (1, 'disabled'),
    (2, 'enabled'),
    (3, 'none'),
    (4, 'read'),
    (5, 'write');

insert into enum_list_permissions (enum_id, name, scope) values
    (0, 'undefined', 0), -- DO NOT CHANGE
    (1, 'undefined global', 1); -- DO NOT CHANGE

insert into enum_audit_reference_types (enum_id, name) values
    (0, 'undefined'); -- DO NOT CHANGE

insert into enum_audit_reasons (enum_id, name) values
    (0, 'undefined'); -- DO NOT CHANGE

-- table insertions
insert into users (user_id, is_superuser, password, first_name, last_name, email) values
    (0, 1, 'h3r3Lay5FuNkYM0Nk3yH35d3Ad', 'Dr.', 'Breen', 'administrator@combine.gov');

commit;