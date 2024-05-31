-- Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas 
-- realizadas en enero 2020 sea superior a 1500. 
select
    c.nombre
    ,c.apellido
    ,c.fecha_nacimiento
    ,count(o.id) as cantidad_ventas
from Customer c
inner join Order as o on c.id = o.customer_id
where c.fecha_nacimiento = current_date()
and o.fecha_pedido between '2020-01-01' AND '2020-01-31'
group by 1, 2, 3
having count(o.id) > 1500;

--Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($)
-- en la categoría Celulares. Se requiere el mes y año de análisis, nombre y 
--apellido del vendedor, cantidad de ventas realizadas, cantidad de productos
-- vendidos y el monto total transaccionado. 
with cte as (
    select
        date_format(o.fecha_pedido, '%Y-%m-01') as mes
        ,c.nombre
        ,c.apellido
        ,count(o.id) as cantidad_ventas
        ,sum(oi.cantidad) as cantidad_productos_vendido
        ,sum(oi.precio_unitario * oi.cantidad) as monto_total_transaccionado
        ,row_number() over(partition by date_format(current_date(), '%Y-%m-01')
            order by sum(oi.precio_unitario * oi.cantidad) desc) as row_num
    from "Order" as o
    inner join Customer as c on c.id = o.customer_id
    inner join Order_Item as oi on oi.order_id = o.id
    inner join Item as i on i.id = oi.item_id
    inner join Category as cat on cat.id = i.categoria_id
    where cat.description = 'Celulares'
    and year(o.fecha_pedido) = 2020
    group by 1, 2, 3
)
select * from cte where row_num <= 5
order by 1, 7;

-- Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin 
-- del día. Tener en cuenta que debe ser reprocesable. Vale resaltar que en la 
-- tabla Item, vamos a tener únicamente el último estado informado por la PK 
-- definida. (Se puede resolver a través de StoredProcedure) 

-- 1. Crear la tabla de histórico
CREATE TABLE ItemHistory (
    item_id INT,
    fecha DATE,
    precio DECIMAL(10, 2),
    estado VARCHAR(20),
    PRIMARY KEY (item_id, fecha)
);

-- 2. Crear la procedure
DELIMITER //

DELIMITER //

CREATE PROCEDURE UpdateItemHistory()
BEGIN
    DECLARE current_date DATE;
    SET current_date = CURDATE();

    INSERT INTO ItemHistory (item_id, fecha, precio, estado)
    SELECT 
        i.id AS item_id,
        current_date AS fecha,
        i.precio AS precio,
        i.estado AS estado
    FROM Item i
    ON DUPLICATE KEY UPDATE
        precio = VALUES(precio),
        estado = VALUES(estado);
END //

DELIMITER ;


-- 3. Crear evento
CREATE EVENT UpdateItemHistoryDaily
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY)
DO CALL UpdateItemHistory();