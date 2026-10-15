import java.io.IOException;
import java.nio.file.*;
import java.util.*;
import java.util.regex.Pattern;

public class LedgerBatch {
    record Tx(String id, String acct, String type, long cents) {}
    private static final int MAX_ACCOUNTS = 100;
    private static final int MAX_TRANSACTIONS = 1000;
    private static final long MAX_CENTS = 99_999_999_999L;
    private static final String ACCOUNT_HEADER = "ACCOUNT_ID,OPENING_CENTS";
    private static final String TX_HEADER = "TX_ID,ACCOUNT_ID,TYPE,AMOUNT_CENTS";
    private static final Pattern INTEGER = Pattern.compile("-?[0-9]+");

    private static String money(long cents) {
        return String.format(Locale.ROOT, "%011d", cents);
    }
    private static List<String> readCsv(Path path, String expectedHeader, String kind) throws IOException {
        List<String> rows = Files.readAllLines(path);
        if (rows.isEmpty() || !rows.get(0).equals(expectedHeader)) {
            throw new IllegalArgumentException("INVALID_" + kind + ": missing or invalid header");
        }
        return rows;
    }
    private static String[] fields(String row, int expected, String kind) {
        String[] f = row.split(",", -1);
        // COBOL line-sequential records treat trailing blanks as record padding.
        // Match that behavior in Java without accepting leading whitespace.
        for (int i = 0; i < f.length; i++) {
            int end = f[i].length();
            while (end > 0 && f[i].charAt(end - 1) == ' ') end--;
            f[i] = f[i].substring(0, end);
        }
        if (f.length != expected) throw new IllegalArgumentException("INVALID_" + kind + ": malformed row");
        for (String value : f) if (value.isEmpty()) throw new IllegalArgumentException("INVALID_" + kind + ": empty field");
        return f;
    }
    private static long parseInteger(String value, String kind) {
        if (!INTEGER.matcher(value).matches()) throw new IllegalArgumentException("INVALID_" + kind + ": amount must be an integer");
        try { return Long.parseLong(value); }
        catch (NumberFormatException e) { throw new IllegalArgumentException("INVALID_" + kind + ": amount out of range", e); }
    }
    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("Usage: LedgerBatch <input-dir> <output-file>");
        Path inputDir = Path.of(args[0]);
        Path outputPath = Path.of(args[1]);
        Path outputParent = outputPath.toAbsolutePath().getParent();
        if (outputParent != null) Files.createDirectories(outputParent);
        Path tempOutput = Files.createTempFile(outputParent, outputPath.getFileName().toString() + ".", ".tmp");
        boolean published = false;
        try {
            Map<String, Long> balances = new LinkedHashMap<>();
            List<String> accountRows = readCsv(inputDir.resolve("accounts.csv"), ACCOUNT_HEADER, "ACCOUNTS");
            for (int i = 1; i < accountRows.size(); i++) {
                String row = accountRows.get(i);
                if (row.isBlank()) continue;
                String[] f = fields(row, 2, "ACCOUNTS");
                String id = f[0];
                long opening = parseInteger(f[1], "ACCOUNTS");
                if (id.length() > 10) throw new IllegalArgumentException("INVALID_ACCOUNTS: account ID too long");
                if (opening < 0 || opening > MAX_CENTS) throw new IllegalArgumentException("INVALID_ACCOUNTS: opening balance out of range");
                if (balances.containsKey(id)) throw new IllegalArgumentException("INVALID_ACCOUNTS: duplicate account ID");
                if (balances.size() >= MAX_ACCOUNTS) throw new IllegalArgumentException("INVALID_ACCOUNTS: account capacity exceeded");
                balances.put(id, opening);
            }

            List<String> transactionRows = readCsv(inputDir.resolve("transactions.csv"), TX_HEADER, "TRANSACTIONS");
            List<Tx> transactions = new ArrayList<>();
            for (int i = 1; i < transactionRows.size(); i++) {
                String row = transactionRows.get(i);
                if (row.isBlank()) continue;
                String[] f = fields(row, 4, "TRANSACTIONS");
                if (f[0].length() > 12 || f[1].length() > 10 || f[2].length() != 1)
                    throw new IllegalArgumentException("INVALID_TRANSACTIONS: field length invalid");
                long cents = parseInteger(f[3], "TRANSACTIONS");
                if (cents > MAX_CENTS || cents < -MAX_CENTS) throw new IllegalArgumentException("INVALID_TRANSACTIONS: amount out of range");
                transactions.add(new Tx(f[0], f[1], f[2], cents));
                if (transactions.size() > MAX_TRANSACTIONS)
                    throw new IllegalArgumentException("INVALID_TRANSACTIONS: transaction capacity exceeded");
            }

            Map<String, Tx> seen = new LinkedHashMap<>();
            List<String> output = new ArrayList<>();
            for (Tx tx : transactions) {
                Tx original = seen.putIfAbsent(tx.id(), tx);
                Long currentBalance = balances.get(tx.acct());
                String status;
                if (original != null) status = original.equals(tx) ? "DUPLICATE" : "ID_CONFLICT";
                else if (tx.cents() < 0) status = "INVALID_AMOUNT";
                else if (!tx.type().equals("D") && !tx.type().equals("C")) status = "INVALID_TYPE";
                else if (currentBalance == null) status = "NO_ACCOUNT";
                else if (tx.type().equals("D") && currentBalance < tx.cents()) status = "DECLINED";
                else {
                    long updated;
                    try { updated = tx.type().equals("D") ? Math.subtractExact(currentBalance, tx.cents()) : Math.addExact(currentBalance, tx.cents()); }
                    catch (ArithmeticException e) { throw new IllegalArgumentException("INVALID_TRANSACTIONS: balance overflow", e); }
                    if (updated < 0 || updated > MAX_CENTS)
                        throw new IllegalArgumentException("INVALID_TRANSACTIONS: resulting balance out of range");
                    balances.put(tx.acct(), updated);
                    status = "APPROVED";
                }
                long displayBalance = balances.getOrDefault(tx.acct(), 0L);
                output.add("TX|" + tx.id() + "|" + status + "|" + money(displayBalance));
            }
            balances.forEach((id, cents) -> output.add("BAL|" + id + "|" + money(cents)));
            Files.write(tempOutput, output);
            try {
                Files.move(tempOutput, outputPath, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException e) {
                Files.move(tempOutput, outputPath, StandardCopyOption.REPLACE_EXISTING);
            }
            published = true;
        } finally {
            if (!published) Files.deleteIfExists(tempOutput);
        }
    }
}
