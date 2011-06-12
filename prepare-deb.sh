#!/bin/bash

SBT_GOOGLE_CODE_PAGE_URL='http://code.google.com/p/simple-build-tool/'
function sbt_GOOGLE_CODE_version { echo ${1} | sed 's/.*sbt-launch-\(.*\).jar/\1/g'; }

SBT_GITHUB_PAGE_URL='https://github.com/harrah/xsbt/wiki/Setup'
function sbt_GITHUB_version { echo ${1} | sed 's|.*/\([0-9\.]*\)/.*|\1|g'; }

JAR_LINK_PATTERN='"http.*jar"'
WORK_DIR='target/tmp'

function clean { rm -rf target; }

function prepare { rm -rf ${WORK_DIR}; mkdir -p ${WORK_DIR}; }

function page { wget ${1} --output-document -; }

function links_to_jars() { grep -o ${JAR_LINK_PATTERN}; }

function first { tail -n 1; }

function unquote { sed 's/"//g'; }

function first_jar_link_from_page { page ${1} | links_to_jars | first | unquote; }

function replace_package_name { sed -i "s/PACKAGE_NAME/${PACKAGE_NAME}/g" ${@}; }

function jar_name { echo ${1} | sed 's|.*/\(.*.jar\).*|\1|g'; }

function replace_jar_name { sed -i "s/JAR_NAME/${JAR_NAME}/g" ${@}; }

function download_from {
  site=${1}
  eval "page=\${SBT_${site}_PAGE_URL}"
  version_nr_extractor_name=sbt_${site}_version
  jar_link=`first_jar_link_from_page ${page}`
  JAR_NAME=`jar_name ${jar_link}`
  PACKAGE_NAME=sbt-`eval "${version_nr_extractor_name} ${jar_link}"`
  SBT_DIR=${WORK_DIR}/usr/lib/${PACKAGE_NAME}
  mkdir -p ${SBT_DIR}
  wget ${jar_link} -P ${SBT_DIR}
}

function build_package {
  cp -pr src/sbt ${SBT_DIR}
  cp -pr src/DEBIAN ${WORK_DIR}
  replace_package_name ${SBT_DIR}/sbt ${WORK_DIR}/DEBIAN/*
  replace_jar_name ${SBT_DIR}/sbt
  mv ${WORK_DIR} target/${PACKAGE_NAME}
  dpkg --build target/${PACKAGE_NAME}
}

clean

for SITE in GOOGLE_CODE GITHUB
do
  prepare
  download_from ${SITE}
  build_package
done
