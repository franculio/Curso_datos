-- Nivel 1

-- Ejercicio 2

-- Utilizando JOIN realizarás las siguientes consultas:

-- Listado de los países que están generando ventas.

SELECT DISTINCT country
FROM company
JOIN transaction ON transaction.company_id = company.id
WHERE transaction.declined = 0;


-- Desde cuántos países se generan las ventas.

SELECT COUNT( DISTINCT country)
FROM company
JOIN transaction ON transaction.company_id = company.id
WHERE declined = 0;


-- Identifica la compañía con la media más alta de ventas.

SELECT company.company_name, AVG(transaction.amount)
FROM company
JOIN transaction ON transaction.company_id = company.id
GROUP BY company.company_name
ORDER BY AVG(transaction.amount) DESC
LIMIT 1;


-- Ejercicio 3

-- Utilizando solo subconsultas (sin utilizar JOIN):

-- Muestra todas las transacciones realizadas por empresas de Alemania.


SELECT * 
FROM transaction
WHERE company_id IN (SELECT id
					FROM company
                    WHERE country = "Germany");
                    

-- Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT company_name
FROM company
WHERE id IN (SELECT company_id
			FROM transaction 
            WHERE amount > (SELECT AVG(amount)
							FROM transaction)
												);


-- Se eliminarán del sistema las empresas que no tienen transacciones registradas, entrega el listado de estas empresas.

SELECT company_name
FROM company
WHERE id NOT IN (SELECT company_id
			FROM transaction);
            
-- Nivel 2

-- Ejercicio 1

-- Identifica los cinco días en que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(transaction.timestamp) AS fecha, SUM(transaction.amount) AS total_ventas
FROM transaction
GROUP BY fecha
ORDER BY total_ventas DESC
LIMIT 5;


-- Ejercicio 2

-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor media.

SELECT company.country, AVG(transaction.amount)
FROM company
JOIN transaction ON transaction.company_id = company.id
GROUP BY company.country
ORDER BY AVG(transaction.amount) DESC;

-- Ejercicio 3

-- En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía "Non Institute". Para ello, te piden la lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que esta compañía.

-- Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM transaction
JOIN company ON transaction.company_id = company.id
WHERE company.country = (  SELECT country
		FROM company
		WHERE company_name = "Non Institute");


-- Muestra el listado aplicando solamente subconsultas.

SELECT * 
FROM transaction
WHERE company_id IN (   SELECT id
						FROM company
						WHERE country = (   SELECT country
											FROM company
											WHERE company_name = "Non Institute")
                                            );

-- Nivel 3

-- Ejercicio 1

-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.

SELECT company.company_name, company.phone, company.country, transaction.amount, DATE(transaction.timestamp) 
FROM company
JOIN transaction ON transaction.company_id = company.id 
WHERE DATE(transaction.timestamp) IN ('2015-04-2015', '2018-07-20', '2024-03-13')
AND transaction.amount BETWEEN 350 AND 400
ORDER BY transaction.amount DESC;



-- Ejercicio 2

-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas. Pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques si tienen más de 400 transacciones o menos.

SELECT company.company_name, COUNT(transaction.id) AS cantidad_transacciones,
	CASE 
		WHEN COUNT(transaction.id) > 400 THEN 'Supera las 400 transacciones'
        WHEN COUNT(transaction.id) < 400 THEN 'No supera las 400 transacciones'
	END AS capacidad
FROM company
JOIN transaction ON transaction.company_id = company.id
GROUP BY company.company_name;
