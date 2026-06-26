-- ==========================================
-- CREAZIONE DOMINI E TIPI
-- ==========================================
CREATE TYPE stato_ordine AS ENUM ('prenotato', 'pagato', 'ritirato', 'annullato', 'no-show', 'rimborsato');
CREATE TYPE stato_convenzione AS ENUM ('attiva', 'scaduta', 'sospesa');

-- ==========================================
-- CREAZIONE TABELLE BASE E ANAGRAFICHE
-- ==========================================
CREATE TABLE IF NOT EXISTS  Utenti (
    username VARCHAR(50) PRIMARY KEY,
    cognome VARCHAR(50) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    telefono VARCHAR(20), 
    email VARCHAR(100) UNIQUE NOT NULL,
    dataReg DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS  Fornitori (
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

CREATE TABLE IF NOT EXISTS  RefFornitore (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE,
    idFornitore INT NOT NULL REFERENCES Fornitori(idFornitore) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS  Studenti (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE,
    isSuspended BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS  Collaboratori (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS  Amministratori (
    username VARCHAR(50) PRIMARY KEY REFERENCES Utenti(username) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS  TipiOfferta (
    nome VARCHAR(50) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS  Condizioni (
    nome VARCHAR(100) PRIMARY KEY
);

-- ==========================================
-- SEDI E PUNTI RITIRO
-- ==========================================
CREATE TABLE IF NOT EXISTS  Sedi (
    idSede SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    comune VARCHAR(100) NOT NULL,
    via VARCHAR(100) NOT NULL,
    civico VARCHAR(10) NOT NULL,
    cap VARCHAR(10) NOT NULL,
    coordinate VARCHAR(100) NOT NULL,
    rifAmmin VARCHAR(50) REFERENCES Amministratori(username) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS  PuntiRitiro (
    nome VARCHAR(100) PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    edificio VARCHAR(100) NOT NULL,
    piano VARCHAR(50) NOT NULL,
    aula VARCHAR(50) NOT NULL,
    note TEXT NOT NULL,
    idSede INT NOT NULL REFERENCES Sedi(idSede) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS  SlotRitiro (
    idSlot SERIAL PRIMARY KEY,
    nomePuntoRitiro VARCHAR(100) NOT NULL REFERENCES PuntiRitiro(nome) ON DELETE CASCADE,
    data DATE NOT NULL,
    oraInizio TIME NOT NULL,
    oraFine TIME NOT NULL,
    massimoPren INT NOT NULL CHECK (massimoPren > 0),
    UNIQUE (data, oraInizio, nomePuntoRitiro),
    CHECK (oraInizio < oraFine) -- constraint base per lo slot
);

-- ==========================================
-- CONVENZIONI E OFFERTE
-- ==========================================
CREATE TABLE IF NOT EXISTS  Convenzioni (
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

CREATE TABLE IF NOT EXISTS  Offerte (
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

CREATE TABLE IF NOT EXISTS  CondizioniOfferte (
    nomeCondizione VARCHAR(100) REFERENCES Condizioni(nome) ON DELETE CASCADE,
    idOfferta INT REFERENCES Offerte(idOfferta) ON DELETE CASCADE,
    PRIMARY KEY (nomeCondizione, idOfferta)
);

CREATE TABLE IF NOT EXISTS  CondizioniStudenti (
    nomeCondizione VARCHAR(100) REFERENCES Condizioni(nome) ON DELETE CASCADE,
    username VARCHAR(50) REFERENCES Studenti(username) ON DELETE CASCADE,
    PRIMARY KEY (nomeCondizione, username)
);

-- ==========================================
-- ORDINI, RECENSIONI, PAGAMENTI
-- ==========================================
CREATE TABLE IF NOT EXISTS  Ordini (
    idOrdine SERIAL PRIMARY KEY,
    idOfferta INT NOT NULL REFERENCES Offerte(idOfferta) ON DELETE RESTRICT,
    username VARCHAR(50) NOT NULL REFERENCES Studenti(username) ON DELETE CASCADE,
    idSlot INT NOT NULL REFERENCES SlotRitiro(idSlot) ON DELETE RESTRICT,
    quantita INT NOT NULL CHECK (quantita > 0),
    stato stato_ordine NOT NULL DEFAULT 'prenotato',
    data DATE NOT NULL,
    ora TIME NOT NULL,
    prezzo NUMERIC(10, 2) NOT NULL -- Da valorizzare con il prezzo dell'offerta (Vincolo 11)
);

CREATE TABLE IF NOT EXISTS  Recensioni (
    idRecensione SERIAL PRIMARY KEY,
    idOrdine INT NOT NULL UNIQUE REFERENCES Ordini(idOrdine) ON DELETE CASCADE,
    data DATE NOT NULL,
    punteggio INT NOT NULL CHECK (punteggio >= 1 AND punteggio <= 5), -- Dominio Recensioni [1, 5]
    commento TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS  Pagamenti (
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
CREATE TABLE IF NOT EXISTS  RecapitoSedi (
    telefono VARCHAR(20),
    idSede INT REFERENCES Sedi(idSede) ON DELETE CASCADE,
    PRIMARY KEY (telefono, idSede)
);

CREATE TABLE IF NOT EXISTS  RecapitoFornitori (
    telefono VARCHAR(20),
    idFornitore INT REFERENCES Fornitori(idFornitore) ON DELETE CASCADE,
    PRIMARY KEY (telefono, idFornitore)
);

