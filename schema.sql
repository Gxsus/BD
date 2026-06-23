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
    tipologia VARCHAR(50),
    via VARCHAR(100),
    civico VARCHAR(10),
    cap VARCHAR(10),
    data DATE,
    orarioApertura TIME,
    orarioChiusura TIME
);

CREATE TABLE RefFornitore (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE,
    idFornitoreFornitori INT NOT NULL REFERENCES Fornitori(idFornitore) ON DELETE CASCADE
);

CREATE TABLE Studenti (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE,
    isSuspended BOOLEAN DEFAULT false
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
    comune VARCHAR(100),
    via VARCHAR(100),
    civico VARCHAR(10),
    cap VARCHAR(10),
    coordinate VARCHAR(100),
    rifAmmin VARCHAR(50) REFERENCES Amministratori(username) ON DELETE SET NULL
);

CREATE TABLE PuntiRitiro (
    nome VARCHAR(100) PRIMARY KEY,
    area VARCHAR(100),
    edificio VARCHAR(100),
    piano VARCHAR(50),
    aula VARCHAR(50),
    note TEXT,
    idSede INT NOT NULL REFERENCES Sedi(idSede) ON DELETE CASCADE
);

CREATE TABLE SlotRitiro (
    idSlot SERIAL PRIMARY KEY,
    nomePuntoRitiro VARCHAR(100) NOT NULL REFERENCES PuntiRitiro(nome) ON DELETE CASCADE,
    data DATE NOT NULL,
    oraInizio TIME NOT NULL,
    oraFine TIME NOT NULL,
    massimoPren INT NOT NULL CHECK (massimoPren > 0),
    UNIQUE (data, oraInizio, nomePuntoRitiro)
);

-- ==========================================
-- CONVENZIONI E OFFERTE
-- ==========================================
CREATE TABLE Convenzioni (
    nome VARCHAR(100) PRIMARY KEY,
    stato stato_convenzione DEFAULT 'attiva',
    idSede INT REFERENCES Sedi(idSede) ON DELETE CASCADE,
    idFornitore INT REFERENCES Fornitori(idFornitore) ON DELETE CASCADE,
    tipoOfferta VARCHAR(50) REFERENCES TipiOfferta(nome) ON DELETE SET NULL
);

CREATE TABLE ConvenzioniStudenti (
    nomeConvenzione VARCHAR(100) REFERENCES Convenzioni(nome) ON DELETE CASCADE,
    username VARCHAR(50) REFERENCES Studenti(username) ON DELETE CASCADE,
    PRIMARY KEY (nomeConvenzione, username)
);

CREATE TABLE Offerte (
    idOfferta SERIAL PRIMARY KEY,
    titolo VARCHAR(100) NOT NULL,
    descrizione TEXT,
    prezzoOrig NUMERIC(10, 2) NOT NULL,
    prezzo NUMERIC(10, 2) NOT NULL,
    quantità INT NOT NULL CHECK (quantità >= 0),
    dataScad DATE,
    oraScad TIME,
    data DATE,
    ora TIME,
    idConvenzioneConvenzioni VARCHAR(100) REFERENCES Convenzioni(nome) ON DELETE SET NULL
);

CREATE TABLE ConvenzioniOfferte (
    nomeConvenzione VARCHAR(100) REFERENCES Convenzioni(nome) ON DELETE CASCADE,
    idOfferta INT REFERENCES Offerte(idOfferta) ON DELETE CASCADE,
    PRIMARY KEY (nomeConvenzione, idOfferta)
);

-- Associazioni aggiunte per supportare il Vincolo 3 (Condizioni delle offerte e degli studenti)
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
    idSlot INT REFERENCES SlotRitiro(idSlot) ON DELETE SET NULL,
    quantità INT NOT NULL CHECK (quantità > 0),
    stato stato_ordine DEFAULT 'prenotato',
    data DATE NOT NULL,
    ora TIME NOT NULL,
    prezzo NUMERIC(10, 2) NOT NULL -- Da valorizzare con il prezzo dell'offerta al momento dell'ordine (Vincolo 11)
);

CREATE TABLE Recensioni (
    idRecensione SERIAL PRIMARY KEY,
    idOrdine INT NOT NULL UNIQUE REFERENCES Ordini(idOrdine) ON DELETE CASCADE,
    data DATE NOT NULL,
    punteggio INT NOT NULL CHECK (punteggio >= 1 AND punteggio <= 5), -- Dominio Recensioni [1, 5]
    commento TEXT
);

CREATE TABLE Pagamenti (
    idPagamento SERIAL PRIMARY KEY,
    idOrdine INT NOT NULL UNIQUE REFERENCES Ordini(idOrdine) ON DELETE CASCADE,
    data DATE NOT NULL,
    ora TIME NOT NULL,
    dataMaxRimborso DATE,
    metPagamento VARCHAR(50)
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


