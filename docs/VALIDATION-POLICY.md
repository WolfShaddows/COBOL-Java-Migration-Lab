# Validation Policy — COBOL + Java Migration Lab

Status: Initial policy approved for the laboratory.

## 1. Financial amounts

- Negative transaction amounts must be rejected.
- Rejected negative amounts must not change balances.
- Zero-value transactions are permitted and must not change balances.
- Valid transaction types are exactly D (debit) and C (credit).
- Unknown transaction types must be rejected without changing balances.
- Amounts are expressed in integer cents.

## 2. Account integrity

- ACCOUNT_ID values must be unique.
- Duplicate account IDs invalidate the accounts input.
- The program must detect duplicate accounts before processing transactions.
- The program must not silently sum or overwrite duplicate account balances.
- An invalid accounts input must not be presented as a successful ledger run.

## 3. Transaction identity and idempotency

- The first occurrence of a transaction ID establishes its payload.
- An identical repeated ID must be reported as DUPLICATE.
- A repeated ID with different transaction data must be reported as ID_CONFLICT.
- Neither DUPLICATE nor ID_CONFLICT may apply a second balance change.
- Once a structurally identifiable transaction ID has been reserved, a business-rule rejection does not release that ID.
- A conflicting payload must never replace the original payload associated with an ID.

## 4. Error handling

- Invalid input must be reported consistently by COBOL and Java.
- A failed input validation must not be represented as a successful complete run.
- Error behavior and output must be covered by regression tests.
- No partial result may be presented as a complete successful ledger.

## 5. Cross-language equivalence

- COBOL and Java must implement the same approved rules.
- Agreement between implementations is not, by itself, proof of financial correctness.
- Existing baseline behavior must remain documented separately from the approved policy.
- Source changes must follow policy tests and must pass regression verification.

## 6. Scope

This policy applies to the synthetic laboratory data and tests.
It does not constitute validation or certification of a production financial system.
## 7. Input structure and capacity

- CSV files must contain the exact expected header.
- Nonblank data rows must contain exactly the expected number of nonempty fields.
- Monetary fields must be integer cents; malformed and out-of-range values are rejected.
- The laboratory supports at most 100 accounts and 1,000 transactions per run.
- A valid header-only accounts file is permitted; transactions referencing absent accounts are reported as NO_ACCOUNT.
- A valid header-only transactions file is permitted and produces final balances without transaction rows.
- Structural validation and capacity checks must complete before final output is created.
- Invalid input must return a nonzero exit code and must not leave a newly generated partial result.
