GRANT SELECT ON authors TO martin;

insert into authors(author_name,author_lastname,author_birthdate)
values('Gustave','Flaubert','12/12/1821');

GRANT INSERT ON authors TO martin;

GRANT UPDATE ON authors_author_id_seq TO martin;

REVOKE INSERT,SELECT ON authors FROM martin;
REVOKE UPDATE on authors_author_id_seq FROM martin;