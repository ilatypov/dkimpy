#! /bin/bash

set -ex

# https://www.rfc-editor.org/rfc/inline-errata/rfc6376.html

# b=...; in rfc-6376-email.txt
echo -n 'AuUoFEfDxTDkHlLXSZEpZj79LICEps6eda7W3deTVFOk4yAUoqOB4nujc7YopdG5dWLSdNg6xNAZpOPr+kHxt1IrE+NahM6L/LbvaHutKVdkLLkpVaVVQPzeRDI009SO2Il5Lu7rDNH6mZckBdrIx0orEtZV4bmp/YzhwvcubU4=' | base64 -d > rfc-6376-signature

# The signature agrees with the public key
openssl rsautl -verify -inkey rfc-6376-rsa-public.pem -pubin -keyform PEM -in rfc-6376-signature > /dev/null
echo $?

openssl rsautl -verify -inkey rfc-6376-rsa-public.pem -pubin -keyform PEM -in rfc-6376-signature | hexdump -C

# Did the signature sign the same plaintext (hash)?

# The errata-corrected body, simple canon (with CRLF in between, with a trailing CRLF).
openssl dgst -sha256 -binary < rfc-6376-body.txt > rfc-6376-bodyh

# Received:..Message:..DKIM-Signature:..;b=;, simple canon (CRLF in between), without a trailing CRLF, without the value of b=.
hexdump -C rfc-6376-hhdkim.txt

# Section 3.7
# cat rfc-6376-hhdkim.txt | openssl dgst -sha256 -binary > rfc-6376-hhdkim-hash
openssl dgst -sha256 -signature rfc-6376-signature -verify rfc-6376-rsa-public.pem rfc-6376-hhdkim.txt

export PUBLIC_KEY='p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDwIRP/UC3SBsEmGqZ9ZJW3/DkMoGeLnQg1fWn7/zYtIxN2SnFCjxOCKG9v3b4jYfcTNh5ijSsq631uBItLa7od+v/RtdC2UzJ1lWT947qR+Rcac2gbto/NMqJ0fzfVjH4OuKhitdY9tf6mcwGjaNBcWToIMmPSPDdQPNUYckcQ2QIDAQAB'

PYTHONPATH=.. python ../dkim/dkimverify.py -v < rfc-6376-email.txt

unset PUBLIC_KEY
export PUBLIC_KEY
# On seeing "No module named DNS", run pip.  For example,
# cd ..
# source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
# workon venv-dkim || mkvirtualenv venv-dkim
# python setup.py install
# cd -
PYTHONPATH=.. python ../dkim/dkimverify.py -v --index 0 < mail-tester-test-3vcvxqshy.txt
PYTHONPATH=.. python ../dkim/dkimverify.py -v --index 1 < mail-tester-test-3vcvxqshy.txt

