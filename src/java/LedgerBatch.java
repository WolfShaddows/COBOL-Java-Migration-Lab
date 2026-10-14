import java.nio.file.*; import java.util.*;
public class LedgerBatch {
 record Tx(String id,String acct,String type,long cents) {}
 public static void main(String[] args) throws Exception {
  Path in=Path.of(args[0]); Map<String,Long> bal=new LinkedHashMap<>();
  for(String s:Files.readAllLines(in.resolve("accounts.csv")).subList(1,Files.readAllLines(in.resolve("accounts.csv")).size())){String[] p=s.split(",");bal.put(p[0],Long.parseLong(p[1]));}
  Set<String> seen=new HashSet<>(); List<String> out=new ArrayList<>();
  List<String> rows=Files.readAllLines(in.resolve("transactions.csv"));
  for(String row:rows.subList(1,rows.size())){String[] p=row.split(",");String id=p[0],acct=p[1],type=p[2];long cents=Long.parseLong(p[3]);String status;Long b=bal.get(acct);
   if(!seen.add(id))status="DUPLICATE";else if(b==null)status="NO_ACCOUNT";else if(type.equals("D")&&b<cents)status="DECLINED";else{bal.put(acct,b+(type.equals("D")?-cents:cents));status="APPROVED";}
   out.add("TX|"+id+"|"+status+"|"+String.format(Locale.ROOT,"%011d",bal.getOrDefault(acct,0L)));
  }
  bal.forEach((id,c)->out.add("BAL|"+id+"|"+String.format(Locale.ROOT,"%011d",c)));
  Files.write(Path.of(args[1]),out);
 }
}
