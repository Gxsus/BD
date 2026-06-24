/*******************************************************************************
********************************************************************************
**********/
--1a. Schema
/*******************************************************************************
********************************************************************************
**********/
/* 
ELENCO VINCOLI E LORO IMPLEMENTAZIONE:
- Vincolo 1 (Fornitore, punto ritiro, convenzione): implementato tramite TRIGGER (inter-relazionale).
- Vincolo 2 (Offerta, punto ritiro, convenzione): implementato tramite TRIGGER (inter-relazionale).
- Vincolo 3 (Condizioni studente e offerta): implementato tramite TRIGGER (inter-relazionale).
- Vincolo 5 (Offerta scaduta, esaurita, annullata): implementato tramite TRIGGER.
- Vincolo 6 (Recensione solo se ordine ritirato): implementato tramite TRIGGER.
- Vincolo 7 (Offerta creabile solo con convenzione attiva): implementato tramite TRIGGER.
- Vincolo 8 (Ritiro solo se pagato): implementato tramite TRIGGER.
- Vincolo 9 (Numero prenotazioni attuali da ordini prenotati): logica di aggregazione calcolata a runtime o in TRIGGER prima dell'inserimento.
- Vincolo 10 (Massimo prenotazioni non superabile): implementato tramite TRIGGER per il controllo sui nuovi ordini.
- Vincolo 11 (Storico prezzo in Ordini): implementato al momento dell'inserimento in Ordini tramite copia valore.
- Vincolo 12 (Slot ritiro non sovrapposti): implementato tramite TRIGGER.
- Vincolo 13 (Ordini: quantita > 0): implementato tramite vincolo CHECK.
- Vincolo 14 (SlotRitiro: massimoPren > 0): implementato tramite vincolo CHECK.
- Vincolo 15 (Offerte: quantita >= 0, modificato per consentire esaurimento): implementato tramite vincolo CHECK.
*/

-- ==========================================
-- CREAZIONE DOMINI E TIPI
-- ==========================================
CREATE TYPE stato_ordine AS ENUM ('prenotato', 'pagato', 'ritirato', 'annullato', 'no-show', 'rimborsato');
CREATE TYPE stato_convenzione AS ENUM ('attiva', 'scaduta', 'sospesa');

