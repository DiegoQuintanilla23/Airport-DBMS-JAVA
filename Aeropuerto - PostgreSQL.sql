-- Database: Aeropuerto

-- DROP DATABASE IF EXISTS "Aeropuerto";

CREATE DATABASE "Aeropuerto"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Mexico.1252'
    LC_CTYPE = 'Spanish_Mexico.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
CREATE SCHEMA InfoAerolinea;
CREATE SCHEMA InfoPasajero;

------------ TABLAS InfoAerolinea ------------
CREATE TABLE InfoAerolinea.Aerolinea
(
    idAerolinea BIGSERIAL NOT NULL,
    Nom_Aerolinea VARCHAR(200) NOT NULL,
    FlotaTotal INT NOT NULL,
    AñoFundacion INT NOT NULL,
    NumVuelos INT NOT NULL,
    Logotipo BYTEA NOT NULL,
    CONSTRAINT PK_AEROLINEA PRIMARY KEY (idAerolinea)
);

CREATE TABLE InfoAerolinea.Piloto
(
    idPiloto BIGSERIAL NOT NULL,
    Nom_Piloto VARCHAR(200) NOT NULL,
    Genero VARCHAR(20) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    NumLicencia BIGINT NOT NULL,
    CONSTRAINT PK_PILOTO PRIMARY KEY (idPiloto)
);
ALTER TABLE InfoAerolinea.Piloto
ADD CONSTRAINT UQ_NUMLIC UNIQUE (NumLicencia);

CREATE TABLE InfoAerolinea.Ciudad
(
    idCiudad BIGSERIAL NOT NULL,
    Nom_Ciudad VARCHAR(200) NOT NULL,
    Pais VARCHAR(200) NOT NULL,
    CONSTRAINT PK_CIUDAD PRIMARY KEY (idCiudad)
);
ALTER TABLE InfoAerolinea.Ciudad
ADD CONSTRAINT UQ_CIUDADPAIS UNIQUE (Nom_Ciudad, Pais);

CREATE TABLE InfoAerolinea.Avion
(
    idAvion BIGSERIAL NOT NULL,
    idAerolinea BIGINT NOT NULL,
    Capacidad INT NOT NULL,
    Modelo VARCHAR(200) NOT NULL,
    AñoFabricacion INT NOT NULL,
    EstadoUso BOOLEAN NOT NULL,
    CONSTRAINT PK_AVION PRIMARY KEY (idAvion),
    CONSTRAINT FK_AEROLINEA FOREIGN KEY (idAerolinea) REFERENCES InfoAerolinea.Aerolinea (idAerolinea)
);

CREATE TABLE InfoAerolinea.Vuelo
(
    idVuelo BIGSERIAL NOT NULL,
    idOrigen BIGINT NOT NULL,
    idDestino BIGINT NOT NULL,
    DuracionHoras INT NOT NULL,
    CostoBase MONEY NOT NULL,
    CONSTRAINT PK_VUELO PRIMARY KEY (idVuelo),
    CONSTRAINT FK_ORIGEN FOREIGN KEY (idOrigen) REFERENCES InfoAerolinea.Ciudad (idCiudad),
    CONSTRAINT FK_DESTINO FOREIGN KEY (idDestino) REFERENCES InfoAerolinea.Ciudad (idCiudad)
);
ALTER TABLE InfoAerolinea.Vuelo
ADD CONSTRAINT UQ_IDORGIDDEST UNIQUE (idOrigen, idDestino);

CREATE TABLE InfoAerolinea.Itinerario
(
    idItinerario BIGSERIAL NOT NULL,
    idPiloto BIGINT NOT NULL,
    idAvion BIGINT NOT NULL,
    idVuelo BIGINT NOT NULL,
    HoraSalida TIME NOT NULL,
    FechaVuelo DATE NOT NULL,
    CONSTRAINT PK_ITINERARIO PRIMARY KEY (idItinerario),
    CONSTRAINT FK_PILOTO FOREIGN KEY (idPiloto) REFERENCES InfoAerolinea.Piloto (idPiloto),
    CONSTRAINT FK_AVION FOREIGN KEY (idAvion) REFERENCES InfoAerolinea.Avion (idAvion),
    CONSTRAINT FK_VUELO FOREIGN KEY (idVuelo) REFERENCES InfoAerolinea.Vuelo (idVuelo)
);
ALTER TABLE InfoAerolinea.Itinerario
ADD CONSTRAINT UQ_PILOTODIA UNIQUE (idPiloto, FechaVuelo);
select * from InfoAerolinea.Itinerario

