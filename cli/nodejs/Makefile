#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###
### WARNING: This file is meant to be invoked by the qcert/Makefile documentation target, not run directly
###

DEP_FILES=../../bin/qcertJS.js \
	../../runtimes/javascript/qcert-runtime.js

all: copy-libs

install: copy-libs
	npm install

package:
	npm pack

copy-libs: $(DEP_FILES)
	@mkdir -p extracted
	cp $^ extracted/

.PHONY: copy-libs package

clean:
	- @rm -rf log
	- @rm -rf node_modules
	- @rm -f qcert-*.tgz

cleanall: clean
	- @rm -f ../../bin/qcertJS.js
	- @rm -f extracted/*.js

