-- Crear tabla Customer
CREATE TABLE Customer (
    ID SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    sexo CHAR(1),
    direccion TEXT,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    tipo VARCHAR(10)
);

-- Crear tabla Category
CREATE TABLE Category (
    ID SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    path TEXT
);

-- Crear tabla Item
CREATE TABLE Item (
    ID SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    estado VARCHAR(50),
    fecha_alta DATE,
    fecha_baja DATE,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES Category(ID)
);

-- Crear tabla Order
CREATE TABLE "Order" (
    ID SERIAL PRIMARY KEY,
    fecha TIMESTAMP NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(ID)
);

-- Crear tabla Order_Item
CREATE TABLE Order_Item (
    order_id INT,
    item_id INT,
    cantidad DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES "Order"(ID),
    FOREIGN KEY (item_id) REFERENCES Item(ID)
);
