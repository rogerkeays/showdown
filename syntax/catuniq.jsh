//usr/bin/env jamaica-shell --execution local $0 $@; exit $? # vim: filetype=java

import static jamaica.unchecked.*;

var seen = new HashSet<String>();

String scrub(String in) { 
  return in.replaceAll("^.*│", "").
            replaceAll("^[-# ]+", "").
            replaceAll("[ >]+$", "").
            toLowerCase(); 
}

void catuniq(String file) throws IOException {
    System.out.println("\n======= " + file + "\n");
    Files.lines(Paths.get(file)).forEach(line -> {
        var scrubbed = scrub(line);
        if (!seen.contains(scrubbed)) {
           seen.add(scrubbed);
           System.out.println(line);
        }
    });
}

Files.list(Paths.get("/path/to/logs")).
   filter(file -> file.toString().endsWith(".log")).
   forEach(ucc(file -> Files.lines(file).forEach(line -> seen.add(scrub(line)))))

/exit
