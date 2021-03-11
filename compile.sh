#!/bin/bash
# 16 bit Redstone Computer Compiler

expand8() {
    read -r value
    length="${#value}"
    end="$((7-length))"
    eight=$(echo 8)
    if [ "$length" = "$eight" ]
    then
        echo "$value"
    else
    for t in $(seq 0 $end)
    do
        value="0$value"
        if [ "$t" = $end ]
        then
        echo "$value"
        fi
    done
    fi
}

expand4() {
    read -r value
    length="${#value}"
    end="$((3-length))"
    four=$(echo 4)
    if [ "$length" = "$four" ]
    then
        echo "$value"
    else
    for t in $(seq 0 $end)
    do
        value="0$value"
        if [ "$t" = $end ]
        then
        echo "$value"
        fi
    done
    fi
}

replace_control_codes() {
    echo "Control Codes"
    case  ${LINE%%[[:space:]]*} in
        NOP)
            echo -n 0000000000000000 > current_line
        ;;
        RTR)
            echo -n 0001 > current_line
            convert_param1_4
            convert_param2_8
        ;;
        DRL)
            echo -n 0010 > current_line
            convert_param1_4
            convert_param2_8
        ;;
        DRH)
            echo -n 0011 > current_line
            convert_param1_4
            convert_param2_8
        ;;
        PSE)
            echo -n 0100000000000000 > current_line
        ;;
        ROP)
            echo -n 0101 > current_line
            convert_param1_4
            convert_param2_8
        ;;
        JPZ)
            echo -n 10000000 > current_line
            convert_param1_8
        ;;
        JNZ)
            echo -n 10010000 > current_line 
            convert_param1_8
        ;;
        JPC)
            echo -n 10100000 > current_line
            convert_param1_8
        ;;
        JNC)
            echo -n 10110000 > current_line
            convert_param1_8
        ;;
        JMP)
            echo -n 11000000 > current_line
            convert_param1_8
        ;;
        #RST)
        #    echo -n 1110 > current_line
        #;;
        HLT)
            echo -n 1111000000000000 > current_line
        ;;
        *)
        :
        ;;
    esac
}

convert_param1_4() {
    echo "Param 1"
    echo "$(echo "${LINE}" | cut -d " " -f 2 )"> second_word
    second_word="$(cat second_word)"
    case ${second_word:0:1} in
        \%)
            echo "Converting from hex"
            sec_upper=${second_word^^}
            echo ${sec_upper:1}
            BIN=$(echo "obase=2; ibase=16; ${sec_upper:1}" | bc )
            echo $BIN
            BIN2=$(echo "$BIN" | expand4)
            echo -n $BIN2 >> current_line
        ;;
        *)
            echo "Decimal to bin"
            BIN=$(echo "obase=2; ibase=10; ${second_word}" | bc )
            echo $BIN
            BIN2=$(echo "$BIN" | expand4)
            echo -n $BIN2 >> current_line
        ;;
    esac 
}

convert_param2_4() {
    echo "Param 2"
    echo "$(echo "${LINE}" | cut -d " " -f 3 )"> third_word
    third_word="$(cat third_word)"
    case ${third_word:0:1} in
        \%)
            echo "Converting from hex"
            thi_upper=${third_word^^}
            echo ${thi_upper:1}
            BIN=$(echo "obase=2; ibase=16; ${thi_upper:1}" | bc )
            echo $BIN
            BIN2=$(echo "$BIN" | expand4)
            echo -n $BIN2 >> current_line
        ;;
        *)
            echo "Decimal to bin"
            BIN=$(echo "obase=2; ibase=10; ${third_word}" | bc )
            echo "$BIN"
            BIN2=$(echo "$BIN" | expand4)
            echo -n "$BIN2" >> current_line
        ;;
    esac 
}

convert_param1_8() {
    echo "Param 1"
    echo "$(echo "${LINE}" | cut -d " " -f 2 )"> second_word
    second_word="$(cat second_word)"
    case ${second_word:0:1} in
        \%)
            echo "Converting from hex"
            sec_upper=${second_word^^}
            echo ${sec_upper:1}
            BIN=$(echo "obase=2; ibase=16; ${sec_upper:1}" | bc )
            echo $BIN
            BIN2=$(echo "$BIN" | expand8)
            echo -n $BIN2 >> current_line
        ;;
        *)
            echo "Decimal to bin"
            BIN=$(echo "obase=2; ibase=10; ${second_word}" | bc )
            echo $BIN
            BIN2=$(echo "$BIN" | expand8)
            echo -n "$BIN2" >> current_line
        ;;
    esac 
}

convert_param2_8() {
    echo "Param 2"
    echo "$(echo "${LINE}" | cut -d " " -f 3 )"> third_word
    third_word="$(cat third_word)"
    case ${third_word:0:1} in
        \%)
            echo "Converting from hex"
            thi_upper=${third_word^^}
            echo ${thi_upper:1}
            BIN=$(echo "obase=2; ibase=16; ${thi_upper:1}" | bc )
            echo $BIN
            BIN2=$(echo "$BIN" | expand8)
            echo -n $BIN2 >> current_line
        ;;
        *)
            echo "Decimal to bin"
            BIN=$(echo "obase=2; ibase=10; ${third_word}" | bc )
            echo "$BIN"
            BIN2=$(echo "$BIN" | expand8)
            echo -n "$BIN2" >> current_line
        ;;
    esac 
}

rm output.bin
sed 's/\$/%/g' "$1" > ihatedollarsigns
while IFS='' read -r LINE || [ -n "${LINE}" ]; do
    echo "Processing line: ${LINE}"
    replace_control_codes
    echo "$(cat current_line)" >> output.bin
done < ihatedollarsigns

rm ihatedollarsigns
rm current_line
rm second_word
rm third_word