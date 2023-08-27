
# Table wide encryption

## Creating table

1. Create new table which will be encrypted entirely
```
DROP TABLE IF EXISTS my_secrets CASCADE; CREATE TABLE my_secrets ( secret text );
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

1. To get encrypted data
```
SELECT * FROM my_secrets;
```
2. To get decrypted data
```
SELECT * FROM decrypted_my_secrets;
```
