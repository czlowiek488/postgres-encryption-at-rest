
# Table wide encryption

## Creating table

1. Create new table which will be encrypted entirely
```
DROP TABLE IF EXISTS my_secrets CASCADE;
CREATE TABLE my_secrets ( secret text );
```
2. Generate new encryption key
```
SELECT id FROM pgsodium.create_key()
```
3. Add security label to make encryption on the fly (replace {id} with id selected from command above)
```
SECURITY LABEL FOR pgsodium ON COLUMN my_secrets.secret 'IS ENCRYPT WITH KEY ID {id}'
```

## Accessing table
1. Add data to the table
```
INSERT INTO my_secrets (secret) VALUES ('sekert1'), ('shhhhh'), ('0xABC_my_payment_processor_key');
```
2. To get encrypted data
```
SELECT * FROM my_secrets;
```
3. To get decrypted data
```
SELECT * FROM decrypted_my_secrets;
```

# Row Level encryption

## Creating table

1. Create new table
```
DROP TABLE IF EXISTS my_customers_data CASCADE; 
CREATE TABLE my_customers_data ( 
    id bigserial, 
    secret_data text, -- data to be encrypted
    key_id uuid REFERENCES pgsodium.key(id) DEFAULT (pgsodium.create_key()).id, 
    nonce bytea DEFAULT pgsodium.crypto_aead_det_noncegen()
);
```
2. Add security label for decryption
```
SECURITY LABEL FOR pgsodium ON TABLE my_customers_data IS 'DECRYPT WITH VIEW public.decrypted_my_customers_data';
```
3. Add security label for encryption, specify which column will be encrypted
```
SECURITY LABEL FOR pgsodium ON COLUMN my_customers_data.secret_data IS 'ENCRYPT WITH KEY COLUMN key_id NONCE nonce';
```

## Accessing table

1. Add data to table 
```
INSERT INTO my_customers_data (secret_data) VALUES ('top secret #1'), ('top secret #2'), ('top secret #3');
```
2. Get encrypted data
```
SELECT secret_data, key_id FROM my_customers_data;
```
3. Get decrypted data
```
SELECT decrypted_secret_data as secret_data, key_id FROM decrypted_my_customers_data;
```

# Generating keys strategies

## Key can be created using any arbitrary string for example user password hashed in sha256 (keep in mind that if user changes his password there may be need to migrate his data to use new key)
```
select * from pgsodium.create_key(raw_key:=digest('userPassword', 'sha256'));
```
## Key can specify parent key which will be using for encryption (e.g. parent_key may allow to group users)
```
select * from pgsodium.create_key(raw_key:=digest('userPassword', 'sha256'),parent_key:='e707f48c-8ce6-471c-88ee-f1b0c9be1517');
```
## Each key can store additional information which is not encrypted, for example to identify user which uses this key
```
select * from pgsodium.create_key(raw_key:=digest('userPassword', 'sha256'),parent_key:='e707f48c-8ce6-471c-88ee-f1b0c9be1517',associated_data:='{"clientName":"someClientName"}');
```