# Installation

## change the PW
```
gpg --edit-key ID

# at termnial enter `passwd`
```

## remove the master key

```
gpg --list-secret-keys

# shows the ID of the private key

rm $HOME/.gnupg/private-keys-v1.d/ID.key
```
