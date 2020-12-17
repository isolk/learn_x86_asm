help(){
    echo "传入文件夹，文件夹内默认应该有loader.asm和app.asm文件。"
    echo "编译且运行: ./build ch10"
    echo "仅编译: ./build -b ch10"
    echo "仅运行: ./build -r"
    echo "清理二进制文件: ./build -c"
    echo "显示帮助: ./build -h"
}

build(){
    nasm -o ${dir}/app.bin ${dir}/app.asm
    if [ $? -ne 0 ]
    then
        echo "编译app.asm失败"
        exit 7
    fi
    nasm -o ${dir}/loader.bin ${dir}/loader.asm
}

prepareFile(){
    rm disk1.img
    mkfile -n 1M disk1.img
}

copyFiles(){
    dd bs=512 count=1 if=${dir}/loader.bin of=disk1.img conv=notrunc
    dd bs=512 count=1 if=${dir}/app.bin of=disk1.img seek=1 conv=notrunc
}

run(){
    bochs -qf bochs.cfg
}

justBuild=false
justClear=false
while getopts "brhc" arg
do
    case $arg in
    h) help;exit 0;;
    b) justBuild=true;;
    r) run; exit 0;;
    c) justClear=true; break;;
    *)
    esac
done

if [[ $OPTIND != 0 ]]
then
shift $((${OPTIND}-1))
fi

if [[ $1 == "" ]]
then
    echo "请输入文件夹"
    exit 7
fi

dir=$1

if [[ $justClear == true ]]
then
    rm ${dir}/app.bin ${dir}/loader.bin
    exit 0
fi

prepareFile
build
if [ $? -ne 0 ]
then
    echo "编译失败"
    exit 7
fi

copyFiles

if [ $justBuild != true ] 
then
    run
fi
