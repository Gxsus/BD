-- ==========================================
-- IMPLEMENTAZIONE VINCOLI TRAMITE TRIGGER (Esempi)
-- ==========================================

-- Vincolo 6: Una recensione può appartenere ad un ordine solo se ha come stato ritirato
CREATE OR REPLACE FUNCTION check_stato_ordine_recensione()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Ordini WHERE idOrdine = NEW.idOrdineOrdini AND stato = 'ritirato') THEN
        RAISE EXCEPTION 'Vincolo 6: Non è possibile recensire un ordine che non sia stato ritirato.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_stato_ordine_recensione
BEFORE INSERT OR UPDATE ON Recensioni
FOR EACH ROW EXECUTE FUNCTION check_stato_ordine_recensione();

-- Vincolo 8: Un ordine può essere ritirato solo se è stato pagato (esiste tupla in Pagamenti)
CREATE OR REPLACE FUNCTION check_pagamento_ordine_ritirato()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stato = 'ritirato' AND NOT EXISTS (SELECT 1 FROM Pagamenti WHERE idOrdineOrdini = NEW.idOrdine) THEN
        RAISE EXCEPTION 'Vincolo 8: Un ordine può passare allo stato ritirato solo se è stato pagato.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_pagamento_ordine_ritirato
BEFORE UPDATE ON Ordini
FOR EACH ROW EXECUTE FUNCTION check_pagamento_ordine_ritirato();

-- Vincolo 10: In uno slot di ritiro non si può superare il massimo delle prenotazioni
CREATE OR REPLACE FUNCTION check_massimo_prenotazioni_slot()
RETURNS TRIGGER AS $$
DECLARE
    prenotazioni_attuali INT;
    massimo_consentito INT;
BEGIN
    IF NEW.idSlotslotRitiro IS NOT NULL THEN
        -- Calcolo del numero di ordini nello slot corrente (Vincolo 9 implicito)
        SELECT SUM(quantità) INTO prenotazioni_attuali 
        FROM Ordini 
        WHERE idSlotslotRitiro = NEW.idSlotslotRitiro 
          AND stato IN ('prenotato', 'pagato') 
          AND idOrdine != COALESCE(NEW.idOrdine, 0);
          
        SELECT massimoPren INTO massimo_consentito FROM SlotRitiro WHERE idSlot = NEW.idSlotslotRitiro;
        
        IF COALESCE(prenotazioni_attuali, 0) + NEW.quantità > massimo_consentito THEN
            RAISE EXCEPTION 'Vincolo 10: Superato il massimo delle prenotazioni consentite per lo slot di ritiro.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_massimo_prenotazioni_slot
BEFORE INSERT OR UPDATE ON Ordini
FOR EACH ROW EXECUTE FUNCTION check_massimo_prenotazioni_slot();

-- Vincolo 12: In una stessa data l'ora di inizio di uno slot deve essere successiva all’ora di fine dello slot precedente
CREATE OR REPLACE FUNCTION check_sovrapposizione_slot()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.oraInizio >= NEW.oraFine THEN
        RAISE EXCEPTION 'L''ora di inizio deve essere precedente all''ora di fine dello slot.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM SlotRitiro 
        WHERE nomePuntiRitiro = NEW.nomePuntiRitiro 
          AND data = NEW.data 
          AND idSlot != COALESCE(NEW.idSlot, 0)
          AND (NEW.oraInizio < oraFine AND NEW.oraFine > oraInizio)
    ) THEN
        RAISE EXCEPTION 'Vincolo 12: Gli slot di ritiro per uno stesso punto nella stessa data non possono sovrapporsi.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_sovrapposizione_slot
BEFORE INSERT OR UPDATE ON SlotRitiro
FOR EACH ROW EXECUTE FUNCTION check_sovrapposizione_slot();

-- Vincolo 3: Uno studente può ordinare un'offerta solo se soddisfa le condizioni
CREATE OR REPLACE FUNCTION check_condizioni_studente_offerta()
RETURNS TRIGGER AS $$
DECLARE
    condizioni_mancanti INT;
BEGIN
    SELECT COUNT(*) INTO condizioni_mancanti
    FROM CondizioniOfferte co
    LEFT JOIN CondizioniStudenti cs 
      ON co.nomeCondizione = cs.nomeCondizione AND cs.usernameStudenti = NEW.usernamestudenti
    WHERE co.idOfferta = NEW.idOfferta AND cs.nomeCondizione IS NULL;

    IF condizioni_mancanti > 0 THEN
        RAISE EXCEPTION 'Vincolo 3: Lo studente non soddisfa tutte le condizioni richieste per l''offerta.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_condizioni_studente_offerta
BEFORE INSERT OR UPDATE ON Ordini
FOR EACH ROW EXECUTE FUNCTION check_condizioni_studente_offerta();