
-- Создание партиционированной таблицы с использованием существующей таблицы в качестве шаблона 

CREATE TABLE bookings.flights_copy (
LIKE bookings.flights
)
PARTITION BY RANGE (flight_id)
;


-- Создание партиций для партиционированной таблицы

CREATE TABLE flights_copy_y2016 PARTITION OF bookings.flights_copy
	FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');
CREATE TABLE flights_copy_y2017 PARTITION OF bookings.flights_copy
	FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');
CREATE TABLE flights_copy_default PARTITION OF bookings.flights_copy
	DEFAULT;


-- Вставка значений в партиционированную таблицу

INSERT INTO bookings.flights_copy
(SELECT * FROM bookings.flights);


-- Пример запроса для просмотра партиций таблицы

SELECT
    nmsp_parent.nspname AS parent_schema,
    parent.relname      AS parent,
    nmsp_child.nspname  AS child_schema,
    child.relname       AS child
FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
    JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid  = parent.relnamespace
    JOIN pg_namespace nmsp_child    ON nmsp_child.oid   = child.relnamespace
WHERE parent.relname='flights_copy';


-- Пример создания функции

CREATE OR REPLACE FUNCTION 
public.test_function () 
RETURNS void
LANGUAGE plpgsql  -- PL/pgSQL — процедурный язык SQL
AS $$
declare
-- Объявление переменных
v_var_name_1 text;
v_var_name_2 int;

begin
	-- Тело функции
end;
$$
EXECUTE ON ANY;


-- Синтаксис создания функции для практического задания

CREATE OR REPLACE FUNCTION public.check_new_students()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
-- IF tg_op = 'INSERT' THEN 
-- Check values in merchant_list
IF NEW."name" IS NOT NULL AND (SELECT sd."name"
					FROM public.students_dict sd
					WHERE sd."name" = NEW."name") IS NULL
THEN INSERT INTO public.students_dict ("name")
VALUES (upper(NEW."name"));
END IF;
-- END IF;
RETURN NEW;
END;
$function$
;



-- Синтаксис создания триггера для практического задания

CREATE TRIGGER insert_new_students AFTER
INSERT
OR
UPDATE
ON
public.student_grades FOR EACH ROW
WHEN ((pg_trigger_depth() = 0)) 
EXECUTE FUNCTION public.check_new_students();


-- Пример вызова функции

SELECT public.check_new_students();