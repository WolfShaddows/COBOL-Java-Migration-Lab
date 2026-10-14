import java.nio.file.*;
import java.util.*;

public class LedgerBatch {
    record Tx(String id, String acct, String type, long cents) {}

    private static String money(long cents) {
        return String.format(Locale.ROOT, "%011d", cents);
    }

    public static void main(String[] args) throws Exception {
        Path inputDir = Path.of(args[0]);
        Path outputPath = Path.of(args[1]);
        Files.deleteIfExists(outputPath);

        Map<String, Long> balances = new LinkedHashMap<>();
        List<String> accountRows = Files.readAllLines(inputDir.resolve("accounts.csv"));

        for (int i = 1; i < accountRows.size(); i++) {
            String row = accountRows.get(i);
            if (row.isBlank()) continue;
            String[] fields = row.split(",", -1);
            if (fields.length != 2) {
                throw new IllegalArgumentException("INVALID_ACCOUNTS: malformed account row");
            }

            String accountId = fields[0];
            long openingCents = Long.parseLong(fields[1]);
            if (balances.containsKey(accountId)) {
                throw new IllegalArgumentException("INVALID_ACCOUNTS: duplicate account ID");
            }
            balances.put(accountId, openingCents);
        }

        Map<String, Tx> seen = new LinkedHashMap<>();
        List<String> output = new ArrayList<>();
        List<String> transactionRows = Files.readAllLines(inputDir.resolve("transactions.csv"));

        for (int i = 1; i < transactionRows.size(); i++) {
            String row = transactionRows.get(i);
            if (row.isBlank()) continue;
            String[] fields = row.split(",", -1);
            if (fields.length != 4) {
                throw new IllegalArgumentException("INVALID_TRANSACTIONS: malformed transaction row");
            }

            String id = fields[0];
            String accountId = fields[1];
            String type = fields[2];
            long cents = Long.parseLong(fields[3]);
            Tx tx = new Tx(id, accountId, type, cents);
            Tx original = seen.putIfAbsent(id, tx);

            Long currentBalance = balances.get(accountId);
            String status;

            if (original != null) {
                status = original.equals(tx) ? "DUPLICATE" : "ID_CONFLICT";
            } else if (cents < 0) {
                status = "INVALID_AMOUNT";
            } else if (!type.equals("D") && !type.equals("C")) {
                status = "INVALID_TYPE";
            } else if (currentBalance == null) {
                status = "NO_ACCOUNT";
            } else if (type.equals("D") && currentBalance < cents) {
                status = "DECLINED";
            } else {
                long updated = type.equals("D")
                    ? currentBalance - cents
                    : currentBalance + cents;
                balances.put(accountId, updated);
                status = "APPROVED";
            }

            long displayBalance = balances.getOrDefault(accountId, 0L);
            output.add("TX|" + id + "|" + status + "|" + money(displayBalance));
        }

        balances.forEach((id, cents) -> output.add("BAL|" + id + "|" + money(cents)));
        Files.write(outputPath, output);
    }
}
