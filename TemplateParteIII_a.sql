--- Progetto BD 25-26 (12 CFU)
--- Numero gruppo
--- Nomi e matricole componenti


--- PARTE III 
/* il file deve essere file SQL ... cio� formato solo testo ed eseguibile in LensQL e pgAdmin */



/*************************************************************************************************************************************************************************/ 
--1b. Schema per popolamento in the large
/*************************************************************************************************************************************************************************/ 


/* per ogni relazione R coinvolta nel carico di lavoro, inserire qui i comandi SQL per creare una nuova relazione R_CL con schema equivalente a R ma senza vincoli di chiave primaria, secondaria o esterna e con eventuali attributi dummy */

DROP TABLE IF EXISTS RecapitoFornitori_CL;
DROP TABLE IF EXISTS RecapitoSedi_CL;
DROP TABLE IF EXISTS Pagamenti_CL;
DROP TABLE IF EXISTS Recensioni_CL;
DROP TABLE IF EXISTS Ordini_CL;
DROP TABLE IF EXISTS CondizioniStudenti_CL;
DROP TABLE IF EXISTS CondizioniOfferte_CL;
DROP TABLE IF EXISTS Offerte_CL;
DROP TABLE IF EXISTS Convenzioni_CL;
DROP TABLE IF EXISTS SlotRitiro_CL;
DROP TABLE IF EXISTS PuntiRitiro_CL;
DROP TABLE IF EXISTS Sedi_CL;
DROP TABLE IF EXISTS Condizioni_CL;
DROP TABLE IF EXISTS TipiOfferta_CL;
DROP TABLE IF EXISTS Collaboratori_CL;
DROP TABLE IF EXISTS Amministratori_CL;
DROP TABLE IF EXISTS Studenti_CL;
DROP TABLE IF EXISTS RefFornitore_CL;
DROP TABLE IF EXISTS Fornitori_CL;
DROP TABLE IF EXISTS Utenti_CL;

