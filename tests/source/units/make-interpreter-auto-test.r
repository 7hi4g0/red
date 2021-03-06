REBOL [
  Title:   "Generates Red interpreter tests"
	Author:  "Peter W A Wood"
	File: 	 %make-interpreter-auto-test.r
	Version: 0.1.0
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2012 Peter W A Wood. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

;;--------------- initialisations 
make-dir %auto-tests/
number-of-files: 0
tests: copy ""
quick-test-path: to file! clean-path %../../../quick-test/quick-test.red
file-list: [
	%binding-test.red									%auto-tests/interpreter-binding-test.red
	%case-test.red										%auto-tests/interpreter-case-test.red
	%conditional-test.red								%auto-tests/interpreter-conditional-test.red
	%evaluation-test.red								%auto-tests/interpreter-evaluation-test.red
	%find-test.red										%auto-tests/interpreter-find-test.red
	%function-test.red								    %auto-tests/interpreter-function-test.red
	%load-test.red										%auto-tests/interpreter-load-test.red
	%logic-test.red										%auto-tests/interpreter-logic-test.red
	%loop-test.red										%auto-tests/interpreter-loop-test.red
	%select-test.red									%auto-tests/interpreter-select-test.red
	%serialization-test.red								%auto-tests/interpreter-serialization-test.red
	%series-test.red									%auto-tests/interpreter-series-test.red
	%type-test.red										%auto-tests/interpreter-type-test.red
	%switch-test.red									%auto-tests/interpreter-switch-test.red
	%append-test.red									%auto-tests/interpreter-append-test.red
	%insert-test.red									%auto-tests/interpreter-insert-test.red
	%make-test.red									    %auto-tests/interpreter-make-test.red
	%system-test.red									%auto-tests/interpreter-system-test.red
	%parse-test.red										%auto-tests/interp-parse-test.red
	%bitset-test.red									%auto-tests/interp-bitset-test.red
	%auto-tests/equal-auto-test.red						%auto-tests/interp-equal-auto-test.red
	%same-test.red										%auto-tests/interp-same-test.red
	%integer-test.red									%auto-tests/interp-integer-test.red
	%char-test.red										%auto-tests/interp-char-test.red
	%auto-tests/greater-auto-test.red					%auto-tests/interp-greater-auto-test.red
	%auto-tests/infix-equal-auto-test.red				%auto-tests/interp-inf-equal-auto-test.red
	%strict-equal-test.red								%auto-tests/interp-strict-equal-test.red
	%auto-tests/infix-greater-equal-auto-test.red		%auto-tests/interp-inf-greater-auto-test.red
	%auto-tests/infix-lesser-auto-test.red				%auto-tests/interp-inf-lesser-auto-test.red
	%auto-tests/infix-lesser-equal-auto-test.red		%auto-tests/interp-inf-lesser-equal-auto-test.red
	%auto-tests/infix-not-equal-auto-test.red			%auto-tests/interp-inf-not-equal-auto-test.red
	%auto-tests/integer-auto-test.red					%auto-tests/interp-integer-auto-test.red
	%auto-tests/lesser-auto-test.red					%auto-tests/interp-lesser-auto-test.red
	%auto-tests/lesser-equal-auto-test.red				%auto-tests/interp-lesser-equal-auto-test.red
	%auto-tests/not-equal-auto-test.red					%auto-tests/interp-not-equal-auto-test.red
]

;;--------------- functions

;; write test file with header
write-test-header: func [file-out [file!]] [
	append tests "Red [^(0A)"
	append tests {  Title:   "Red auto-generated interpreter test"^(0A)}
	append tests {	Author:  "Peter W A Wood"^(0A)}
	append tests {  License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"^(0A)}
	append tests "]^(0A)^(0A)"
	append tests "^(0A)^(0A)comment {"
	append tests "  This file is generated by make-interpreter-auto-test.r^(0A)"
	append tests "  Do not edit this file directly.^(0A)"
	append tests "}^(0A)^(0A)"
	write file-out tests
]

write-test-footer: func [file-out [file!]] [
	write/append file-out "]"
]

read-write-test-body: func [
	file-in		[file!]
	file-out	[file!]
	/local
		body
][
	body: read file-in
	body: find/tail body "../../quick-test/quick-test.red"
	insert body join "#include %" [quick-test-path "^(0A) do ["]				 
	write/append file-out body
]

;;--------------- Main Processing

print "checking to see if interpreter test files need generating"

foreach [file-in file-out] file-list [
	rebuild: false
	either not exists? file-out [
		rebuild: true
	][
		if 0:00 < difference modified? file-in modified? file-out [
			rebuild: true
		]
	]
	if rebuild [
		tests: copy ""
		write-test-header file-out
		read-write-test-body file-in file-out
		write-test-footer file-out
		number-of-files: number-of-files + 1
	]
]

print [number-of-files "files were generated"]

