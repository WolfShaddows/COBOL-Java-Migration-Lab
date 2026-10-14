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
fd af. 01 ar pic x(100).
fd tf. 01 tr pic x(150).
fd ofile. 01 ol pic x(100).
working-storage section.
01 out-path pic x(260).
01 fs pic xx.
01 fs2 pic xx.
01 aid pic x(10).
01 baltext pic x(20).
01 txid pic x(12).
01 typ pic x.
01 amttext pic x(20).
01 amount pic 9(11) comp-5.
01 fmtbal pic 9(11).
01 status-text pic x(12).
01 acct-count binary-long value 0.
01 tx-count binary-long value 0.
01 i binary-long.
01 j binary-long.
01 accounts.
 05 acct occurs 100 times.
  10 acct-id pic x(10).
  10 acct-bal pic 9(11) comp-5.
01 seen-ids.
 05 seen-id occurs 1000 times pic x(12).
procedure division.
 accept out-path from command-line
 open input af tf output ofile
 read af
 perform until fs = "10"
   move spaces to aid baltext
   unstring ar delimited by "," into aid baltext
   if function trim(aid) not = "ACCOUNT_ID"
    add 1 to acct-count
    move aid to acct-id(acct-count)
    compute acct-bal(acct-count) = function numval(baltext)
   end-if
   read af
 end-perform
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
    move "APPROVED" to status-text
    perform varying i from 1 by 1 until i > tx-count
      if seen-id(i) = txid move "DUPLICATE" to status-text end-if
    end-perform
    if status-text not = "DUPLICATE"
      add 1 to tx-count
      move txid to seen-id(tx-count)
      if j = 0
       move "NO_ACCOUNT" to status-text
      else
       if typ = "D" and acct-bal(j) < amount
        move "DECLINED" to status-text
       else
        if typ = "D" subtract amount from acct-bal(j)
        else add amount to acct-bal(j) end-if
       end-if
      end-if
    end-if
    if j = 0 move 0 to fmtbal else move acct-bal(j) to fmtbal end-if
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
 close af tf ofile
 stop run.