------------ TABLAS InfoPasajero ------------
CREATE TABLE InfoPasajero.Pasajero
(
    idPasajero BIGSERIAL NOT NULL,
    Nom_Pasajero VARCHAR(200) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Edad INT,
    Nacionalidad VARCHAR(50) NOT NULL,
    Genero VARCHAR(20) NOT NULL,
	NumPasaporte VARCHAR(15) NOT NULL,
	Telefono BIGINT NOT NULL,
	ContactoEmergencia BIGINT NOT NULL,
	Email VARCHAR(200) NOT NULL,
    CONSTRAINT PK_PASAJERO PRIMARY KEY (idPasajero)
);
ALTER TABLE InfoPasajero.Pasajero
ADD CONSTRAINT UQ_NUMPASAPORTEPASAJERO UNIQUE (NumPasaporte);
ALTER TABLE InfoPasajero.Pasajero
ADD CONSTRAINT UQ_NUMTELPASAJERO UNIQUE (Telefono);
ALTER TABLE InfoPasajero.Pasajero
ADD CONSTRAINT UQ_EMAILPASAJERO UNIQUE (Email);

CREATE TABLE InfoPasajero.TarjetaPasajero
(
    idTarjetaPasajero BIGSERIAL NOT NULL,
    idPasajero BIGINT NOT NULL,
    NombreTitular VARCHAR(200) NOT NULL,
    Banco VARCHAR(200) NOT NULL,
    NumTarjeta BIGINT NOT NULL,
    FechaVencimiento DATE NOT NULL,
    CVV INT NOT NULL,
    CONSTRAINT PK_TARJETAPASAJERO PRIMARY KEY (idTarjetaPasajero),
    CONSTRAINT FK_PASAJERO1 FOREIGN KEY (idPasajero) REFERENCES InfoPasajero.Pasajero (idPasajero)
)
ALTER TABLE InfoPasajero.TarjetaPasajero
ADD CONSTRAINT UQ_IDPASAJNUMTARJ UNIQUE (idPasajero, NumTarjeta);

CREATE TABLE InfoPasajero.Asiento
(   
    idAsiento BIGSERIAL NOT NULL,
    idItinerario BIGINT NOT NULL,
    Num_Asiento INT NOT NULL,
    Letra CHAR(1) NOT NULL,
    Ocupado BOOLEAN NOT NULL,
    CONSTRAINT PK_ASIENTO PRIMARY KEY (idAsiento),
    CONSTRAINT FK_ITINERARIO1 FOREIGN KEY (idItinerario) REFERENCES InfoAerolinea.Itinerario (idItinerario)
)
ALTER TABLE InfoPasajero.Asiento
ADD CONSTRAINT UQ_ASIENTO UNIQUE (idItinerario, Num_Asiento, Letra);

CREATE TABLE InfoPasajero.Venta
(
    idVenta BIGSERIAL NOT NULL,
    idTarjetaPasajero BIGINT NOT NULL,
    idItinerario BIGINT NOT NULL,
    FechaVenta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    MontoTotal MONEY,
    EstadoPago BOOLEAN NOT NULL,
    CONSTRAINT PK_VENTA PRIMARY KEY (idVenta),
    CONSTRAINT FK_TARJETAPASAJERO FOREIGN KEY (idTarjetaPasajero) REFERENCES InfoPasajero.TarjetaPasajero (idTarjetaPasajero),
    CONSTRAINT FK_ITINERARIO2 FOREIGN KEY (idItinerario) REFERENCES InfoAerolinea.Itinerario (idItinerario)
);
ALTER TABLE InfoPasajero.Venta
ADD CONSTRAINT UQ_TJPASAJEROITINERARIO UNIQUE (idTarjetaPasajero, idItinerario);
SELECT * FROM InfoPasajero.Venta

CREATE TABLE InfoPasajero.Boleto
(
    idBoleto BIGSERIAL NOT NULL,
    idVenta BIGINT NOT NULL,
    idPasajero BIGINT,
    idAsiento BIGINT NOT NULL,
    Impuestos REAL NOT NULL,
    TarifasAdicionales MONEY NOT NULL,
    CostoTotal MONEY NOT NULL,
    Estado BOOLEAN NOT NULL,
    CONSTRAINT PK_BOLETO PRIMARY KEY (idBoleto),
    CONSTRAINT FK_VENTA FOREIGN KEY (idVenta) REFERENCES InfoPasajero.Venta (idVenta),
    CONSTRAINT FK_PASAJERO2 FOREIGN KEY (idPasajero) REFERENCES InfoPasajero.Pasajero (idPasajero),
    CONSTRAINT FK_ASIENTO FOREIGN KEY (idAsiento) REFERENCES InfoPasajero.Asiento (idAsiento)
);
SELECT * FROM InfoPasajero.Boleto

