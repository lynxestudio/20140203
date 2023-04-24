# Utilizando los comandos GRANT y REVOKE en PostgreSQL

Cuando se trata de la seguridad de los datos almacenados es muy importante tener en cuenta las siguientes consideraciones sobretodo en ambientes productivos:

Los datos de cualquier tabla deben ser accesibles únicamente a los usuarios del DBMS que realmente necesiten esa información, el resto no debe tener acceso.
A cada uno de los usuarios del DBMS que tienen acceso a una determinada tabla, se les debe de asignar una cierta acción según sus necesidades, por ejemplo a ciertos usuarios se les permitirá ejecutar un UPDATE, mientras que al resto (o a todos) se les permitirá únicamente ejecutar un SELECT.
En ciertos casos incluso para la ejecución de un SELECT solo se permitirá que un usuario del DBMS pueda consultar una tabla a nivel de ciertas columnas.
Cabe recordar que en producción los usuarios del DBMS son asociados más con aplicaciones o grupos de programas que con usuarios operativos. Existen tres conceptos en el esquema de seguridad SQL: Usuarios, Objetos y privilegios.

Privilegios
Los privilegios suelen clasificarse en privilegios del sistema y de objetos.

Los privilegios del sistema permiten al usuario realizar algún tipo de operación que afecta a todo el sistema.

Los privilegios de objetos se definen como las acciones que le son permitidas a un usuario ejecutar en un determinado objeto de la base de datos (tabla,vista,secuencia,función), esto una vez que el usuario haya sido autentificado dentro del DBMS.

Los privilegios de objetos dependen del tipo de objeto, por ejemplo el estándar SQL1 especifica 4 privilegios para tablas y vistas:

SELECT - Permite consultar todas las filas.
INSERT - Permite la creación de nuevos registros.
DELETE - Permite la eliminación de filas.
UPDATE - Permite la modificación de filas ya creadas.
Para el resto de los objetos en PostgreSQL pueden o no aplicar los siguientes privilegios:

RULE - Permite la creación de reglas para una tabla o una vista.
REFERENCES - Permite la creación de llaves foráneas (foreign key) al crear relaciones.
TRIGGER - Permite la creación de triggers.
EXECUTE - Permite la ejecución de funciones o store procedures.
ALL - Permite todos los privilegios.
De manera predeterminada en PostgreSQL cuando se crea un objeto el creador del objeto es el propietario y se le asignan todos los privilegios sobre ese objeto, el resto de los usuarios no tiene ningún privilegio sobre ese objeto.

El DDL (Data Definition Language) incluye dos comandos para conceder y retirar privilegios: GRANT y REVOKE

Como ejemplo voy a crear la siguiente tabla en una base de datos llamada bibl, cuyo dueño de la base de datos es el usuario postgres.

  CREATE TABLE Authors(
 author_id        serial primary key,
 author_name     varchar(256),
 author_lastname     varchar(256),
 author_birthdate     date
 );
  


Paso siguiente voy a insertar unos registros:

insert into authors(author_name,author_lastname,author_birthdate)
values('Elizabeth','Bishop','02/08/1911');

insert into authors(author_name,author_lastname,author_birthdate)
values('Charles','Dickens','07/02/1812');

insert into authors(author_name,author_lastname,author_birthdate)
values('Jack','London','12/01/1876');

insert into authors(author_name,author_lastname,author_birthdate)
values('Joseph','Conrad','03/12/1857');
  
Hago un SELECT y muestro los registros de la tabla.



Como se ve con el usuario postgres pude ejecutar sin ningún tipo de restricción las siguientes acciones: CREATE, INSERT y SELECT

Ahora ingresaré con un usuario distinto al usuario postgres, ingresaré en la base de datos con el usuario martin y ejecutaré un SELECT sobre la tabla authors.

Al ejecutar el SELECT PostgreSQL nos muestra los siguientes mensajes:

ERROR:  permission denied for relation authors
STATEMENT:  SELECT * FROM authors;
ERROR:  permission denied for relation authors


GRANT
Estos mensajes me indican que el usuario martin no tiene los privilegios necesarios para ejecutar el SELECT en esa tabla y que por lo tanto no podrá leer los registros a menos que el usuario propietario postgres conceda el privilegio de hacerlo ejecutando el comando GRANT. La sintaxis básica del comando es:

GRANT [privilegios] ON [objeto] TO {public | group | username}
Así que con la sesión de postgres ejecuto el siguiente comando:

  GRANT SELECT ON authors TO martin;


Regresando a la sesión del usuario martin, vuelvo a ejecutar el comando SELECT.

  SELECT * FROM authors;
Ya es posible que el usuario martin pueda ejecutar la consulta.



Ahora intentaré crear un nuevo registro

insert into authors(author_name,author_lastname,author_birthdate)
values('Gustave','Flaubert','12/12/1821');
PostgreSQL me envía el siguiente mensaje debido a que este usuario no tiene el privilegio de INSERT:

  ERROR:  permission denied for relation authors
  


Concedo al usuario martin el privilegio de INSERT, con el siguiente comando ejecutado por el usuario postgres

GRANT INSERT ON authors TO martin;


Ejecuto nuevamente el INSERT y PostgreSQL me envía ahora el siguiente mensaje:

ERROR: permission denied for sequence authors_author_id_seq


Concedo entonces al usuario martin el privilegio de poder actualizar la secuencia con el siguiente comando (debe ser ejecutado por postgres):

GRANT UPDATE ON authors_author_id_seq TO martin;


Con los privilegios otorgados a la tabla y a la secuencia ahora ya es posible crear el registro.



Para mostrar los privilegios que se tienen sobre un determinado objeto, utilizamos el comando \z. La sintaxis es:

\z [nombre del objeto]
Para este ejemplo ejecutamos:

\z authors;


REVOKE
De la misma manera que se otorgaron los privilegios al usuario martin se le pueden retirar con el comando REVOKE la sintaxis básica del comando es:

REVOKE [privilegios] ON [objecto] FROM {public | group | username }
Así que con el usuario postgres ejecuto los siguientes comandos para retirarle los privilegios otorgados a martin en la tabla y en la secuencia:

REVOKE INSERT,SELECT ON authors FROM martin;
REVOKE UPDATE on authors_author_id_seq FROM martin;


Si mostramos los privilegios de la tabla y de la secuencia, observamos que ya no se muestran los privilegios para el usuario martin , esto por que los quito el usuario postgres, quien es el propietario de los objetos. Para mostrar los privilegios de ambos objetos (secuencia y tabla) únicamente ejecuto el comando \z sin argumentos.

