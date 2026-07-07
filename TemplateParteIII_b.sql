--- Progetto BD 25-26 (12 CFU)
--- Numero gruppo
--- Nomi e matricole componenti


--- PARTE III 
/* il file deve essere file SQL ... cio� formato solo testo ed eseguibile in LensQL e pgAdmin */






/*************************************************************************************************************************************************************************/ 
--1f. Popolamento in the large
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per il popolamento 'in the large' delle relazioni
coinvolte nel carico di lavoro  */

-- Popolamento Utenti_CL
-- 1500 tuple. Essendo il campo dummy un CHAR(2000), occuperemo ~3MB,
-- ovvero diverse centinaia di pagine su disco.
INSERT INTO Utenti_CL (username, cognome, nome, telefono, email, dataReg, dummy)
SELECT 
    'user' || i, 
    'Cognome' || i, 
    'Nome' || i, 
    '333' || LPAD(i::text, 7, '0'), 
    'user' || i || '@example.com', 
    CURRENT_DATE - (i % 365),
    'dummy_string'
FROM generate_series(1, 1500) as i;

-- Popolamento Studenti_CL
-- Assumiamo che i primi 1000 utenti siano studenti
INSERT INTO Studenti_CL (username, isSuspended, dummy)
SELECT 
    'user' || i, 
    (i % 10 = 0), -- Un 10% di studenti sospesi
    'dummy_string'
FROM generate_series(1, 1000) as i;

-- Popolamento Offerte_CL
-- Inseriamo 1500 offerte, variando quantità e date per soddisfare le query
INSERT INTO Offerte_CL (idOfferta, titolo, descrizione, prezzoOrig, prezzo, quantita, dataScad, oraScad, data, ora, idConv, dummy)
SELECT 
    i, 
    'Offerta ' || i, 
    'Descrizione per offerta ' || i, 
    10.00 + (i % 10), 
    5.00 + (i % 5), 
    (i % 5), -- quantità variabile, in modo da avere record con quantita > 0 e quantita = 0
    CURRENT_DATE + (i % 30), 
    '20:00:00', 
    CURRENT_DATE - (i % 10), 
    '10:00:00', 
    (i % 10) + 1,
    'dummy_string'
FROM generate_series(1, 1500) as i;

-- Popolamento Ordini_CL
-- Inseriamo 1500 ordini
INSERT INTO Ordini_CL (idOrdine, idOfferta, username, idSlot, quantita, stato, data, ora, prezzo, dummy)
SELECT 
    i, 
    (i % 1500) + 1, 
    'user' || ((i % 1000) + 1), 
    (i % 100) + 1, 
    (i % 3) + 1, 
    (CASE WHEN (i % 2 = 0) THEN 'prenotato' ELSE 'pagato' END)::stato_ordine,
    CURRENT_DATE - (i % 30), 
    '12:00:00', 
    10.00 + (i % 5),
    'dummy_string'
FROM generate_series(1, 1500) as i;