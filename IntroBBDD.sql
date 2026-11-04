/*
===============================================================================
PROYECTO 4: SQL - CONSULTAS SOBRE LA BASE DE DATOS AIRLINES (POSTGRESQL)
Alumno: Agustín Scandolo Robledo

Instrucciones:
1. Instala la base de datos de ejemplo de PostgreSQL/PostgresPro.
2. Abre psql o la extensión de PostgreSQL en VS Code.
3. Conéctate a la base de datos donde se haya instalado el esquema bookings.
4. Ejecuta las consultas de este archivo una por una.

NOTA SOBRE VERSIONES:
El enunciado menciona aircraft_data / aircrafts_data. En el esquema clásico
Airlines de PostgreSQL la tabla suele llamarse aircrafts_data y su columna
identificadora es aircraft_code. En algunas versiones más recientes de
PostgresPro pueden cambiar nombres de tablas (por ejemplo, airplanes_data,
segments o ticket_flights). Si una consulta indica que una relación no existe,
comprueba los nombres con:
    \dt bookings.*
    \d bookings.flights
    \d bookings.aircrafts_data
    \d bookings.tickets
    \d bookings.ticket_flights

En las consultas se utiliza el esquema bookings de forma explícita para que
funcionen aunque el search_path de la conexión sea diferente.
===============================================================================
*/


/* ---------------------------------------------------------------------------
EJERCICIO 1 (OBLIGATORIO)
Enunciado:
Escribe una consulta que recupere los vuelos (flights) y su identificador
que figuren con status 'On Time'.

Explicación:
- FROM flights indica la tabla de la que queremos obtener los datos.
- SELECT muestra el identificador del vuelo (flight_id) y el número de vuelo
  (flight_no).
- WHERE filtra únicamente los registros cuyo estado sea 'On Time'.
--------------------------------------------------------------------------- */

SELECT
    flight_id,
    flight_no
FROM bookings.flights
WHERE status = 'On Time';


/* ---------------------------------------------------------------------------
EJERCICIO 2 (OBLIGATORIO)
Enunciado:
Extrae todas las columnas de la tabla bookings y muestra las reservas cuyo
importe total sea superior a 1.000.000 de rublos.

Explicación:
- SELECT * devuelve todas las columnas.
- total_amount contiene el importe total de la reserva.
- > 1000000 selecciona importes estrictamente superiores a un millón.
--------------------------------------------------------------------------- */

SELECT *
FROM bookings.bookings
WHERE total_amount > 1000000;


/* ---------------------------------------------------------------------------
EJERCICIO 3 (OBLIGATORIO)
Enunciado:
Extrae todas las columnas de los datos de los modelos de aviones disponibles.
La tabla puede aparecer como aircraft_data o aircrafts_data según la versión.

Explicación:
En el esquema clásico de Airlines la tabla se llama aircrafts_data.
El asterisco (*) permite recuperar todas sus columnas.
--------------------------------------------------------------------------- */

SELECT *
FROM bookings.aircrafts_data;


/* ---------------------------------------------------------------------------
EJERCICIO 4 (OBLIGATORIO)
Enunciado:
Extrae los identificadores de vuelo que han volado con un Boeing 737
(código de modelo de avión = '733').

Explicación:
- aircraft_code identifica el modelo de avión utilizado por el vuelo.
- '733' es el código indicado para el Boeing 737 en el ejercicio.
- Solo necesitamos mostrar flight_id, por eso no usamos SELECT *.
--------------------------------------------------------------------------- */

SELECT
    flight_id
FROM bookings.flights
WHERE aircraft_code = '733';


/* ---------------------------------------------------------------------------
EJERCICIO 5 (OBLIGATORIO)
Enunciado:
Muestra la información detallada de los tickets que han comprado las personas
que se llaman Irina.

Explicación:
- tickets contiene los datos de los billetes y el nombre del pasajero.
- ILIKE permite buscar sin distinguir entre mayúsculas y minúsculas.
- Los porcentajes (%) permiten que Irina aparezca en cualquier parte
  del nombre completo.
--------------------------------------------------------------------------- */

