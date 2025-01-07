Name:-Hase Pranali Dnyaneshwar.
Branch:-Computer (TE-A)
Project name:-Grocery Store Management System.
# PL_SQL_ZENSAR_PROJECT
##Description:  This project is designed to build an efficient database system for managing grocery store operations, particularly for online grocery platforms. 
The system includes handling inventory, customer orders, order items, and stock management. The main components of this system are implemented using SQL queries, PL/SQL functions, procedures, and triggers to ensure smooth operations and data integrity. 
Here's a breakdown of the system's key features and components:
##key task:-
#Inventory Management: Tracks items' details and recommends restocking when stock falls below a threshold.
#Order Management: Manages customer orders and stores items and quantities in the order_items table.
#Stock Updates: Automatically updates stock levels after orders, cancellations, or restocks using triggers and functions.
#Stock Availability Check: Ensures sufficient stock is available before placing an order.
#Trigger for Order Insertion: Updates stock levels when new order items are inserted.
#Trigger for Order Cancellation: Restores stock levels when an order is canceled.
#Restocking Recommendations: Generates a report for items that need restocking based on stock levels and thresholds.

##Tables
#items:Stores information about each grocery item.
  Columns: item_id, item_name, price, stock_level, restock_threshold.

#orders:Stores information about customer orders.
Columns: order_id, customer_id, order_date, status, total_amount.

#order_items:Stores information about the individual items in each order.
Columns: order_item_id, order_id, item_id, quantity, price_per_unit.

##PL/SQL Procedures & Triggers
Procedure for Adding New Orders:The add_new_order procedure allows for adding a new order to the system. It takes the customer ID, item IDs, and quantities as inputs,calculates the total order amount, and updates the stock levels.

Function for Stock Availability:The is_stock_available function checks if there is enough stock for a given item and quantity. It returns a boolean value (TRUE or FALSE).

Trigger for Stock Update After Order Insertion:The update_stock_after_order trigger automatically updates the stock levels whenever an order item is added to theorder_items table.

Trigger for Restoring Stock After Order Cancellation:The restore_stock_after_cancellation trigger restores the stock levels of canceled items, ensuring that inventorylevels reflect cancellations.

Restocking Recommendations:The generate_restocking_recommendations procedure generates a list of items that need to be restocked based on their stock levels and predefinedrestock thresholds.

##Workflow
Placing an Order:The user places an order by calling the add_new_order procedure, which inserts the order and order items, calculates the total amount, and updates the stock levels accordingly.

Order Cancellation:If an order is canceled (via an UPDATE on the orders table), the restore_stock_after_cancellation trigger is activated. It will update the stock levelsby adding back the quantities of canceled items.

Stock Level Check:Before placing an order, the system checks whether enough stock is available using the is_stock_available function.

Restocking Recommendations:The generate_restocking_recommendations procedure is executed periodically or on demand to identify items that are below their restock thresholds,helping store managers know which items need to be reordered.


