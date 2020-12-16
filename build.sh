help(){
    echo "传入文件夹，文件夹内默认应该有loader.asm和app.asm文件。"
    echo "编译文件夹: ./build ch10"
    echo "编译且运行文件夹: ./build -r ch10"
    echo "直接运行: ./build -q"
    echo "显示帮助: ./build -h"
}

build(){
    nasm -o ${dir}/app.bin ${dir}/app.asm
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

r=false
while getopts "qrh" arg
do
    case $arg in
    h) help;exit 0;;
    r) r=true;;
    q) run; exit 0;;
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

prepareFile
build
copyFiles

if [ $r == true ] 
then
    run
fi