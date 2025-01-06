CREATE TABLE items (
    item_id NUMBER PRIMARY KEY,
    item_name VARCHAR2(100) NOT NULL,
    price NUMBER(10, 2) NOT NULL,
    stock_level NUMBER NOT NULL,
    restock_threshold NUMBER NOT NULL
);
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    phone_number VARCHAR2(15)
);
INSERT INTO customers (customer_id, customer_name, email, phone_number)
VALUES (1, 'John Doe', 'john.doe@example.com', '1234567890');

INSERT INTO customers (customer_id, customer_name, email, phone_number)
VALUES (2, 'Jane Smith', 'jane.smith@example.com', '0987654321');

INSERT INTO customers (customer_id, customer_name, email, phone_number)
VALUES (3, 'Robert Brown', 'robert.brown@example.com', '5678901234');

CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customers(customer_id),
    order_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) CHECK (status IN ('PLACED', 'CANCELED')),
    total_amount NUMBER(10, 2)
);
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
VALUES (1, 1, SYSDATE - 1, 'PLACED', 15.00);

INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
VALUES (2, 2, SYSDATE - 2, 'PLACED', 20.50);

INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
VALUES (3, 3, SYSDATE - 3, 'CANCELED', 0.00);

CREATE TABLE order_items (
    order_item_id NUMBER PRIMARY KEY,
    order_id NUMBER REFERENCES orders(order_id),
    item_id NUMBER REFERENCES items(item_id),
    quantity NUMBER NOT NULL,
    price_per_unit NUMBER(10, 2) NOT NULL
);
INSERT INTO order_items (order_item_id, order_id, item_id, quantity, price_per_unit)
VALUES (1, 1, 1, 10, 0.50); 

INSERT INTO order_items (order_item_id, order_id, item_id, quantity, price_per_unit)
VALUES (2, 1, 3, 5, 1.20);  

INSERT INTO order_items (order_item_id, order_id, item_id, quantity, price_per_unit)
VALUES (3, 2, 2, 15, 0.30); 

INSERT INTO order_items (order_item_id, order_id, item_id, quantity, price_per_unit)
VALUES (4, 2, 4, 3, 1.50);  




INSERT INTO items (item_id, item_name, price, stock_level, restock_threshold)
VALUES (1, 'Apple', 0.50, 100, 20);

INSERT INTO items (item_id, item_name, price, stock_level, restock_threshold)
VALUES (2, 'Banana', 0.30, 120, 30);

INSERT INTO items (item_id, item_name, price, stock_level, restock_threshold)
VALUES (3, 'Milk', 1.20, 50, 10);

INSERT INTO items (item_id, item_name, price, stock_level, restock_threshold)
VALUES (4, 'Bread', 1.50, 40, 15);

INSERT INTO items (item_id, item_name, price, stock_level, restock_threshold)
VALUES (5, 'Rice', 0.80, 200, 50);
SELECT * FROM items;
SELECT * FROM customers;
SELECT * FROM orders;
select * from order_items;


SELECT item_name, stock_level, restock_threshold
FROM items
WHERE stock_level <= restock_threshold;

DECLARE
    v_customer_id NUMBER := 1;  -- Set the customer_id value
