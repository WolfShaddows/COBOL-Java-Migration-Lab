       $set sourceformat(free)
identification division.
program-id. ledger.
environment division.
input-output section.
file-control.
 select af assign to "accounts.csv" organization line sequential file status fs.
 select tf assign to "transactions.csv" organization line sequential file status fs2.
 select ofile assign to dynamic temp-path organization line sequential file status fsout.
data division.
file section.
fd af.
01 ar pic x(100).
fd tf.
01 tr pic x(150).
fd ofile.
01 ol pic x(100).
working-storage section.
01 out-path pic x(260).
01 temp-path pic x(260).
01 backup-path pic x(260).
01 final-path pic x(260).
01 file-details pic x(16).
01 rename-status binary-long.
01 fs pic xx.
01 fs2 pic xx.
01 fsout pic xx.
01 aid pic x(10).
01 baltext pic x(20).
01 txid pic x(12).
01 typ pic x.
01 amttext pic x(20).
01 raw-aid pic x(150).
01 raw-baltext pic x(150).
01 raw-txid pic x(150).
01 raw-tx-aid pic x(150).
01 raw-typ pic x(150).
01 raw-amttext pic x(150).
01 token-length binary-long.
01 char-index binary-long.
01 numeric-invalid binary-char value 0.
01 current-char pic x.
01 amount pic s9(11) comp-5.
01 fmtbal pic 9(11).
01 status-text pic x(14).
01 acct-count binary-long value 0.
01 tx-count binary-long value 0.
01 i binary-long.
01 j binary-long.
01 found-index binary-long.
01 field-count binary-long.
01 comma-count binary-long.
01 invalid-accounts binary-char value 0.
01 invalid-transactions binary-char value 0.
01 accounts.
 05 acct occurs 100 times.
  10 acct-id pic x(10).
  10 acct-bal pic 9(11) comp-5.
01 seen-transactions.
 05 seen-tx occurs 1000 times.
  10 seen-id pic x(12).
  10 seen-acct pic x(10).
  10 seen-type pic x.
  10 seen-amount pic s9(11) comp-5.
procedure division.
 accept out-path from command-line
 move spaces to temp-path backup-path final-path file-details
 string function trim(out-path) ".phase6tmp" x"00" into temp-path
 string function trim(out-path) ".phase6bak" x"00" into backup-path
 string function trim(out-path) x"00" into final-path
 call "CBL_CHECK_FILE_EXIST" using by reference backup-path by reference file-details returning rename-status
 if rename-status = 0
   display "INVALID_OUTPUT: backup already exists; refusing to overwrite it"
   move 1 to return-code
   stop run
 end-if
 call "CBL_CHECK_FILE_EXIST" using by reference temp-path by reference file-details returning rename-status
 if rename-status = 0
   call "CBL_DELETE_FILE" using by reference temp-path returning rename-status
   if rename-status not = 0
     display "INVALID_OUTPUT: cannot remove stale temporary output"
     move 1 to return-code
     stop run
   end-if
 end-if

 open input af
 if fs not = "00"
   display "INVALID_ACCOUNTS: cannot open accounts.csv"
   move 1 to return-code
   stop run
 end-if
 read af
 if fs = "10"
   move 1 to invalid-accounts
 else
   if ar not = "ACCOUNT_ID,OPENING_CENTS"
     move 1 to invalid-accounts
   end-if
 end-if
 perform until fs = "10" or invalid-accounts = 1
   read af
   if fs not = "10"
     if function trim(ar) not = spaces
move spaces to raw-aid raw-baltext aid baltext
     move 0 to field-count
     unstring ar delimited by "," into raw-aid raw-baltext tallying in field-count
     move 0 to comma-count
     inspect ar tallying comma-count for all ","
     if field-count not = 2 or comma-count not = 1 or function trim(raw-aid) = spaces
       move 1 to invalid-accounts
     else
       if function stored-char-length(raw-aid) > 10 or function stored-char-length(raw-baltext) = 0 or function stored-char-length(raw-baltext) > 20
         move 1 to invalid-accounts
       else
         move 0 to numeric-invalid
         compute token-length = function stored-char-length(raw-baltext)
         perform varying char-index from 1 by 1 until char-index > token-length
           move raw-baltext(char-index:1) to current-char
           if (current-char < "0" or current-char > "9") and not (char-index = 1 and current-char = "-")
             move 1 to numeric-invalid
           end-if
         end-perform
         if numeric-invalid = 1 or function test-numval(function trim(raw-baltext)) not = 0
           move 1 to invalid-accounts
         else
           if function numval(raw-baltext) < 0 or function numval(raw-baltext) > 99999999999
             move 1 to invalid-accounts
           else
             move raw-aid to aid
             move raw-baltext to baltext
             if acct-count >= 100
               move 1 to invalid-accounts
             else
               move 0 to j
               perform varying i from 1 by 1 until i > acct-count
                 if acct-id(i) = aid move i to j end-if
               end-perform
               if j not = 0
                 move 1 to invalid-accounts
               else
                 add 1 to acct-count
                 move aid to acct-id(acct-count)
                 compute acct-bal(acct-count) = function numval(raw-baltext)
               end-if
             end-if
           end-if
         end-if
       end-if
     end-if
      end-if
   end-if
 end-perform
 close af
 if invalid-accounts = 1
   display "INVALID_ACCOUNTS: malformed, duplicate, or capacity exceeded"
   move 1 to return-code
   stop run
 end-if

 *> Preflight every transaction before opening the output file.
 open input tf
 if fs2 not = "00"
   display "INVALID_TRANSACTIONS: cannot open transactions.csv"
   move 1 to return-code
   stop run
 end-if
 read tf
 if fs2 = "10"
   move 1 to invalid-transactions
 else
   if tr not = "TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS"
     move 1 to invalid-transactions
   end-if
 end-if
 perform until fs2 = "10" or invalid-transactions = 1
   read tf
   if fs2 not = "10"
     if function trim(tr) not = spaces
