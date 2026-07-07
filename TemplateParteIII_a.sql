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
	dataReg DATE NOT NULL DEFAULT CURRENT_DATE,
	dummy CHAR(2000)
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
	isSuspended BOOLEAN NOT NULL DEFAULT false,
	dummy CHAR(2000)
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
	idConv INT NOT NULL,
	dummy CHAR(2000)
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
	prezzo NUMERIC(10, 2) NOT NULL,
	dummy CHAR(2000)
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

/* 
=============================================================================
MOTIVAZIONI DELLE SCELTE E GERARCHIA
=============================================================================
La piattaforma prevede quattro ruoli principali: Studente, Referente Fornitore,
Collaboratore, Amministratore.

Gerarchia:
L'Amministratore supervisiona e gestisce l'intera piattaforma, pertanto
si è scelto di definire una gerarchia in cui il RuoloAmministratore eredita 
i privilegi dagli altri tre ruoli (Studente, Referente Fornitore, Collaboratore),
oltre ad avere ALL PRIVILEGES su tutte le relazioni per poter effettuare 
operazioni di manutenzione.

Motivazioni dei privilegi:
- Studente: Necessita di permessi di lettura (SELECT) sulle tabelle informative 
  (Fornitori, Sedi, PuntiRitiro, Offerte, SlotRitiro, ecc.) per esplorare le offerte. 
  Necessita di permessi di scrittura (INSERT) per effettuare Ordini, Pagamenti e 
  inserire Recensioni. Inoltre, necessita di UPDATE sui propri dati e per poter
  annullare ordini.
- Referente Fornitore: Deve poter pubblicare e gestire offerte e slot per i
  propri fornitori. Di conseguenza, necessita di INSERT, UPDATE, DELETE sulle 
  tabelle Offerte_CL, SlotRitiro_CL e CondizioniOfferte_CL. Necessita anche di 
  UPDATE sugli Ordini_CL per aggiornarne lo stato (es. registrare un 'ritirato' 
  o un 'no-show').
- Collaboratore: Essendo coinvolto nella logistica, necessita di consultare i dati
  (SELECT) e di aggiornare lo stato degli Ordini (UPDATE) durante la 
  distribuzione e supporto nei punti di ritiro.
- Amministratore: Avendo funzioni di supervisione, ottiene ALL PRIVILEGES su
  tutte le tabelle del database.

=============================================================================
TABELLA RIASSUNTIVA DELLE POLITICHE DI CONTROLLO DELL'ACCESSO
=============================================================================
| Relazione               | Studente   | Referente  | Collab.  | Amministratore |
|-------------------------|------------|------------|----------|----------------|
| Utenti_CL               | S, U       | S          | S        | ALL            |
| Fornitori_CL            | S          | S          | S        | ALL            |
| Sedi_CL                 | S          | S          | S        | ALL            |
| PuntiRitiro_CL          | S          | S          | S        | ALL            |
| TipiOfferta_CL          | S          | S          | S        | ALL            |
| Condizioni_CL           | S          | S          | S        | ALL            |
| RecapitoSedi_CL         | S          | S          | S        | ALL            |
| RecapitoFornitori_CL    | S          | S, U       | S        | ALL            |
| RefFornitore_CL         | S          | S, U       | S        | ALL            |
| Studenti_CL             | S, U       | S          | S        | ALL            |
| CondizioniStudenti_CL   | S, U       | S          | S        | ALL            |
| Convenzioni_CL          |            | S          |          | ALL            |
| Collaboratori_CL        |            |            | S        | ALL            |
| Amministratori_CL       |            |            |          | ALL            |
| Offerte_CL              | S          | S, I, U, D | S        | ALL            |
| CondizioniOfferte_CL    | S          | S, I, U, D | S        | ALL            |
| SlotRitiro_CL           | S          | S, I, U, D | S        | ALL            |
| Ordini_CL               | S, I, U    | S, U       | S, U     | ALL            |
| Pagamenti_CL            | S, I       | S          | S        | ALL            |
| Recensioni_CL           | S, I, U    | S          | S        | ALL            |

Legenda: S=SELECT, I=INSERT, U=UPDATE, D=DELETE, ALL=ALL PRIVILEGES
*/

