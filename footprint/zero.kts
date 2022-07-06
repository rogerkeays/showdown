//usr/bin/env [ $0 -nt $0.jar ] && kotlinc -d $0.jar $0; [ $0.jar -nt $0 ] && kotlin -cp $0.jar $(echo $(basename $0) | sed "s/^./\U&/;s/-/_/g;s/.kt$/Kt/") $@; exit 0

fun main() { println("hello world") }

