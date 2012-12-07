#!/bin/sh -e
##
# SimpleParallelDumpRestore - Simple scripts to dump and restore data in parallel as comma-seperated values (CSV)
#
# Copyright (c) 2011-2012, Tart İnternet Teknolojileri AŞ
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby
# granted, provided that the above copyright notice and this permission notice appear in all copies.
# 
# The software is provided "as is" and the author disclaims all warranties with regard to the software including all
# implied warranties of merchantability and fitness. In no event shall the author be liable for any special, direct,
# indirect, or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether
# in an action of contract, negligence or other tortious action, arising out of or in connection with the use or
# performance of this software.
##

(test ! $1 || test $1 = "-h" || test $1 = "--help") && echo "Usage: $0 <psql arguments>" && exit 1
parallel "echo \"Copy {.} from '{}' csv null '\\\\N' escape '\\\\'\" | psql $@" ::: *.csv
exit 0