-------------------------------------- TRIGGERS --------------------------------------------------
-- Trigger 1 --
CREATE OR REPLACE FUNCTION TR_CUPOASIENTO_FUNCTION() 
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica si la clave foránea se ha insertado más de 8 veces.
    IF (SELECT COUNT(*) FROM InfoPasajero.Asiento WHERE idItinerario = NEW.idItinerario) > 8 THEN
        -- Si ya se insertó 8 veces, entonces genera un error.
        RAISE EXCEPTION 'No se pueden insertar más de 8 registros con el mismo itinerario';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_CUPOASIENTO
AFTER INSERT OR UPDATE ON InfoPasajero.Asiento
FOR EACH ROW
EXECUTE FUNCTION TR_CUPOASIENTO_FUNCTION();


-- Trigger 2 --
CREATE OR REPLACE FUNCTION TR_ACTUALIZAMONTOTOTAL1_FUNCTION() 
RETURNS TRIGGER AS $$
DECLARE
    CostoBoleto MONEY;
BEGIN
	-- Obtener el costo del boleto del registro eliminado
    CostoBoleto = OLD.CostoTotal;

    -- Actualizar el campo "MontoTotal" en la tabla "Venta" restando el costo del boleto
    UPDATE InfoPasajero.Venta 
    SET MontoTotal = MontoTotal - CostoBoleto 
    WHERE idVenta = OLD.idVenta;
	
    -- Obtener el costo del boleto del registro recién insertado
    CostoBoleto = NEW.CostoTotal;

    -- Actualizar el campo "MontoTotal" en la tabla "Venta" sumando el costo del boleto
    UPDATE InfoPasajero.Venta 
    SET MontoTotal = MontoTotal + CostoBoleto 
    WHERE idVenta = NEW.idVenta;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ACTUALIZAMONTOTOTAL1
AFTER INSERT OR UPDATE ON InfoPasajero.Boleto
FOR EACH ROW
EXECUTE FUNCTION TR_ACTUALIZAMONTOTOTAL1_FUNCTION();

-- Trigger 3 --
-- Trigger TR_ACTUALIZAMONTOTOTAL2 --
CREATE OR REPLACE FUNCTION TR_ACTUALIZAMONTOTOTAL2_FUNCTION() 
RETURNS TRIGGER AS $$
DECLARE
    CostoBoleto MONEY;
BEGIN
    -- Obtener el costo del boleto del registro eliminado
    CostoBoleto = OLD.CostoTotal;

    -- Actualizar el campo "MontoTotal" en la tabla "Venta" restando el costo del boleto
    UPDATE InfoPasajero.Venta 
    SET MontoTotal = MontoTotal - CostoBoleto 
    WHERE idVenta = OLD.idVenta;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ACTUALIZAMONTOTOTAL2
AFTER DELETE ON InfoPasajero.Boleto
FOR EACH ROW
EXECUTE FUNCTION TR_ACTUALIZAMONTOTOTAL2_FUNCTION();


-- Trigger 4 --
CREATE OR REPLACE FUNCTION TR_BANCOTARJETA_FUNCTION() 
RETURNS TRIGGER AS $$
DECLARE
    NumeroTarjeta VARCHAR(16);
    BancoI VARCHAR(50);
BEGIN
    -- Obtener el número de tarjeta insertado o actualizado
    NumeroTarjeta := SUBSTRING(CAST(NEW.NumTarjeta AS VARCHAR) FROM LENGTH(CAST(NEW.NumTarjeta AS VARCHAR)) FOR 1);

    -- Analizar los últimos dígitos para determinar el banco
    CASE NumeroTarjeta
        WHEN '1' THEN BancoI := 'Santander';
        WHEN '2' THEN BancoI := 'Bancomer';
        WHEN '3' THEN BancoI := 'Banorte';
        WHEN '4' THEN BancoI := 'BanBajio';
        WHEN '5' THEN BancoI := 'Scotiabank';
        WHEN '6' THEN BancoI := 'Banco Azteca';
        ELSE BancoI := 'Desconocido';
    END CASE;

    -- Actualizar el campo Banco en la misma fila de la tabla
    NEW.Banco := BancoI;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_BANCOTARJETA
BEFORE INSERT OR UPDATE ON InfoPasajero.TarjetaPasajero
FOR EACH ROW
EXECUTE FUNCTION TR_BANCOTARJETA_FUNCTION();


