select * from store.customers
where address like "%TRAIL%" OR address like "%Avenue%";

select * from store.customers
where last_name not like "_____y";

-- REGEXP
select * from customers
-- where last_name REGEXP 'field';
-- where last_name REGEXP '^field';   -- here ^ means begins
-- where last_name REGEXP 'field$';    -- $ ends with
-- where last_name REGEXP '[igm]e';   -- which contain ie, ge, me
-- where last_name REGEXP 'e[igmby]';    -- which contains ei, eg, em, eb, ey
-- where last_name REGEXP '[a-h]e';       -- which contains ae, be, ce, etc upto -- he 
-- where last_name REGEXP 'e[a-h]';        -- which contains ea,eb, ec, upto eh
-- where first_name REGEXP 'ELKA|AMBUR';    -- which contains ELKA or AMBUR
-- where last_name REGEXP 'ey$|ON$';    -- which ends with ey or ON
where last_name REGEXP '^my|se';        -- which starts with my or contains se 


-- records with missing values NULL Operator
select * from customers
-- where phone is NULL  -- customer whose phone no is missing or not updated
where phone is NOT NULL;   -- custumers with phone numbers

select * from orders
where shipped_date IS null OR shipper_id IS null;  -- get the orders that are not shipped

-- ORDER BY clause
select * from customers
order by state ASC, first_name DESC;
select first_name, last_name, state from customers
order by 1,2;                   -- not recommended
select first_name, last_name, state from customers
order by birth_date;

SELECT *, quantity*unit_price AS total_price FROM order_items
where order_id=2
order by total_price DESC;

-- LIMIT clause
select * from customers
-- LIMIT 3;
LIMIT 6, 3;   -- let's go frist 6 rows, next 3 rows as results
-- Get the top three loyal cusdtomers (means customers with highest points)
select * from customers
order by points DESC
limit 3;

-- Join  means inner join here keyword inner is optional
select c.first_name, c.last_name, c.customer_id, o.order_id from customers c
join orders o  -- means inner join
on o.customer_id = c.customer_id;

select oi.*, p.name from order_items oi   -- here order_items table uint price indicates price of the productwhen user or customer ordered
join products p                           -- and unit price in product table give price of the product at current time
on p.product_id = oi.product_id;

-- joining cross databases
select * from order_items oi          -- prefix the table that is not part of current database
join sql_inventory.products p
on oi.product_id = p.product_id;

-- self join
use sql_hr;
select e.employee_id, e.first_name, m.first_name as manager from employees e
join employees m 
on e.reports_to = m.employee_id;

-- joining multiple tables
use store;
select o.order_id, o.order_date, c.first_name, c.last_name, os.name as status from orders o
join customers c on o.customer_id = c.customer_id
join order_statuses os on o.status = os.order_status_id;

use sql_invoicing;
select p.payment_id, c.name as client, p.date, p.amount, pm.name as payment_method from payments p
join clients c on p.client_id = c.client_id
join payment_methods pm on p.payment_method = pm.payment_method_id;

-- compound join conditions
use store;
select * from order_items oi   -- here order_item_notes table is missing and this type of join is needed when there is no unique identifier column
join order_item_notes oin      -- so we join using two columns
on oi.order_id = oin.order_id AND oi.product_id = oin.product_id;

-- implicit join syntax
select * from orders o
join customers c on o.customer_id = c.customer_id;
-- below is implict join for above join but try to not use it if forget where clause it will cross join
select * from orders o, customers c
where o.customer_id= c.customer_id;

-- outer join here in query if left or right keyword is used then outer keyword is optional
select c.customer_id, c.first_name, o.order_id from customers c
join orders o 
on c.customer_id = o.customer_id
order by c.customer_id;  -- this gives inner join but if observe not all customers ids ore returned

select c.customer_id, c.first_name, o.order_id from customers c
left join orders o 
on c.customer_id = o.customer_id
order by c.customer_id;  -- this returns all customers regradless of conditon left table

select c.customer_id, c.first_name, o.order_id from orders o 
right join customers c
on c.customer_id = o.customer_id
order by c.customer_id;  -- this gives same result as above join using right join

select p.product_id, p.name, oi.quantity from products p
left join order_items oi
on p.product_id = oi.product_id;

-- outer join between multiple tables
select c.customer_id, c.first_name, o.order_id, sh.name as shipper from customers c
left join orders o 
on c.customer_id = o.customer_id
left join shippers sh
on o.shipper_id = sh.shipper_id;

select o.order_date, o.order_id, c.first_name as customer, sh.name as shipper, os.name as status from orders o
join customers c on c.customer_id = o.customer_id
left join shippers sh on o.shipper_id = sh.shipper_id
left join order_statuses os on o.status = os.order_status_id;

