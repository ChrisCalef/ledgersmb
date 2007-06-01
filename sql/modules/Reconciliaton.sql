CREATE TABLE pending_reports (
    id bigserial primary key not null,
    report_id int,
    scn int,
    their_balance INT,
    our_balance INT,
    code INT,
    user TEXT,
    corrections INT NOT NULL DEFAULT 0
    clear_time TIMESTAMP NOT NULL,
    insert_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    ledger_id int REFERENCES acc_trans(entry_id),
    overlook boolean not null default 'f'
);

-- to correct OUR wrong amount.
CREATE OR REPLACE FUNCTION reconciliation_correct_ledger (in_report_id INT, in_id int, in_new_amount NUMERIC, reason TEXT) returns INT AS $$

    DECLARE
        new_code INT;
        current_row RECORD;
        l_row acc_trans;
        in_user TEXT;
        full_reason TEXT;
    BEGIN
        select into in_user from current_user;
        
        select into current_row from pending_reports where pending_reports.id = in_report_id and pending_reports.id = in_id;
        select into l_row from acc_trans where entry_id = current_row.lid;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No such id % in this report.', in_scn;
        END IF;
        
        IF user <> current_row.user THEN
        
            IF current_row.our_balance <> in_new_amount AND in_new_amount = current_row.their_balance THEN
                update pending_reports pr
                set pr.corrections = pending_reports.corrections + 1, 
                pr.new_balance = in_new_amount,
                error_code = 0
                where id = in_report_id and scn = in_scn;
                return 0;
                
                -- After that, it is required to update the general ledger.
                full_reason := "User % is filing a reconciliation correction on the general ledger, changing amount % to amount %. 
                Their reason given is: %", in_user, current_row.our_balance, in_new_amount, reason;
                select update_ledger(current_row.lid, in_new_amount, full_reason)
            ELSE IF current_row.our_balance = in_new_amount THEN
                -- This should be something, does it equal the original 
                -- balance? If so, there's no change.
                return current_row.error_code;
            END IF;
        END IF;
        
        return current_row.error_code;            
                    
    END;
$$ language 'plpgsql';

-- to correct an incorrect bank statement value.
CREATE OR REPLACE FUNCTION reconciliation_correct_bank_statement (in_report_id INT, in_id int, in_new_amount NUMERIC) returns INT AS $$

    DECLARE
        new_code INT;
        current_row RECORD;
        in_user TEXT;
    BEGIN
        select into in_user from current_user;
        select into current_row from pending_reports where pending_reports.id = in_report_id and pending_reports.scn = in_scn;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No such SCN % in this report.', in_scn;
        END IF;
        
        IF user <> current_row.user THEN
        
            IF current_row.their_balance <> in_new_amount AND in_new_amount = current_row.our_balance THEN
                update pending_reports pr
                set pr.corrections = pending_reports.corrections + 1, 
                pr.new_balance = in_new_amount,
                error_code = 0
                where id = in_report_id and scn = in_scn;
                return 0;
            
            ELSE IF current_row.their_balance = in_new_amount THEN
                -- This should be something, does it equal the original 
                -- balance? If so, there's no change.
                return current_row.error_code;         
            END IF;
        END IF;
        
        return current_row.error_code;            
                    
    END;
$$ language 'plpgsql';


CREATE OR REPLACE reconciliation_correct_passthrough ( in_report_id int, in_id int ) returns INT AS $$

    DECLARE
        in_user TEXT;
        pending_entry pending_reports;
    BEGIN
        select into in_user from current_user;
        
        select into pending_entry from pending_reports where report_id = in_report_id and id = in_id;
        
        IF NOT FOUND THEN
            -- Raise an exception.
            RAISE EXCEPTION "Cannot find entry.";
        ELSE IF pending_entry.errorcode <> 4 THEN 
            -- Only error codes of 4 may be "passed through" safely.
            RAISE EXCEPTION "Selected entry not permitted to be passed through.";
            
        ELSE
            -- Then we mark it passthroughable, and "approve" will overlook it.
            update pending_reports set overlook = 't', errorcode = 0 where report_id = in_report_id and id = in_id;
            return 0;
        END IF;
    END;

$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION reconciliation_correct_bank_charge (in_report_id int, in_id int) returns INT AS $$

    DECLARE
        in_user TEXT;
        pending_entry pending_reports;
    BEGIN
    
        IF NOT FOUND THEN
             -- Raise an exception.
             RAISE EXCEPTION "Cannot find entry with ID % in report %.", in_id, in_report_id;
         ELSE IF pending_entry.errorcode <> 2 THEN 
             -- Only error codes of 4 may be "passed through" safely.
             RAISE EXCEPTION "Attempt to retroactively add a non-bank-charge entry to the ledger.";
         
         ELSE
             -- Then we mark it passthroughable, and "approve" will overlook it.
             
             select create_entry (pending_entry.their_balance, 'payable', pending_entry.clear_date, 'Bank charge');
             
             update pending_reports set errorcode = 0 where report_id = in_report_id and id = in_id;
             return 0;
         END IF;
    END;

