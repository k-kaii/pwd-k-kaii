CREATE TABLE rekening (
    no_rekening SERIAL PRIMARY KEY,
    nama VARCHAR(100), 
    saldo NUMERIC(15, 2) 
);

INSERT INTO rekening (nama, saldo) VALUES 
('Adelia', 200000),
('Sahroni', 1000000),
('Bahlil', 1000);

SELECT * FROM rekening;

--membuat stored  procedure (buat rekening baru)
CREATE OR REPLACE PROCEDURE buat_rekening(
    IN nama_nasabah VARCHAR(100),
    IN saldo_awal NUMERIC(15, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF saldo_awal < 20000 END 
    THEN
    RAISE EXCEPTION 'Saldo awal minimal harus rp 20.000';

    ELSE

    INSERT INTO rekening (nama, saldo);
    VALUES (nama_nasabah, saldo_awal);

    RAISE NOTICE 'Rekening atas nama % berhasil dibuat dengan saldo awal Rp % telah dibuat', nama_nasabah, saldo_awal;
    END IF; 

END;
$$

--memanggil procedure (buat_rekening)
CALL buat_rekening('Raka',1000000000);

--stored procedure (transfer saldo)
CREATE OR REPLACE PROCEDURE trasfer_saldo(
    INOUT no_pengirim INT,
    INOUT no_penerima INT,
    INOUT jumlah NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    saldo_pengirim NUMERIC;
BEGIN
    SELECT saldo INTO saldo_pengirim FROM rekening WHERE no_rekening = no_pengirim;

	 IF no_pengirim IS NULL THEN
        RAISE EXCEPTION 'Nomor rekening pengirim dengan ID % tidak ditemukan', no_pengirim;
        ELSIF no_penerima IS NULL THEN
            RAISE EXCEPTION 'Nomor rekening penerima dengan ID % tidak ditemukan', no_penerima;
            ELSIF saldo_pengirim < jumlah THEN
                RAISE EXCEPTION 'Saldo tidak mencukupi untuk melakukan transfer';
                ELSE
                    UPDATE rekening
                    SET saldo = saldo - jumlah
                    WHERE no_rekening = no_pengirim;

                    UPDATE rekening
                    SET saldo = saldo + jumlah
                    WHERE no_rekening = no_penerima;

                    RAISE NOTICE 'Transfer sebesar Rp % dari rekening % ke rekening % berhasil dilakukan', jumlah, no_pengirim, no_penerima;
            END IF;
		
END;
$$