-- self outer joins
select e.employee_id, e.first_name, m.first_name as manager from employees e
left join employees m 
on e.reports_to = m.employee_id;

-- using clause column names must be exactly same across different tables
select * from customers c
join orders o USING (customer_id);  -- inner join
select * from order_items oi
join order_item_notes oin using (order_id, product_id);  -- outer join

use sql_invoicing;
select p.date, c.name, p.amount, pm.name from payments p
JOIN clients c USING(client_id)
JOIN payment_methods pm on p.payment_method = pm.payment_method_id;

-- Natural Joins recommended not to use as it can produce unexpected results
USE store;
select c.first_name, o.order_id from customers c
NATURAL JOIN orders o;

-- cross joins
select c.first_name as customer, p.name as productname   from customers c
CROSS JOIN products p
order by customer;

select sh.name as shippername, p.name as productname from products p
cross join shippers sh 
order by shippername;  -- explicit join example
select sh.name as shippername, p.name as productname
from products p, shippers sh
order by shippername;   -- impicit cross join

-- UNION clause
select customer_id, first_name, points, 'Bronze' as type from customers
where points <2000
UNION
select customer_id, first_name, points, 'Silver' as type from customers
where points >= 2000 AND points < 3000
UNION
select customer_id, first_name, points, 'Gold' as type from customers
where points >= 3000;  -- basic level

select customer_id, first_name, points, 'Bronze' as type from customers
where points <2000
UNION
select customer_id, first_name, points, 'Silver' as type from customers
where points BETWEEN 2000 AND 3000
UNION
select customer_id, first_name, points, 'Gold' as type from customers
where points > 3000  -- modified looks good

-- insert single row
INSERT INTO CUSTOMERS
VALUES (DEFAULT,
         'John',
         'Smith',
         '1990-01-01',
         null,
         'address',
         'city',
         'CA',
         default);

INSERT INTO CUSTOMERS(
          first_name, 
          last_name, 
          birth_date, 
          address, 
          city, 
          state)
VALUES ('John',
         'Smith2',
         '1990-01-02',
         'address2',
         'city2',
         'CA');

INSERT INTO CUSTOMERS(
          last_name,
          first_name, 
          birth_date, 
          address, 
          city, 
          state)
VALUES ( 'Smith3',
         'John',
         '1990-01-03',
         'address3',
         'city3',
         'CA');         
 select * from customers  
 
 -- inserting multiple rows
 insert into shippers(name)
values ('shippers1'), 
       ('shippers2'),
       ('shippers3');
       
select * from shippers; 
-- insert three rows into product table
select * from products;

insert into products (name, quantity_in_stock, unit_price)
values ('clicnic Plus', 20, 2.5),
       ('Dettol Handwash', 50, 9.99),
       ('Milk powder', 10, 10);
  -- inserting Hierarchical rows
insert into orders(customer_id, order_date, status)
values(1, '1990-01-20',1);
insert into order_items
values(last_insert_id(), 1, 2, 1.23),
      (last_insert_id(), 2, 5, 2.23); 
 select * from orders;     
 select * from order_items;
 -- create a copy of a table
CREATE TABLE orders_archived AS
select * from orders;

INSERT INTO orders_archived
select * from orders where order_date < '2019-01-01';
-- another example
USE sql_invoicing;
select i.*, c.name from invoices i, clients c
where c.client_id = i.client_id AND i.payment_date is not null;

create table invoice_archive AS
select i.*, c.name from invoices i, clients c
where c.client_id = i.client_id AND i.payment_date is not null;

-- we can also write like this as below
create table invoice_archive AS
select i.invoice_id, 
       i.number, 
       c.name, 
       i.invoice_total, 
       i.payment_total, 
       i.invoice_date, 
       i.due_date, 
       i.payment_date
from invoices i
join clients c USING (client_id)
where i.payment_date is not null;
select * from invoice_archive;

-- update a single row
UPDATE invoices
SET payment_total = invoice_total*0.5,
    payment_date  = due_date
    where invoice_id =1;
-- update multiple rows    
UPDATE invoices      -- uncheck safe update setting in mysql settings
SET payment_total = invoice_total*0.5,
    payment_date  = due_date
    where client_id in (3,5);    
    
use store;
select * from customers;
update customers
set points = points + 50
where birth_date <'1990-01-01';  

-- using subqueries in update
UPDATE invoices
SET payment_total = invoice_total*0.5,
    payment_date  = due_date
    where client_id = (select client_id from clients where state in ('CA', 'NY') );
    
 UPDATE orders
SET comments = 'Golden customer'
    where customer_id IN(
                    select customer_id from customers
                    where points> 3000);
    
-- delete row statement
USE sql_invoicing;
Delete from invoices
where client_id IN (
select client_id from clients where name = 'myworks');
select * from invoices;
