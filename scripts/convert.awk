BEGINFILE {
 printf "Processing " FILENAME ": "
 title=""
 filename=""
 created=""
 tags=""
 cat=""
 content="" 
 tempfile=".temp.md"
 in_body=0
 system("rm -f " tempfile)
}

/.. title:/ {title=gensub(".*title:[ ]*","","g")}
/.. slug:/ {filename=gensub(".*slug:[ ]*","","g") ".md"}
/.. date:/ {created_raw=gensub(".*date:[ ]*","","g");
            cmd="date --iso-8601=seconds -d \"" created_raw "\"";
            cmd | getline created;
            close(cmd) }
/.. tags:/ {tags=gensub(".*tags:[ ]*","","g")
            tags="[" gensub("\*", "", "g", tags) "]"}
/.. category:/ {cat="[" gensub(".*category:[ ]*","","g") "]"}


{ if ( in_body )
    print $0 >> tempfile
}

/-->/ {in_body=1}

ENDFILE {

    close(tempfile)
    cmd="sha256sum " tempfile " | cut -d ' ' -f1"
    cmd | getline csum
    close(cmd)

    if ( csum in content_seen ) {
        print "SKIPPING. Content seen in " content_seen[csum] "."
    } else {
        content_seen[csum] = FILENAME


        print "  Writing " filename "."
        print "---"                > filename
        print "title: \"" gensub("\"","\\\\\"", "g", title) "\"" > filename
        print "date: "       created > filename
        if (tags != "")
            print "tags: "       tags  > filename
        if (cat!= "")
        print "categories: " cat  > filename
        print "---" > filename
        print ""    > filename
        print "# " title > filename
        print ""      > filename
        system("fold -s -w 120 " tempfile ">>" filename)
    }
    system("rm -f " tempfile)
}