CREATE TABLE Utenti_CL (
	username VARCHAR(50),
	cognome VARCHAR(50) NOT NULL,
	nome VARCHAR(50) NOT NULL,
	telefono VARCHAR(20),
	email VARCHAR(100) NOT NULL,
	dataReg DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE Fornitori_CL (
	idFornitore INT,
	nome VARCHAR(100) NOT NULL,
	tipologia VARCHAR(50) NOT NULL,
	via VARCHAR(100) NOT NULL,
	civico VARCHAR(10) NOT NULL,
	cap VARCHAR(10) NOT NULL,
	data DATE NOT NULL,
	orarioApertura TIME NOT NULL,
	orarioChiusura TIME NOT NULL
);

CREATE TABLE RefFornitore_CL (
	username VARCHAR(50),
	idFornitore INT NOT NULL
);

CREATE TABLE Studenti_CL (
	username VARCHAR(50),
	isSuspended BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE Collaboratori_CL (
	username VARCHAR(50)
);

CREATE TABLE Amministratori_CL (
	username VARCHAR(50)
);

CREATE TABLE TipiOfferta_CL (
	nome VARCHAR(50)
);

CREATE TABLE Condizioni_CL (
	nome VARCHAR(100)
);

CREATE TABLE Sedi_CL (
	idSede INT,
	nome VARCHAR(100) NOT NULL,
	comune VARCHAR(100) NOT NULL,
	via VARCHAR(100) NOT NULL,
	civico VARCHAR(10) NOT NULL,
	cap VARCHAR(10) NOT NULL,
	coordinate VARCHAR(100) NOT NULL,
	rifAmmin VARCHAR(50)
);

CREATE TABLE PuntiRitiro_CL (
	nome VARCHAR(100),
	area VARCHAR(100) NOT NULL,
	edificio VARCHAR(100) NOT NULL,
	piano VARCHAR(50) NOT NULL,
	aula VARCHAR(50) NOT NULL,
	note TEXT NOT NULL,
	idSede INT NOT NULL
);

CREATE TABLE SlotRitiro_CL (
	idSlot INT,
	nomePuntoRitiro VARCHAR(100) NOT NULL,
	data DATE NOT NULL,
	oraInizio TIME NOT NULL,
	oraFine TIME NOT NULL,
	massimoPren INT NOT NULL
);

CREATE TABLE Convenzioni_CL (
	idConv INT,
	sogliaMinPubbl NUMERIC(10, 2),
	commissione NUMERIC(10, 2) NOT NULL,
	stato stato_convenzione NOT NULL DEFAULT 'attiva',
	fineValid DATE NOT NULL,
	inizioValid DATE NOT NULL,
	modRitiro VARCHAR(100) NOT NULL,
	scontoMin NUMERIC(5, 2) NOT NULL,
	sogliaMaxPubbl NUMERIC(10, 2) NOT NULL,
	nomeTipoOfferta VARCHAR(50) NOT NULL,
	idSede INT NOT NULL,
	idFornitore INT NOT NULL
);

CREATE TABLE Offerte_CL (
	idOfferta INT,
	titolo VARCHAR(100) NOT NULL,
	descrizione TEXT NOT NULL,
	prezzoOrig NUMERIC(10, 2) NOT NULL,
	prezzo NUMERIC(10, 2) NOT NULL,
	quantita INT NOT NULL CHECK (quantita >= 0),
	dataScad DATE NOT NULL,
	oraScad TIME NOT NULL,
	data DATE NOT NULL,
	ora TIME NOT NULL,
	idConv INT NOT NULL
);

CREATE TABLE CondizioniOfferte_CL (
	nomeCondizione VARCHAR(100),
	idOfferta INT
);

CREATE TABLE CondizioniStudenti_CL (
	nomeCondizione VARCHAR(100),
	username VARCHAR(50)
);

CREATE TABLE Ordini_CL (
	idOrdine INT,
	idOfferta INT NOT NULL,
	username VARCHAR(50) NOT NULL,
	idSlot INT NOT NULL,
	quantita INT NOT NULL CHECK (quantita > 0),
	stato stato_ordine NOT NULL DEFAULT 'prenotato',
	data DATE NOT NULL,
	ora TIME NOT NULL,
	prezzo NUMERIC(10, 2) NOT NULL
);

CREATE TABLE Recensioni_CL (
	idRecensione INT,
	idOrdine INT NOT NULL,
	data DATE NOT NULL,
	punteggio INT NOT NULL CHECK (punteggio >= 1 AND punteggio <= 5),
	commento TEXT NOT NULL
);

CREATE TABLE Pagamenti_CL (
	idPagamento INT,
	idOrdine INT NOT NULL,
	data DATE NOT NULL,
	ora TIME NOT NULL,
	dataMaxRimborso DATE NOT NULL,
	metPagamento VARCHAR(50) NOT NULL
);

CREATE TABLE RecapitoSedi_CL (
	telefono VARCHAR(20),
	idSede INT
);

CREATE TABLE RecapitoFornitori_CL (
	telefono VARCHAR(20),
	idFornitore INT
);





/*************************************************************************************************************************************************************************/
--1c. Carico di lavoro
/*************************************************************************************************************************************************************************/ 


/*************************************************************************************************************************************************************************/ 
/* Q1: Query con singola selezione e nessun join */
/*************************************************************************************************************************************************************************/ 


/* inserire qui il comando SQL corrispondente alla query, in modo da visualizzarne piano di esecuzione e tempo di esecuzione */ 

EXPLAIN ANALYZE
SELECT idOfferta, titolo, prezzo, quantita
FROM Offerte_CL
WHERE quantita > 0;



/*************************************************************************************************************************************************************************/ 
/* Q2: Query con condizione di selezione complessa e nessun join */
/*************************************************************************************************************************************************************************/ 


/* inserire qui il comando SQL corrispondente alla query, in modo da visualizzarne piano di esecuzione e tempo di esecuzione */ 

EXPLAIN ANALYZE
SELECT idOrdine, username, stato, data, ora, prezzo
FROM Ordini_CL
WHERE stato IN ('prenotato', 'pagato')
	AND quantita BETWEEN 1 AND 3
	AND data >= CURRENT_DATE - INTERVAL '30 days'
	AND prezzo >= 10;


/*************************************************************************************************************************************************************************/ 
/* Q3: Query con almeno un join e almeno una condizione di selezione */
/*************************************************************************************************************************************************************************/ 


/* inserire qui il comando SQL corrispondente alla query, in modo da visualizzarne piano di esecuzione e tempo di esecuzione */ 

EXPLAIN ANALYZE
SELECT u.nome, u.cognome
FROM Utenti_CL u
JOIN Studenti_CL s ON s.username = u.username
WHERE s.isSuspended = TRUE AND u.nome = 'Francesco';





/*************************************************************************************************************************************************************************/
--1e. Schema fisico
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per cancellare tutti gli indici gi� esistenti per le tabelle coinvolte nel carico di lavoro */

DROP INDEX IF EXISTS idxQuantOff;
DROP INDEX IF EXISTS idxDatOrd;
DROP INDEX IF EXISTS idxUsrnUt;


/* inserire qui i comandi SQL per la creazione dello schema fisico della base di dati in accordo al risultato della fase di progettazione fisica per il carico di lavoro. */

CREATE INDEX idxQuantOff ON Offerte_CL (quantita);
CREATE INDEX idxDatOrd ON Ordini_CL (data);
CLUSTER Ordini_CL USING idxDatOrd;
CREATE INDEX idxUsrnUt ON Utenti_CL USING HASH (username);






/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la definizione della politica di controllo dell'accesso della base di dati  (definizione ruoli, gerarchia, definizione utenti, assegnazione privilegi) in modo che, dopo l'esecuzione di questi comandi,  le operazioni corrispondenti ai privilegi delegati ai ruoli e agli utenti siano correttamente eseguibili. */








