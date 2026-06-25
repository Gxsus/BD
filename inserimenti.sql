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
(2, 'Panetteria Il Forno', 'Panetteria', 'Via Garibaldi', '20', '00100', CURRENT_DATE, '07:00', '19:00');

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
(2, 50.00, 3.00, 'attiva', '2025-01-01', '2026-12-31', 'Spedizione interna', 15.00, 200.00, 'Sconto Fissi', 2, 2),
(3, NULL, 4.00, 'attiva', '2025-01-01', '2026-12-31', 'Ritiro in sede', 10.00, 150.00, 'Sconto Fissi', 1, 2);

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
(2, 'Magic Box Colazione', 'Brioche e paste invendute', 15.00, 4.99, 50, CURRENT_DATE + 30, '23:59', CURRENT_DATE, '10:00', 2),
(3, 'Menu Studenti', 'Pizza + bibita', 10.00, 6.00, 20, CURRENT_DATE + 30, '23:59', CURRENT_DATE, '10:00', 1),
(4, 'Magic Box Salato', 'Pizzette e focacce a fine turno', 12.00, 3.99, 100, CURRENT_DATE + 30, '23:59', CURRENT_DATE, '10:00', 2);

-- Ordini
INSERT INTO Ordini (idOrdine, idOfferta, username, quantita, data, ora, prezzo, stato, idSlot) VALUES
(1, 1, 'mario.rossi', 2, CURRENT_DATE, '09:00', 5.00, 'ritirato', 1),
(2, 2, 'luigi.verdi', 1, CURRENT_DATE, '09:30', 4.99, 'pagato', 1),
(3, 3, 'giulia.bianchi', 1, CURRENT_DATE, '10:00', 6.00, 'prenotato', 2),
(4, 2, 'mario.rossi', 1, CURRENT_DATE, '11:00', 4.99, 'prenotato', 3);

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
