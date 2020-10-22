-- Inventory transfers
CREATE TABLE trf (
    id 			integer PRIMARY KEY DEFAULT nextval('id'),
    transdate 		date,
    trfnumber 		text,
    description 	text,
    notes 		text,
    department_id 	integer,
    from_warehouse_id	integer,
    to_warehouse_id 	integer DEFAULT 0,
    employee_id		integer DEFAULT 0
);

-- Customisation of 'inventory' table for transfer module
-- linetype:
---- 0 for transactions from ar, ap, oe etc.
---- 1 for transaction entered by user in trf
---- 2 for offsetting transaction generated by system in trf
---- 3 Inventory taken out to build assembly
---- 4 Assembly built
ALTER TABLE inventory 
	ADD COLUMN department_id 	integer,
	ADD COLUMN warehouse_id2 	integer,
	ADD COLUMN serialnumber 	text,
	ADD COLUMN itemnotes 		text,
	ADD COLUMN cost 		float,
	ADD COLUMN linetype 		CHAR(1) DEFAULT '0'
;

-- delivereddate is updated by a seperate form when goods are 'received' at the other warehouse.
ALTER TABLE trf ADD COLUMN delivereddate DATE;

ALTER TABLE invoice ADD COLUMN transdate DATE;

-- Table for invoices reposting / FIFO reports.
-- trans_id is ar.id
CREATE TABLE fifo (
	trans_id	integer,
	transdate	date,
	parts_id	integer,
	qty		float,
	costprice	float,
	sellprice	float
);

ALTER TABLE invoice ADD COLUMN lastcost float;

CREATE TABLE invoicetax (
	trans_id	integer,
 	invoice_id	integer,
	chart_id	integer,
	taxamount	float
);

CREATE INDEX invoice_parts_id ON invoice (parts_id); 
CREATE INDEX fifo_parts_id ON fifo (parts_id);

CREATE TABLE build (
	id		integer PRIMARY KEY DEFAULT nextval('id'),
	reference	text,
	transdate	date,
	department_id	integer,
	warehouse_id	integer,
	employee_id	integer
);

-- description column stores user-modified description of item from invoices and transfer screen.
ALTER TABLE inventory ADD COLUMN description TEXT;

-- FIFO is based on warehouse now.
ALTER TABLE fifo ADD COLUMN warehouse_id INTEGER;
ALTER TABLE invoice ADD COLUMN warehouse_id INTEGER;

-- invoice_id reference in acc_trans 
ALTER TABLE fifo ADD COLUMN invoice_id INTEGER;

ALTER TABLE inventory ADD COLUMN invoice_id INTEGER;
CREATE INDEX inventory_invoice_id ON inventory (invoice_id);

ALTER TABLE invoice ADD COLUMN cogs float;
ALTER TABLE inventory ADD COLUMN cogs float;

-- armaghan 01/apr/2010 acc_trans primary key
CREATE SEQUENCE entry_id;
SELECT nextval ('entry_id');
ALTER TABLE acc_trans ADD COLUMN entry_id INTEGER DEFAULT nextval('entry_id');


-- Update new denormalized columns (moved from cogs reposting)
UPDATE invoice SET 
	transdate = (SELECT transdate FROM ar WHERE ar.id = invoice.trans_id),
	warehouse_id = (SELECT warehouse_id FROM ar WHERE ar.id = invoice.trans_id)
WHERE trans_id IN (SELECT id FROM ar);

UPDATE invoice SET 
	transdate = (SELECT transdate FROM ap WHERE ap.id = invoice.trans_id),
	warehouse_id = (SELECT warehouse_id FROM ap WHERE ap.id = invoice.trans_id)
WHERE trans_id IN (SELECT id FROM ap);

-- Few indexes to speed up cogs reposting
CREATE INDEX fifo_trans_id ON fifo (trans_id);
CREATE INDEX invoice_qty ON invoice (qty);

-- Tables for Ledgercart
CREATE SEQUENCE customerloginid start 1;
SELECT nextval('customerloginid');

CREATE TABLE customercart (
    cart_id character varying(32),
    customer_id integer,
    parts_id integer,
    qty double precision DEFAULT 0,
    price double precision DEFAULT 0,
    taxaccounts text
);

CREATE TABLE customerlogin (
    id integer DEFAULT nextval('customerloginid') primary key,
    "login" character varying(100) unique,
    passwd character(32),
    "session" character(32) unique,
    session_exp character varying(20),
    customer_id integer
);

CREATE TABLE partsattr (
    parts_id INTEGER,
    hotnew VARCHAR(3)
);

ALTER TABLE acc_trans ADD tax TEXT;
ALTER TABLE acc_trans ADD taxamount float;

-- dispatch methods table
CREATE TABLE dispatch (
  id int DEFAULT nextval('id'),
  description text
);

ALTER TABLE customer ADD dispatch_id INTEGER;
ALTER TABLE vendor ADD dispatch_id INTEGER;

ALTER TABLE invoicetax ADD amount float;

ALTER TABLE acc_trans ADD tax_chart_id INTEGER;

ALTER TABLE ar ADD linetax BOOLEAN DEFAULT false;
ALTER TABLE ap ADD linetax BOOLEAN DEFAULT false;

-- DATEV export 
create table debits (id serial, reference text, description text, transdate date, accno text, amount numeric(12,2));
create table credits (id serial, reference text, description text, transdate date, accno text, amount numeric(12,2));
create table debitscredits (id serial, reference text, description text, transdate date, debit_accno text, credit_accno text, amount numeric(12,2));

CREATE TABLE gl_log (
    id integer,
    reference text,
    description text,
    transdate date,
    employee_id integer,
    notes text,
    department_id integer,
    approved boolean,
    curr character(3),
    exchangerate double precision,
    ticket_id integer,
    ts timestamp without time zone
);

alter table gl add column onhold boolean;
alter table gl_log add column onhold boolean;
alter table gl_log_deleted add column onhold boolean;