-- Triggers 5 --
CREATE OR REPLACE FUNCTION TR_ACTUALIZARFLOTA1_FUNCTION() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.idAerolinea IS DISTINCT FROM OLD.idAerolinea THEN
        -- Restar 1 a la antigua Aerolínea
        UPDATE InfoAerolinea.Aerolinea
        SET FlotaTotal = FlotaTotal - 1,
            NumVuelos = NumVuelos - (SELECT COUNT(*) FROM InfoAerolinea.Itinerario WHERE idAvion = OLD.idAvion)
        WHERE idAerolinea = OLD.idAerolinea;

        -- Sumar 1 a la nueva Aerolínea
        UPDATE InfoAerolinea.Aerolinea
        SET FlotaTotal = FlotaTotal + 1,
            NumVuelos = NumVuelos + (SELECT COUNT(*) FROM InfoAerolinea.Itinerario WHERE idAvion = NEW.idAvion)
        WHERE idAerolinea = NEW.idAerolinea;
    END IF;
    RETURN NEW;
END;

$$ LANGUAGE plpgsql;
CREATE TRIGGER TR_ACTUALIZARFLOTA1
AFTER INSERT OR UPDATE OF idAerolinea ON InfoAerolinea.Avion
FOR EACH ROW
EXECUTE FUNCTION TR_ACTUALIZARFLOTA1_FUNCTION();

-- Trigger 6 --
CREATE OR REPLACE FUNCTION TR_ACTUALIZARFLOTA2_FUNCTION() 
RETURNS TRIGGER AS $$
BEGIN
    -- Restar 1 a la Aerolínea
    UPDATE InfoAerolinea.Aerolinea
    SET FlotaTotal = FlotaTotal - 1,
        NumVuelos = NumVuelos - (SELECT COUNT(*) FROM InfoAerolinea.Itinerario WHERE idAvion = OLD.idAvion)
    WHERE idAerolinea = OLD.idAerolinea;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ACTUALIZARFLOTA2
AFTER DELETE ON InfoAerolinea.Avion
FOR EACH ROW
EXECUTE FUNCTION TR_ACTUALIZARFLOTA2_FUNCTION();

-- Trigger 7 --
CREATE OR REPLACE FUNCTION TR_ACTUALIZARNUMVUELOS1_FUNCTION()
RETURNS TRIGGER AS $$
BEGIN	
    IF NEW.idAvion IS DISTINCT FROM OLD.idAvion THEN
		UPDATE InfoAerolinea.Aerolinea AS T
		SET NumVuelos = T.NumVuelos - 1
		FROM InfoAerolinea.Avion AS S
		WHERE S.idAerolinea = T.idAerolinea AND S.idAvion = OLD.idAvion;

		UPDATE InfoAerolinea.Aerolinea AS T
		SET NumVuelos = T.NumVuelos + 1
		FROM InfoAerolinea.Avion AS S
		WHERE S.idAerolinea = T.idAerolinea AND S.idAvion = NEW.idAvion;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ACTUALIZARNUMVUELOS1
AFTER INSERT OR UPDATE OF idAvion ON InfoAerolinea.Itinerario
FOR EACH ROW
EXECUTE FUNCTION TR_ACTUALIZARNUMVUELOS1_FUNCTION();

-- Trigger 8 --
CREATE OR REPLACE FUNCTION TR_ACTUALIZARNUMVUELOS2_FUNCTION()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE InfoAerolinea.Aerolinea AS T
	SET NumVuelos = T.NumVuelos - 1
	FROM InfoAerolinea.Avion AS S
	WHERE S.idAerolinea = T.idAerolinea AND S.idAvion = OLD.idAvion;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ACTUALIZARNUMVUELOS2
AFTER DELETE ON InfoAerolinea.Itinerario
FOR EACH ROW
EXECUTE FUNCTION TR_ACTUALIZARNUMVUELOS2_FUNCTION();

-- Trigger 9 --
CREATE OR REPLACE FUNCTION TR_CALCULAREDADPASAJERO_FUNCTION() 
RETURNS TRIGGER AS $$
DECLARE
    edad INT;
BEGIN
    edad := EXTRACT(YEAR FROM age(current_date, NEW.FechaNacimiento));
    NEW.Edad := edad;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_CALCULAREDADPASAJERO
BEFORE INSERT OR UPDATE OF
FechaNacimiento ON InfoPasajero.Pasajero
FOR EACH ROW
EXECUTE FUNCTION TR_CALCULAREDADPASAJERO_FUNCTION();


