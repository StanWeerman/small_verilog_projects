proc listFromFile {filename} {
    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}

set sig_list [listFromFile build/wave_names.txt]

gtkwave::addSignalsFromList $sig_list
gtkwave::/Time/Zoom/Zoom_Best_Fit