-- 1. Definizione dei ruoli
CREATE ROLE RuoloStudente;
CREATE ROLE RuoloReferente;
CREATE ROLE RuoloCollaboratore;
CREATE ROLE RuoloAmministratore;

-- 2. Definizione della gerarchia
GRANT RuoloStudente TO RuoloAmministratore;
GRANT RuoloReferente TO RuoloAmministratore;
GRANT RuoloCollaboratore TO RuoloAmministratore;

-- 3. Assegnazione dei ruoli definiti a 4 utenti a scelta
CREATE USER usr_studente1 WITH PASSWORD 'pass123';
CREATE USER usr_referente1 WITH PASSWORD 'pass123';
CREATE USER usr_collaboratore1 WITH PASSWORD 'pass123';
CREATE USER usr_admin1 WITH PASSWORD 'pass123';

GRANT RuoloStudente TO usr_studente1;
GRANT RuoloReferente TO usr_referente1;
GRANT RuoloCollaboratore TO usr_collaboratore1;
GRANT RuoloAmministratore TO usr_admin1;

-- 4. Definizione della politica di controllo dell'accesso (Assegnazione privilegi)

-- Privilegi Comuni di Lettura
GRANT SELECT ON Fornitori_CL, Sedi_CL, PuntiRitiro_CL, TipiOfferta_CL, Condizioni_CL, RecapitoSedi_CL TO RuoloStudente, RuoloReferente, RuoloCollaboratore;
GRANT SELECT ON Utenti_CL, RecapitoFornitori_CL, RefFornitore_CL, Studenti_CL, CondizioniStudenti_CL, Offerte_CL, CondizioniOfferte_CL, SlotRitiro_CL, Ordini_CL, Pagamenti_CL, Recensioni_CL TO RuoloStudente, RuoloReferente, RuoloCollaboratore;

-- Privilegi Specifici per RuoloStudente
GRANT UPDATE ON Utenti_CL, Studenti_CL, CondizioniStudenti_CL TO RuoloStudente;
GRANT INSERT, UPDATE ON Ordini_CL TO RuoloStudente;
GRANT INSERT ON Pagamenti_CL TO RuoloStudente;
GRANT INSERT, UPDATE ON Recensioni_CL TO RuoloStudente;

-- Privilegi Specifici per RuoloReferente
GRANT UPDATE ON RecapitoFornitori_CL, RefFornitore_CL TO RuoloReferente;
GRANT SELECT ON Convenzioni_CL TO RuoloReferente;
GRANT INSERT, UPDATE, DELETE ON Offerte_CL, CondizioniOfferte_CL, SlotRitiro_CL TO RuoloReferente;
GRANT UPDATE ON Ordini_CL TO RuoloReferente;

-- Privilegi Specifici per RuoloCollaboratore
GRANT SELECT ON Collaboratori_CL TO RuoloCollaboratore;
GRANT UPDATE ON Ordini_CL TO RuoloCollaboratore;

-- Privilegi Specifici per RuoloAmministratore
-- (Oltre a quelli ereditati, si assegnano esplicitamente permessi completi su tutte le tabelle)
GRANT ALL PRIVILEGES ON Utenti_CL, Fornitori_CL, RefFornitore_CL, Studenti_CL, Collaboratori_CL, Amministratori_CL, TipiOfferta_CL, Condizioni_CL, Sedi_CL, PuntiRitiro_CL, SlotRitiro_CL, Convenzioni_CL, Offerte_CL, CondizioniOfferte_CL, CondizioniStudenti_CL, Ordini_CL, Recensioni_CL, Pagamenti_CL, RecapitoSedi_CL, RecapitoFornitori_CL TO RuoloAmministratore;
