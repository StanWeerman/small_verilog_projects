export name="$1"
export dump="$2"
DUMPO=0
DUMPC=0
COMMANDS=""
WAVE=0

for VAR in "$@"
do
    case $VAR in
        "-d")
            DUMPO=1
            DUMPC=1
            ;;
        "-dc")
            DUMPC=1
            ;;
        "-do")
            DUMPO=1
            ;;
        -w)
            WAVE=1
            ;;
        +*)
            COMMANDS+=" $VAR"
            ;;
        *)
            ;;
    esac
done

if [ -f $name/$name.v ]
then
    echo "Running '$name':"
else
    echo "No Project Found"
    exit 1
fi

if [ -e $name/build ]
then
    rm -r $name/build
fi
mkdir $name/"build"
if [ -e build ]
then
    rm -r build
fi

echo "------Start------"

if [ -f $name/file_list.txt ]
then
    iverilog -o $name/build/$name -c $name/file_list.txt
else
    iverilog -o $name/build/$name $name/${name}_tb.v $name/$name.v
fi

vvp $name/build/$name > $name/build/vvp.txt + $COMMANDS

if [ $DUMPC -eq 1 ]; then
    cat $name/build/vvp.txt
fi
if [ -f output_results.txt ]
then
    mv output_results.txt $name/build
    if [ $DUMPO -eq 1 ]; then
        echo "-----Results-----"
        cat $name/build/output_results.txt
    fi
fi

if [ -f dump.vcd ]
then
    mv dump.vcd $name/build
    if [ $WAVE -eq 1 ]; then
        if [ -f $name/wave_names.txt ]; then
            mkdir "build"
            cp $name/wave_names.txt build/wave_names.txt
            nohup gtkwave $name/build/dump.vcd --script=add_waves.tcl s > $name/build/wave.txt &
        else nohup gtkwave $name/build/dump.vcd --script=add_waves.tcl s > $name/build/wave.txt &
        fi
    fi
fi

echo "------Done-------"
