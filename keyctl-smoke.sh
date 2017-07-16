#!/bin/sh

die()
{
	keyctl clear @u
	if [ -n "$POLICYHANDLE" ]; then
		./tpm2-flush $POLICYHANDLE
	fi
	if [ -n "$POLICYHANDLE" ]; then
		./tpm2-flush $KEYHANDLE
	fi
	exit $1
}

KEYHANDLE=$(./tpm2-root-key || die 1)
POLICYDIGEST=$(./tpm2-pcr-policy --pcr 16 --name-alg=sha256 --bank=sha1 --trial || die 1)
POLICYHANDLE=$(./tpm2-pcr-policy --pcr 16 --name-alg=sha256 --bank=sha1 || die 1)
KEYID=$(keyctl add trusted kmk "new 32 keyhandle=$KEYHANDLE hash=sha256 policydigest=$POLICYDIGEST" @u || die 1)

keyctl pipe $KEYID > blob.hex || die 1
keyctl clear @u || die 1
keyctl add trusted kmk "load `cat blob.hex` keyhandle=$KEYHANDLE  policyhandle=$POLICYHANDLE" @u || die 1

die 0