SELECT *
FROM bookings.tickets
WHERE passenger_name ILIKE '%Irina%';


/* ===========================================================================
EJERCICIOS OPCIONALES
=========================================================================== */


/* ---------------------------------------------------------------------------
EJERCICIO 6 (OPCIONAL)
Enunciado:
Mostrar las ciudades con más de un aeropuerto.

Explicación:
- La vista airports contiene el código y la ciudad de cada aeropuerto.
- GROUP BY agrupa los aeropuertos que pertenecen a la misma ciudad.
- COUNT cuenta cuántos aeropuertos hay en cada grupo.
- HAVING filtra los grupos que tienen más de un aeropuerto.
--------------------------------------------------------------------------- */

SELECT
    city,
    COUNT(*) AS numero_aeropuertos
FROM bookings.airports
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY numero_aeropuertos DESC;


/* ---------------------------------------------------------------------------
EJERCICIO 7 (OPCIONAL)
Enunciado:
Mostrar el número de vuelos por modelo de avión.

Explicación:
- Unimos flights con aircrafts_data mediante aircraft_code.
- COUNT cuenta los vuelos de cada modelo.
- GROUP BY agrupa los resultados por el modelo del avión.
--------------------------------------------------------------------------- */

SELECT
    a.aircraft_code,
    a.model,
    COUNT(f.flight_id) AS numero_vuelos
FROM bookings.aircrafts_data AS a
LEFT JOIN bookings.flights AS f
    ON f.aircraft_code = a.aircraft_code
GROUP BY
    a.aircraft_code,
    a.model
ORDER BY numero_vuelos DESC;


/* ---------------------------------------------------------------------------
EJERCICIO 8 (OPCIONAL)
Enunciado:
Mostrar las reservas que tienen más de un billete (varios pasajeros).

Explicación:
- bookings contiene las reservas.
- tickets contiene los billetes asociados a cada reserva.
- JOIN relaciona ambas tablas por book_ref.
- COUNT cuenta los billetes de cada reserva.
- HAVING deja únicamente las reservas con más de un billete.
--------------------------------------------------------------------------- */

SELECT
    b.book_ref,
    b.book_date,
    b.total_amount,
    COUNT(t.ticket_no) AS numero_billetes
FROM bookings.bookings AS b
INNER JOIN bookings.tickets AS t
    ON t.book_ref = b.book_ref
GROUP BY
    b.book_ref,
    b.book_date,
    b.total_amount
HAVING COUNT(t.ticket_no) > 1
ORDER BY numero_billetes DESC;


/* ---------------------------------------------------------------------------
EJERCICIO 9 (OPCIONAL)
Enunciado:
Mostrar los vuelos que han sufrido un retraso de salida superior a una hora.

Explicación:
- scheduled_departure es la hora de salida programada.
- actual_departure es la hora real de salida.
- Sumamos una hora a la hora programada y comprobamos si la salida real
  fue posterior.
- IS NOT NULL evita incluir vuelos sin hora real de salida registrada.
--------------------------------------------------------------------------- */

SELECT
    flight_id,
    flight_no,
    scheduled_departure,
    actual_departure,
    actual_departure - scheduled_departure AS retraso
FROM bookings.flights
WHERE actual_departure IS NOT NULL
  AND actual_departure > scheduled_departure + INTERVAL '1 hour'
ORDER BY retraso DESC;


/* ===========================================================================
CONSULTAS DE AYUDA PARA COMPROBAR EL ESQUEMA (NO SON EJERCICIOS)
Descomenta y ejecuta estas instrucciones si alguna tabla no existe.
=========================================================================== */

-- Ver las tablas del esquema bookings:
-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'bookings'
-- ORDER BY table_name;

-- Ver las columnas de flights:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'bookings' AND table_name = 'flights'
-- ORDER BY ordinal_position;

-- Ver las columnas de aircrafts_data:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'bookings' AND table_name = 'aircrafts_data'
-- ORDER BY ordinal_position;
