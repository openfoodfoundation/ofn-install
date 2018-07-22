#!/bin/sh
#
# Rails expects unicode as database encoding, but Posgres may have a different default.
# Since Rails doesn't set the encoding explicitly when creating databases,
# we need to change the template database.
#
# https://stackoverflow.com/questions/16736891/pgerror-error-new-encoding-utf8-is-incompatible

psql -U postgres <<'HEREDOC'
update pg_database set datistemplate=false where datname='template1';
drop database Template1;
create database template1 with owner=postgres encoding='UTF-8' lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;
update pg_database set datistemplate=true where datname='template1';
HEREDOC