-- ==========================================
-- CREAZIONE TABELLE BASE E ANAGRAFICHE
-- ==========================================
CREATE TABLE Utenti (
    username VARCHAR(50) PRIMARY KEY,
    cognome VARCHAR(50) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    telefono VARCHAR(20), 
    email VARCHAR(100) UNIQUE NOT NULL,
    dataReg DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE Fornitori (
    idFornitore SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipologia VARCHAR(50) NOT NULL,
    via VARCHAR(100) NOT NULL,
    civico VARCHAR(10) NOT NULL,
    cap VARCHAR(10) NOT NULL,
    data DATE NOT NULL,
    orarioApertura TIME NOT NULL,
    orarioChiusura TIME NOT NULL
);

CREATE TABLE RefFornitore (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE,
    idFornitore INT NOT NULL REFERENCES Fornitori(idFornitore) ON DELETE CASCADE
);

CREATE TABLE Studenti (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE,
    isSuspended BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE Collaboratori (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE
);

CREATE TABLE Amministratori (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE
);

CREATE TABLE TipiOfferta (
    nome VARCHAR(50) PRIMARY KEY
);

CREATE TABLE Condizioni (
    nome VARCHAR(100) PRIMARY KEY
);

-- ==========================================
-- SEDI E PUNTI RITIRO
-- ==========================================
CREATE TABLE Sedi (
    idSede SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    comune VARCHAR(100) NOT NULL,
    via VARCHAR(100) NOT NULL,
    civico VARCHAR(10) NOT NULL,
    cap VARCHAR(10) NOT NULL,
    coordinate VARCHAR(100) NOT NULL,
    rifAmmin VARCHAR(50) REFERENCES Amministratori(username) ON DELETE SET NULL
);

CREATE TABLE PuntiRitiro (
    nome VARCHAR(100) PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    edificio VARCHAR(100) NOT NULL,
    piano VARCHAR(50) NOT NULL,
    aula VARCHAR(50) NOT NULL,
    note TEXT NOT NULL,
    idSede INT NOT NULL REFERENCES Sedi(idSede) ON DELETE CASCADE
);

CREATE TABLE SlotRitiro (
    idSlot SERIAL PRIMARY KEY,
    nomePuntoRitiro VARCHAR(100) NOT NULL REFERENCES PuntiRitiro(nome) ON DELETE CASCADE,
    data DATE NOT NULL,
    oraInizio TIME NOT NULL,
    oraFine TIME NOT NULL,
    massimoPren INT NOT NULL CHECK (massimoPren > 0),
    UNIQUE (data, oraInizio, nomePuntoRitiro),
    CHECK (oraInizio < oraFine)
);

-- ==========================================
-- CONVENZIONI E OFFERTE
-- ==========================================
CREATE TABLE Convenzioni (
    idConv SERIAL PRIMARY KEY,
    sogliaMinPubbl NUMERIC(10, 2), 
    commissione NUMERIC(10, 2) NOT NULL,
    stato stato_convenzione NOT NULL DEFAULT 'attiva',
    fineValid DATE NOT NULL,
    inizioValid DATE NOT NULL,
    modRitiro VARCHAR(100) NOT NULL,
    scontoMin NUMERIC(5, 2) NOT NULL,
    sogliaMaxPubbl NUMERIC(10, 2) NOT NULL,
    nomeTipoOfferta VARCHAR(50) NOT NULL REFERENCES TipiOfferta(nome) ON DELETE RESTRICT,
    idSede INT NOT NULL REFERENCES Sedi(idSede) ON DELETE CASCADE,
    idFornitore INT NOT NULL REFERENCES Fornitori(idFornitore) ON DELETE CASCADE,
    CHECK (inizioValid <= fineValid)
);

CREATE TABLE Offerte (
    idOfferta SERIAL PRIMARY KEY,
    titolo VARCHAR(100) NOT NULL,
    descrizione TEXT NOT NULL,
    prezzoOrig NUMERIC(10, 2) NOT NULL,
    prezzo NUMERIC(10, 2) NOT NULL,
    quantita INT NOT NULL CHECK (quantita >= 0),
    dataScad DATE NOT NULL,
    oraScad TIME NOT NULL,
    data DATE NOT NULL,
    ora TIME NOT NULL,
    idConv INT NOT NULL REFERENCES Convenzioni(idConv) ON DELETE CASCADE
);

CREATE TABLE CondizioniOfferte (
    nomeCondizione VARCHAR(100) REFERENCES Condizioni(nome) ON DELETE CASCADE,
    idOfferta INT REFERENCES Offerte(idOfferta) ON DELETE CASCADE,
    PRIMARY KEY (nomeCondizione, idOfferta)
);

CREATE TABLE CondizioniStudenti (
    nomeCondizione VARCHAR(100) REFERENCES Condizioni(nome) ON DELETE CASCADE,
    username VARCHAR(50) REFERENCES Studenti(username) ON DELETE CASCADE,
    PRIMARY KEY (nomeCondizione, username)
);

-- ==========================================
-- ORDINI, RECENSIONI, PAGAMENTI
-- ==========================================
CREATE TABLE Ordini (
    idOrdine SERIAL PRIMARY KEY,
    idOfferta INT NOT NULL REFERENCES Offerte(idOfferta) ON DELETE RESTRICT,
    username VARCHAR(50) NOT NULL REFERENCES Studenti(username) ON DELETE CASCADE,
    idSlot INT NOT NULL REFERENCES SlotRitiro(idSlot) ON DELETE RESTRICT,
    quantita INT NOT NULL CHECK (quantita > 0),
    stato stato_ordine NOT NULL DEFAULT 'prenotato',
    data DATE NOT NULL,
    ora TIME NOT NULL,
    prezzo NUMERIC(10, 2) NOT NULL 
);

CREATE TABLE Recensioni (
    idRecensione SERIAL PRIMARY KEY,
    idOrdine INT NOT NULL UNIQUE REFERENCES Ordini(idOrdine) ON DELETE CASCADE,
    data DATE NOT NULL,
    punteggio INT NOT NULL CHECK (punteggio >= 1 AND punteggio <= 5), 
    commento TEXT NOT NULL
);

CREATE TABLE Pagamenti (
    idPagamento SERIAL PRIMARY KEY,
    idOrdine INT NOT NULL UNIQUE REFERENCES Ordini(idOrdine) ON DELETE CASCADE,
    data DATE NOT NULL,
    ora TIME NOT NULL,
    dataMaxRimborso DATE NOT NULL,
    metPagamento VARCHAR(50) NOT NULL
);

-- ==========================================
-- TABELLE MULTIVALORE / RECAPITI
-- ==========================================
CREATE TABLE RecapitoSedi (
    telefono VARCHAR(20),
    idSede INT REFERENCES Sedi(idSede) ON DELETE CASCADE,
    PRIMARY KEY (telefono, idSede)
);

CREATE TABLE RecapitoFornitori (
    telefono VARCHAR(20),
    idFornitore INT REFERENCES Fornitori(idFornitore) ON DELETE CASCADE,
    PRIMARY KEY (telefono, idFornitore)
);

/*******************************************************************************
********************************************************************************
**********/
--1b. Popolamento
/*******************************************************************************
********************************************************************************
**********/

-- Utenti e Studenti
INSERT INTO Utenti (username, cognome, nome, email, dataReg) VALUES
('mario.rossi', 'Rossi', 'Mario', 'mario.rossi@studenti.uni.it', CURRENT_DATE),
('luigi.verdi', 'Verdi', 'Luigi', 'luigi.verdi@studenti.uni.it', CURRENT_DATE),
('giulia.bianchi', 'Bianchi', 'Giulia', 'giulia.bianchi@studenti.uni.it', CURRENT_DATE),
('amministratore1', 'Admin', 'Capo', 'admin@uni.it', CURRENT_DATE);

INSERT INTO Studenti (username, isSuspended) VALUES
('mario.rossi', false),
('luigi.verdi', false),
('giulia.bianchi', false);

INSERT INTO Amministratori (username) VALUES
('amministratore1');

-- Fornitori
INSERT INTO Fornitori (idFornitore, nome, tipologia, via, civico, cap, data, orarioApertura, orarioChiusura) VALUES
(1, 'Pizzeria Bella Napoli', 'Ristorazione', 'Via Roma', '10', '00100', CURRENT_DATE, '10:00', '22:00'),
(2, 'Libreria Universitaria', 'Libreria', 'Via Verdi', '20', '00100', CURRENT_DATE, '09:00', '19:00');

-- Tipi Offerta
INSERT INTO TipiOfferta (nome) VALUES ('Sconto Fissi'), ('Menu Speciale');

-- Sedi
INSERT INTO Sedi (idSede, nome, comune, via, civico, cap, coordinate, rifAmmin) VALUES
(1, 'Sede Centrale', 'Roma', 'Viale Universita', '1', '00185', '41.902,12.496', 'amministratore1'),
(2, 'Sede Ingegneria', 'Roma', 'Via Ingegneria', '5', '00184', '41.890,12.490', 'amministratore1');

-- PuntiRitiro
INSERT INTO PuntiRitiro (nome, area, edificio, piano, aula, note, idSede) VALUES
('Atrio Centrale', 'Ingresso', 'Edificio Principale', 'PT', 'Atrio', 'Vicino ascensore', 1),
('Portineria Ingegneria', 'Ingresso', 'Edificio B', 'PT', 'Portineria', 'Ingresso Est', 2);

-- SlotRitiro
INSERT INTO SlotRitiro (idSlot, nomePuntoRitiro, data, oraInizio, oraFine, massimoPren) VALUES
(1, 'Atrio Centrale', CURRENT_DATE, '10:00', '12:00', 10),
(2, 'Atrio Centrale', CURRENT_DATE, '14:00', '16:00', 5),
(3, 'Portineria Ingegneria', CURRENT_DATE, '10:00', '12:00', 10);

-- Convenzioni
INSERT INTO Convenzioni (idConv, sogliaMinPubbl, commissione, stato, inizioValid, fineValid, modRitiro, scontoMin, sogliaMaxPubbl, nomeTipoOfferta, idSede, idFornitore) VALUES 
(1, NULL, 5.00, 'attiva', '2025-01-01', '2026-12-31', 'Ritiro in sede', 10.00, 100.00, 'Menu Speciale', 1, 1),
(2, 50.00, 3.00, 'attiva', '2025-01-01', '2026-12-31', 'Spedizione interna', 15.00, 200.00, 'Sconto Fissi', 2, 2);

-- Condizioni
INSERT INTO Condizioni (nome) VALUES
('Iscritto Ingegneria'),
('Media > 25');

-- CondizioniStudenti
INSERT INTO CondizioniStudenti (nomeCondizione, username) VALUES
('Iscritto Ingegneria', 'mario.rossi'),
('Iscritto Ingegneria', 'luigi.verdi'),
('Iscritto Ingegneria', 'giulia.bianchi');

-- Offerte
INSERT INTO Offerte (idOfferta, titolo, descrizione, prezzoOrig, prezzo, quantita, dataScad, oraScad, data, ora, idConv) VALUES
(1, 'Pizza Margherita', 'Ottima pizza margherita', 8.00, 5.00, 100, CURRENT_DATE + 30, '23:59', CURRENT_DATE, '10:00', 1),
(2, 'Testo Analisi 1', 'Libro per analisi', 40.00, 30.00, 50, CURRENT_DATE + 30, '23:59', CURRENT_DATE, '10:00', 2),
(3, 'Menu Studenti', 'Pizza + bibita', 10.00, 6.00, 20, CURRENT_DATE + 30, '23:59', CURRENT_DATE, '10:00', 1);

-- Ordini
INSERT INTO Ordini (idOrdine, idOfferta, username, quantita, data, ora, prezzo, stato, idSlot) VALUES
(1, 1, 'mario.rossi', 2, CURRENT_DATE, '09:00', 5.00, 'ritirato', 1),
(2, 2, 'luigi.verdi', 1, CURRENT_DATE, '09:30', 30.00, 'pagato', 1),
(3, 3, 'giulia.bianchi', 1, CURRENT_DATE, '10:00', 6.00, 'prenotato', 2);

-- Pagamenti
INSERT INTO Pagamenti (idPagamento, idOrdine, data, ora, dataMaxRimborso, metPagamento) VALUES
(1, 1, CURRENT_DATE, '09:05', CURRENT_DATE + 14, 'Carta di Credito'),
(2, 2, CURRENT_DATE, '09:35', CURRENT_DATE + 14, 'PayPal');

-- Recensioni
INSERT INTO Recensioni (idRecensione, idOrdine, data, punteggio, commento) VALUES
(1, 1, CURRENT_DATE, 5, 'Ottima pizza e servizio veloce');

-- Reset sequences
SELECT setval('fornitori_idfornitore_seq', (SELECT MAX(idFornitore) FROM Fornitori));
SELECT setval('sedi_idsede_seq', (SELECT MAX(idSede) FROM Sedi));
SELECT setval('slotritiro_idslot_seq', (SELECT MAX(idSlot) FROM SlotRitiro));
SELECT setval('convenzioni_idconv_seq', (SELECT MAX(idConv) FROM Convenzioni));
SELECT setval('offerte_idofferta_seq', (SELECT MAX(idOfferta) FROM Offerte));
SELECT setval('ordini_idordine_seq', (SELECT MAX(idOrdine) FROM Ordini));
SELECT setval('pagamenti_idpagamento_seq', (SELECT MAX(idPagamento) FROM Pagamenti));
SELECT setval('recensioni_idrecensione_seq', (SELECT MAX(idRecensione) FROM Recensioni));


/*******************************************************************************
********************************************************************************
**********/
--2. Vista
/* Vista che aggrega le statistiche sulle offerte per fornitore. 
Mostra il nome del fornitore, il titolo dell'offerta, il numero totale di ordini effettuati 
per quell'offerta, il ricavo totale generato e la quantità media per ordine. 
Accede a 4 tabelle: Fornitori, Convenzioni, Offerte, Ordini.
Effettua raggruppamento per Fornitore e Offerta e calcola 3 funzioni aggregate (COUNT, SUM, AVG). */
/*******************************************************************************
********************************************************************************
**********/

CREATE OR REPLACE VIEW StatisticheOfferteFornitori AS
SELECT 
    f.nome AS fornitore,
    o.titolo AS offerta,
    COUNT(ord.idOrdine) AS numero_ordini,
    SUM(ord.quantita * ord.prezzo) AS ricavo_totale,
    AVG(ord.quantita) AS media_quantita_per_ordine
FROM Fornitori f
JOIN Convenzioni c ON f.idFornitore = c.idFornitore
JOIN Offerte o ON c.idConv = o.idConv
JOIN Ordini ord ON o.idOfferta = ord.idOfferta
GROUP BY f.nome, o.titolo;


/*******************************************************************************
********************************************************************************
**********/
--3. Interrogazioni
/*******************************************************************************
********************************************************************************
**********/

/*******************************************************************************
********************************************************************************
**********/
/* 3a (interrogazione con operazione insiemistica)
*/
/* Trovare gli username degli studenti che possiedono una specifica condizione  
(es. 'Iscritto Ingegneria') TRANNE (EXCEPT) quelli che hanno effettivamente effettuato un ordine 
per un'offerta che richiede o fa parte di una convenzione. 
Coinvolge le tabelle: CondizioniStudenti, Ordini, Offerte, Convenzioni.
*/
/*******************************************************************************
********************************************************************************
**********/

SELECT cs.username
FROM CondizioniStudenti cs
WHERE cs.nomeCondizione = 'Iscritto Ingegneria'
EXCEPT
SELECT o.username
FROM Ordini o
JOIN Offerte off ON o.idOfferta = off.idOfferta
JOIN Convenzioni c ON off.idConv = c.idConv
WHERE c.nomeTipoOfferta = 'Sconto Fissi';

/*******************************************************************************
********************************************************************************
**********/
/* 3b (interrogazione di divisione)
*/
/* Trovare gli studenti che hanno ordinato TUTTE le offerte disponibili per una 
specifica convenzione (nell'esempio idConv = 2). Utilizza la divisione con doppio 
NOT EXISTS e coinvolge le tabelle Studenti, Offerte e Ordini.
*/
/*******************************************************************************
********************************************************************************
**********/

SELECT s.username
FROM Studenti s
WHERE NOT EXISTS (
    SELECT 1 
    FROM Offerte o
    WHERE o.idConv = 2
    AND NOT EXISTS (
        SELECT 1
        FROM Ordini ord
        WHERE ord.username = s.username
        AND ord.idOfferta = o.idOfferta
    )
);

/*******************************************************************************
********************************************************************************
**********/
/* 3c (interrogazione con sottointerrogazione correlata)
*/

/* Trovare per ogni punto di ritiro lo slot che ha registrato il massimo numero 
totale di quantità prenotata. La correlazione è necessaria per comparare la somma delle quantità 
di ciascuno slot con il massimo tra tutti gli slot DELLO STESSO punto di ritiro.
*/
/*******************************************************************************
********************************************************************************
**********/

SELECT pr.nome AS punto_ritiro, sr.oraInizio, sr.oraFine, SUM(o.quantita) AS totale_prenotato
FROM PuntiRitiro pr
JOIN SlotRitiro sr ON pr.nome = sr.nomePuntoRitiro
JOIN Ordini o ON sr.idSlot = o.idSlot
GROUP BY pr.nome, sr.idSlot, sr.oraInizio, sr.oraFine
HAVING SUM(o.quantita) = (
    SELECT MAX(totale_slot)
    FROM (
        SELECT sr2.idSlot, SUM(o2.quantita) AS totale_slot
        FROM SlotRitiro sr2
        JOIN Ordini o2 ON sr2.idSlot = o2.idSlot
        WHERE sr2.nomePuntoRitiro = pr.nome -- Correlazione essenziale
        GROUP BY sr2.idSlot
    ) AS sub
);

/*******************************************************************************
********************************************************************************
**********/
--4. Funzioni
/*******************************************************************************
********************************************************************************
**********/

/*******************************************************************************
********************************************************************************
**********/
/* 4a: operazione di inserimento non banale, effettuando tutti gli opportuni con
trolli e calcoli di dati derivati.
*/
/* Inserimento di un nuovo ordine: la procedura riceve lo studente, l'offerta, 
lo slot desiderato e la quantità. Verifica che l'offerta esista e abbia quantità sufficiente, 
verifica che lo slot abbia disponibilità. Calcola il prezzo dell'ordine basandosi sul prezzo 
corrente dell'offerta e scala automaticamente la quantità disponibile dell'offerta.
*/
/*******************************************************************************
********************************************************************************
**********/

CREATE OR REPLACE FUNCTION inserisci_ordine(
    p_username VARCHAR(50),
    p_idOfferta INT,
    p_idSlot INT,
    p_quantita INT
) RETURNS VOID AS $$
DECLARE
    v_prezzo NUMERIC(10,2);
    v_qta_disp INT;
    v_max_pren INT;
    v_pren_attuali INT;
BEGIN
    -- Controllo disponibilità offerta
    SELECT prezzo, quantita INTO v_prezzo, v_qta_disp
    FROM Offerte WHERE idOfferta = p_idOfferta;
    
    IF v_prezzo IS NULL THEN
        RAISE EXCEPTION 'Offerta non trovata';
    END IF;
    
    IF v_qta_disp < p_quantita THEN
        RAISE EXCEPTION 'Quantità richiesta dell''offerta non disponibile (disponibili: %)', v_qta_disp;
    END IF;
    
    -- Controllo disponibilità slot
    IF p_idSlot IS NOT NULL THEN
        SELECT massimoPren INTO v_max_pren
        FROM SlotRitiro WHERE idSlot = p_idSlot;
        
        IF v_max_pren IS NULL THEN
             RAISE EXCEPTION 'Slot di ritiro non trovato';
        END IF;
        
        SELECT COALESCE(SUM(quantita), 0) INTO v_pren_attuali
        FROM Ordini WHERE idSlot = p_idSlot AND stato IN ('prenotato', 'pagato');
        
        IF v_pren_attuali + p_quantita > v_max_pren THEN
            RAISE EXCEPTION 'Capacità dello slot di ritiro insufficiente';
        END IF;
    END IF;
    
    -- Inserimento nuovo ordine
    INSERT INTO Ordini (idOfferta, username, idSlot, quantita, stato, data, ora, prezzo)
    VALUES (p_idOfferta, p_username, p_idSlot, p_quantita, 'prenotato', CURRENT_DATE, CURRENT_TIME, v_prezzo);
    
    -- Aggiornamento dati derivati: scalare la quantità dell'offerta
    UPDATE Offerte SET quantita = quantita - p_quantita WHERE idOfferta = p_idOfferta;
    
    RAISE NOTICE 'Ordine inserito con successo.';
END;
$$ LANGUAGE plpgsql;

/* Validazione 4a: */
SELECT inserisci_ordine('mario.rossi', 1, 1, 1);

/*******************************************************************************
********************************************************************************
**********/
/* 4b: calcolo di un'informazione derivata rilevante e non banale, che richieda l
'accesso a diverse tabelle e un'aggregazione
*/
/* Calcola il ricavo totale mensile per un dato fornitore in un dato mese e anno.
Questa funzione unisce Fornitori, Convenzioni, Offerte, Ordini e Pagamenti per sommare
l'importo totale degli ordini ('pagato' o 'ritirato') nel periodo specificato.
*/
/*******************************************************************************
********************************************************************************
**********/

CREATE OR REPLACE FUNCTION calcola_ricavo_fornitore_mese(
    p_idFornitore INT,
    p_anno INT,
    p_mese INT
) RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_totale NUMERIC(10,2);
BEGIN
    SELECT COALESCE(SUM(o.quantita * o.prezzo), 0.00) INTO v_totale
    FROM Fornitori f
    JOIN Convenzioni c ON f.idFornitore = c.idFornitore
    JOIN Offerte off ON c.idConv = off.idConv
    JOIN Ordini o ON off.idOfferta = o.idOfferta
    JOIN Pagamenti p ON o.idOrdine = p.idOrdine
    WHERE f.idFornitore = p_idFornitore
      AND EXTRACT(YEAR FROM p.data) = p_anno
      AND EXTRACT(MONTH FROM p.data) = p_mese
      AND o.stato IN ('pagato', 'ritirato');
      
    RETURN v_totale;
END;
$$ LANGUAGE plpgsql;

/* Validazione 4b: */
SELECT calcola_ricavo_fornitore_mese(1, EXTRACT(YEAR FROM CURRENT_DATE)::int, EXTRACT(MONTH FROM CURRENT_DATE)::int);


/*******************************************************************************
********************************************************************************
**********/
--5. Trigger
/*******************************************************************************
********************************************************************************
**********/

/*******************************************************************************
********************************************************************************
**********/
/* 5a: trigger per la verifica di un vincolo che non sia implementabile come vin
colo CHECK
*/
/* Vincolo: Una recensione per un ordine può essere effettuata esclusivamente
se lo stato dell'ordine stesso è 'ritirato'. Essendo un controllo inter-tabella,
non può essere un semplice CHECK su Recensioni.
*/
/*******************************************************************************
********************************************************************************
**********/

CREATE OR REPLACE FUNCTION check_recensione_ordine_ritirato()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Ordini WHERE idOrdine = NEW.idOrdine AND stato = 'ritirato') THEN
        RAISE EXCEPTION 'Vincolo inter-relazionale: Non è possibile recensire un ordine che non sia stato completato e ritirato.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_recensione_ordine_ritirato
BEFORE INSERT OR UPDATE ON Recensioni
FOR EACH ROW EXECUTE FUNCTION check_recensione_ordine_ritirato();

/* Validazione 5a: 
-- Inserimento non valido (fallisce perché l'ordine 3 è in stato prenotato):
-- INSERT INTO Recensioni (idOrdine, data, punteggio, commento) VALUES (3, CURRENT_DATE, 4, 'Test');
*/

/*******************************************************************************
********************************************************************************
**********/
/* 5b: trigger per il mantenimento di informazione derivata o per l'implementazi
one di una regola di dominio
*/
/* Regola di dominio per il mantenimento della coerenza: se un ordine viene annullato,
la sua quantità viene restituita alla disponibilità dell'offerta, permettendo
ad altri studenti di ordinarla.
*/
/*******************************************************************************
********************************************************************************
**********/

CREATE OR REPLACE FUNCTION ripristina_quantita_offerta_annullata()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        -- Controlliamo che lo stato stia cambiando specificatamente in 'annullato'
        IF OLD.stato != 'annullato' AND NEW.stato = 'annullato' THEN
            UPDATE Offerte 
            SET quantita = quantita + NEW.quantita
            WHERE idOfferta = NEW.idOfferta;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ripristina_quantita_offerta_annullata
AFTER UPDATE OF stato ON Ordini
FOR EACH ROW EXECUTE FUNCTION ripristina_quantita_offerta_annullata();

/* Validazione 5b: 
-- UPDATE Ordini SET stato = 'annullato' WHERE idOrdine = 3;
-- SELECT quantita FROM Offerte WHERE idOfferta = (SELECT idOfferta FROM Ordini WHERE idOrdine = 3);
*/