-- Triggers 10 --
-- Trigger TR_ESTADOASIENTO1 --
CREATE OR REPLACE FUNCTION TR_ESTADOASIENTO1_FUNCTION() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.idAsiento IS DISTINCT FROM OLD.idAsiento THEN
        -- Actualizar el estado del asiento a NO ocupado en el itinerario pasado
        UPDATE InfoPasajero.Asiento
        SET Ocupado = FALSE
    	WHERE idAsiento = OLD.idAsiento;

        -- Actualizar el estado del asiento a ocupado en el itinerario específico
        UPDATE InfoPasajero.Asiento
        SET Ocupado = TRUE
    	WHERE idAsiento = NEW.idAsiento;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ESTADOASIENTO1
AFTER INSERT OR UPDATE OF idAsiento ON InfoPasajero.Boleto
FOR EACH ROW
EXECUTE FUNCTION TR_ESTADOASIENTO1_FUNCTION();

-- Trigger 11 --
-- Trigger TR_ESTADOASIENTO2 --
CREATE OR REPLACE FUNCTION TR_ESTADOASIENTO2_FUNCTION() 
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar el estado del asiento a NO OCUPADO en el itinerario pasado
    UPDATE InfoPasajero.Asiento
    SET Ocupado = FALSE
    WHERE idAsiento = OLD.idAsiento;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_ESTADOASIENTO2
AFTER DELETE ON InfoPasajero.Boleto
FOR EACH ROW
EXECUTE FUNCTION TR_ESTADOASIENTO2_FUNCTION();


-------------------------------------- USUARIOS --------------------------------------------------

CREATE ROLE administrador WITH LOGIN PASSWORD '232323ADM';
GRANT CONNECT ON DATABASE "Aeropuerto" TO administrador;
GRANT ALL PRIVILEGES ON DATABASE "Aeropuerto" TO administrador;
-- Otorgar permisos en el esquema InfoAerolinea
GRANT USAGE, CREATE ON SCHEMA InfoAerolinea TO administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA InfoAerolinea TO administrador;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA InfoAerolinea TO administrador;
-- Otorgar permisos en el esquema InfoPasajero
GRANT USAGE, CREATE ON SCHEMA InfoPasajero TO administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA InfoPasajero TO administrador;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA InfoPasajero TO administrador;


CREATE ROLE aerolinea_staff WITH LOGIN PASSWORD '235491AERS';
GRANT CONNECT ON DATABASE "Aeropuerto" TO aerolinea_staff;
GRANT USAGE ON SCHEMA InfoAerolinea TO aerolinea_staff;
GRANT USAGE ON SCHEMA InfoPasajero TO aerolinea_staff;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA InfoAerolinea TO aerolinea_staff;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA InfoPasajero TO aerolinea_staff;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA InfoAerolinea TO aerolinea_staff;
GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA InfoPasajero TO aerolinea_staff;
GRANT INSERT, DELETE ON ALL TABLES IN SCHEMA InfoAerolinea TO aerolinea_staff;
REVOKE ALL PRIVILEGES ON TABLE InfoAerolinea.Ciudad FROM aerolinea_staff;


CREATE ROLE pasajero_service WITH LOGIN PASSWORD '094312PASER';
GRANT CONNECT ON DATABASE "Aeropuerto" TO pasajero_service;
GRANT USAGE ON SCHEMA InfoPasajero TO pasajero_service;
GRANT USAGE ON SCHEMA InfoAerolinea TO pasajero_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA InfoPasajero TO pasajero_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA InfoAerolinea TO pasajero_service;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA InfoPasajero TO pasajero_service;
GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA InfoAerolinea TO pasajero_service;
REVOKE DELETE ON ALL TABLES IN SCHEMA InfoPasajero FROM pasajero_service;
REVOKE INSERT, DELETE ON ALL TABLES IN SCHEMA InfoAerolinea FROM pasajero_service;

-------------------------------------- CHECK CONSTRAINT ------------------------------------------

ALTER TABLE InfoPasajero.Pasajero
ADD CONSTRAINT CHECK_EDAD CHECK (Edad > 0 AND Edad <= 110);

ALTER TABLE InfoPasajero.TarjetaPasajero
ADD CONSTRAINT CHECK_BANCO CHECK (Banco IN ('Santander','Bancomer','Banorte','BanBajio','Scotiabank','Banco Azteca','Desconocido'));

ALTER TABLE InfoAerolinea.Piloto
ADD CONSTRAINT CK_EDAD CHECK (FechaNacimiento <= CURRENT_DATE - INTERVAL '25 years');

ALTER TABLE InfoAerolinea.Avion
ADD CONSTRAINT CHK_ANIOFABRICACION
CHECK (AñoFabricacion <= EXTRACT(YEAR FROM CURRENT_DATE) AND AñoFabricacion >= 1905);


