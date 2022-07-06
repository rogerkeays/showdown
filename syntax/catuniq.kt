//usr/bin/env [ $0 -nt $0.jar ] && kotlinc -d $0.jar $0; [ $0.jar -nt $0 ] && java -cp $CLASSPATH:$0.jar CatuniqKt $@; exit 0

import java.io.File

val seen = HashSet<String>()

fun scrub(str: String): String { 
  return str.replace(Regex("^.*│"), "")  // remove journal prefix
            .replace(Regex(" [/+#=!>@:][^/+#=!>@: ].*"), "") // remove trailing tags
            .replace(Regex(" --.*$"), "")  // remove attributions
            .replace(Regex("[^a-zA-Z]"), "") // normalize
            .lowercase()
}

fun catuniq(filename: String) {
  println("\n======= " + filename + "\n")
  File(filename).forEachLine {
    var scrubbed = scrub(it)
    if (!seen.contains(scrubbed)) {
      seen.add(scrubbed)
      println(it)
    }
  }
}

fun catdup(filename: String) = File(filename).forEachLine { 
  var scrubbed = scrub(it)
  if (scrubbed.isNotBlank() && seen.contains(scrubbed)) println(it)
} 

fun main(args: Array<String>) {
  File("/path/to/logs").listFiles()
     .filter { it.name.endsWith(".log") }
     .forEach { it.forEachLine { seen.add(scrub(it)) } }
  args.forEach { catuniq(it) }
}