$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION reconciliation_correct_unaccounted_charge (in_report_id int, in_id int, reason TEXT) RETURNS INT AS $$

    DECLARE
        in_user TEXT;
        pending_entry pending_reports;
        note TEXT;
    BEGIN
    
        IF NOT FOUND THEN
             -- Raise an exception.
             RAISE EXCEPTION "Cannot find entry with ID % in report %.", in_id, in_report_id;
         ELSE IF pending_entry.errorcode <> 3 THEN 
             -- Only error codes of 4 may be "passed through" safely.
             RAISE EXCEPTION "Not an unaccounted charge; cannot be retroactively added to the ledger.";
         
         ELSE
             -- Then we mark it passthroughable, and "approve" will overlook it.
             
             note := 'Retroactive addition of an unaccounted entry, of value %. 
             Being added by user % with the following explanation: %', pending_entry.their_balance, in_user, in_reason;
             
             select create_entry (pending_entry.their_balance, 'payable', pending_entry.clear_date,note);
             
             update pending_reports set errorcode = 0 where report_id = in_report_id and id = in_id;
             return 0;
         END IF;
    END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION reconciliation_report_approve (in_report_id INT) returns INT as $$
    
    -- Does some basic checks before allowing the approval to go through; 
    -- moves the approval to "reports", I guess, or some other "final" table.
    --
    -- Pending may just be a single flag in the database to mark that it is
    -- not finalized. Will need to discuss with Chris.
    
    DECLARE
        current_row RECORD;
        completed pending_reports;
        total_errors INT;
        in_user TEXT;
    BEGIN
        
        select into in_user current_user;
        select into current_row distinct on user * from pending_reports where report_id = in_report_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION "Fatal Error: Pending report % not found", in_report_id;
        END IF;
        
        IF current_row.user = in_user THEN
            RAISE EXCEPTION "Fatal Error: User % cannot self-approve report!", in_user;
        END IF;
        
        SELECT INTO total_errors count(*) from pending_reports where report_id = in_report_id and error_code <> 0;
        
        IF total_errors <> 0 THEN
            RAISE EXCEPTION "Fatal Error: Cannot approve while % uncorrected errors remain.", total_errors;
        END IF;
        
        -- so far, so good. Different user, and no errors remain. Therefore, we can move it to completed reports.
        --
        -- User may not be necessary - I would think it better to use the 
        -- in_user, to note who approved the report, than the user who
        -- filed it. This may require clunkier syntax..
        
        insert into reports (report_id, scn, their_balance, our_balance, code, user, correction )
            SELECT report_id, scn, their_balance, our_balance, code, user, corrections 
            FROM pending_reports 
            WHERE report_id = in_report_id;
        
        return 1;        
    END;

$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION reconciliation_new_report () returns INT as $$

    SELECT nextval('pending_report_report_id_seq');

$$ language 'sql';

create or replace function reconciliation_add_entry(in_report_id INT, in_scn INT, in_amount INT, in_account INT, in_user TEXT, in_date TIMESTAMP) RETURNS INT AS $$
    
    DELCARE
        la RECORD;
        errorcode INT;
        our_value NUMERIC;
        lid INT;
    BEGIN
    
        SELECT INTO la FROM acc_trans gl 
        WHERE gl.source = in_scn 
        and gl.account = in_account 
        and gl.amount = in_amount;
        
        lid := NULL;
        IF NOT FOUND THEN
            -- they have it, we don't. This is Bad, and implies either a bank
            -- charge or an unaccounted cheque.
            
            if in_scn <> '' and in_scn IS NOT NULL THEN
            
                -- It's a bank charge. Approval action will probably be 
                -- adding it as an entry to the general ledger.
                errorcode := 2; 
                our_value := 0;
            ELSE
                -- Okay, now this is bad.
                -- They have a cheque/sourced charge that we don't. 
                -- REsolution action is going to be
                errorcode := 3;
                our_value := 0;
            END IF;
            
        ELSE if la.amount <> in_amount THEN
        
            errorcode := 1;
            our_value := la.amount;
            lid := la.entry_id;
            
        ELSE
            -- it reconciles. No problem.
            
            errorcode := 0;
            our_value := la.amount;
            lid := la.entry_id;
            
        END IF;
        
        INSERT INTO pending_reports (
                report_id,
                scn,
                their_balance,
                our_balance,
                error_code, 
                user,
                clear_time,
                ledger_id
            ) 
            VALUES (
                in_report_id,
                in_scn,
                in_amount,
                gl.balance,
                errorcode,
                in_user,
                in_date,
                lid
            );
            
        -- success, basically. This could very likely be collapsed to
        -- do the compare check here, instead of in the Perl app. Save us a DB
        -- call.
        return 1; 
        
    END;    
$$ language 'plpgsql';

create or replace function reconciliation_pending_transactions (in_report_id INT, in_month TIMESTAMP, in_user INT) RETURNS setof int as $$
    
    DECLARE
        gl_row acc_trans;
    BEGIN
    
        FOR gl_row IN
            select gl.* from acc_trans gl, pending_reports pr 
            where gl.cleared = 'f' 
            and date_trunc('month',gl.transdate) <= date_trunc('month', in_month)
            and gl.entry_id <> pr.lid
        LOOP
        
            INSERT INTO pending_reports (
                report_id,
                scn,
                their_balance,
                our_balance,
                error_code, 
                user,
                clear_time,
                ledger_id
            ) 
            VALUES (
                in_report_id,   -- add it to the report ID
                gl_row.source,  -- the source control number
                0,              -- The banks' amount for the transaction
                gl_row.amount,  -- our recorded amount
                4,              -- The error code, meaning it's uncleared.
                in_user,        -- the report-generating user
                in_month,       -- basically, right now.
                gl_row.entry_id -- the foreign key to the ledger
            );
        
        END LOOP;
    END;
    
$$ language plpgsql;