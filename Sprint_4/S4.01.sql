-- Nivel 1 

-- Descarga los archivos CSV, estúdialos y diseña una base de datos con un esquema en estrella que contenga al menos 4 tablas, a partir de las cuales puedas realizar las siguientes consultas:

-- Ejercicio 1

-- Realiza una subconsulta que muestre todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.


CREATE DATABASE ventas;


CREATE TABLE credit_cards (
	id VARCHAR(255) NULL, 
    user_id VARCHAR(255) NULL, 
    iban VARCHAR(255) NULL, 
    pin VARCHAR(255) NULL,
    pan VARCHAR(255) NULL,
    cvv VARCHAR(255) NULL, 
    track1 VARCHAR(255) NULL,
    track2 VARCHAR(255) NULL,
    expiring_date VARCHAR(255) NULL
);

CREATE TABLE transactions (
	id VARCHAR(255) NULL,
    card_id VARCHAR(255) NULL,
    business_id VARCHAR(255) NULL, 
    timestamp VARCHAR(255) NULL, 
    amount VARCHAR(255) NULL, 
    declined VARCHAR(255) NULL,
    products_ids VARCHAR(255) NULL,
    user_id VARCHAR(255) NULL,
    lat VARCHAR(255) NULL,
    longitude VARCHAR(255) 
);

CREATE TABLE companies (
	company_id VARCHAR(255) NULL, 
    company_name VARCHAR(255) NULL, 
    phone VARCHAR(255) NULL, 
    email VARCHAR(255) NULL, 
    country VARCHAR(255) NULL,
    website VARCHAR(255) NULL
);

CREATE TABLE american_users (
	id VARCHAR(255) NULL,
    name VARCHAR(255) NULL,
    surname VARCHAR(255) NULL,
    phone VARCHAR (255) NULL, 
    email VARCHAR(255) NULL,
    birth_date VARCHAR(255) NULL,
    country VARCHAR(255) NULL, 
    city VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    address VARCHAR(255) NULL 
);

CREATE TABLE european_users (
	id VARCHAR(255) NULL,
    name VARCHAR(255) NULL,
    surname VARCHAR(255) NULL,
    phone VARCHAR (255) NULL, 
    email VARCHAR(255) NULL,
    birth_date VARCHAR(255) NULL,
    country VARCHAR(255) NULL, 
    city VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    address VARCHAR(255) NULL 
);


SHOW VARIABLES LIKE 'pid_file';
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA 
INFILE '/Users/fran/mysql_files/transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT * FROM transactions;

LOAD DATA 
INFILE '/Users/fran/mysql_files/companies - companies.csv'
INTO TABLE companies
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT * FROM companies;

LOAD DATA 
INFILE "/Users/fran/mysql_files/european_users.csv"
INTO TABLE european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM european_users;

LOAD DATA 
INFILE '/Users/fran/mysql_files/american_users - american_users.csv'
INTO TABLE american_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM american_users;

LOAD DATA 
INFILE '/Users/fran/mysql_files/credit_cards - credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM credit_cards;

SELECT american_users.id
FROM american_users
JOIN european_users ON american_users.id = european_users.id; -- Para verificar que los id de las dos tablas no se repitan.

-- creamos un nuevo mismo campo en cada tabla para poder diferenciarlas cuando las unamos

ALTER TABLE american_users
ADD continent VARCHAR(255) NOT NULL DEFAULT "america";


ALTER TABLE european_users
ADD continent VARCHAR(255) NOT NULL DEFAULT "europe";

-- pasamos a unir las dos tablas para crear una nueva 

CREATE TABLE users AS 
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address, continent
FROM american_users
UNION ALL
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address, continent
FROM european_users;


-- verificamos que la suma de los registros de correcta 

SELECT COUNT(*) FROM american_users;
SELECT COUNT(*) FROM european_users;
SELECT COUNT(*) FROM users;

-- borramos las tablas viejas 

DROP TABLE american_users;
DROP TABLE european_users;

-- empezamos modificando los tipos de datos en las tablas

ALTER TABLE companies
MODIFY company_id VARCHAR(30) PRIMARY KEY,
MODIFY company_name VARCHAR(255) NOT NULL,
MODIFY phone VARCHAR(30),
MODIFY country VARCHAR(150);

ALTER TABLE users
MODIFY id INT PRIMARY KEY,
MODIFY name VARCHAR(100),
MODIFY surname VARCHAR(100),
CHANGE phone personal_phone VARCHAR(50),
CHANGE email personal_email VARCHAR(255),
MODIFY country VARCHAR(100),
MODIFY city VARCHAR(100),
MODIFY postal_code VARCHAR(20),
MODIFY address VARCHAR(255);

ALTER TABLE users
ADD birth_date_clean DATE;   -- creo una columna nueva para limpiar la fecha de cumpleaños

