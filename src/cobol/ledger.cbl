>>SOURCE FORMAT FREE
identification division.
program-id. ledger.
environment division.
input-output section.
file-control.
 select af assign to "accounts.csv" organization line sequential file status fs.
 select tf assign to "transactions.csv" organization line sequential file status fs2.
 select ofile assign to dynamic out-path organization line sequential.
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
01 fs pic xx.
01 fs2 pic xx.
01 aid pic x(10).
01 baltext pic x(20).
01 txid pic x(12).
01 typ pic x.
01 amttext pic x(20).
01 amount pic s9(11) comp-5.
01 fmtbal pic 9(11).
01 status-text pic x(14).
01 acct-count binary-long value 0.
01 tx-count binary-long value 0.
01 i binary-long.
01 j binary-long.
01 found-index binary-long.
01 invalid-accounts binary-char value 0.
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

 *> Load and validate all accounts before opening the output file.
 open input af
 read af
 perform until fs = "10"
   move spaces to aid baltext
   unstring ar delimited by "," into aid baltext
   if function trim(aid) not = "ACCOUNT_ID"
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
         compute acct-bal(acct-count) = function numval(baltext)
       end-if
     end-if
   end-if
   read af
 end-perform
 close af

 if invalid-accounts = 1
   display "INVALID_ACCOUNTS: duplicate account ID or account capacity exceeded"
   move 1 to return-code
   stop run
 end-if

 open input tf output ofile
 read tf
 perform until fs2 = "10"
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
       if seen-acct(found-index) = aid
          and seen-type(found-index) = typ
          and seen-amount(found-index) = amount
         move "DUPLICATE" to status-text
       else
         move "ID_CONFLICT" to status-text
       end-if
     else
       if tx-count >= 1000
         display "INVALID_TRANSACTIONS: transaction capacity exceeded"
         close tf ofile
         move 1 to return-code
         stop run
       end-if

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

     if j = 0
       move 0 to fmtbal
     else
       move acct-bal(j) to fmtbal
     end-if
     move spaces to ol
     string "TX|" function trim(txid) "|" function trim(status-text) "|" fmtbal into ol
     write ol
   end-if
   read tf
 end-perform

 perform varying i from 1 by 1 until i > acct-count
   move acct-bal(i) to fmtbal
   move spaces to ol
   string "BAL|" acct-id(i) "|" fmtbal into ol
   write ol
 end-perform
 close tf ofile
 move 0 to return-code
 stop run.
