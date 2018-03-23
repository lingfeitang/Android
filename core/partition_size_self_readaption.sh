#!/bin/sh

echo "---$0 by spreadtrum---"

PARTITION_XML_PATH=$1
echo PARTITION_XML_PATH=${PARTITION_XML_PATH}
SYSTEM_PARTITION_SIZE=$2
echo SYSTEM_PARTITION_SIZE=${SYSTEM_PARTITION_SIZE}

GET_SYSTEM_IMAGE_SIZE=$(echo $(( ${SYSTEM_PARTITION_SIZE} / 1024 / 1024)) )
echo "GET_SYSTEM_IMAGE_SIZE"=${GET_SYSTEM_IMAGE_SIZE}

#get partition xml file list
GET_PARTITION_XML_LIST=$(ls ${PARTITION_XML_PATH}/*.xml)
echo "PARTITION_XML_LIST"=${GET_PARTITION_XML_LIST}

#change partition size for each xml file
for xmlname in ${GET_PARTITION_XML_LIST}
do
	$(sed '/system.*size/s/[0-9][0-9]*/'${GET_SYSTEM_IMAGE_SIZE}'/' ${xmlname} > ${xmlname}.tmp)
	mv ${xmlname}.tmp ${xmlname}
done
