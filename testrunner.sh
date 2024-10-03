#!/bin/bash

if [ $# -lt 1 ]
then
  echo 1>&2 "$0: First argument must provide islisp invocation command, using FILE as a placeholder for the test file path."
  exit 2
fi

commandTemplate=$1
testingRequireReplacement=$(<tests/testtemplate.lisp.txt)
exitCode=0

successCount=0
failCount=0

for f in tests/*.lisp
do
  # drop `.lisp` suffix
  name=${f::-5}
  # drop `tests/` prefix
  name=${name:6}
  testContent=$(<"$f" )
  echo ${testContent//(requires \"testing.lisp\")/$testingRequireReplacement} > tmp.lisp
  command=${commandTemplate/'FILE'/'tmp.lisp'}
  eval "$command" > tmp.txt 2>&1
  if ! cmp --silent "tmp.txt" "tests/$name.expect.txt"
  then
    echo "Failed test: $name"
    echo "Expected:"
    echo "$(<"tests/$name.expect.txt")"
    echo "Was:"
    echo "$(<tmp.txt )"
    echo -e "\n\n"
    failCount=$((failCount + 1))
    exitCode=1
  else
    successCount=$((successCount + 1))
  fi
done

echo '====================='
echo "Successful tests: $successCount"
echo "Failed tests: $failCount"

exit $exitCode
