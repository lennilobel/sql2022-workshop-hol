/* =================== Always Encrypted with Secure Enclaves (2019) =================== */

CREATE DATABASE MyEncryptedDB
GO

USE MyEncryptedDB
GO

-- Populate a table with sensitive data
CREATE TABLE Customer(
 CustomerId int IDENTITY(1,1) NOT NULL,
 Name varchar(20) NOT NULL,
 SSN varchar(20) NOT NULL,
 City varchar(20) NOT NULL)

INSERT INTO Customer VALUES
 ('John Smith', '123-45-6789', 'New York'),
 ('Doug Nichols', '987-65-4321', 'Boston'),
 ('Joe Anonymous', 'n/a', 'Chicago')

-- View the sensitive data, unencrypted
SELECT * FROM Customer


/* Create enclave-enabled CMK1 (in Windows certificate store for current user) and CEK1 */


-- Discover Always Encrypted keys (enclave-enabled)
SELECT * FROM sys.column_master_keys
SELECT * FROM sys.column_encryption_keys 
SELECT * FROM sys.column_encryption_key_values

-- Discover columns protected by Always Encrypted (none yet)
SELECT * FROM sys.columns WHERE column_encryption_key_id IS NOT NULL


/* New connection with AE enabled and attestation URL set to http://10.10.0.5/Attestation */


-- Encrypt in-place

USE MyEncryptedDB
GO

ALTER TABLE Customer
 ALTER COLUMN SSN varchar(20) COLLATE Latin1_General_BIN2
 ENCRYPTED WITH
  (COLUMN_ENCRYPTION_KEY = CEK1,
   ENCRYPTION_TYPE = Randomized,
   ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
 WITH (ONLINE = ON)

-- Data is being decrypted because of AE-enabled connection
SELECT * FROM Customer


/* New connection with AE disabled */


USE MyEncryptedDB
GO

-- Data appears encrypted
SELECT * FROM Customer


/* New connection with AE enabled and attestation URL set to http://10.10.0.5/Attestation */

USE MyEncryptedDB
GO

-- Data appears decrypted, but can it also be queried?
SELECT * FROM Customer

-- Let's try equality on randomly encrypted SSN; this always worked only with deterministic encryption
DECLARE @SSN varchar(20) = '987-65-4321'
SELECT * FROM Customer
 WHERE SSN = @SSN

GO

-- Range searching works too
DECLARE @SSN varchar(20) = '5'
SELECT * FROM Customer
 WHERE SSN > @SSN

GO

-- And so does LIKE... it's magic!
DECLARE @SSN varchar(20) = '%-4%'
SELECT * FROM Customer
 WHERE SSN LIKE @SSN

GO
