-- Nivel 1 

-- Ejercicio 1

-- Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. La nueva tabla debe ser capaz de identificar de manera única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). Después de crear la tabla será necesario que ingreses la información del documento denominado "dades_introduir_credit". Recuerda mostrar el diagrama y realizar una breve descripción de este.


CREATE TABLE credit_card (
	id VARCHAR(20) NOT NULL,
    iban VARCHAR(50) NOT NULL,
    pan VARCHAR(30) NOT NULL,
    pin VARCHAR(10) NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    expiring_date VARCHAR(8) NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_creditcard
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

SHOW TABLES;



-- Ejercicio 2 

-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a la tarjeta de crédito con ID CcU-2938. La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.

UPDATE credit_card 
	SET iban = "TR323456312213576817699999"
    WHERE id = "CcU-2938";
    
SELECT id, iban
FROM credit_card
WHERE id = "CcU-2938";
    
-- Ejercicio 3 

-- En la tabla "transaction" ingresa un nuevo usuario con la siguiente información:
    
INSERT INTO credit_card (id, iban, pin, cvv, expiring_date)
	VALUES("CcU-9999","","",0,"");
    
INSERT INTO company (id, company_name, phone, email, country)
	VALUES ("b-9999", "", "", "","");
    
INSERT INTO data_user (id, name, surname, phone, personal_email)
	VALUES ("9999", "","","","");
    
INSERT INTO transaction (id,credit_card_id, company_id, user_id, lat, longitude, amount, declined)
	VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", 829.999, -117.999, 111.11, 0);
    
SELECT * FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";
    
-- Ejercicio 4 

-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.

ALTER TABLE credit_card
DROP COLUMN pan; 

SHOW COLUMNS FROM credit_card;

-- NIVEL 2 

-- Ejercicio 1 

-- Elimina de la tabla transaction el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

DELETE FROM transaction 
	WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";
    
    -- AGREGAR CONSULTA VERIFICACION
    
-- Ejercicio 2 

-- La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. Será necesario que crees una vista llamada VistaMarketing que contenga la siguiente información: nombre de la compañía, teléfono de contacto, país de residencia, media de compra realizada por cada compañía. Presenta la vista creada, ordenando los datos de mayor a menor media de compra.
    
CREATE VIEW VistaMarketing AS
SELECT company.company_name AS nombre_empresa, company.phone AS telefono, company.country AS pais, AVG (transaction.amount) AS media_ventas
FROM company
JOIN transaction on transaction.company_id = company.id
GROUP BY company.id
ORDER BY media_ventas DESC;

SELECT * FROM VistaMarketing;

-- Ejercicio 3 

-- Filtra la vista VistaMarketing para mostrar únicamente las compañías que tienen su país de residencia en "Germany".

SELECT * 
FROM VistaMarketing
WHERE pais = "Germany";

-- Nivel 3

-- Ejercicio 1 

RENAME TABLE user to data_user;

ALTER TABLE data_user
MODIFY id INT,
CHANGE email personal_email VARCHAR(150) NOT NULL;

ALTER TABLE company 
DROP COLUMN website;  

ALTER TABLE transaction 
MODIFY declined TINYINT(1),
MODIFY user_id INT,
ADD CONSTRAINT fk_transaction_user
	FOREIGN KEY (user_id) REFERENCES data_user(id);

ALTER TABLE credit_card 
MODIFY pin VARCHAR(4),
MODIFY cvv INT, 
MODIFY expiring_date VARCHAR(20),
ADD fecha_actual DATE; 


DELIMITER $$

CREATE TRIGGER tg_fecha_actual
	BEFORE INSERT ON credit_card
	FOR EACH ROW
BEGIN
	
    SET NEW.fecha_actual = CURDATE();

END $$
DELIMITER ;



-- Ejercicio 2 

CREATE VIEW InformeTecnico AS
SELECT transaction.id AS numero_transaccion, data_user.name AS nombre, data_user.surname AS apellido, credit_card.iban AS numero_cuenta, company.company_name AS empresa
FROM transaction 
JOIN data_user ON transaction.user_id = data_user.id
JOIN company ON transaction.company_id = company.id
JOIN credit_card ON transaction.credit_card_id = credit_card.id;

SELECT * FROM InformeTecnico
ORDER BY numero_transaccion;