move spaces to raw-txid raw-tx-aid raw-typ raw-amttext txid aid typ amttext
     move 0 to field-count
     unstring tr delimited by "," into raw-txid raw-tx-aid raw-typ raw-amttext tallying in field-count
     move 0 to comma-count
     inspect tr tallying comma-count for all ","
     if field-count not = 4 or comma-count not = 3 or function trim(raw-txid) = spaces or function trim(raw-tx-aid) = spaces or function trim(raw-typ) = spaces
       move 1 to invalid-transactions
     else
       if function stored-char-length(raw-txid) > 12 or function stored-char-length(raw-tx-aid) > 10 or function stored-char-length(raw-typ) not = 1 or function stored-char-length(raw-amttext) = 0 or function stored-char-length(raw-amttext) > 12
         move 1 to invalid-transactions
       else
         move 0 to numeric-invalid
         compute token-length = function stored-char-length(raw-amttext)
         perform varying char-index from 1 by 1 until char-index > token-length
           move raw-amttext(char-index:1) to current-char
           if (current-char < "0" or current-char > "9") and not (char-index = 1 and current-char = "-")
             move 1 to numeric-invalid
           end-if
         end-perform
         if numeric-invalid = 1 or function test-numval(function trim(raw-amttext)) not = 0
           move 1 to invalid-transactions
         else
           if function numval(raw-amttext) > 99999999999 or function numval(raw-amttext) < -99999999999
             move 1 to invalid-transactions
           else
             if tx-count >= 1000
               move 1 to invalid-transactions
             else
               add 1 to tx-count
             end-if
           end-if
         end-if
       end-if
     end-if
      end-if
   end-if
 end-perform
 close tf
 if invalid-transactions = 1
   display "INVALID_TRANSACTIONS: malformed, nonnumeric, or capacity exceeded"
   move 1 to return-code
   stop run
 end-if

 move 0 to tx-count
 open input tf output ofile
 if fs2 not = "00" or fsout not = "00"
   display "INVALID_OUTPUT: unable to open ledger files"
   move 1 to return-code
   stop run
 end-if
 read tf
 perform until fs2 = "10"
   read tf
   if fs2 not = "10"
     if function trim(tr) not = spaces
move spaces to txid aid typ amttext
     unstring tr delimited by "," into txid aid typ amttext
     if function trim(txid) not = "TX_ID"
       compute amount = function numval(amttext)
       move 0 to j
       perform varying i from 1 by 1 until i > acct-count
         if acct-id(i) = aid move i to j end-if
       end-perform
       move 0 to found-index
       perform varying i from 1 by 1 until i > tx-count
         if seen-id(i) = txid move i to found-index end-if
       end-perform
       if found-index > 0
         if seen-acct(found-index) = aid and seen-type(found-index) = typ and seen-amount(found-index) = amount
           move "DUPLICATE" to status-text
         else
           move "ID_CONFLICT" to status-text
         end-if
       else
         add 1 to tx-count
         move txid to seen-id(tx-count)
         move aid to seen-acct(tx-count)
         move typ to seen-type(tx-count)
         move amount to seen-amount(tx-count)
         if amount < 0
           move "INVALID_AMOUNT" to status-text
         else
           if typ not = "D" and typ not = "C"
             move "INVALID_TYPE" to status-text
           else
             if j = 0
               move "NO_ACCOUNT" to status-text
             else
               if typ = "D" and acct-bal(j) < amount
                  move "DECLINED" to status-text
                else
                  if typ = "C" and amount > 99999999999 - acct-bal(j)
                    display "INVALID_TRANSACTIONS: resulting balance exceeds 11 digits"
                    close tf ofile
                    move 1 to return-code
                    stop run
                  else
                    if typ = "D"
                      subtract amount from acct-bal(j)
                    else
                      add amount to acct-bal(j)
                    end-if
                    move "APPROVED" to status-text
                  end-if
                end-if
             end-if
           end-if
         end-if
       end-if
       if j = 0 move 0 to fmtbal else move acct-bal(j) to fmtbal end-if
       move spaces to ol
       string "TX|" function trim(txid) "|" function trim(status-text) "|" fmtbal into ol
       write ol
     end-if
      end-if
   end-if
 end-perform
 perform varying i from 1 by 1 until i > acct-count
   move acct-bal(i) to fmtbal
   move spaces to ol
   string "BAL|" acct-id(i) "|" fmtbal into ol
   write ol
 end-perform
 close tf ofile
 call "CBL_CHECK_FILE_EXIST" using by reference final-path by reference file-details returning rename-status
 if rename-status = 0
   call "CBL_RENAME_FILE" using by reference final-path by reference backup-path returning rename-status
   if rename-status not = 0
     display "INVALID_OUTPUT: cannot preserve previous output"
     move 1 to return-code
     stop run
   end-if
 end-if
 call "CBL_RENAME_FILE" using by reference temp-path by reference final-path returning rename-status
 if rename-status not = 0
   call "CBL_CHECK_FILE_EXIST" using by reference backup-path by reference file-details returning rename-status
   if rename-status = 0
     call "CBL_RENAME_FILE" using by reference backup-path by reference final-path returning rename-status
   end-if
   display "INVALID_OUTPUT: cannot publish staged output"
   move 1 to return-code
   stop run
 end-if
 call "CBL_CHECK_FILE_EXIST" using by reference backup-path by reference file-details returning rename-status
 if rename-status = 0
   call "CBL_DELETE_FILE" using by reference backup-path returning rename-status
 end-if
 move 0 to return-code
 stop run.
