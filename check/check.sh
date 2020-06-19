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

# unset PUBLIC_KEY
# export PUBLIC_KEY
# On seeing "No module named DNS", run pip.  For example,
# cd ..
# source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
# workon venv-dkim || mkvirtualenv venv-dkim
# python setup.py install
# cd -

# Alternatively, keep the public key with the test here.
# $ host -t TXT s2048._domainkey.yahoo.ca ns1.yahoo.com
# Using domain server:
# Name: ns1.yahoo.com
# Address: 68.180.131.16#53
# Aliases:
# 
# s2048._domainkey.yahoo.ca is an alias for s2048._domainkey.yahoo.com.
# s2048._domainkey.yahoo.com descriptive text "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuoWufgbWw58MczUGbMv176RaxdZGOMkQmn8OOJ/HGoQ6dalSMWiLaj8IMcHC1cubJx2gz" "iAPQHVPtFYayyLA4ayJUSNk10/uqfByiU8qiPCE4JSFrpxflhMIKV4bt+g1uHw7wLzguCf4YAoR6XxUKRsAoHuoF7M+v6bMZ/X1G+viWHkBl4UfgJQ6O8F1ckKKoZ5K" "qUkJH5pDaqbgs+F3PpyiAUQfB6EEzOA1KMPRWJGpzgPtKoukDcQuKUw9GAul7kSIyEcizqrbaUKNLGAmz0elkqRnzIsVpz6jdT1/YV5Ri6YUOQ5sN5bqNzZ8TxoQlkb" "VRy6eKOjUnoSSTmSAhwIDAQAB;"
export PUBLIC_KEY="p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuoWufgbWw58MczUGbMv176RaxdZGOMkQmn8OOJ/HGoQ6dalSMWiLaj8IMcHC1cubJx2gziAPQHVPtFYayyLA4ayJUSNk10/uqfByiU8qiPCE4JSFrpxflhMIKV4bt+g1uHw7wLzguCf4YAoR6XxUKRsAoHuoF7M+v6bMZ/X1G+viWHkBl4UfgJQ6O8F1ckKKoZ5KqUkJH5pDaqbgs+F3PpyiAUQfB6EEzOA1KMPRWJGpzgPtKoukDcQuKUw9GAul7kSIyEcizqrbaUKNLGAmz0elkqRnzIsVpz6jdT1/YV5Ri6YUOQ5sN5bqNzZ8TxoQlkbVRy6eKOjUnoSSTmSAhwIDAQAB"
PYTHONPATH=.. python ../dkim/dkimverify.py -v --index 0 < mail-tester-test-3vcvxqshy.txt


# This fails in verifying the signature.  Why?
# $ host -t TXT 20200614._domainkey.mlcirm.biz
# 20200614._domainkey.mlcirm.biz descriptive text "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy7pQV1Q9OCu4NwDQTMWcggcq4eBMOL1lMHbc3JCc+RlJ8HHfU8qUwcjvOXNQKqSKccE6IP0Rz3SA0B0/FSvNfrVMRZyMh9stUFX3WwIpNmrSDDqW0cQ4onQ/QR2o/0gTFZHB82wAXtCgZYiVWnF2Bmkm7zR7PPQcMyOV2R82poPvNRTcXMMPLrB9qHPQboKUCLF+oV3hRP" "A44ynL5U7tpZWZC9AJ5GdfKGr1Q+NHpS+sa4j2bTQrvDCTI1Bo7YSqUMQDmllZkIK/IHgh4SzwkVpDE7kfkUPN+SU0ViGulWNxgJL9CfcFIrT7O/yeaxl+gdaCFgLr5Okx3cf+iLfIXwIDAQAB"
export PUBLIC_KEY="p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy7pQV1Q9OCu4NwDQTMWcggcq4eBMOL1lMHbc3JCc+RlJ8HHfU8qUwcjvOXNQKqSKccE6IP0Rz3SA0B0/FSvNfrVMRZyMh9stUFX3WwIpNmrSDDqW0cQ4onQ/QR2o/0gTFZHB82wAXtCgZYiVWnF2Bmkm7zR7PPQcMyOV2R82poPvNRTcXMMPLrB9qHPQboKUCLF+oV3hRPA44ynL5U7tpZWZC9AJ5GdfKGr1Q+NHpS+sa4j2bTQrvDCTI1Bo7YSqUMQDmllZkIK/IHgh4SzwkVpDE7kfkUPN+SU0ViGulWNxgJL9CfcFIrT7O/yeaxl+gdaCFgLr5Okx3cf+iLfIXwIDAQAB"
PYTHONPATH=.. python ../dkim/dkimverify.py -v --index 1 < mail-tester-test-3vcvxqshy.txt || :

echo "
############################################################################################
"

# Let's see.

# b=...; in the mlcirm.biz DKIM signature in mail-tester-test-3vcvxqshy.txt
echo -n 'X6s0EqaiO+a5WQRE7urSo6s6uk/Wl9wrYsj+O7v0fvweufeE2VdPjCTw5RyR4p+NawWvSpt7DSwhOQCaeB0srMi9AY3DEg9mVZcIySDR9wlLOILCJst/kj3k/JSnEWclLl283x1mir5nixc3j5QxnyVnU0q1IItkU6OTKquLKGydX7vabg5GNASQRO0+Hn2e/8Bq9BRQki4Y9rpovIhtiASZJuOvbuLLXC6fC3khxF6LrGjQXIgVkxa9//kKHvsdhNIdZO1s2ewY4x3N3+4Fp0GmSZ9p+yp1AJew6IKUazqrUNgt3EsUAw/IrqKH2L6ftxitb8cZPtSgctaqH7cAHg==' | base64 -d > mail-tester-test-3vcvxqshy-signature

# The signature agrees with the public key
openssl rsautl -verify -inkey mlcirm.biz-public.pem -pubin -keyform PEM -in mail-tester-test-3vcvxqshy-signature > /dev/null
echo $?
openssl rsautl -verify -inkey mlcirm.biz-public.pem -pubin -keyform PEM -in mail-tester-test-3vcvxqshy-signature | hexdump -C

# Did the signature sign the same plaintext (hash)?

# The body, relaxed canon (with CRLF in between, with a trailing CRLF).
openssl dgst -sha256 -binary < mail-tester-test-3vcvxqshy-body.txt > mail-tester-test-3vcvxqshy-bodyh

# date:..from:..:..dkim-signature:..;b=;, relaxed canon (CRLF in between), without a trailing CRLF, without the value of b=.
hexdump -C mail-tester-test-3vcvxqshy-hhdkim.txt

# Section 3.7
openssl dgst -sha256 -signature mail-tester-test-3vcvxqshy-signature -verify mlcirm.biz-public.pem mail-tester-test-3vcvxqshy-hhdkim.txt

