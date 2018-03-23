#!/bin/sh

#testcase1: make -j32
#testcase2: make systemimage -j32
#testcase3: source build/core/partition_size_self_adaption.sh \
#           out/target/product/sp9860g_2h10           \
#           out/target/product/sp9860g_2h10/system    \
#           out/target/product/sp9860g_2h10/obj/PACKAGING/systemimage_intermediates/system_image_size.txt
# $1: where is product partition xml,
#     we will change system partition size in the xml(<Partition id="system" size="1300"/>) by minimum system image size.
# $2: where is system folder,
#     we will get minimum system image size by the command: du -sm $(system folder)
# $3: where is temp file to store minimum system image size,
#     build/core/Makefile will change BOARD_SYSTEMIMAGE_PARTITION_SIZE via this file,
#     see also: $(eval BOARD_SYSTEMIMAGE_PARTITION_SIZE=`(cat $(systemimage_intermediates)/SYSTEM_IMG_SIZE.txt)`)

echo "---$0 by yongjun.zang---"

SYSTEM_IMAGE_SIZE_ADAPT=$4
echo SYSTEM_IMAGE_SIZE_ADAPT=${SYSTEM_IMAGE_SIZE_ADAPT}

PARTITION_XML_PATH=$1
SYSTEM_FOLDER_PATH=$2
SYSTEM_IMAGE_SIZE_FILE=$3
echo PARTITION_XML_PATH=${PARTITION_XML_PATH}
echo SYSTEM_FOLDER_PATH=${SYSTEM_FOLDER_PATH}
echo SYSTEM_IMAGE_SIZE_FILE=${SYSTEM_IMAGE_SIZE_FILE}

cat ${SYSTEM_IMAGE_SIZE_FILE}

if [ "${SYSTEM_IMAGE_SIZE_ADAPT}" != "false" ]; then

DU_SYSTEM_FOLDER=$(du -sm ${SYSTEM_FOLDER_PATH})
echo "DU_SYSTEM_FOLDER"=${DU_SYSTEM_FOLDER}

GET_SYSTEM_FOLDER_SIZE=$(echo ${DU_SYSTEM_FOLDER} | cut -d " " -f 1)
echo "SYSTEM_FOLDER_SIZE"=${GET_SYSTEM_FOLDER_SIZE}

GET_SYSTEM_IMAGE_SIZE=$(echo $(( ${GET_SYSTEM_FOLDER_SIZE} * 1024 * 1024 * 104 / 100 + (100 * 1024 * 1024))) )
echo "SYSTEM_IMAGE_SIZE_Byte"=${GET_SYSTEM_IMAGE_SIZE}
echo "SYSTEM_IMAGE_SIZE_MB"=$(echo $(( ${GET_SYSTEM_IMAGE_SIZE}/1024/1024)) )

GET_SYSTEM_PARTITION_SIZE=$(echo $(( ${GET_SYSTEM_IMAGE_SIZE} / 1024 /1024 / 50 * 50 + 50)) )
echo "SYSTEM_PARTITION_SIZE"=${GET_SYSTEM_PARTITION_SIZE}

#dm-verify bug: system partition size must equal image size. to be continue?
GET_SYSTEM_IMAGE_SIZE=$(echo $(( ${GET_SYSTEM_PARTITION_SIZE} * 1024 *1024)) )
echo "SYSTEM_IMAGE_SIZE_DM"=${GET_SYSTEM_IMAGE_SIZE}

#save system image size to file
echo ${GET_SYSTEM_IMAGE_SIZE} > ${SYSTEM_IMAGE_SIZE_FILE}

else

GET_SYSTEM_IMAGE_SIZE=$(cat ${SYSTEM_IMAGE_SIZE_FILE})
echo "SYSTEM_IMAGE_SIZE_Byte"=${GET_SYSTEM_IMAGE_SIZE}
GET_SYSTEM_PARTITION_SIZE=$(echo $(( ${GET_SYSTEM_IMAGE_SIZE}/1024/1024)) )
echo "SYSTEM_PARTITION_SIZE"=${GET_SYSTEM_PARTITION_SIZE}

fi

#get partition xml file list
GET_PARTITION_XML_LIST=$(ls ${PARTITION_XML_PATH}/*.xml)
echo "PARTITION_XML_LIST"=${GET_PARTITION_XML_LIST}

#change partition size for each xml file
for xmlname in ${GET_PARTITION_XML_LIST}
do
	$(sed '/system.*size/s/[0-9][0-9]*/'${GET_SYSTEM_PARTITION_SIZE}'/' ${xmlname} > ${xmlname}.tmp)
#	mv ${xmlname}     ${xmlname}.bak
	mv ${xmlname}.tmp ${xmlname}
done