BEGIN
    FOR rec IN (
        SELECT o.order_id, o.order_date, o.status, o.total_amount, 
               i.item_name, oi.quantity, oi.price_per_unit
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN items i ON oi.item_id = i.item_id
        WHERE o.customer_id = v_customer_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Order ID: ' || rec.order_id);
    END LOOP;
END;
/


    
CREATE OR REPLACE PROCEDURE add_new_order (
    p_customer_id IN NUMBER,
    p_items IN SYS.ODCINUMBERLIST,
    p_quantities IN SYS.ODCINUMBERLIST
) IS
    v_order_id NUMBER;
    v_total_amount NUMBER := 0;
    v_price NUMBER;
    v_stock_level NUMBER;
    v_order_item_id NUMBER;
BEGIN
    -- Generate a new order ID
    SELECT NVL(MAX(order_id), 0) + 1 INTO v_order_id FROM orders;

    -- Insert order into the orders table
    INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
    VALUES (v_order_id, p_customer_id, SYSDATE, 'PLACED', 0);

    -- Loop over the items in the order
    FOR i IN 1..p_items.COUNT LOOP
        -- Get the price for the item
        SELECT price INTO v_price FROM items WHERE item_id = p_items(i);

        -- Check the stock level for the item
        SELECT stock_level INTO v_stock_level FROM items WHERE item_id = p_items(i);

        -- Check if there is sufficient stock
        IF v_stock_level < p_quantities(i) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for item ' || p_items(i));
        ELSE
            -- Insert the item into the order_items table
            SELECT NVL(MAX(order_item_id), 0) + 1 INTO v_order_item_id FROM order_items;

            INSERT INTO order_items (order_item_id, order_id, item_id, quantity, price_per_unit)
            VALUES (
                v_order_item_id,
                v_order_id,
                p_items(i),
                p_quantities(i),
                v_price
            );

            -- Update the total amount for the order
            v_total_amount := v_total_amount + (v_price * p_quantities(i));

            -- Update stock level for the item
            UPDATE items
            SET stock_level = stock_level - p_quantities(i)
            WHERE item_id = p_items(i);
        END IF;
    END LOOP;

    -- Update the total amount in the orders table
    UPDATE orders
    SET total_amount = v_total_amount
    WHERE order_id = v_order_id;

    -- Commit the changes (ensure that the changes are saved)
    COMMIT;

    -- Output a success message
    DBMS_OUTPUT.PUT_LINE('Order placed successfully. Order ID: ' || v_order_id);
EXCEPTION
    WHEN OTHERS THEN
        -- In case of any error, rollback the transaction
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


DECLARE
    p_customer_id NUMBER := 1;  -- Example customer ID
    p_items SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 2);  -- Example item IDs
    p_quantities SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(5, 10);  -- Example quantities
BEGIN
    add_new_order(p_customer_id, p_items, p_quantities);
END;
/

SELECT * FROM orders WHERE order_id = 5;
SELECT * FROM order_items WHERE order_id = 5;
SELECT item_id, item_name, stock_level FROM items WHERE item_id IN (1, 2, 3);


CREATE OR REPLACE PROCEDURE generate_restocking_recommendations AS
BEGIN
    FOR rec IN (
        SELECT item_name, stock_level, restock_threshold
        FROM items
        WHERE stock_level <= restock_threshold
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Restock Needed: ' || rec.item_name || 
                             ' (Stock: ' || rec.stock_level || 
                             ', Threshold: ' || rec.restock_threshold || ')');
    END LOOP;
END;
/
BEGIN
    generate_restocking_recommendations;
END;
/
SELECT item_name, stock_level, restock_threshold FROM items;

CREATE OR REPLACE TRIGGER update_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE items
    SET stock_level = stock_level - :NEW.quantity
    WHERE item_id = :NEW.item_id;
END;
/

CREATE OR REPLACE TRIGGER restore_stock_after_cancellation
AFTER UPDATE OF status ON orders
FOR EACH ROW
WHEN (NEW.status = 'CANCELED' AND OLD.status = 'PLACED')
BEGIN
    FOR rec IN (
        SELECT item_id, quantity
        FROM order_items
        WHERE order_id = :NEW.order_id
    ) LOOP
        UPDATE items
        SET stock_level = stock_level + rec.quantity
        WHERE item_id = rec.item_id;
    END LOOP;
END;
/
UPDATE orders
SET status = 'CANCELED'
WHERE order_id = 1; 

SELECT item_name, stock_level FROM items;

CREATE OR REPLACE FUNCTION is_stock_available (
    p_item_id IN NUMBER,
    p_quantity IN NUMBER
) RETURN BOOLEAN IS
    v_stock_level NUMBER;
BEGIN
    SELECT stock_level INTO v_stock_level FROM items WHERE item_id = p_item_id;
    RETURN v_stock_level >= p_quantity;
END;
/
DECLARE
    v_item_id NUMBER := 1;
    v_quantity NUMBER := 10;
    v_is_available BOOLEAN;
BEGIN
    v_is_available := is_stock_available(v_item_id, v_quantity);

    IF v_is_available THEN
        DBMS_OUTPUT.PUT_LINE('Stock is available.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Stock is not available.');
    END IF;
END;
/