UPDATE users
SET birth_date_clean = STR_TO_DATE(birth_date, "%b %d, %Y"); -- cambio al formato correcto

SELECT id, birth_date, birth_date_clean 
FROM users ; -- verificacion

ALTER TABLE users
DROP COLUMN birth_date; 

ALTER TABLE users
CHANGE birth_date_clean birth_date DATE; -- reemplazo la columna vieja por la nueva



ALTER TABLE credit_cards
MODIFY id VARCHAR(50) PRIMARY KEY,
MODIFY user_id INT,
MODIFY iban VARCHAR(150), 
MODIFY pan VARCHAR(50),
MODIFY pin VARCHAR(50),
MODIFY cvv VARCHAR(10),
MODIFY expiring_date VARCHAR(30);


ALTER TABLE transactions
MODIFY id VARCHAR(50) PRIMARY KEY,
MODIFY card_id VARCHAR(50), 
CHANGE business_id company_id VARCHAR(30),
MODIFY timestamp DATETIME,
MODIFY amount DECIMAL(10,2),
MODIFY declined TINYINT(1),
MODIFY user_id INT,
MODIFY lat DECIMAL(10,8),
MODIFY longitude DECIMAL(11,8);

SELECT * FROM transactions;

ALTER TABLE transactions -- agrego las FOREIGN KEYS a la tabla transactions
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (card_id) REFERENCES credit_cards(id),
ADD CONSTRAINT fk_company
FOREIGN KEY (company_id) REFERENCES companies(company_id),
ADD CONSTRAINT fk_users
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE credit_cards -- agrego la FOREIGN KEY a la tabla credit_cards para relacionar con users
ADD CONSTRAINT fk_user_cards
FOREIGN KEY (user_id) REFERENCES users(id);

-- Ejercicio 1 

-- Realiza una subconsulta que muestre todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.

SELECT id, name AS nombre, surname AS apellido
FROM users
WHERE id IN (   SELECT user_id
					FROM transactions
                    GROUP BY user_id
                    HAVING COUNT(id) > 80 
                    );


-- Ejercicio 2 

-- Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd, utiliza al menos 2 tablas.

SELECT credit_cards.iban AS numero_cuenta, AVG(transactions.amount) AS media_gastos
FROM credit_cards
JOIN transactions ON credit_cards.id = transactions.card_id 
JOIN companies ON companies.company_id = transactions.company_id
WHERE companies.company_name = "Donec Ltd"
GROUP BY credit_cards.iban;

-- Nivel 2

-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito en función de si las últimas tres transacciones fueron declinadas y genera la siguiente consulta:

-- Cuantas tarjetas estan activas?


CREATE TABLE validez_tarjeta AS 
SELECT card_id AS tarjeta_id, SUM(contador.declined) AS cantidad_transacciones_validas,
	CASE 
		WHEN SUM(contador.declined) = 3 THEN 'Tarjeta Invalida'
        WHEN SUM(contador.declined) < 3 THEN 'Tarjeta Valida'
	END AS validez
FROM (  SELECT card_id, declined
		FROM transactions t
		WHERE (
				SELECT COUNT(*) 
				FROM transactions t2
				WHERE t2.card_id = t.card_id
				AND t2.timestamp > t.timestamp
				) < 3
		) AS contador
GROUP BY card_id;

			

SELECT COUNT(*)
FROM validez_tarjeta
WHERE validez = "Tarjeta Valida";



-- Nivel 3 

-- Crea una tabla con la cual podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:

-- Ejercicio 1 

-- Necesitamos conocer el número de veces que se ha vendido cada producto.

CREATE TABLE products (
	id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price VARCHAR(100),
    colour VARCHAR(50),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(100)
    );

LOAD DATA 
INFILE '/Users/fran/mysql_files/products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT * FROM products;

CREATE TABLE transactions_products (
    transaction_id VARCHAR(50),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id) -- Creacion de la tabla puente/intermedia
				);

UPDATE transactions
SET products_ids = CONCAT(

		'[', 
			REPLACE(TRIM(products_ids), ', ', ','),
		']'
			);

SELECT JSON_VALID(products_ids) 
FROM transactions
WHERE JSON_VALID(products_ids) = 0; -- Se modifica el campo para que los datos se puedan 
									-- utilizar con la funcion JSON_TABLE y verificamos que sean todos validos.
                                                            


INSERT INTO transactions_products (transaction_id, product_id)
	SELECT transactions.id, jt.product_id
FROM transactions 
JOIN JSON_TABLE(transactions.products_ids, '$[*]' COLUMNS(product_id INT path '$')) AS jt;


SELECT products.product_name AS producto, transactions_products.product_id, COUNT(transactions_products.transaction_id) AS cantidad_ventas
FROM transactions_products
JOIN products ON transactions_products.product_id = products.id
GROUP BY transactions_products.product_id;

            
