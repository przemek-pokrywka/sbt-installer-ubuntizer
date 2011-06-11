#!/bin/bash

SBT_PAGE_URL='http://code.google.com/p/simple-build-tool/'
JAR_LINK_PATTERN='"http.*jar"'
WORK_DIR='target/tmp'

function clean {
  rm -rf target
  mkdir -p target/tmp
}
function sbt_page {
  wget $SBT_PAGE_URL --output-document -
}
function links_to_jars() {
  grep -o $JAR_LINK_PATTERN
}
function first {
  tail -n 1
}
function unquote {
  sed 's/"//g'
}
function sbt_version {
  echo $1 | sed 's/.*sbt-launch-\(.*\).jar/\1/g'
}
function replace_sbt_version {
  sed -i "s/SBT_VERSION/${SBT_VERSION}/g" $@
}

clean
JAR_LINK=`sbt_page | links_to_jars | first | unquote`
SBT_VERSION=`sbt_version ${JAR_LINK}`
SBT_DIR=${WORK_DIR}/usr/lib/sbt-${SBT_VERSION}
mkdir -p ${SBT_DIR}
wget ${JAR_LINK} -P ${SBT_DIR}
cp -pr src/sbt ${SBT_DIR}
cp -pr src/DEBIAN ${WORK_DIR}
replace_sbt_version ${SBT_DIR}/sbt ${WORK_DIR}/DEBIAN/*
mv ${WORK_DIR} target/sbt-${SBT_VERSION}
dpkg --build target/sbt-${SBT_VERSION}
