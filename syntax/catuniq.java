//usr/bin/env [ $0 -nt $0.jar ] && javac -d $0.jar $0; [ $0.jar -nt $0 ] && java -cp $CLASSPATH:$0.jar catuniq $@; exit 0

import java.io.*;
import java.nio.file.*;
import java.util.*;
import static jamaica.unchecked.*;

public class catuniq {

final static String journal = "/home/guybrush/journal/history";
final static Set<String> seen = new HashSet<>();

static String scrub(String in) { 
  return in.replaceAll("^.*│", "") // remove journal prefix
           .replaceAll(" [/+#=!>@:][^/+#=!>@: ].*", "") // remove trailing tags
           .replaceAll(" --.*$", "")  // remove attributions
           .replaceAll("[^a-zA-Z]", "") // normalize
           .toLowerCase(); 
}

static void catuniq(String file) {
    System.out.println("\n======= " + file + "\n");
    try {
        Files.lines(Paths.get(file)).forEach(line -> {
            var scrubbed = scrub(line);
            if (!seen.contains(scrubbed)) {
               seen.add(scrubbed);
               System.out.println(line);
            }
        });
    } catch (IOException e) {
        throw unchecked(e);
    }
}

public static void main(String [] args) {
    try {
        Files.list(Paths.get(journal)).
           filter(file -> file.toString().endsWith(".log")).
           forEach(ucc(file -> Files.lines(file).forEach(line -> seen.add(scrub(line)))));
        for (String arg : args) {
           catuniq(arg);
        }
    } catch (IOException e) {
        throw unchecked(e);
    }
}
}
