ALTER TABLE IF EXISTS bank_account
    ADD PRIMARY KEY (id);

CREATE TABLE IF NOT EXISTS transaction_import_event (
    id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    status TEXT NOT NULL,
    bank_account_id INT REFERENCES bank_account (id) NOT NULL,
    total_amount DOUBLE PRECISION NOT NULL,
    transactions_count INT NOT NULL,
    imported_when DATE NOT NULL,
    source_type TEXT NOT NULL,
    is_manual BOOLEAN NOT NULL,
    filename TEXT,
    file_content TEXT
);

CREATE TABLE IF NOT EXISTS bank_account_balance (
    id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    transaction_import_event_id INT REFERENCES transaction_import_event (id) NOT NULL,
    balance_type TEXT NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    credit_debit TEXT NOT NULL,
    date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS imported_transaction (
    id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    transaction_import_event_id INT REFERENCES transaction_import_event (id) NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    credit_debit TEXT NOT NULL,
    reversal_indicator BOOLEAN,
    booking_date DATE NOT NULL,
    transaction_ref TEXT,
    bank_domain_code TEXT,
    bank_family_code TEXT,
    bank_sub_family_code TEXT,
    transaction_text TEXT,
    origin_amount DOUBLE PRECISION,
    origin_currency VARCHAR(3),
    exchange_rate DOUBLE PRECISION,
    third_party_name TEXT,
    third_party_address JSONB,
    parent_imported_transaction_id INT REFERENCES imported_transaction (id),
    end_to_end_id TEXT,
    purpose TEXT,
    remittance_ref TEXT,
    remittance_type TEXT
);

UPDATE defaults SET fldvalue = '2.8.33' where fldname = 'version';