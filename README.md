# COBOL + Java Migration Lab

### Modernize with evidence. Preserve what works. Replace only what makes sense.

**A practical laboratory for evaluating COBOL and Java coexistence, behavioral equivalence, and incremental modernization.**

[![COBOL](https://img.shields.io/badge/COBOL-GnuCOBOL%203.2-blue)](https://sourceforge.net/projects/gnucobol/)
[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://www.oracle.com/java/)
[![Platform](https://img.shields.io/badge/Platform-Windows-informational)](https://www.microsoft.com/windows)
[![Status](https://img.shields.io/badge/Project-Experimental-yellow)](#scope-and-limitations)

---

## The idea: modernization is not synonymous with replacement

Should enterprises replace COBOL with Java, or can both technologies coexist as part of a modernization strategy?

The answer should not be determined by the age of a programming language.

Enterprise systems may contain decades of accumulated business rules, operational knowledge, financial calculations, integrations, and processing behavior. Replacing such systems without understanding their dependencies can introduce unnecessary cost, migration risk, and functional regressions.

At the same time, modern application architectures offer opportunities to improve integration, maintainability, observability, and the development of new capabilities.

**Our approach is to complement first and migrate selectively.**

Rather than treating COBOL and Java as opposing choices, this project explores how both can be evaluated within a controlled modernization strategy.

The objective is not to preserve every legacy component indefinitely. It is to preserve proven business value, reduce unnecessary risk, and modernize where measurable benefits justify the change.

> **Modernize with evidence. Preserve what works. Replace only what makes sense.**

## Our position: COBOL vs. Java is the wrong question

The relevant question is not which language is newer. It is which architecture best satisfies the system's functional, operational, economic, and security requirements.

For an enterprise with an existing COBOL core that continues to meet its objectives, retaining proven workloads while introducing Java selectively can be a reasonable starting point.

That decision must be evaluated against the actual system rather than assumed to be universally correct.

| Consideration | COBOL | Java | What must be evaluated |
|---|---|---|---|
| Existing business logic | Can preserve established processing behavior | Can implement new or migrated capabilities | Functional equivalence and regression risk |
| Financial calculations | Decimal-oriented representations can express financial rules clearly | `BigDecimal` or appropriate integer minor units can support exact arithmetic | Scale, rounding, overflow, currency rules, and edge cases |
| Batch processing | May be suitable for established high-volume workloads | Can support batch processing and parallel execution | Throughput, I/O, contention, checkpoints, and recovery |
| New capabilities | Can continue evolving existing workloads | Offers a broad ecosystem for services, APIs, and integrations | Actual requirements and integration boundaries |
| Security | CICS and RACF can provide configurable identity, authorization, and auditing controls | Security controls must be designed, configured, and operated appropriately | Effective permissions, identity propagation, auditability, and threat model |
| Operations | May rely on established scheduling, monitoring, and recovery procedures | May introduce additional services and operational dependencies | Total cost, observability, skills, failure modes, and support |
| Migration risk | Existing behavior must be understood and protected | New behavior must be verified against the established contract | Golden-master tests, equivalence, rollback, and reconciliation |

Neither language is inherently secure, faster, cheaper, or more reliable in every environment.

Performance depends on the complete workload, execution platform, data access patterns, concurrency, and operational configuration. Security depends on effective controls, not the programming language alone.

The decision must be based on evidence.

## The coexistence strategy

Our working strategy has three possible outcomes.

### Option A — Preserve

Keep the existing COBOL workload when it continues to satisfy business and operational objectives and its cost, performance, resilience, and risk remain acceptable.

Preservation is an active engineering decision, not an excuse to avoid modernization.

It still requires documentation, regression testing, security reviews, operational support, and an understanding of dependencies.

### Option B — Complement

Introduce Java where a concrete requirement justifies it.

Potential examples include new application capabilities, selected integrations, or components whose requirements are better served by a different implementation.

Where coexistence is appropriate, the integration contract must explicitly define:

- Request and response formats.
- Identity and authorization.
- Timeouts and error handling.
- Retry and idempotency behavior.
- Backpressure and capacity limits.
- Transaction boundaries and consistency expectations.
- Observability and audit requirements.
- Recovery and rollback procedures.

An API should not be introduced merely because it is fashionable.

Every additional service or network boundary can introduce latency, operational complexity, and new failure modes.

For financial systems, the authoritative ledger and the ownership of accounting state must remain explicit.

### Option C — Migrate selectively

Migrate a specific function when a measurable benefit justifies the cost and risk.

Before retiring its COBOL implementation, establish a behavioral specification, freeze an approved reference version, build a representative test corpus, demonstrate equivalence, benchmark the candidate on the target platform, validate security, and rehearse rollback.

A complete replacement can be the right decision when the evidence supports it.

It should be the result of an engineering decision, not the default definition of modernization.

## Project overview

The COBOL + Java Migration Lab is a local, fictional mini-ledger implemented in both COBOL and Java.

Both implementations process shared test fixtures, and a PowerShell script compares their generated outputs.

The current experiment focuses on reproducibility and behavioral equivalence.

It provides a small, inspectable environment for investigating how two implementations can be evaluated against the same expected behavior before attempting more complex modernization work.

### Current capabilities

- COBOL and Java implementations of the same example workload.
- Shared fixtures containing account and transaction scenarios.
- Integer-valued amounts in the current test data.
- Local compilation and execution.
- Byte-by-byte comparison of generated outputs.
- A repeatable execution script.
- Documentation covering architecture decisions, migration planning, security, testing, sources, and toolchain setup.

### What the current result demonstrates

The current laboratory reports:

`PASS: COBOL and Java outputs match byte-for-byte.`

The comparison reports that the eight decision and balance output lines match byte by byte for the tested scenario.

This establishes matching outputs for the cases represented by the current test fixtures.

It does not establish equivalence for every possible input, performance parity, production readiness, distributed transaction guarantees, or compatibility with a real banking environment.

The distinction matters: a successful test is evidence for a defined scope, not proof of universal correctness.

## Architecture

The current laboratory uses a deliberately small architecture.

```text
                 Shared Test Fixtures
                          |
                +---------+---------+
                |                   |
                v                   v
        COBOL Implementation   Java Implementation
                |                   |
                v                   v
           COBOL Output         Java Output
                |                   |
                +---------+---------+
                          |
                          v
                 Output Comparison
                          |
                          v
                    PASS / FAIL
```

The shared fixtures provide a common basis for both implementations.

The comparison helps identify observable differences in the generated output without requiring a production banking environment or external financial infrastructure.

The current implementation is a comparison laboratory, not a complete COBOL-to-Java interoperability platform.

A future experiment could introduce a controlled integration boundary between independently executable components. That would require additional design and testing for identity, authorization, timeouts, error handling, transaction ownership, idempotency, and recovery.

## Repository structure

```text
COBOL-JAVA-MIGRATION-LAB/
├── data/
│   └── Test fixtures and example inputs
├── docs/
│   ├── DECISION.md
│   ├── PLAYBOOK.md
│   ├── SECURITY.md
│   ├── SOURCES.md
│   ├── TEST-PLAN.md
│   └── TOOLCHAIN.md
├── scripts/
│   └── run.ps1
├── src/
│   └── COBOL and Java implementations
├── tools/
│   └── Local COBOL toolchain
├── work/
│   └── Generated artifacts
└── README.md
```

Generated files are written to `work/` by the supplied workflow.

The repository's documentation describes the decisions, procedures, and limitations associated with the laboratory.

## Requirements

The current local setup uses:

- Windows.
- Java 17 or later.
- GnuCOBOL 3.2.0 x64 with the included GCC 13.1/MSYS2-based toolchain.
- Windows PowerShell.

The project uses a portable COBOL toolchain under:

`tools/gnucobol-3.2-msys2/`

The supplied script configures the relevant environment variables for its own process rather than changing the global installation.

See [`docs/TOOLCHAIN.md`](docs/TOOLCHAIN.md) for additional details about the compiler distribution, provenance, integrity checks, and licensing considerations.

### Toolchain provenance

The included Windows compiler distribution is a community build, not an official installer produced by the GnuCOBOL project.

The documented archive passed the project's local 7-Zip integrity test. Its SHA-256 hash is recorded in `docs/TOOLCHAIN.md`.

The provider's cryptographic signature was not verified.

The included components retain their respective licensing obligations. Review those obligations before redistributing any toolchain components.

## Run the laboratory

Open PowerShell at the repository root.

Execute:

```powershell
.\scripts\run.ps1
```

The script configures the local execution environment, runs the implementations, and compares their outputs.

A successful execution currently reports:

```text
PASS: COBOL and Java outputs match byte-for-byte.
```

The exact output depends on the current script implementation.

Generated artifacts are stored under `work/`.

### Reproducibility

For a meaningful comparison:

1. Use the same test fixtures for both implementations.
2. Keep the expected behavior explicit.
3. Record the toolchain and execution environment.
4. Preserve the generated outputs.
5. Investigate every unexplained difference.
6. Repeat the comparison after changing either implementation.

The current script provides a starting point for this workflow. Broader correctness requires additional test coverage and independent acceptance criteria.

## Behavioral equivalence: what must be tested

Matching output is an important starting point, but a serious migration requires a broader contract.

The test plan should include the following cases.

### Functional behavior

- Valid debit.
- Insufficient balance.
- Credit.
- Nonexistent account.
- Duplicate transaction.
- Reused transaction identifier with a different payload.
- Zero-value transaction.
- Boundary conditions.
- Overflow.
- Malformed input.
- Empty input file.
- Changed transaction order.

### Financial correctness

- Approved reference outputs.
- Identical balances and totals.
- Explicit decimal scale and rounding rules.
- Correct currency handling.
- Consistent overflow behavior.
- No unexplained monetary differences.

Java implementations must not use `double` for financial amounts where exact decimal semantics are required.

Use `BigDecimal` with explicit scale and rounding rules, or integer minor units where appropriate. Currency-specific exponents and rounding rules must be defined explicitly.

### Resilience and recovery

- Failure before, during, and after a commit.
- Ambiguous timeout.
- Retry behavior.
- Partial input files.
- Checkpoint and restart.
- Reprocessing.
- Duplicate prevention.
- Reconciliation after recovery.

### Concurrency and capacity

- Low, typical, and peak workloads.
- Competing workloads.
- Transaction ordering.
- Lock contention.
- I/O and memory consumption.
- Batch execution windows.
- Recovery time.
- Throughput and latency percentiles where applicable.

### Security

- Positive and negative authorization tests.
- Identity propagation.
- Access restrictions by user, action, account, and branch where applicable.
- Idempotency and replay protection.
- Audit-log integrity.
- Secret handling.
- Separation of duties.

The detailed acceptance plan is maintained in [`docs/TEST-PLAN.md`](docs/TEST-PLAN.md).

**No migration should proceed to cutover while unexplained financial differences remain.**

## A migration playbook

The laboratory is a foundation for a broader, evidence-driven modernization process.

A controlled migration can follow these stages.

### 1. Delimit the workload

Select one job or capability.

Identify its owner, service-level objectives, volume, processing windows, dependencies, data sources, scheduling, checkpoints, retry behavior, and rollback procedure.

### 2. Discover existing behavior

Inventory relevant COBOL programs, copybooks, JCL, schedulers, CICS and DB2 dependencies, utilities, output formats, return codes, and operational runbooks.

Consult operations and accounting teams to uncover undocumented business rules.

### 3. Specify the contract

Document input and output formats, currencies, scales, rounding, overflow, ordering, business dates, duplicate handling, atomicity, and errors.

Obtain business approval for representative examples.

### 4. Establish a golden master

Freeze an approved COBOL version and create a representative synthetic or appropriately masked test corpus.

Record expected outputs and totals.

Include edge cases, malformed input, duplicate transactions, restarts, and reprocessing.

### 5. Port one bounded unit

Preserve the observable behavior of the selected function.

Separate parsing, business rules, and persistence where appropriate.

If integration with COBOL is introduced, define identity, timeouts, backpressure, error handling, and transaction boundaries explicitly.

### 6. Demonstrate equivalence

Run both implementations against the same input snapshot and transaction order.

Use shadow execution without allowing the candidate to produce unintended external side effects.

Compare records, balances, totals, counts, return codes, ordering, and restart behavior.

Investigate every unexplained difference.

### 7. Measure capacity

Benchmark on the intended platform using low, typical, and peak workloads.

Measure throughput, CPU, I/O, memory, garbage collection, locking, latency percentiles, and recovery.

Evaluate partitioning and chunk sizes against the actual workload rather than assuming they will improve performance.

Define commits and checkpoints so that recovery does not duplicate or lose transactions.

### 8. Validate security

Create a threat model covering the relevant terminal, middleware, core, database, and operational components.

Validate least privilege, identity propagation, authorization, auditability, idempotency, replay protection, secrets management, rate limits, separation of duties, and alerting.

### 9. Run a controlled pilot

Introduce the candidate with explicit limits, a feature flag where applicable, operational ownership, monitoring, and reconciliation.

Keep COBOL authoritative for the accounting workload until the required acceptance criteria have been met.

### 10. Rehearse rollback and cutover

Test how to stop writes, drain queues, reconcile idempotency keys, return to the approved COBOL workload, and resume from a validated checkpoint.

Retire the original implementation only after the responsible business, operations, platform, and security stakeholders approve the evidence.

The full procedure is documented in [`docs/PLAYBOOK.md`](docs/PLAYBOOK.md).

## Performance: measure the complete system

A language-level comparison cannot establish the performance of an enterprise system.

Java can respond in milliseconds without guaranteeing the p99 latency of an entire transaction flow.

Likewise, batch processing must be evaluated against its processing window, volume, I/O, contention, and recovery requirements.

A meaningful benchmark should consider:

- End-to-end latency.
- p50, p95, and p99 latency where relevant.
- Throughput.
- CPU and I/O consumption.
- Memory and garbage collection.
- Locking and contention.
- Network round trips.
- Transaction boundaries.
- Checkpoints and recovery.
- Competing workloads.
- Operational overhead and total cost.

Partitioning, chunking, and parallel execution are hypotheses to test, not performance guarantees.

A local demonstration cannot substitute for measurements on the intended production platform.

The goal is not to declare a universal performance winner. It is to establish which approach satisfies the workload's actual requirements.

## Security and financial-system boundaries

Security must be evaluated across the complete system.

CICS and RACF can provide transaction and resource authorization, identity controls, and auditing when correctly configured. Java systems can implement corresponding controls through appropriate identity, authorization, logging, and operational mechanisms.

Neither language is inherently secure.

A migration must validate the effective configuration and demonstrate that unauthorized operations are rejected.

For financial integrations, additional boundaries matter:

- **Terminal:** approved devices, authenticity, anti-tampering controls, inventory, inspection, and controlled firmware and keys.
- **Acquiring layer:** confirmation of backend authorization, transaction identifiers, amount and currency validation, idempotency, reversals, and reconciliation.
- **Middleware:** protected communication, service authentication, identity propagation, authorization, input validation, rate limits, replay protection, and safe logging.
- **Core ledger:** atomic and idempotent accounting, account-state validation, reconciliation, and auditability.
- **Operations:** incident procedures, preserved logs, monitoring, recovery, and escalation to the relevant provider.

A local user interface displaying a successful transaction is not proof of backend authorization or settlement.

Evidence from a screenshot alone cannot establish which payment protocol was used, whether a real card transaction occurred, or whether a transaction was authorized and settled.

Investigations involving payment systems must use authorized procedures, provider records, and appropriate transaction evidence. Commercial terminals and accounts belonging to others must not be used for unauthorized experiments.

This repository is a local, fictional laboratory. It does not connect to payment systems, point-of-sale terminals, banks, card networks, or external financial infrastructure.

See [`docs/SECURITY.md`](docs/SECURITY.md) for the documented scope and security considerations.

## Decision framework

The recommended starting point for an existing COBOL core that continues to meet its objectives is:

**Complement first. Migrate selectively.**

Use the following decision gates.

| Decision | Conditions |
|---|---|
| Preserve | Existing functionality meets requirements and its cost, operation, resilience, and risk remain acceptable. |
| Complement | A concrete requirement justifies a new capability with a well-defined integration contract. |
| Migrate a function | The behavior is specified, equivalence is demonstrated, performance is measured on the target platform, security is validated, and rollback is rehearsed. |
| Retire COBOL | Business, operations, platform, and security stakeholders approve the evidence and the cutover plan. |

The preferred strategy can change as requirements, costs, risks, and evidence change.

The point is not to choose coexistence at any cost. It is to make the decision deliberately.

## Roadmap

Potential next steps for the laboratory include:

- Expand the shared test fixtures and regression suite.
- Add randomized and boundary-condition testing.
- Improve malformed-input and duplicate-transaction coverage.
- Test interruption, retry, and recovery behavior.
- Add reproducible workload benchmarks.
- Measure resource consumption under controlled conditions.
- Document explicit interfaces between COBOL and Java components.
- Explore controlled interoperability experiments.
- Evaluate shadow execution and reconciliation procedures.
- Document acceptance criteria for a hypothetical incremental migration.
- Improve automated validation and reporting.

Each extension should have a clear objective, defined acceptance criteria, and reproducible results.

A feature should not be described as implemented until it exists in the repository and its behavior has been verified.

## Project documentation

The repository's supporting documentation provides additional detail:

- [`docs/DECISION.md`](docs/DECISION.md) — The COBOL versus Java decision framework and the conditions for preserving, complementing, or migrating existing workloads.
- [`docs/PLAYBOOK.md`](docs/PLAYBOOK.md) — The end-to-end migration process, from workload discovery through equivalence testing, pilot, rollback, and cutover.
- [`docs/SECURITY.md`](docs/SECURITY.md) — Security boundaries, payment-system evidence limitations, and controls across the relevant layers.
- [`docs/SOURCES.md`](docs/SOURCES.md) — Primary references and the limits of what those references establish.
- [`docs/TEST-PLAN.md`](docs/TEST-PLAN.md) — Functional, financial, performance, resilience, security, and cutover acceptance criteria.
- [`docs/TOOLCHAIN.md`](docs/TOOLCHAIN.md) — Local compiler setup, provenance, integrity information, and licensing considerations.

These documents distinguish the laboratory's observed results from architectural proposals and future experiments.

## References

The following primary sources provide background for interoperability, security, and device controls.

- [IBM — COBOL/Java interoperability](https://www.ibm.com/docs/en/c-and-ji?topic=cobol-java-interoperability): capabilities for COBOL and Java interoperability on z/OS.
- [IBM — CICS transaction security](https://www.ibm.com/docs/en/cics-ts/6.x?topic=cics-transaction-security): transaction-security concepts and controls.
- [IBM — How CICS security works with RACF](https://www.ibm.com/docs/en/cics-ts/6.x?topic=cics-how-it-works-securing-racf): identity, authorization, and auditing.
- [EMVCo — EMV Contact Chip](https://www.emvco.com/emv-technologies/emv-contact-chip/): EMV transaction cryptography and transaction-specific cryptograms.
- [PCI Security Standards Council — Physical security of point-of-interaction devices](https://www.pcisecuritystandards.org/faqs/are-point-of-interaction-devices-required-to-be-physically-secured-for-example-with-a-cable-or-tether-to-prevent-removal-or-substitution-to-meet-pci-dss-requirement-9-5/): device inventory, inspection, and anti-tampering controls.
- [GnuCOBOL — Release files](https://sourceforge.net/projects/gnucobol/files/gnucobol/3.2/): compiler distribution files.
- [GnuCOBOL — Community Windows builds and setup notes](https://www.arnoldtrembley.com/GnuCOBOL.htm): community distribution information.

These sources provide technical context. They do not independently validate the laboratory's implementation, prove the cause of behavior observed in external screenshots, or establish production equivalence.

## Scope and limitations

This project is an experimental, local comparison laboratory.

It is not:

- A production banking system.
- A replacement for a core-banking platform.
- A complete COBOL-to-Java migration framework.
- A production implementation of distributed financial transactions.
- A benchmark establishing a universal performance winner.
- A certification of financial correctness, security, or regulatory compliance.

The current byte-by-byte comparison establishes matching output for the tested cases only.

Broader conclusions require broader evidence.

Any future production-oriented work would need system-specific discovery, approved business requirements, representative test data, security assessment, operational validation, performance testing, reconciliation, and a demonstrated rollback procedure.

## Final principle

COBOL and Java are technologies. Modernization is an engineering decision.

A mature system should not be replaced merely because a newer language exists. Nor should an existing implementation be preserved when evidence demonstrates that a different approach would better meet the system's requirements.

The objective is to understand the existing behavior, define what must remain true, measure the alternatives, and migrate only when the benefits justify the risks.

**Modernize with evidence. Preserve what works. Replace only what makes sense.**

*Darkshadows Group — Engineering modernization through evidence, controlled change, and measurable outcomes.*