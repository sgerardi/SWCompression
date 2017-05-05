# Test Results

These are the results of performance tests which were run on my computer (Macbook Pro, Late 2011).
The main purpose of them is to demonstrate the difference between Debug and Release configurations,
as well as show the general progress from version to version.

__Note:__ Some tests have "-" mark instead of an actual result.
This means, that performance in that version and that configuration wasn't enough
to complete the test in reasonable amount of time.

Tests description
---------------------------
- test1: text file with "Hello, World!\n".
- test2: text file with copyright free song lyrics from http://www.freesonglyrics.co.uk/lyrics13.html
- test3: text file with random string from https://www.random.org/strings/
- test4: text file with string "I'm a tester" repeated several times.
- test5: empty file.
- test6: file with size of 5MB containing nulls from /dev/null.
- test7: file with size of 5MB containing random bytes from /dev/urandom.

Release
=================
BZip2 (Decompression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|1.2.1|0.000|0.007|0.005|0.002|0.000|0.061|-|
|1.2.2|0.000|0.004|0.002|0.001|0.000|0.065|-|
|2.0.0|0.000|0.004|0.002|0.001|0.000|0.068|-|
|2.1.0|0.000|0.004|0.002|0.001|0.000|0.061|-|
|2.2.0|0.000|0.004|0.002|0.001|0.000|0.069|-|
|2.3.0|0.000|0.003|0.002|0.001|0.000|0.053|2.430|
|2.4.0|0.000|0.004|0.002|0.001|0.000|0.051|3.749|

Deflate (Decompression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|1.2.1|0.001|0.003|0.003|0.001|0.001|20.701|0.049|
|1.2.2|0.001|0.001|0.001|0.000|0.001|23.589|0.057|
|2.0.0|0.001|0.001|0.000|0.001|0.000|0.026|0.043|
|2.1.0|0.001|0.001|0.001|0.001|0.001|0.025|0.044|
|2.2.0|0.000|0.001|0.000|0.001|0.000|0.035|0.062|
|2.3.0|0.001|0.001|0.001|0.001|0.001|0.024|0.042|
|2.4.0|0.001|0.002|0.001|0.001|0.001|0.024|0.198|

Deflate (Compression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|2.2.0|0.001|0.005|0.003|0.000|0.000|0.065|9.520|
|2.3.0|0.001|0.002|0.003|0.001|0.000|0.029|3.174|
|2.4.0|0.001|0.002|0.002|0.001|0.000|0.028|3.050|

XZ (LZMA/LZMA2) (Decompression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|2.0.0|0.003|0.005|0.005|0.004|0.000|0.083|0.158|
|2.1.0|0.003|0.005|0.005|0.003|0.000|0.081|0.159|
|2.2.0|0.005|0.006|0.006|0.004|0.000|0.109|0.207|
|2.3.0|0.004|0.005|0.005|0.004|0.000|0.076|0.152|
|2.4.0|0.004|0.005|0.006|0.004|0.000|0.077|0.351|

Debug
=================
BZip2 (Decompression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|1.2.0|0.003|0.528|0.230|0.174|0.000|11.202|-|
|1.2.1|0.002|0.377|0.177|0.157|0.000|8.215|-|
|1.2.2|0.002|0.472|0.395|0.185|0.000|9.829|-|
|2.0.0|0.002|0.424|0.198|0.184|0.000|8.879|-|
|2.1.0|0.002|0.390|0.167|0.159|0.000|8.296|-|
|2.2.0|0.003|0.436|0.326|0.173|0.000|10.768|-|
|2.3.0|0.002|0.365|0.153|0.148|0.000|7.391|-|
|2.4.0|0.002|0.290|0.141|0.123|0.000|6.808|-|

Deflate (Decompression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|1.2.0|0.003|0.046|0.024|0.004|0.001|61.985|0.297|
|1.2.1|0.003|0.020|0.017|0.004|0.003|41.641|0.522|
|1.2.2|0.002|0.009|0.003|0.004|0.002|45.554|0.637|
|2.0.0|0.002|0.004|0.003|0.002|0.002|0.313|0.461|
|2.1.0|0.002|0.004|0.003|0.002|0.002|0.317|0.478|
|2.2.0|0.002|0.008|0.006|0.003|0.002|0.447|0.551|
|2.3.0|0.001|0.006|0.005|0.002|0.002|0.337|0.487|
|2.4.0|0.002|0.005|0.004|0.002|0.002|0.332|0.305|

Deflate (Compression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|2.2.0|0.006|0.293|0.386|0.007|0.000|6.302|-|
|2.3.0|0.004|0.032|0.023|0.005|0.000|0.894|-|
|2.4.0|0.004|0.028|0.022|0.004|0.000|0.843|-|

XZ (LZMA/LZMA2) (Decompression)
---------------------------

|Version|test1|test2|test3|test4|test5|test6|test7|
|-
|2.0.0|0.014|0.175|0.139|0.016|0.000|2.527|0.990|
|2.1.0|0.015|0.021|0.021|0.015|0.000|0.651|0.961|
|2.2.0|0.018|0.022|0.023|0.015|0.000|0.995|1.349|
|2.3.0|0.009|0.015|0.015|0.009|0.000|0.696|1.025|
|2.4.0|0.009|0.015|0.016|0.009|0.000|0.694|0.826|